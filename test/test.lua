local orm = require 'orm'
tprint = require('utils').print_table

-- test
local type_list = (require 'typedef').parse('test.td', "./test")
tprint(type_list)

print('[TC]: type init')
orm.init(type_list)

print('--- obj_class_map')
tprint(orm.cls_map)

print('[TC]: struct init')
local obj_a = orm.create('class_a')
tprint(obj_a)

print('[TC]: struct set attr')
obj_a.a = nil
obj_a.b = 2
obj_a.c = true
obj_a.d = 'hello world'
tprint(obj_a)
for k, v in pairs(obj_a) do
    print(k, v)
end


print('[TC]: struct init by data')
local obj_a = orm.create('class_a', {a=10, b=100})
tprint(obj_a)

print('[TC]: list init by data')
local obj_b = orm.create('class_b', {4, 3, 2, 1})
tprint(obj_b)
print("len:", #obj_b)

print('[TC]: list insert and remove')
table.insert(obj_b, 11)
table.insert(obj_b, 12)
print("len:", #obj_b)
for idx, item in ipairs(obj_b) do
    print(idx, item)
end

print('[TC]: list remove')
print("len:", #obj_b)
table.remove(obj_b, 4)
print("remove 1")
for idx, item in ipairs(obj_b) do
    print(idx, item)
end

print('[TC]: list set')
obj_b[1] = 100
obj_b[2] = nil
tprint(obj_b)
print("len:", #obj_b)
for idx, item in ipairs(obj_b) do
    print(idx, item)
end

print('[TC]: map')
local obj_c = orm.create('class_c', {[1] = '2', ['2'] = '2'})
tprint(obj_c)
for k, v in pairs(obj_c) do
    print(k, v)
end


print('[TC]: type ref')
local obj_d = orm.create('class_d')
obj_d.a = {a = 100}
obj_d.b = {1, 2, 3, 4, 5, 6}
obj_d.c[8] = 'a'
tprint(obj_d)

print('[TC]: complex')
local obj_e = orm.create('class_e')
obj_e.a = {b = {3,4,5,6}}
obj_e.b = {{["1"] = 2, ["2"] = 3},}
tprint(obj_e)
for k, v in pairs(obj_e.b[1]) do
    print(k, type(k), v, type(v))
end


print('[TC]: type ref optimize')
local obj_a = orm.create('class_a')
print("--- obj_a")
local obj_b = orm.create('class_b', {4, 2, 3})
print("--- obj_b")
local obj_c = orm.create('class_c', {[8] = 'a', [15] = 'b'})
print("--- obj_c")
local obj_d = orm.create('class_d', {a=obj_a, b=obj_b, c=obj_c})
print("--- obj_d")
-- tprint(obj_d)
local obj_e = orm.create('class_e')
table.insert(obj_e.b, obj_d)
obj_e.d = {
    a = 1,
    b = 'test',
    c = {
        b = {'a', 'b', 'c'},
        c = {a = 1, b = 2, c = 3}
    }
}
-- tprint(obj_e)
print('--- check default', obj_e.d.c.a)
assert(obj_e.d.c.a)
