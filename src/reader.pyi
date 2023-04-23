from typing import Union, Iterator, Tuple, overload
from _typeshed import ReadableBuffer
from yapyflags import YapyReadFlag


# So why put the documentation here?
# The Simple answer is that VS code was used to develop YapyJson and 
# Pylance can't read Cython Docstrings yet... 
# If this feature changes I'll move them over into Cython - Vizonex




class YapyObject:
    """Used as a keyword for parsing json data that stores `key:value` pairs.

    `WARNING!` YapyObjects do not check for the curly brackets `{}` delimiters!  """

    def __init__(self, data:ReadableBuffer, flag:int = 0) -> None: ...
    def get_pointer(self,data:Union[str,ReadableBuffer]) -> Union["YapyObject", "YapyArray" , int, str, bytes , float, None]:
        """Gets a pointer object from a path just like in `simdjson`
        paths should always start with a slash `/` . Returns `None` if the object misses or is not found...

        example::

            >> y = YapyObject(b'{"Foo":["bar","baz"]}', 0)
            >> bar = y.get_pointer("/Foo/0")
            >> print(bar)
            'bar'

        see `RFC 6901` for more details...
        """
        ...

    def __getitem__(self, i:Union[str,ReadableBuffer]) ->  Union["YapyObject","YapyArray", int, str, bytes , float, None]:
        """Allows for items to be looked up 
        `WARNING!` 
        lookups take a linear search time as does `yyjson` itself"""
        ...

    def __iter__(self) -> Iterator[Tuple[Union["YapyObject","YapyArray", int, str, bytes , float, None],Union["YapyObject","YapyArray", int, str, bytes , float, None]]]:...


class YapyArray:
    """Used as a keyword for parsing json data that stores `value` arrays.

    `WARNING!` YapyArrays do not check for the curly brackets `[]` delimiters!  """

    def __init__(self, data:ReadableBuffer, flag:int = 0) -> None: ...
    def get_pointer(self,data:Union[str,ReadableBuffer]) -> Union["YapyObject","YapyArray", int, str, bytes , float, None]:
        """Gets a pointer object from a path just like in `simdjson`
        paths should always start with a  slash `/` . Returns `None` 
        if the object misses or is not found...

        example::

            >> YapyArray(b'["Foo" , ["bar","baz"]]', 0)
            >> bar = y.get_pointer("/1/0")
            >> print(bar)
            'bar'
        
        see `RFC 6901` for more details...
        """
        ...
    
    
    @overload
    def __getitem__(self, i:int) ->  Union["YapyObject","YapyArray", int, str, bytes , float, list, None]:
        """Allows for items to be looked up 
        `WARNING!` 
        lookups take a linear search time as does `yyjson` itself"""
        ...

    @overload
    def __getitem__(self,i:slice) -> list[Union["YapyObject", "YapyArray", int, str, bytes , float, None]]:
        """Allows for items to be looked up 
        `WARNING!` 
        lookups take a linear search time as does `yyjson` itself
        It takes even longer as a slice methoad"""
        ...

def loads(data:ReadableBuffer,flag:Union[int,YapyReadFlag] = 0) -> Union["YapyObject", "YapyArray", int, str, bytes , float, None]:
    """Loads Json into a readable objects , Note that you can used the 
    yapyflags module provided can be used to reconfigure how the json data should be read and accessed"""

# TODO Write a semi-loader for handling larger sums and amounts of json objects when 
# yyjson gets to adding streaming API
