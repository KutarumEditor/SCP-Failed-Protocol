function canTakeLoot( ply, item )
    local weps = ply:GetWeapons()

    for i, wep in ipairs( weps ) do
        if wep:IsDerived( "fp_hands" ) then
            table.remove( weps, i )
        end
    end

    return #weps < ply:GetInvSlots() and not ply:HasWeapon( item.class )
end

local function roll_card_low( item )
    local lootData = item

    local cardpool = {
        "janitor",
        "lab",
        "medic",
        "logist"
    }

    lootData.data.access = cardpool[FPRandom( #cardpool )]

    return lootData
end

local function keycard_from_item( item, ply )
    ply:GiveKeycard( item.data.access )
end

MAX_LOOT_DISTANCE = 128
LOOT_CFG = {
    --[[
    ["name"] = {
        size = 3,
        amount = 2,
        pool = {
            ["fp_keycard"] = { 1, 1, spawn_callback, take_callback },
            ["fp_gasmask"] = { 3 },
            ["fp_bandage"] = { 2 },
        },
    },
    ]]
    ["locker_lcz"] = {
        size = 16,
        amount = { 1, 3 },
        pool = {
            ["fp_keycard"] = { 10, 1, roll_card_low, keycard_from_item },
            ["fp_gasmask"] = { 15 },
            ["fp_bandage"] = { 5 },
        },
    },
}