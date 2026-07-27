function SpawnDefaultItems()
	print( "Items spawned!" )
end

function SpawnDefaultMapEntities()
	if istable( TESLA_GATES ) then
		for i, v in ipairs( TESLA_GATES ) do
			local ent = ents.Create( "fp_tesla_gate" )
			ent:SetPos( v.pos )
			ent:SetAngles( v.ang )
			ent:Spawn()
		end
	end

	print( "Map entities spawned!" )
end