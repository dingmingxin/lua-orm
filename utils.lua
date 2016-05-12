local M = {}

local tconcat = table.concat
local tinsert = table.insert
local srep = string.rep

M.print_table = function(root)
    local cache = {  [root] = "." }
    local function _dump(t,space,name)
        local temp = {}
        for k, v in next, t do
            local key = tostring(k)
            if cache[v] then
                tinsert(temp,"+" .. key .. " {" .. cache[v].."}")
            elseif type(v) == "table" then
                local new_key = name .. "." .. key
                cache[v] = new_key
                tinsert(temp,"+" .. key .. _dump(v,space .. (next(t,k) and "|" or " " ).. srep(" ",#key),new_key))
            else
                tinsert(temp,"+" .. key .. " [" .. tostring(v).."]")
            end
        end
        return tconcat(temp,"\n"..space)
    end

    print(_dump(root, "",""))
end


M.print_table_bypairs = function(root)
    local cache = {  [root] = "." }
    local function _dump(t,space,name)
        local item_list = {}
        for k, v in pairs(t) do
            item_list[#item_list+1] = {k, v}
        end
        local temp = {}
        for idx=1, #item_list do
            local item = item_list[idx]
            local k = item[1]
            local v = item[2]

            local key = tostring(k)
            if cache[v] then
                tinsert(temp,"+" .. key .. " {" .. cache[v].."}")
            elseif type(v) == "table" then
                local new_key = name .. "." .. key
                cache[v] = new_key
                local next_k = item_list[idx + 1]
                tinsert(temp,"+" .. key .. _dump(v,space .. (next_k and "|" or " " ).. srep(" ",#key),new_key))
            else
                tinsert(temp,"+" .. key .. " [" .. tostring(v).."]")
            end
        end
        return tconcat(temp,"\n"..space)
    end

    print(_dump(root, "",""))
end

return M
