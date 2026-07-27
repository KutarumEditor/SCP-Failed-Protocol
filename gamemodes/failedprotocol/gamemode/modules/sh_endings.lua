ENDINGS = {
	["default"] = {
		[1] = {
			lang = "facility_destroyed",
			check = function( plys )
				return ROUNDPROP.Get( "WarheadDetonated" ) == true
			end,
			callback = function()
				print( "Facility was destroyed by nuclear warheads!" )
			end,
		},
		[2] = {
			lang = "power_seized",
			check = function( plys )
				if #plys == 0 then return false end

				for i, ply in ipairs( plys ) do
					if !FPTeams.IsEnemy( ply:FPTeam(), TEAM_MTF ) then return false end
					
					if ply:FPTeam() == TEAM_SCP then return false end
				end

				return true
			end,
			callback = function()
				print( "Power over facility was seized by the groups of interest!" )
			end,
		},
		[3] = {
			lang = "break_out",
			check = function( plys )
				if #plys == 0 then return false end
				
				for i, ply in ipairs( plys ) do
					if FPTeams.IsEnemy( ply:FPTeam(), TEAM_SCP ) == true then
						return false
					end
				end

				return true
			end,
			callback = function()
				print( "Anomalies massacred facility!" )
			end,
		},
		[4] = {
			lang = "control_regained",
			check = function( plys )
				if #plys == 0 then return false end

				for i, ply in ipairs( plys ) do
					if FPTeams.IsEnemy( ply:FPTeam(), TEAM_MTF ) then return false end
				end

				return true
			end,
			callback = function()
				print( "Foundation regained control over the facility!" )
			end,
		},
		[5] = {
			lang = "unknown_fate",
			check = function( plys )
				return true
			end,
			callback = function()
				print( "Fate of the facility is unknown..." )
			end,
		},
	}
}