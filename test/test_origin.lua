-- local mt = {
--     __cls = cls,
--     __index = data,
--     __newindex = M.struct_setfield,
-- }

local function new_obj()
    local data = {}
    local obj = {
        data = data
    }
    setmetatable(
        obj,
        {
            __cls = 'test',
            __index  = obj.data,
            __pairs  = function(t)
                return next, t.data, nil
            end,
            __newindex = function(t, k, v)
                t.data[k] = v
            end
        }
    )
    return obj
end

obj_a = new_obj()
print("obj_a", obj_a.a)
obj_a.a = 1
print("obj_a", obj_a.a)
obj_a.a = 2
print("obj_a", obj_a.a)

obj_b = new_obj()
print("obj_b", obj_b.a)
obj_b.a = 1
print("obj_b", obj_b.a)
obj_b.a = 2
print("obj_b", obj_b.a)
obj_b.b = 2

for k, v in pairs(obj_b) do
    print(k, v)
end

-- local t_begin = os.time()
-- for n=1, 100000 do
--     local tbl = {}
--     for i=1, 1000 do
--         tbl[i] = i
--     end
-- end
-- print(os.time() - t_begin)

-- local t_begin = os.time()
-- for n=1, 100000 do
--     local tbl = {}
--     for i=1, 1000 do
--         rawset(tbl, i, i)
--     end
-- end
-- print(os.time() - t_begin)

print("usc next pairs")
local t = {a = 1, b = 2}
local k, v = next(t)
while k do
    print(k, v)
    k, v = next(t, k)
end
