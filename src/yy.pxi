from libc.stdint cimport int64_t , uint64_t, uint32_t

cdef extern from "yyjson/yyjson.h" nogil:

    struct yyjson_str_pool:
        size_t chunk_size
        size_t chunk_size_max
        # ...

    struct yyjson_mut_val:
        uint64_t tag

    struct yyjson_mut_doc:
        yyjson_mut_val *root
        # ...

    struct yyjson_val_pool:
        size_t chunk_size
        size_t chunk_size_max
        # ...

    struct yyjson_alc:
        void *ctx

    ctypedef uint32_t yyjson_write_flag 

    yyjson_mut_doc *yyjson_mut_doc_new(const yyjson_alc *alc)
    yyjson_mut_val *yyjson_mut_obj(yyjson_mut_doc *doc) 
    char *yyjson_mut_write(const yyjson_mut_doc *doc, yyjson_write_flag flg, size_t *len)
    void yyjson_mut_doc_free(yyjson_mut_doc *doc)
    
    bint yyjson_mut_obj_add_null(yyjson_mut_doc *doc,yyjson_mut_val *obj, const char *_key)
    bint yyjson_mut_obj_add_bool(yyjson_mut_doc *doc,yyjson_mut_val *obj, const char *_key, bint _val)
    bint yyjson_mut_obj_add_uint(yyjson_mut_doc *doc,yyjson_mut_val *obj, const char *_key,uint64_t _val)
    bint yyjson_mut_obj_add_int(yyjson_mut_doc *doc,yyjson_mut_val *obj, const char *_key, int64_t _val)
    bint yyjson_mut_obj_add_real(yyjson_mut_doc *doc,yyjson_mut_val *obj,
                                               const char *_key, double _val) 
    bint yyjson_mut_obj_add_str(yyjson_mut_doc *doc, yyjson_mut_val *obj,
                                            const char *_key, const char *_val)
    bint yyjson_mut_obj_add_strn(yyjson_mut_doc *doc,
                                               yyjson_mut_val *obj,
                                               const char *_key,
                                               const char *_val,
                                               size_t _len)
    bint yyjson_mut_obj_add_strcpy(yyjson_mut_doc *doc,
                                                 yyjson_mut_val *obj,
                                                 const char *_key,
                                                 const char *_val)
    bint yyjson_mut_obj_add_strncpy(yyjson_mut_doc *doc,
                                                  yyjson_mut_val *obj,
                                                  const char *_key,
                                                  const char *_val,
                                                  size_t _len)
    bint yyjson_mut_obj_add_val(yyjson_mut_doc *doc,
                                              yyjson_mut_val *obj,
                                              const char *_key,
                                              yyjson_mut_val *_val)

    yyjson_mut_val *yyjson_mut_obj_remove_key(yyjson_mut_val *obj, const char *key)

    bint yyjson_mut_obj_clear(yyjson_mut_val *obj)

    
    # arrays 

    yyjson_mut_val *yyjson_mut_arr(yyjson_mut_doc *doc)


    bint yyjson_mut_arr_add_val(yyjson_mut_val *arr, yyjson_mut_val *val)
    bint yyjson_mut_arr_add_int(yyjson_mut_doc *doc,yyjson_mut_val *arr,
                                int64_t num)
    bint yyjson_mut_arr_add_null(yyjson_mut_doc *doc,yyjson_mut_val *arr)
    bint yyjson_mut_arr_add_bool(yyjson_mut_doc *doc,yyjson_mut_val *arr, bint _val)
    bint yyjson_mut_arr_add_real(yyjson_mut_doc *doc,
                                               yyjson_mut_val *arr,
                                               double num)
    bint yyjson_mut_arr_add_strn(yyjson_mut_doc *doc,
                                               yyjson_mut_val *arr,
                                               const char *str,
                                               size_t len)
    bint yyjson_mut_arr_add_strncpy(yyjson_mut_doc *doc, yyjson_mut_val *arr, 
                                const char *str, size_t len)  

    yyjson_mut_val *yyjson_mut_arr_add_arr(yyjson_mut_doc *doc, yyjson_mut_val *arr)

    # bint yyjson_mut_arr_insert(yyjson_mut_val *arr, yyjson_mut_val *val, size_t idx)
    
    #TODO (Vizonex) Add The Reader API stuff down below in the future 

