from setuptools import setup, Extension, find_packages
import pathlib

VERSION = "0.0.1"

HERE = pathlib.Path("ypyjson")
with open("readme.md","r") as r:
    LONG_DESC = r.read()

# Name change from yapy to ypy due to contorvoursy over a guy who made a yap flag , 
# hung it up over neighbor's houses and later swats them 

def main():
    yyjson =  HERE / "yyjson"
    
    extensions = [
        Extension("ypyjson.reader", [
                str(HERE /"reader.c"), 
                str(yyjson / "yyjson.c")
            ]
        )
    ]
    
    setup(
        name="ypyjson", 
        version=VERSION,
        author="Vizonex", 
        description="yet another python json library using yyjson",
        long_description=LONG_DESC,
        ext_modules = extensions,
        license="Unlicense",
        packages=find_packages(
            include=['ypyjson'],
            exclude=['reader.cp39-win_amd64.pyd']
            ),
        # Include cython packages , stub files and yyjson's header file
        data_files=["ypyjson/reader.pyi",
                    "ypyjson/yyr.pxi",
                    "ypyjson/reader.pxd",
                    "ypyjson/reader.pyx",
                    "ypyjson/yyjson/yyjson.h"],
        keywords=["yyjson", "ypyjson", "json", "cython"],
        classifiers=[
            'Programming Language :: Python :: 3.9',
            'Programming Language :: Python :: 3.10',
            'Programming Language :: Python :: 3.11'
        ]
    )

if __name__ == "__main__":
    main()
