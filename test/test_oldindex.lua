local mt = {}
local trigger = false
function mt.__newindex(obj, k, v)
    print('__newindex', obj, k, obj[k], v)
    assert(obj[k] == nil)
    trigger = true
    rawset(obj, k, v)    
end

function mt.__oldindex(obj, k, v)
    print('__oldindex', obj, k, obj[k], v)
    assert(obj[k] ~= nil)
    trigger = true
    rawset(obj, k, v)
end


local function create_obj()
    local obj = {}
    setmetatable(obj, mt)
    return obj
end

local obj_a = create_obj()
print('test new 1', obj_a.a)
trigger = false
obj_a.a = nil
assert(trigger)

print('test new 2')
trigger = false
obj_a.a = 1
assert(trigger)

print('test old 1')
trigger = false
obj_a.a = 2
assert(trigger)

print('test old 2')
trigger = false
obj_a.a = nil
assert(trigger)

print('test new 3')
trigger = false
obj_a.a = 1
assert(trigger)

print('test index', obj_a.a)
