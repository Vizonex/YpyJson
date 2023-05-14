from typing import Union, Iterator, Tuple, overload
from _typeshed import ReadableBuffer
from ypyjson.ypyflags import YpyReadFlag


# So why put the documentation here?
# The Simple answer is that VS code was used to develop YpyJson and 
# Pylance can't read Cython Docstrings yet... 
# If this feature changes I'll move them over into Cython - Vizonex




class YpyObject:
    """Used as a keyword for parsing json data that stores `key:value` pairs.

    `WARNING!` YpyObjects do not check for the curly brackets `{}` delimiters!  """

    def __init__(self, data:ReadableBuffer, flag:int = 0) -> None: ...
    def get_pointer(self,data:Union[str,ReadableBuffer]) -> Union["YpyObject", "YpyArray" , int, str, bytes , float, None]:
        """Gets a pointer object from a path just like in `simdjson`
        paths should always start with a slash `/` . Returns `None` if the object misses or is not found...

        example::

            >> y = YpyObject(b'{"Foo":["bar","baz"]}', 0)
            >> bar = y.get_pointer("/Foo/0")
            >> print(bar)
            'bar'

        see `RFC 6901` for more details...
        """
        ...

    def __getitem__(self, i:Union[str,ReadableBuffer]) ->  Union["YpyObject","YpyArray", int, str, bytes , float, None]:
        """Allows for items to be looked up 
        `WARNING!` 
        lookups take a linear search time as does `yyjson` itself"""
        ...

    def __iter__(self) -> Iterator[Tuple[Union["YpyObject","YpyArray", int, str, bytes , float, None],Union["YpyObject","YpyArray", int, str, bytes , float, None]]]:...


class YpyArray:
    """Used as a keyword for parsing json data that stores `value` arrays.

    `WARNING!` YpyArrays do not check for the curly brackets `[]` delimiters!  """

    def __init__(self, data:ReadableBuffer, flag:int = 0) -> None: ...
    def get_pointer(self,data:Union[str,ReadableBuffer]) -> Union["YpyObject","YpyArray", int, str, bytes , float, None]:
        """Gets a pointer object from a path just like in `simdjson`
        paths should always start with a  slash `/` . Returns `None` 
        if the object misses or is not found...

        example::

            >> YpyArray(b'["Foo" , ["bar","baz"]]', 0)
            >> bar = y.get_pointer("/1/0")
            >> print(bar)
            'bar'
        
        see `RFC 6901` for more details...
        """
        ...
    
    
    @overload
    def __getitem__(self, i:int) ->  Union["YpyObject","YpyArray", int, str, bytes , float, list, None]:
        """Allows for items to be looked up 
        `WARNING!` 
        lookups take a linear search time as does `yyjson` itself"""
        ...

    @overload
    def __getitem__(self,i:slice) -> list[Union["YpyObject", "YpyArray", int, str, bytes , float, None]]:
        """Allows for items to be looked up 
        `WARNING!` 
        lookups take a linear search time as does `yyjson` itself
        It takes even longer as a slice methoad"""
        ...

def loads(data:ReadableBuffer,flag:Union[int,YpyReadFlag] = 0) -> Union["YpyObject", "YpyArray", int, str, bytes , float, None]:
    """Loads Json into a readable objects , Note that you can used the 
    ypyflags module provided can be used to reconfigure how the json data should be read and accessed"""

# TODO Write a semi-loader for handling larger sums and amounts of json objects when 
# yyjson gets to adding streaming API
