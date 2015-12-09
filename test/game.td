Profile {
    name string
    gender integer
    exp integer
    lv integer
    pl integer
    gold integer
    diamond integer
    vip integer
    create_time integer
}

ItemBaseAttr {
    type integer
    value integer
}

Item {
    id integer
    uuid string
    is_bind boolean
    base_attrs [ItemBaseAttr]
}

StackableItem {
    id integer
    amount integer
}

UniqueItemSet {
    id integer
    items <string, Item>
}

EquipSlot {
    id integer
    item Item
}

BagMgr {
    stackable <integer, StackableItem>
    unique <integer, UniqueItemSet>
}

Player {
    account string
    uuid string
    profile Profile # test
    bag BagMgr
    equip <integer, EquipSlot>
    books [Item]
}