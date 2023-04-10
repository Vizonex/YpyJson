#cython: language_level=3

include "yy.pxi" 

from cpython.bytes cimport PyBytes_AsStringAndSize, PyBytes_AsString, PyBytes_FromStringAndSize
from libc.stdint cimport uint64_t, int64_t


cimport cython


cdef extern from "Python.h":
    Py_ssize_t PyByteArray_Size(object) except -1
    char* PyByteArray_AsString(object)
    const char* PyUnicode_AsUTF8AndSize(object unicode, Py_ssize_t *size)

cdef struct buffer_t:
    const char* data 
    Py_ssize_t len



cdef buffer_t* from_object(object _s):
    cdef buffer_t buf

    if isinstance(_s,(str,unicode)):
        buf.data = PyUnicode_AsUTF8AndSize(_s, &buf.len)
    
    elif isinstance(_s, bytes):
        PyBytes_AsStringAndSize(_s, <char**>&buf.data, &buf.len)

    elif isinstance(_s, bytearray):
        buf.data = <const char*>PyByteArray_AsString(_s)
        buf.len = PyByteArray_Size(_s)
    
    else:
        raise TypeError("object must be in a str , bytes , or bytearrary")

    return &buf 





# Safety feature...
@cython.no_gc_clear
cdef class JsonObjectWriter:
    cdef:
        yyjson_mut_doc * doc
        yyjson_mut_val * root
        bint is_main

    def __cinit__(self):
        self.doc = yyjson_mut_doc_new(NULL)
        self.root = yyjson_mut_obj(self.doc)
        self.is_main = 1 

    def __dealloc__(self):
        if self.is_main:
            yyjson_mut_doc_free(self.doc)
        else:
            yyjson_mut_obj_clear(self.root)

    cpdef bint write_str(self, object key,  object s) except 0:
        cdef buffer_t *_val = from_object(s)
        cdef buffer_t*_key = from_object(key)
        return yyjson_mut_obj_add_strn(self.doc,self.root,_key.data,_val.data,_val.len)

    cpdef bint write_strncpy(self, object key,  object s) except 0:
        cdef buffer_t *_val = from_object(s)
        cdef buffer_t*_key = from_object(key)
        return yyjson_mut_obj_add_strncpy(self.doc,self.root,_key.data,_val.data,_val.len)

    cpdef bint write_bool(self,object key , bint boolean) except 0:
        return yyjson_mut_obj_add_bool(self.doc,self.root,from_object(key).data,boolean)

    cpdef bint write_int(self, object key, Py_ssize_t i) except 0:
        return yyjson_mut_obj_add_int(self.doc,self.root, from_object(key).data, i)

    cpdef bint write_Null(self,object key) except 0:
        return yyjson_mut_obj_add_null(self.doc,self.root,from_object(key).data)


    cpdef JsonObjectWriter add_node(self,object key):
        cdef JsonObjectWriter w = <JsonObjectWriter>JsonObjectWriter.__new__(JsonObjectWriter)
        w.doc = self.doc 
        w.is_main = 0
        w.root = yyjson_mut_obj(self.doc)
        if not yyjson_mut_obj_add_val(self.doc,self.root, from_object(key).data, w.root):
            raise RuntimeError("value couldn't be added for some Unknown reason...")
        return w 
    
    cpdef JsonArrayWriter add_arr(self,object key):
        cdef JsonArrayWriter w = <JsonArrayWriter>JsonArrayWriter.__new__(JsonArrayWriter)
        w.doc = self.doc 
        w.is_main = 0
        w.root = yyjson_mut_obj_add_arr(self.doc, self.root)
        if w.root == NULL:
            raise RuntimeError("Array couldn't be added for some Unknown reason...")
        return w

    @cython.nonecheck(False)
    def __setitem__(self,object key , object s):
        cdef JsonObjectWriter jow
        cdef object k , v 

        if s == None:
            self.write_Null(key)

        elif isinstance(s,bool):
            self.write_bool(key,s)

        elif isinstance(s,int):
            self.write_int(key, s)
        
        elif isinstance(s,(bytes,bytearray,str,unicode)):
            self.write_str(key, s)

        elif isinstance(s,dict):
            jow = <JsonObjectWriter>self.add_node(key)
            for k, v in s.items():
                jow[k] = v
    
    def __delitem__(self,object key):
        cdef char* _key = from_object(key).data
        yyjson_mut_obj_remove_key(self.root, _key)



    cpdef bytes output(self,yyjson_write_flag flag = 0):
        cdef size_t size
        cdef char* result = yyjson_mut_write(self.doc,flag, &size)
        return PyBytes_FromStringAndSize(result,<Py_ssize_t>size)


            


@cython.no_gc_clear
cdef class JsonArrayWriter:
    cdef:
        yyjson_mut_doc * doc
        yyjson_mut_val * root
        bint is_main

    def __cinit__(self):
        self.doc = yyjson_mut_doc_new(NULL)
        self.root = yyjson_mut_arr(self.doc)
        self.is_main = 1 

    def __dealloc__(self):
        if self.is_main:
            yyjson_mut_doc_free(self.doc)
    
    

            
    cpdef bint write_str(self, object s) except 0:
        cdef buffer_t *_val = from_object(s)
        return yyjson_mut_arr_add_strn(self.doc,self.root,_val.data,_val.len)

    cpdef bint write_bool(self,bint s) except 0:
        return yyjson_mut_arr_add_bool(self.doc,self.root, s)
    
    cpdef bint write_strncpy(self, object s) except 0:
        cdef buffer_t *_val = from_object(s)
        return yyjson_mut_arr_add_strncpy(self.doc,self.root,_val.data,_val.len)

    cpdef bint write_Null(self) except 0:
        return yyjson_mut_arr_add_null(self.doc,self.root)
    
    cpdef bint write_int(self,Py_ssize_t i) except 0:
        return yyjson_mut_arr_add_int(self.doc,self.root, i)

    cpdef JsonObjectWriter add_node(self):
        cdef JsonObjectWriter w = <JsonObjectWriter>JsonObjectWriter.__new__(JsonObjectWriter)
        w.doc = self.doc 
        w.is_main = 0
        w.root = yyjson_mut_obj(self.doc)
        if not yyjson_mut_arr_add_val(self.root, w.root):
            raise RuntimeError("value couldn't be added for some Unknown reason...")
        return w 
    
    cpdef JsonArrayWriter add_arr(self):
        cdef JsonArrayWriter w = <JsonArrayWriter>JsonArrayWriter.__new__(JsonArrayWriter)
        w.doc = self.doc 
        w.is_main = 0
        w.root = yyjson_mut_arr_add_arr(self.doc, self.root)
        if w.root == NULL:
            raise RuntimeError("Array couldn't be added for some Unknown reason...")
        return w

    # Note that this function in the future might be able to accept numpy arrays...
    @cython.nonecheck(False)
    cpdef void dump_items(self, list arr):
        cdef object s, k , v
        cdef JsonObjectWriter jow

        for s in arr:
            if s == None:
                self.write_Null()

            elif isinstance(s,bool):
                self.write_bool(s)

            elif isinstance(s,int):
                self.write_int(s)

            elif isinstance(s,(bytes,bytearray,str,unicode)):
                self.write_str(s)
            
            elif isinstance(s,dict):
                jow = <JsonObjectWriter>self.add_node()
                for k, v in s.items():
                    jow[k] = v

            elif isinstance(s,list):
                self.add_arr().dump_items(s)

    cpdef bytes output(self,yyjson_write_flag flag = 0):
        cdef size_t size
        cdef char* result = yyjson_mut_write(self.doc,flag, &size)
        return PyBytes_FromStringAndSize(result,<Py_ssize_t>size)
