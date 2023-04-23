#cython:language_level=3

from libc.stdint cimport (
    int64_t , uint64_t, uint32_t, uint8_t
)


cdef extern from "yyjson/yyjson.h" nogil:

    ctypedef uint8_t yyjson_type

    uint8_t YYJSON_TYPE_NONE        
    uint8_t YYJSON_TYPE_RAW         
    uint8_t YYJSON_TYPE_NULL        
    uint8_t YYJSON_TYPE_BOOL        
    uint8_t YYJSON_TYPE_NUM         
    uint8_t YYJSON_TYPE_STR         
    uint8_t YYJSON_TYPE_ARR        
    uint8_t YYJSON_TYPE_OBJ

    ctypedef uint8_t yyjson_subtype
    uint8_t YYJSON_SUBTYPE_NONE   
    uint8_t YYJSON_SUBTYPE_FALSE  
    uint8_t YYJSON_SUBTYPE_TRUE   
    uint8_t YYJSON_SUBTYPE_UINT   
    uint8_t YYJSON_SUBTYPE_SINT   
    uint8_t YYJSON_SUBTYPE_REAL 

    ctypedef uint32_t yyjson_read_flag
    ctypedef uint32_t yyjson_read_code


    struct yyjson_read_err:
        yyjson_read_code code
        const char *msg
        size_t pos

    struct yyjson_alc:
        void *(*malloc)(void *ctx, size_t size)
        void *(*realloc)(void *ctx, void *ptr, size_t old_size, size_t size)
        void (*free)(void *ctx, void *ptr)
        void *ctx

    struct yyjson_doc:
        yyjson_val *root
        yyjson_alc alc
        # ...

    union yyjson_val_uni:
        uint64_t    u64
        int64_t     i64
        double      f64
        const char *str
        void       *ptr
        size_t      ofs

    struct yyjson_val:
        uint64_t tag
        yyjson_val_uni uni


    struct yyjson_read_err:
        yyjson_read_code code
        const char *msg
        size_t pos



    yyjson_doc * yyjson_read(const char * dat, size_t len, yyjson_read_flag flg) 	


    yyjson_val *yyjson_doc_get_root(yyjson_doc *doc)


    # Converter types 
    int unsafe_yyjson_get_int 	(yyjson_val *val)
    bint unsafe_yyjson_get_bool (yyjson_val *val)
    const char *unsafe_yyjson_get_str(yyjson_val *val)
    double unsafe_yyjson_get_num(yyjson_val *val)
    int64_t unsafe_yyjson_get_sint(yyjson_val *val)
    uint64_t unsafe_yyjson_get_uint(yyjson_val *val)
    size_t yyjson_get_len(yyjson_val *val)
    double unsafe_yyjson_get_real(yyjson_val *val)
    const char * unsafe_yyjson_get_raw(yyjson_val *val) 	


    yyjson_val *yyjson_obj_get(yyjson_val *obj, const char *key)
    yyjson_val *yyjson_get_pointer(yyjson_val * val, const char * ptr) 	
    void yyjson_doc_free(yyjson_doc * doc) 	

    yyjson_type yyjson_get_type(yyjson_val * val)
    uint8_t unsafe_yyjson_get_tag(void *val) except 0

    # Object Iterators...

    struct yyjson_obj_iter:
        size_t idx 
        size_t max
        yyjson_val *cur
        yyjson_val *obj


    bint yyjson_obj_iter_init( 	
        yyjson_val *obj,
		yyjson_obj_iter *iter
        )

    yyjson_val *yyjson_obj_iter_get_val(yyjson_val *key) 	
    yyjson_val *yyjson_obj_iter_next(yyjson_obj_iter *iter)


    # Arrays...
    size_t yyjson_arr_size 	(yyjson_val *arr) 

    yyjson_val *yyjson_arr_get_first (yyjson_val *arr)
    yyjson_val *yyjson_arr_get_last(yyjson_val *arr)
    yyjson_val *yyjson_arr_get(yyjson_val *arr, size_t idx)

    # Array iterator

    struct yyjson_arr_iter:
        yyjson_val * cur
        size_t idx
        size_t max 


    bint yyjson_arr_iter_init(yyjson_val *arr, yyjson_arr_iter * iter) except 0
    yyjson_val * yyjson_arr_iter_next(yyjson_arr_iter * iter)
