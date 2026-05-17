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
	["prop_ragdoll"] = {
		[1] = {
	        name = "check",
	        func = function( ply )
	        	ply:TimedTask( "body_check", 1, Color( 180, 175, 0 ), function()
			        return IsValid( ent ) and IsValid( ply ) and ply:EyePos():Distance( ply:GetEyeTrace().HitPos ) < 100 and ply:GetEyeTrace().Entity == ent
			    end, function()
			        ply:CheckBody( ent )
			    end )
	        end
	    },
	},
	["player"] = {
		[1] = {
			name = "detain",
	        cooldown = 3,
	        func = function( ply, ent )
	        	ply:TimedTask( "detaining", 2.5, Color( 200, 155, 0 ),
			    function()
			    	local tr = ply:GetEyeTrace()

			        return IsValid( ent ) and IsValid( ply ) and ply:EyePos():Distance( ent:GetPos() + Vector( 0, ent:OBBCenter().y, 0 ) ) < 100
			    end, function()
			        ent:Detain( ply )
			    end )
	        end
		}
	}
}