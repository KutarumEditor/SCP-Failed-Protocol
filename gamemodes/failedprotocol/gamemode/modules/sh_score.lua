SCORE = SCORE or {}

local SCORE_TEAMS = {
	{ -- SCP Foundation
		teams = {
			[TEAM_SCI] = true,
			[TEAM_SD] = true,
			[TEAM_MTF] = true,
		},
		classes = {}
	},
	{ -- GOC
		teams = {
			[TEAM_GOC] = true,
		},
		classes = {}
	},
	{ -- GRU
		teams = {
			[TEAM_GRU] = true,
		},
		classes = {}
	},
	{ -- PENTAGRAM
		teams = {
			[TEAM_SPEAR] = true,
		},
		classes = {}
	},
	{ -- CI
		teams = {
			[TEAM_CI] = true,
		},
		classes = {}
	},
	{ -- CBG
		teams = {
			[TEAM_CBG] = true,
		},
		classes = {}
	},
	{ -- Anomalies
		teams = {
			[TEAM_SH] = true,
			[TEAM_SCP] = true,
		},
		classes = {}
	},
}

local PLAYER = FindMetaTable( "Player" )

function PLAYER:GetScoreTeam()
	for i, v in ipairs( SCORE_TEAMS ) do
		if v.teams[self:FPTeam()] or v.classes[self:GetFPClass()] then
			return i
		end
	end

	return nil
end

function AnnulScore()
	SCORE = {}
end

function AddScore( team, ply, count )
	if not isnumber( team ) then return end

	SCORE[team] = SCORE[team] or {}
	SCORE[team][ply] = SCORE[team][ply] or 0

	SCORE[team][ply] = SCORE[team][ply] + count
end

function GetTeamScore( team )
	local score = 0

	for k, v in pairs( SCORE[team] ) do
		score = score + v
	end

	return score
end