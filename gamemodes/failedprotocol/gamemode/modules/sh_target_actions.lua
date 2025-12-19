ENTITY_ACTIONS_OVERRIDE = { -- Overrides won't work on those entities that already have Actions table!
	--[[["prop_door_rotating"] = {
		[1] = {
	        name = "use",
	        cooldown = 1,
	        func = function( ply, ent )
	        	ent:Use( ply )
	        end
	    },
	    [2] = {
	        name = "knock",
	        cooldown = .3,
	        func = function( ply, ent )
	            ent:EmitSound( "physics/wood/wood_crate_impact_hard2.wav" )
	        end
	    }
	},]]
}