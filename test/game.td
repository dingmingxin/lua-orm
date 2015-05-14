Profile {
    name string
    gender number
    exp number
    lv number
    pl number
    gold number
    diamond number
    vip number
    create_time number
}

ItemBaseAttr {
    type number
    value number
}

Item {
    id number
    uuid string
    is_bind boolean
    base_attrs [ItemBaseAttr]
}

StackableItem {
    id number
    amount number
}

UniqueItemSet {
    id number
    items <string, Item>
}

EquipSlot {
    id number
    item Item
}

BagMgr {
    stackable <number, StackableItem>
    unique <number, UniqueItemSet>
}

Player {
    account string
    uuid string
    profile Profile # test
    bag BagMgr
    equip <number, EquipSlot>
}