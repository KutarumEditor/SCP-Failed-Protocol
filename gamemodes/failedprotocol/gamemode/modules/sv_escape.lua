function SetupExits()
	for name, exit in pairs( EXITS ) do
		local m1, m2 = exit.bounds[1], exit.bounds[2]
		local diff = m2 - m1
		local ent = ents.Create( "fp_exit" )
		ent:SetName( name )
		ent:SetPos( LerpVector( .5, m1, m2 ) )
		ent:Spawn()
		ent:SetCollisionBounds( ( -diff ) / 2, diff / 2 )
		ent.EscapeCallback = exit.callback
		ent.EscapeCheck = exit.check
	end
end