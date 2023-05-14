# YpyJson

Yet Another Python Json Library 

A Fast Json Reader made in Cython for handling fast json parsing 
using the yyjson library. 

Some of it's techniques are simillar to simdjson but with a few
fast conversion methods to convert objects to python objects. 

Ypyjson can trade safety for speed since yyjson is faster than simdjson

```python 
from ypyjson import YpyObject

y = YpyObject(b'{"Eggs":"spam","Foo":["bar","baz"]}', 0)
bar = y.get_pointer("/Foo/0")
print(f"result :{bar!r}")
# result: 'bar'
print(y["Eggs"])
# spam
```

Ypy also has flags for reading json files as well

```python
from ypyjson import loads, YpyReadFlag


y = loads(b'{"ypy":"json","data":{"text":[1,2,3,4]}}', YpyReadFlag.ALLOW_COMMENTS | YpyReadFlag.READ_NUMBER_AS_RAW)


text = y.get_pointer("/data/text")

print(text)
for t in text:
    print(t)

# <ypyjson.reader.YpyArray object at 0x00000256F6DD1D30>
# b'1'
# b'2'
# b'3'
# b'4'

```

Ypyjson has Cython compatability and is really made for Cython as well for expandable performance benefits elsewhere...

```cython 
from ypyjson.reader cimport cloads, YpyObject , YpyArray 
#etc...
```
Note that for the read flags, you'll need to refer to the Variable Documentation linked below in yyjson's documentation 

https://ibireme.github.io/yyjson/doc/doxygen/html/yyjson_8h.html#aff1d62b68993630e74355e4611b77520

Luckily , `ypyjson.reader.pxd` has them already inplace 
so you'll just have to do the following
to access those variables...

```cython 
#cython: langauge_level = 3
from ypyjson.reader cimport (
    cloads, 
    YpyObject , 
    YpyArray , 
    YYJSON_READ_ALLOW_COMMENTS,
    YYJSON_READ_ALLOW_INF_AND_NAN,
    YYJSON_READ_ALLOW_INVALID_UNICODE
    #etc...
)

```
## Installation
For now it is still being worked on and figured out but I'm almost done so don't worry about it yet... :) 

## TODOs
- [x] Implement a reader and extract all variables directly to python...

- [] Create Benchmarks with SimdJson's python library to figure what could be needed to improve this library's performance...

- [] Make sure that after launching to pypi
library for this code that YpyJson can work directly with Cython via cimport , Might have to look into numpy for ideas on it's implementation...

- [] Maybe look into Adding YpyJson as a Header File for CPython Usage....

- [] Make a YpyVariable cdef class Object in Cython (Cython only...) to improve upon speed until the Object needs or is ready to be identified in either C or Python...

- [] In a future update, implement a mutable writer (The Current one made is broken and is having issues...)

- [] When yyjson comes out with a Streaming API , add streaming API Under a DynamicLoader class varaible

- [] Once Beta Version of this python library is avalibe and inplace via pypi Make sure that yyjson.c as well as yyjson.h is included for compiling to Cython.
 
- [x] including/bundling cython package with pypi when I've figure it out...
