# YapyJson
Yet Another Python Json Library as a Cython wrapper for using yyjson 


A Fast Json Reader made in Cython for handling fast json parsing 
using the yyjson library. 

Some of it's techniques are simillar to simdjson but with a few
fast conversion methods to convert objects to python objects. 

Yapyjson can trade safety for speed since yyjson is faster than simdjson


```python 
from yapyjson import YapyObject

y = YapyObject(b'{"Eggs":"spam","Foo":["bar","baz"]}', 0)
bar = y.get_pointer("/Foo/0")
print(f"result :{bar!r}")
# result: 'bar'
print(y["Eggs"])
# spam
```

Yapyjson has Cython compatability and is really made for Cython as well for expandable performance benefits elsewhere...

```cython 
from yapyjson.reader cimport cloads, YapyObject , YapyArray 
#etc...
```
Note that for the read flags You'll need to refer to the Variable Documentation in yyjson's documentation 

https://ibireme.github.io/yyjson/doc/doxygen/html/yyjson_8h.html#aff1d62b68993630e74355e4611b77520

Luckily , `yapyjson.reader.pxd` has them already inplace 
so you'll just have to do the following
to access those variables...

```cython 
#cython: langauge_level = 3
from yapyjson.reader cimport (
    cloads, 
    YapyObject , 
    YapyArray , 
    YYJSON_READ_ALLOW_COMMENTS,
    YYJSON_READ_ALLOW_INF_AND_NAN,
    YYJSON_READ_ALLOW_INVALID_UNICODE
    #etc...
)

```


## TODOs
- [x] Implement a reader and extract all variables directly to python...

- [] Create Benchmarks with SimdJson's python library to figure what could be needed to improve this library's performance...

- [] Make sure that after launching to pypi
library for this code that YapyJson can work directly with Cython via cimport , Might have to look into numpy for ideas on it's implementation...


- [] Maybe look into Adding YapyJson as a Header File for CPython Usage....

- [] Make a YapyVariable cdef class Object in Cython (Cython only...) to improve upon speed until the Object needs or is ready to be identified in either C or Python...

- [] In a future update, implement a mutable writer (The Current one made is broken and is having issues...)

- [] When yyjson comes out with a Streaming API , add streaming API Under a DynamicLoader class varaible

