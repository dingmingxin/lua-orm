# lua-orm
lua orm lib for database schema, can use like a ordinary lua table

# require
- new metamethod __oldindex to hook table attr change when table has it

  modify a litte code in lua5.3.0, you can see detail in this 
  <a href="https://github.com/pigparadise/lua-orm/commit/8079829b3c3f3a3714c3a947a533e51aa43afd26" target="_blank">commit</a>
  
- [lpeg](http://www.inf.puc-rio.br/~roberto/lpeg/) for schema parser

# support
- basic data type: boolean, integer, string, struct, list, map
- custom define class
- class ref

# typedef examples
struct
```
class_a {
    a integer
    b integer
    c boolean
    d string
}
```
list
```
class_b [integer]
```
map
```
class_c <integer, string>
```

class ref
```
class_d {
    a class_a
    b class_b
    c class_c
}
```

complex
```
class_e {
    a {
        b [integer]
    }
    b [class_c]
    c <string, class_c>
    d {
        a integer
        b string
        c {
            a integer
            b [string]
            c <string, integer>
        }
    }
}
```

# lua code examples
```
local orm = require 'orm'
local type_list = (require 'typedef').parse('test.td', ".")
orm.init(type_list)
local obj_a = orm.create('class_a')
```

you need make lua first and can see more examples in test.lua.

if you want create your own typedef syntax, you can see typedef.lua.

