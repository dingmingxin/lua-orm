local enable_oldindex = enable_oldindex or function() end
local mt = {}
local trigger = false
function mt.__newindex(obj, k, v)
    print('__newindex', obj, k, v, obj[k])
    assert(obj[k] == nil)
    trigger = true
    rawset(obj, k, v)    
end

function mt.__oldindex(obj, k, v)
    print('__oldindex', obj, k, v, obj[k])
    assert(obj[k] ~= nil)
    trigger = true
    rawset(obj, k, v)
end


local function create_obj()
    local obj = {}
    enable_oldindex(obj, true)
    setmetatable(obj, mt)
    return obj
end

print("--- start")
local obj_a = create_obj()
print('\ntest set nil to nil', obj_a.a)
trigger = false
obj_a.a = nil
assert(trigger)

print('\ntest set nil to nonil')
trigger = false
obj_a.a = 1
assert(trigger)

print('\ntest change nonil to nonil')
trigger = false
obj_a.a = 2
assert(trigger)

print('\ntest set nonil to nil')
trigger = false
obj_a.a = nil
assert(trigger)

print("\ntest insert, only newindex")
trigger = false
print("-- insert 1")
table.insert(obj_a, 1)
print("-- insert 2")
table.insert(obj_a, 2)
print("-- insert 3")
table.insert(obj_a, 3)
print("-- insert 4")
table.insert(obj_a, 4)

print("-- insert a", table.concat(obj_a, ","))
table.insert(obj_a, 1, 'a')
print("-- insert b", table.concat(obj_a, ","))
table.insert(obj_a, 1, 'b')
print("-- insert c", table.concat(obj_a, ","))
table.insert(obj_a, 1, 'c')
print("-- insert d", table.concat(obj_a, ","))
table.insert(obj_a, 1, 'd')
print("insert end", table.concat(obj_a))
assert(trigger)

print("\ntest remove, don't need oldindex")
print("-- remove 1", table.concat(obj_a, ","))
table.remove(obj_a, 1)
print("-- remove 3", table.concat(obj_a, ","))
table.remove(obj_a, 3)
print("remove end", table.concat(obj_a))

print('test index', obj_a.a)
