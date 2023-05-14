from enum import IntFlag


# NOTE Changed the name from yapy to ypy due to controvoursy over a new flag on twitter 
# that I will never be associated with and I found the flag to be downright 
# innapropreate and therefore have decided to change the library's name before publishing... 

class YpyReadFlag(IntFlag):
    """Used to set read flags with `YpyObject` `YpyArray` and `loads()`
    Thse flags are from yyjson's library but brought into here for simplicity sake..."""
    READ_NOFLAG = 0 
    """Ignore the use of flags..."""

    READ_INSITU = 1 << 0
    """Speeds up reading by eliminating the use of nullbytes found"""

    STOP_WHEN_DONE = 1 << 1
    """This has not been Implemented or introduced into yapy yet but this will stop dynamic loading when finished..."""

    ALLOW_TRAILING_COMMAS = 1 << 2
    """allows for the use of extra commas """

    ALLOW_COMMENTS = 1 << 3
    """enables json to be compiled with comments"""

    READ_ALLOW_INF_AND_NAN = 1 << 4
    """\"Allow inf/nan number and literal, case-insensitive,
such as 1e999, NaN, inf, -Infinity (non-standard)\" - yyjson"""

    READ_NUMBER_AS_RAW = 1 << 5
    """
    This can actually be a good thing if 
    larger numbers are to be used to prevent large number 
    conversion vulnerabilities, see `CVE-2020-27619` for more details...

    Numbers will be returned as `bytes` objects instead of being integers.
    A library like `gmpy2` or `numpy` would be a good replacement if you still need to use those 
    big numbers elsewhere...

    ::

        import gmpy2
        from yapyjson import YapyReadFlag, loads

        # Example...
        raw_json = '''{ // This is just a poorly written example... with comments inside the json...
                        "result":123456372525828636819341946377296473924692
                    }'''

        # Numbers when set with this flag will now become bytes instead of integers...
        flag = YapyReadFlag.READ_NUMBER_AS_RAW 

        # If were handling more flags we need to use this '|=' bitwsie operator...
        flag |= YapyReadFlag.ALLOW_COMMENTS

        # Or more simply 
        flag = YapyReadFlag.READ_NUMBER_AS_RAW | YapyReadFlag.ALLOW_COMMENTS

        data = loads(raw_json,flag)

        large_number = gympy2.from_binary(data["result"])
        ...
    """
    
    ALLOW_INVALID_UNICODE = 1 << 6
    """\"Warning! Strings in JSON values may contain incorrect encoding when this
    option is used, you need to handle these strings carefully to avoid security
    risks.\" - yyjson """
