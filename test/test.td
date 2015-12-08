include test2.td

class_a {
    a integer
    b integer
    c boolean
    d string
}

class_b [integer]

class_c <integer, string>

class_d {
    a class_a
    b class_b
    c class_c  
}

class_e {
    a {
        b [integer]
    }
    b [class_d]
    c <string, class_d>
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
