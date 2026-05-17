net.Receive( "FPLootSync", function()
    net.ReadEntity().LootTable = net.ReadTable()
end )