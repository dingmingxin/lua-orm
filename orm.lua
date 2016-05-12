local M = {}

local KEYWORD_MAP = {
    boolean = true,
    integer = true,
    string = true,
    struct = true,
    list = true,
    map = true,
}

local CONTAINER_DATA_TYPES = {
    struct = true,
    list = true,
    map = true,
}

M.KEY_ATTRS = {
    ['__cls'] = true
}
local ERR_CHANGE_KEY_ATTRS = "can't modify key attrs"

M.cls_ref_map = {} -- cls_name : [parent_name, ...]
local cls_map = {} -- cls_name: cls
local string_format = string.format
local math_tointeger = math.tointeger


function M.check_ref(node_id, parent_id)
    -- print('check ref', node_id, parent_id)
    if parent_id == nil then
        return
    end

    if parent_id == node_id then
        error(string_format('type<%s> ref recursion define', node_id))
    end

    local p_map = M.cls_ref_map[node_id]
    if not p_map then
        p_map = {}
        M.cls_ref_map[node_id] = p_map
    end

    p_map[parent_id] = true -- record parent

    -- check and update parent's parent
    local pp_map = M.cls_ref_map[parent_id]
    if not pp_map then
        pp_map = {}
        M.cls_ref_map[parent_id] = pp_map
    end

    for pp_id, _ in pairs(pp_map) do
        M.check_ref(node_id, pp_id)
    end
end

function M.get_default(cls)
    local cls_type = cls.type
    if not cls.is_atom then
        error(string_format("cls<%s> type<%s> no default", cls.name, cls_type))
    end
    if cls_type == 'boolean' then
        return cls.default or false
    elseif cls_type == 'integer' then
        return cls.default or 0
    elseif cls_type == 'string' then
        return cls.default or ""
    end
end

local function _cls_parse_error(cls, data, msg)
    local s = string_format("cls<%s> data<%s> %s", cls.name, data, msg)
    error(s)
end

function M.parse_boolean(cls, s)
    return s == true
end

function M.parse_string(cls, s)
    local stype = type(s)
    if stype ~= 'int' and stype ~= 'string' then
        _cls_parse_error(cls, s, "is not string")
    end
    return tostring(s)
end

function M.parse_integer(cls, s)
    local value = math_tointeger(s)
    if value == nil then
        _cls_parse_error(cls, s, "is not integer")
    end

    return value
end

function M.parse_struct(cls, data)
    if data == nil then
        return cls:new()
    end

    if type(data) ~= 'table' then
        _cls_parse_error(cls, data, "is not table")
    end

    local ret = {}
    for attr_name, attr_cls in pairs(cls.attrs) do
        local attr_data = data[attr_name]
        -- 如果原子类型并且数据为nil时跳过(有default)
        if not (attr_data == nil and attr_cls.is_atom) then
            ret[attr_name] = attr_cls:parse(attr_data)
        end
    end

    -- print('parse struct create obj', cls.name, ret)
    return cls:new(ret)
end


function M.parse_list(cls, data)
    if data == nil then
        return cls:new()
    end

    if type(data) ~= 'table' then
        _cls_parse_error(cls, data, "is not table")
    end

    local ret = {}
    local item_cls = cls.item
    for _idx=1, #data do
        table.insert(ret, item_cls:parse(data[_idx]))
    end
    return cls:new(ret)
end

function M.parse_map(cls, data)
    if data == nil then
        return cls:new()
    end

    if type(data) ~= 'table' then
        _cls_parse_error(cls, data, "is not table")
    end

    local cls_name = cls.name
    local k_cls = cls.key
    local v_cls = cls.value
    local ret = {}
    for k_data, v_data in pairs(data) do
        ret[k_cls:parse(k_data)] = v_cls:parse(v_data)
    end
    return cls:new(ret)
end

local data_parsers = {
    boolean = M.parse_boolean,
    integer = M.parse_integer,
    string = M.parse_string,
    struct = M.parse_struct,
    list = M.parse_list,
    map = M.parse_map,
}

function M.load_cls_define(cls, parent_name)
    assert(cls, "no cls define")
    -- print('init obj type', cls.name, cls.type)

    if parent_name ~= nil then
        cls.name = parent_name .. "." .. cls.name
    end
    local cls_name = cls.name

    if KEYWORD_MAP[cls_name] then
        error(string_format("cls name<%s> is keyword", cls_name))
    end

    local data_type = cls.type
    if not data_type then
        error(string_format("init cls<%s> no data type", cls_name))
    end

    if not KEYWORD_MAP[data_type] then -- ref type
        local ref_cls_name = data_type
        local ref_cls = cls_map[ref_cls_name]
        if ref_cls == nil then
            error(string_format("init cls<%s|%s>, ref illegal ", cls.name, data_type))
        end

        M.check_ref(ref_cls.name, parent_name)
        for k, v in pairs(ref_cls) do -- copy ref
            cls[k] = v
        end
        if not ref_cls.id then
            cls.id = ref_cls
        end
        cls.name = cls_name
        return cls
    end

    cls.id = cls
    local parser = data_parsers[data_type]
    if not parser then
        error(string_format("data type<%s> no parser", data_type))
    end
    cls.parse = parser
    -- print('init obj type', cls.name, data_type, cls.d_cls, cls.parser)

    M.check_ref(cls_name, parent_name)
    cls_map[cls_name] = cls
    cls.is_atom = (CONTAINER_DATA_TYPES[data_type] == nil)
    if cls.is_atom then
        return cls
    end

    if data_type == 'struct' then
        cls.new = M.create_struct
        local mt = {
            __cls = cls,
        }
        cls.mt = {__index = mt}
        assert(cls.attrs, "not attrs")
        local attrs = {}
        for k, v in pairs(cls.attrs) do
            if M.KEY_ATTRS[k] then
                error(string_format("class<%s> define key attr<%s>", cls_name, k))
            end
            v.name = k
            local v_cls = M.load_cls_define(v, cls_name)
            if v_cls.is_atom then -- set default
                mt[k] = M.get_default(v_cls)
            end
            attrs[k] = v_cls
        end
        cls.attrs = attrs
        return cls
    end

    if data_type == 'list' then
        cls.new = M.create_list
        local mt = {
            __cls = cls,
        }
        cls.mt = {__index = mt}
        cls.item.name = 'item'
        cls.item = M.load_cls_define(cls.item, cls_name)
        return cls
    end

    if data_type == 'map' then
        cls.new = M.create_map
        local mt = {
            __cls = cls,
        }
        cls.mt = {__index = mt}
        cls.key.name = 'key'
        cls.key = M.load_cls_define(cls.key, cls_name)
        cls.value.name = 'value'
        cls.value = M.load_cls_define(cls.value, cls_name)
        return cls
    end

    error(string_format("unsupport data type<%s>", data_type))
end


function M.init(type_list)
    -- reset
    cls_map = {}
    M.cls_ref_map = {}

    for _, item in ipairs(type_list) do
        local name = item.name
        assert(name, 'not cls name')
        M.load_cls_define(item, nil)
    end
    M.cls_map = cls_map
end

function M.struct_setfield(obj, k, v)
    -- print('struct __newindex', obj, k, v)
    local cls = obj.__cls
    if not cls then
        error(string_format("struct no cls info"))
    end

    local v_cls = cls.attrs[k]
    if not v_cls then
        error(string_format('cls<%s> has no attr<%s>', cls.name, k))
    end

    -- optimize, trust cls obj by name
    local obj_data = obj.__data
    if type(v) == 'table' and v.__cls ~= nil then
        if v_cls.id == v.__cls.id then
            -- print(
            --     '-- struct trust cls obj', 
            --     cls.name, k, v_cls.name, v.__cls
            -- )
            obj_data[k] = v
            return
        end
        local s = string_format(
            'obj<%s.%s> value type not match, need<%s>, give<%s>',
            cls.name, k, v_cls.id.name, v.__cls.name
        )
        error(s)
    end

    -- if v == nil, set node default
    -- print('-- struct, paser ', cls.name, k, v, v_cls.name, v_cls.parser)
    if v == nil and v_cls.is_atom then
        obj_data[k] = nil
        return
    end

    obj_data[k] = v_cls:parse(v)
end

function M.list_setfield(obj, k, v)
    -- print('list __newindex', obj, k, v)
    local cls = obj.__cls
    if not cls then
        error(string_format("list no cls info"))
    end

    if k ~= math_tointeger(k) then
        local s = string_format(
            'cls<%s> key<%s> data<%s> is not integer', 
            cls.name, k, data
        )
        error(s)
    end

    local obj_data = obj.__data
    if v == nil then -- if v == nil, remove node
        obj_data[k] = nil
        return
    end

    local v_cls = cls.item
    -- optimize, trust cls obj by name
    if type(v) == 'table' and v.__cls ~= nil then
        if v_cls.id == v.__cls.id then
            -- print(
            --     '-- list trust cls obj', 
            --     cls.name, k, v_cls.name, v.__cls
            -- )
            obj_data[k] = v
            return
        end
        local s = string_format(
            'cls<%s.%s> value type not match, need<%s>, give<%s>',
            cls.name, k, v_cls.id.name, v.__cls.name
        )
        error(s)
    end

    obj_data[k] = v_cls:parse(v)
end

function M.map_setfield(obj, k, v)
    -- print('map __newindex', obj, k, v)
    -- assert(k ~= "__cls", ERR_CHANGE_KEY_ATTRS)
    local cls = obj.__cls
    if not cls then
        error(string_format("no cls info<%s>", cls_name))
    end

    local obj_data = obj.__data
    local k_data = cls.key:parse(k)
    if v == nil then -- if v == nil, remove node
        obj_data[k_data] = nil
        return
    end

    local v_cls = cls.value
    -- optimize, trust cls obj by name
    if type(v) == 'table' and v.__cls ~= nil then
        if v_cls.id == v.__cls.id then
            -- print(
            --     '-- map trust cls obj', 
            --     cls.name, k, v_cls.name, v.__cls
            -- )
            obj_data[k_data] = v
            return
        end

        local s = string_format(
            'obj<%s.%s> value type not match, need<%s>, give<%s>',
            cls.name, k_data, v_cls.id.name, v.__cls.name
        )
        error(s)
    end

    obj_data[k_data] = v_cls:parse(v)
end


function M.container_len(obj)
    return #obj.__data
end

function M.container_pairs(obj)
    return next, obj.__data, nil
end

function M.next(obj, k)
    -- is normal table
    if not obj.__cls then
        return next(obj, k)
    end

    -- is orm obj
    return next(obj.__data, k)
end

function M.create_struct(cls, data)
    local _data = {}
    local obj = {
        __data = _data,
    }
    setmetatable(_data, cls.mt)
    setmetatable(
        obj,
        {
            __index = _data,
            __newindex = M.struct_setfield,
            __pairs =  M.container_pairs,
            __len = M.container_len,
        }
    )

    -- check data type
    if data == nil then
        for k, v in pairs(cls.attrs) do
            if not v.is_atom then
                obj[k] = nil
            end
        end
    else
        for k, v in pairs(cls.attrs) do
            local k_data = data[k]
            if not (k_data == nil and v.is_atom) then
                obj[k] = k_data
            end
        end
    end

    return obj
end

function M.create_list(cls, data)
    local _data = {}
    local obj = {
        __data = _data,
    }
    setmetatable(_data, cls.mt)
    setmetatable(
        obj,
        {
            __index = _data,
            __newindex = M.list_setfield,
            __pairs = M.container_pairs,
            __len = M.container_len,
        }
    )

    if data == nil then
        return obj
    end


    for idx=1, #data do
        obj[idx] = data[idx]
    end
    return obj
end


function M.create_map(cls, data)
    local _data = {}
    local obj = {
        __data = _data,
    }
    setmetatable(_data, cls.mt)
    setmetatable(
        obj,
        {
            __index = _data,
            __newindex = M.map_setfield,
            __pairs =  M.container_pairs,
            __len = M.container_len,
        }
    )

    if data == nil then
        return obj
    end

    for k, v in pairs(data) do
        obj[k] = v
    end
    return obj
end

--- 创建orm对象
function M.create(cls_name, data)
    local cls = cls_map[cls_name]
    if not cls then
        error(string_format("create obj, illgeal cls<%s>", cls_name))
    end
    return cls:new(data)
end


return M
