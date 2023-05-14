#cython:language_level=3, boundscheck=False
#distutils:sources = yyjson/yyjson.c

# import yyjson C library
include "yyr.pxi"

# This will allow for others to use this library within cython...

cdef class YpyObject:
    cdef:
        yyjson_doc * doc 
        yyjson_val * root
        Py_buffer buff 
        bint main

    cdef object cget_pointer(self, const char* pointer)


cdef class YpyArray:
    cdef:
        yyjson_doc * doc 
        yyjson_val * root
        Py_buffer buff 
        bint main
    cdef size_t fix_value(self,long long val)
    cdef object cget_pointer(self, const char* pointer)

cdef object cloads(object data, yyjson_read_flag flag)

ctypedef fused ypytype_t:
    YpyObject
    YpyArray

cdef object convert(yyjson_val* val, ypytype_t y)
