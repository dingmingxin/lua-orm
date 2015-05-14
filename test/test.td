include test2.td

class_a {
    a number
    b number
    c boolean
    d string
}

class_b [number]

class_c <number, string>

class_d {
    a class_a
    b class_b
    c class_c  
}

class_e {
    a {
        b [number]
    }
    b [class_d]
    c <string, class_d>
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
