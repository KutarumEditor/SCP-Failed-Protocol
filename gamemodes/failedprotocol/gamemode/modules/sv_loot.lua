function GenerateLoot( type )
    local cfg = LOOT_CFG[type]

    local resultLoot = {}
    
    local totalWeight = 0
    for itemName, itemData in pairs( cfg.pool ) do
        totalWeight = totalWeight + ( itemData[1] or 0 )
    end

    if totalWeight <= 0 then return {} end

    local minAmount = cfg.amount[1] or 1
    local maxAmount = cfg.amount[2] or 1
    local itemsToSpawn = FPRandom( minAmount, maxAmount )

    local availableSlots = {}
    for i = 1, cfg.size do
        table.insert( availableSlots, i )
    end

    for i = 1, itemsToSpawn do
        if #availableSlots == 0 then break end

        local roll = FPRandom( 1, totalWeight )
        local currentWeight = 0
        local chosenItem = nil
        local chosenItemData = nil

        for itemName, itemData in pairs( cfg.pool ) do
            currentWeight = currentWeight + ( itemData[1] or 0 )
            if roll <= currentWeight then
                chosenItem = itemName
                chosenItemData = itemData
                break
            end
        end

        if chosenItem then
            local slotIndex = FPRandom( 1, #availableSlots )
            local targetSlot = availableSlots[slotIndex]

            table.remove( availableSlots, slotIndex )

            local itemAmount = chosenItemData[2] or 1

            resultLoot[targetSlot] = {
                class = chosenItem,
                amount = itemAmount,
                data = {}
            }

            local cb = cfg.pool[chosenItem][3]
            if cb != nil then
                resultLoot[targetSlot] = cb( resultLoot[targetSlot] )
            end
        end
    end

    return resultLoot
end

local ENTITY = FindMetaTable( "Entity" )

function ENTITY:SetLoot( type )
    self:SetType( type )

    self.LootTable = GenerateLoot( type )
end

local PLAYER = FindMetaTable( "Player" )

function PLAYER:TakeLoot( ent, slot )
    if not canTakeLoot( self, ent.LootTable[slot] ) then return end

    if ent.LootTable[slot] == nil then return end

    local cb = LOOT_CFG[ent:GetType()].pool[ent.LootTable[slot].class][4]
    if cb == nil then
        self:Give( ent.LootTable[slot].class )
    else
        cb( ent.LootTable[slot], self )
    end

    ent.LootTable[slot] = nil

    self:SyncInv()
    SyncLootable( ent )
end

hook.Add( "FPLootCheck", "DefaultLootCheck", function( ply, ent )
    if not ply:Alive() then return false end

    if not ply:IsHuman() then return false end

    if ply:EyePos():Distance( ent:GetPos() ) > MAX_LOOT_DISTANCE then return false end

    return true
end )

net.Receive( "FPLoot", function( len, ply )
    local ent = net.ReadEntity()
    local slot = net.ReadFloat()

    if not hook.Run( "FPLootCheck", ply, ent ) then return end

    ply:TakeLoot( ent, slot )
end )

function SyncLootable( ent )
    timer.Simple( FrameTime() * 3, function()
        net.Start( "FPLootSync" )
            net.WriteEntity( ent )
            net.WriteTable( ent.LootTable )
        net.Broadcast()
    end )
end

function SetupLootables()
    for _, tbl in ipairs( LOOTABLES ) do
        local amount = math.ceil( #tbl.lootables * tbl.percentage )
        local lootables = table.Copy( tbl.lootables )

        for i = 1, amount do
            local lootbl = table.remove( lootables, FPRandom( #lootables ) )
            local bounds = lootbl.bounds
            local size = bounds[2] - bounds[1]
            local pos = bounds[1] + size/2

            local ent = ents.Create( "fp_lootable" )
            ent:SetPos( pos )
            ent:SetLoot( lootbl.type )
            ent:Spawn()
            
            SyncLootable( ent )
        end
    end
end

concommand.Add( "fp_reset_lootables", function()
    for i, v in ents.Iterator() do
        if v:GetClass() == "fp_lootable" then
            v:Remove()
        end
    end

    SetupLootables()
end )