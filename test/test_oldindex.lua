local mt = {}
function mt.__newindex(obj, k, v)
    print('__newindex', obj, k, v)
    rawset(obj, k, v)    
end

function mt.__oldindex(obj, k, v)
    print('__oldindex', obj, k, v)
    rawset(obj, k, v)
end


local function create_obj()
    local obj = {}
    setmetatable(obj, mt)
    return obj
end

local obj_a = create_obj()
print('test0', obj_a.a)
obj_a.a = nil
print('test1', obj_a.a)
obj_a.a = 1
print('test2', obj_a.a)
obj_a.a = 2
print('test3', obj_a.a)
obj_a.a = nil
print('test4', obj_a.a)
obj_a.a = 1
print('test5', obj_a.a)
