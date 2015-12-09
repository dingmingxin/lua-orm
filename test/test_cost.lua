local orm = require 'orm'
tprint = require('utils').print_table
local type_list = (require 'typedef').parse('game.td', "./test")
orm.init(type_list)

local data =   {
    ["_id"] = "551a1b6d67634b94416ec033",
    ["profile"] = {
        ["gold"] = 3018,
        ["pl"] = 298,
        ["exp"] = 2998,
        ["lv"] = 1000,
        ["name"] = "test_account",
        ["diamond"] = 3020,
        ["vip"] = 6,
        ["create_time"] = 1427774317
    },
    ["account"] = "test_account",
    ["bag"] = {
        ["stackable"] = {
            ["30001"] = {
                ["amount"] = 20,
                ["id"] = 30001
            },
            ["40001"] = {
                ["amount"] = 19,
                ["id"] = 40001
            },
            ["30002"] = {
                ["amount"] = 19,
                ["id"] = 30002
            },
            ["40002"] = {
                ["amount"] = 19,
                ["id"] = 40002
            }
        },
        ["unique"] = {
            ["10002"] = {
                ["items"] = {
                    ["551a4f7367634b945c6e040c"] = {
                        ["id"] = 10002,
                        ["amount"] = 1,
                        ["uuid"] = "551a4f7367634b945c6e040c"
                    }
                },
                ["id"] = 10002
            },
            ["10001"] = {
                ["items"] = {
                    ["551b55c367634bec3ace9efe"] = {
                        ["id"] = 10001,
                        ["amount"] = 1,
                        ["uuid"] = "551b55c367634bec3ace9efe"
                    },
                    ["551a4f7067634b945c6e040b"] = {
                        ["id"] = 10001,
                        ["amount"] = 1,
                        ["uuid"] = "551a4f7067634b945c6e040b"
                    }
                },
                ["id"] = 10001
            },
            ["20001"] = {
                ["items"] = {
                    ["551b55c367634bec3ace9f00"] = {
                        ["id"] = 20001,
                        ["amount"] = 1,
                        ["uuid"] = "551b55c367634bec3ace9f00"
                    }
                },
                ["id"] = 20001
            }
        }
    },
    ["equip"] = {
        ["6"] = {
            ["item"] = {
                ["id"] = 10002,
                ["amount"] = 1,
                ["uuid"] = "551b55c367634bec3ace9eff"
            }
        },
        ["1"] = {
            ["item"] = {
                ["id"] = 20002,
                ["amount"] = 1,
                ["uuid"] = "551b55c367634bec3ace9f01"
            }
        }
    },
    ["uuid"] = "551a1b6d67634b94416ec032"
}

local function test_normal()
    local obj = orm.create('Player', data)
    obj.uuid = 'a'
    obj.profile.vip = 1
    obj.bag.unique[1002] = nil
    obj.equip[2] = {item = {id=2001, amount = 1, uuid = 'asdfasdfasd'}}

    obj.bag = data.bag
    for k, v in pairs(obj.bag.unique) do
        for _k, _v in pairs(v.items) do
        end
    end

    local books = obj.books
    for i=1, 10 do
        table.insert(books, {id=2001, amount = 1, uuid = 'asdfasdfasd'})
    end
    for i=5, 1, -1 do
        table.remove(books, i)
    end
    
    -- tprint(obj)
    -- print("is bind", obj.equip[1].item.is_bind)
end

local test_case = {
    {
        name = 'normal',
        func = test_normal,
        count = 5 * 10000
    }
}

for _, case in ipairs(test_case) do
    print(string.format('test case<%s> begin', case.name))
    local t_begin = os.clock()
    for i=1, case.count do
        -- print("case begin", i)
        case.func()
        -- print("case end", i)
    end

    local t_cost = os.clock() - t_begin
    print(
        string.format(
            'test case<%s> end, count<%s>, time<%s>',
            case.name, case.count, t_cost
        )
    )
end


