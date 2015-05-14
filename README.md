# lua-orm
lua orm lib for database schema, can use like a ordinary lua table

# require
make a litte change to lua5.3.0(add new metamethod __oldindex)

# support
- basic data type: boolean, number, string, struct, list, map
- custom define class
- class ref

# typedef examples
struct
```
class_a {
    a number
    b number
    c boolean
    d string
}
```
list
```
class_b [number]
```
map
```
class_c <number, string>
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
        b [number]
    }
    b [class_c]
    c <string, class_c>
    d {
        a number
        b string
        c {
            a number
            b [string]
            c <string, number>
        }
    }
}
```

# code examples
```
local orm = require 'orm'
local type_list = (require 'typedef').parse('test.td', ".")
orm.init(type_list)
local obj_a = orm.create('class_a')
```

you need make lua first and can see more examples in test_typedef.lua

if you want create your own typedef, you can see typedef.lua and test.lua


