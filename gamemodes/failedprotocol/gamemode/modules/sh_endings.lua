local function checkFoundationRivalry( ply )
	return NEUTRALITY.IsBrokenByTeam( TEAM_SD, ply ) or NEUTRALITY.IsBrokenByTeam( TEAM_MTF, ply ) or FPTeams.IsEnemy( ply:FPTeam(), TEAM_MTF ) or FPTeams.IsEnemy( ply:FPTeam(), TEAM_SD )
end

local function testCurrentFactionsRivalry()
	local curFactions = {}

	for _, ply in player.Iterator() do
		curFactions[ply:FPTeam()] = true
	end

	for _, fac in pairs( curFactions ) do
		for _, fac2 in pairs( curFactions ) do
			if FPTeams.IsEnemy( fac, fac2 ) then return false end
		end
	end


	return true
end

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
					if !checkFoundationRivalry( ply ) then return false end
					
					if ply:FPTeam() == TEAM_SCP then return false end
				end

				return testCurrentFactionsRivalry()
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
					if checkFoundationRivalry( ply ) then return false end
				end

				return testCurrentFactionsRivalry()
			end,
			callback = function()
				print( "Foundation regained control over the facility!" )
			end,
		},
		[5] = {
			lang = "unknown_fate",
			check = function( plys )
				return ( testCurrentFactionsRivalry() and ROUNDPROP.Get( "support_count" ) > 1 ) or #player.GetAlive() == 0
			end,
			callback = function()
				print( "Fate of the facility is unknown..." )
			end,
		},
	}
}