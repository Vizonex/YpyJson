#cython:language_level=3
#distutils:sources = yyjson/yyjson.c
from libc.stdint cimport uint8_t, uint32_t, uint64_t
from libc.string cimport strlen
from cpython.buffer cimport Py_buffer , PyBUF_SIMPLE, PyObject_GetBuffer, PyBuffer_Release
cimport cython 



# Externing lessens python interaction making code size smaller and therefore faster 
cdef extern from "Python.h":
    object PyUnicode_DecodeLocaleAndSize(const char *str, Py_ssize_t len, const char *errors)
    object PyUnicode_FromFormat(const char *format, ...)
    const char *PyUnicode_AsUTF8(object)
    char *PyByteArray_AsString(object)
    char *PyBytes_AsString(object)
    object PyBytes_FromString(const char* v)
    bint PyLong_Check(object p)

cdef const char* unicode2bytes(object u):
    cdef object encoded
    if isinstance(u, unicode):
        return PyUnicode_AsUTF8(u)
    elif isinstance(u, bytearray):
        return <const char*>PyByteArray_AsString(u)
    elif isinstance(u, bytes):
        return <const char*>PyBytes_AsString(u)

    # This may have too much python interaction but I really 
    # wanted to make sure That this would be as easy as possible to diagnose...
    raise TypeError(f"expected str, bytes or bytearray got type: {type(u)!r} which belongs to {u!r} ")


cdef object ypyval2str(yyjson_val*val):
    cdef const char* data = unsafe_yyjson_get_str(val)
    return PyUnicode_DecodeLocaleAndSize(data, <Py_ssize_t>strlen(data), "surrogateescape")


@cython.final
cdef class YpyObject:
    # I commented it out but left it here for help...
    # cdef:
    #     yyjson_doc * doc 
    #     yyjson_val * root
    #     Py_buffer buff 
    #     bint main

    def __init__(self, data, yyjson_read_flag flag = 0):
        PyObject_GetBuffer(data, &self.buff, PyBUF_SIMPLE)
        self.doc = yyjson_read(<const char*>self.buff.buf,<size_t>self.buff.len, flag)
        self.root = yyjson_doc_get_root(self.doc)
        self.main = 1
    
    def __dealloc__(self):
        if self.main:
            PyBuffer_Release(&self.buff)
            yyjson_doc_free(self.doc)

    def __getitem__(self, i):
        return convert(yyjson_obj_get(self.root, unicode2bytes(i)), self)

    def __setitem__(self, k , v):
        raise TypeError("YpyObject cannot set items")

    def get_pointer(self,object pointer):
        return convert(yyjson_get_pointer(self.root, unicode2bytes(pointer)), self)

    cdef object cget_pointer(self, const char* pointer):
        return convert(yyjson_get_pointer(self.root, unicode2bytes(pointer)), self)


    def __iter__(self):
        """iterates over key and items...
        returns with a generator over key and value..."""
        cdef yyjson_val *key
        cdef yyjson_val *val
        cdef yyjson_obj_iter _iter
        yyjson_obj_iter_init(self.root, &_iter)
        key = yyjson_obj_iter_next(&_iter)

        while key != NULL:
            val = yyjson_obj_iter_get_val(key)
            yield (ypyval2str(key) , convert(val, self))
            key = yyjson_obj_iter_next(&_iter)

    def to_dict(self):
        """allows for the object to be converted to a dictionary , 
        Warning! This is slower than `YpyObject`"""
        return {k : v for (k, v) in self.__iter__()}


@cython.final
cdef class YpyArray:
    # I commented it out but left it here for help...
    # cdef:
    #     yyjson_doc * doc 
    #     yyjson_val * root
    #     Py_buffer buff 
    #     bint main

    # __cinit__ will not work here it must be done with __init__ so that __new__() can bypass it 
    def __init__(self, data, yyjson_read_flag flag = 0):
        PyObject_GetBuffer(data, &self.buff, PyBUF_SIMPLE)
        self.doc = yyjson_read(<const char*>self.buff.buf,<size_t>self.buff.len, flag)
        self.root = yyjson_doc_get_root(self.doc)
        self.main = 1

    def __dealloc__(self):
        if self.main:
            PyBuffer_Release(&self.buff)
            yyjson_doc_free(self.doc)

    cdef size_t fix_value(self,long long val):
        return <size_t>(yyjson_arr_size(self.root) + <size_t>(val * -1)) if val < 0 else <size_t>val 
    
    def get_pointer(self,object pointer):
        return convert(yyjson_get_pointer(self.root, unicode2bytes(pointer)), self)

    cdef object cget_pointer(self, const char* pointer):
        return convert(yyjson_get_pointer(self.root, unicode2bytes(pointer)), self)

    def __len__(self):
        return yyjson_arr_size(self.root)

    def __getitem__(self,object i):
        cdef size_t _len
        if PyLong_Check(i):
            _len = (yyjson_arr_size(self.root) + i) if i < 0 else <size_t>i
            return convert(yyjson_arr_get(self.root, _len), self)

        elif isinstance(i,slice):
            # SLICING CAN BE SLOW ON BIGGER ITERATORS!!!
            if not i.step:
                return [convert(yyjson_arr_get(self.root, _len), self) for _len in range(self.fix_value(i.start), self.fix_value(i.stop))]

            return [convert(yyjson_arr_get(self.root, _len), self) for _len in range(self.fix_value(i.start), self.fix_value(i.stop),i.step)]
        else:
            raise TypeError(f"object {i} must be a slice or integer not type:{type(i)}")
    
    def __setitem__(self, k , v):
        raise TypeError("YpyArray cannot set items")


    def __iter__(self):
        cdef yyjson_val *val 
        cdef yyjson_arr_iter iter
        yyjson_arr_iter_init(self.root,&iter)

        val = yyjson_arr_iter_next(&iter)
        while val != NULL:
            yield convert(val, self)
            val = yyjson_arr_iter_next(&iter)

    def __list__(self):
        return list(self.__iter__())







cdef object convert(yyjson_val* val, ypytype_t y):
    cdef uint8_t tag = unsafe_yyjson_get_tag(val)
    cdef YpyObject obj 
    cdef YpyArray arr 

    if val == NULL:
        return None 

    
    if tag == YYJSON_TYPE_RAW  | YYJSON_SUBTYPE_NONE: 
        return PyBytes_FromString(unsafe_yyjson_get_raw(val))
    
    if tag == YYJSON_TYPE_NULL | YYJSON_SUBTYPE_NONE:  
        return None 

    elif tag == YYJSON_TYPE_STR  | YYJSON_SUBTYPE_NONE:  
        return PyUnicode_DecodeLocaleAndSize(unsafe_yyjson_get_str(val), <Py_ssize_t>yyjson_get_len(val),"surrogateescape")

    
    elif tag == YYJSON_TYPE_ARR  | YYJSON_SUBTYPE_NONE:
        arr = <YpyArray>YpyArray.__new__(YpyArray)
        arr.doc = y.doc
        # pass along our new value to the object so that we have it for later use elsewhere...
        arr.root = val
        arr.main = 0
        return arr  

    
    elif tag == YYJSON_TYPE_OBJ  | YYJSON_SUBTYPE_NONE:
        obj = <YpyObject>YpyObject.__new__(YpyObject)
        obj.doc = y.doc
        # pass along our new value to the object so that we have it for later use elsewhere...
        obj.root = val
        obj.main = 0
        return obj
    

    elif tag == YYJSON_TYPE_BOOL | YYJSON_SUBTYPE_TRUE:  
        return True 
    
    elif tag == YYJSON_TYPE_BOOL | YYJSON_SUBTYPE_FALSE:
        return False 
    
    elif tag == YYJSON_TYPE_NUM  | YYJSON_SUBTYPE_UINT:  
        # TODO Find ways to preserve 64 bit integers over to python escpecially the unsigned types...
        return unsafe_yyjson_get_uint(val)
    
    elif tag == YYJSON_TYPE_NUM  | YYJSON_SUBTYPE_SINT:  
        return unsafe_yyjson_get_sint(val)
    
    elif tag == YYJSON_TYPE_NUM  | YYJSON_SUBTYPE_REAL:
        return unsafe_yyjson_get_real(val)

# Cython Version 
cdef object cloads(object data, yyjson_read_flag flag):
    cdef:
        yyjson_doc * doc 
        yyjson_val * root
        Py_buffer buff 
        bint main
        uint8_t tag 
    
    PyObject_GetBuffer(data, &buff, PyBUF_SIMPLE)
    doc = yyjson_read(<const char*>buff.buf,<size_t>buff.len, flag)
    root = yyjson_doc_get_root(doc)
    if root == NULL:
        return None 

    tag = unsafe_yyjson_get_tag(root)

    if tag == YYJSON_TYPE_RAW  | YYJSON_SUBTYPE_NONE: 
        return PyBytes_FromString(unsafe_yyjson_get_raw(root))
    
    elif tag == YYJSON_TYPE_NULL | YYJSON_SUBTYPE_NONE:  
        return None 

    elif tag == YYJSON_TYPE_STR  | YYJSON_SUBTYPE_NONE:  
        return PyUnicode_DecodeLocaleAndSize(unsafe_yyjson_get_str(root), <Py_ssize_t>yyjson_get_len(root),"surrogateescape")

    
    elif tag == YYJSON_TYPE_ARR  | YYJSON_SUBTYPE_NONE:
        arr = <YpyArray>YpyArray.__new__(YpyArray)
        arr.doc = doc
        arr.root = root 
        # Buffer must be set so that it can later be freed after use...
        arr.buff = buff 
        # Main must be set to 1 to deallocate propperly...
        arr.main = 1
        return arr 

    
    elif tag == YYJSON_TYPE_OBJ  | YYJSON_SUBTYPE_NONE:
        obj = <YpyObject>YpyObject.__new__(YpyObject)
        obj.doc = doc
        obj.root = root 
        obj.buff = buff 
        obj.main = 1
        return obj
    

    elif tag == YYJSON_TYPE_BOOL | YYJSON_SUBTYPE_TRUE:  
        return True 
    
    elif tag == YYJSON_TYPE_BOOL | YYJSON_SUBTYPE_FALSE:
        return False 
    
    elif tag == YYJSON_TYPE_NUM  | YYJSON_SUBTYPE_UINT:  
        # TODO Find ways to preserve 64 bit integers over to python escpecially the unsigned types...
        return unsafe_yyjson_get_uint(root)
    
    elif tag == YYJSON_TYPE_NUM  | YYJSON_SUBTYPE_SINT:  
        return unsafe_yyjson_get_sint(root)
    
    elif tag == YYJSON_TYPE_NUM  | YYJSON_SUBTYPE_REAL:
        return unsafe_yyjson_get_real(root)

# Python access version 
def loads(object data, yyjson_read_flag flag = 0):
    cdef:
        yyjson_doc * doc 
        yyjson_val * root
        Py_buffer buff 
        bint main
        uint8_t tag 
    
    PyObject_GetBuffer(data, &buff, PyBUF_SIMPLE)
    doc = yyjson_read(<const char*>buff.buf,<size_t>buff.len, flag)
    root = yyjson_doc_get_root(doc)
    if root == NULL:
        return None 

    tag = unsafe_yyjson_get_tag(root)

    if tag == YYJSON_TYPE_RAW  | YYJSON_SUBTYPE_NONE: 
        return PyBytes_FromString(unsafe_yyjson_get_raw(root))
    
    elif tag == YYJSON_TYPE_NULL | YYJSON_SUBTYPE_NONE:  
        return None 

    elif tag == YYJSON_TYPE_STR  | YYJSON_SUBTYPE_NONE:  
        return PyUnicode_DecodeLocaleAndSize(unsafe_yyjson_get_str(root), <Py_ssize_t>yyjson_get_len(root),"surrogateescape")

    
    elif tag == YYJSON_TYPE_ARR  | YYJSON_SUBTYPE_NONE:
        arr = <YpyArray>YpyArray.__new__(YpyArray)
        arr.doc = doc
        arr.root = root 
        # Buffer must be set so that it can later be freed after use...
        arr.buff = buff 
        # Main must be set to 1 to deallocate propperly...
        arr.main = 1
        return arr 

    
    elif tag == YYJSON_TYPE_OBJ  | YYJSON_SUBTYPE_NONE:
        obj = <YpyObject>YpyObject.__new__(YpyObject)
        obj.doc = doc
        obj.root = root 
        obj.buff = buff 
        obj.main = 1
        return obj
    

    elif tag == YYJSON_TYPE_BOOL | YYJSON_SUBTYPE_TRUE:  
        return True 
    
    elif tag == YYJSON_TYPE_BOOL | YYJSON_SUBTYPE_FALSE:
        return False 
    
    elif tag == YYJSON_TYPE_NUM  | YYJSON_SUBTYPE_UINT:  
        # TODO Find ways to preserve 64 bit integers over to python escpecially the unsigned types...
        return unsafe_yyjson_get_uint(root)
    
    elif tag == YYJSON_TYPE_NUM  | YYJSON_SUBTYPE_SINT:  
        return unsafe_yyjson_get_sint(root)
    
    elif tag == YYJSON_TYPE_NUM  | YYJSON_SUBTYPE_REAL:
        return unsafe_yyjson_get_real(root)










