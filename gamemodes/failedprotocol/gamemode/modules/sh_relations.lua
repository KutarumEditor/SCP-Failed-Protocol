--[[ RIVALRY SYSTEM ]]--

RIVALRY = RIVALRY or {
    TEAMS = {}
}

function RIVALRY.Reset()
    RIVALRY.TEAMS = {}
end

function RIVALRY.GetPoints( t )
    return RIVALRY.TEAMS[t] or 0
end

function RIVALRY.SetPoints( t, points )
    RIVALRY.TEAMS[t] = points
end

function RIVALRY.AddPoints( t, points )
    RIVALRY.SetPoints( t, RIVALRY.GetPoints( t ) + points )
end

function RIVALRY.CalcWinner( ... )
    local tbl, fintab = table.Pack( ... ), {}

    for i, v in ipairs( tbl ) do
        fintab[v] = RIVALRY.GetPoints( v )
    end

    table.sort( fintab, function( a, b ) return a > b end )

    return fintab[1], fintab
end

--[[ NEUTRALITY SYSTEM ]]--

NEUTRALITY = NEUTRALITY or {
    TEAMS = {},
    PLAYERS = {}
}

function NEUTRALITY.Reset()
    NEUTRALITY.TEAMS = {}
    NEUTRALITY.PLAYERS = {}
end

local function _breakPlayerNeutrality( ply1, ply2 )
    local t1, t2 = ply1:FPTeam(), ply2:FPTeam()

    NEUTRALITY.TEAMS[t1] = NEUTRALITY.TEAMS[t1] or {
        TEAMS = {},
        PLAYERS = {}
    }
    NEUTRALITY.PLAYERS[ply1] = NEUTRALITY.PLAYERS[ply1] or {
        TEAMS = {},
        PLAYERS = {}
    }
    NEUTRALITY.TEAMS[t2] = NEUTRALITY.TEAMS[t2] or {
        TEAMS = {},
        PLAYERS = {}
    }
    NEUTRALITY.PLAYERS[ply2] = NEUTRALITY.PLAYERS[ply2] or {
        TEAMS = {},
        PLAYERS = {}
    }

    if FPTeams.HasInfo( t1, FPTeams.INFO_LONER ) then
        if FPTeams.HasInfo( t2, FPTeams.INFO_LONER ) then
            NEUTRALITY.PLAYERS[ply1].PLAYERS[ply2] = true
            NEUTRALITY.PLAYERS[ply2].PLAYERS[ply1] = true
        else
            NEUTRALITY.PLAYERS[ply1].TEAMS[t2] = true
            NEUTRALITY.TEAMS[t2].PLAYERS[ply1] = true
        end
    else
        if FPTeams.HasInfo( t2, FPTeams.INFO_LONER ) then
            NEUTRALITY.TEAMS[t1].PLAYERS[ply2] = true
            NEUTRALITY.PLAYERS[ply2].TEAMS[t1] = true
        else
            NEUTRALITY.TEAMS[t1].TEAMS[t2] = true
            NEUTRALITY.TEAMS[t2].TEAMS[t1] = true
        end
    end
end

local function _breakTeamNeutrality( t1, ply2 )
    local t2 = ply2:FPTeam()

    NEUTRALITY.TEAMS[t1] = NEUTRALITY.TEAMS[t1] or {
        TEAMS = {},
        PLAYERS = {}
    }
    NEUTRALITY.TEAMS[t2] = NEUTRALITY.TEAMS[t2] or {
        TEAMS = {},
        PLAYERS = {}
    }
    NEUTRALITY.PLAYERS[ply2] = NEUTRALITY.PLAYERS[ply2] or {
        TEAMS = {},
        PLAYERS = {}
    }

    if !FPTeams.HasInfo( t1, FPTeams.INFO_LONER ) then
        if FPTeams.HasInfo( t2, FPTeams.INFO_LONER ) then
            NEUTRALITY.TEAMS[t1].PLAYERS[ply2] = true
            NEUTRALITY.PLAYERS[ply2].TEAMS[t1] = true
        else
            NEUTRALITY.TEAMS[t1].TEAMS[t2] = true
            NEUTRALITY.TEAMS[t2].TEAMS[t1] = true
        end
    end
end

function NEUTRALITY.Break( ply1, ply2 )
    for k, v in pairs( FPTeams.GetByGroup( FPTeams.GetGroup( ply1:FPTeam() ) ) ) do
        if not FPTeams.HasInfo( k, FPTeams.INFO_LONER ) then
            _breakTeamNeutrality( k, ply2 )
        end
    end

    for k, v in pairs( FPTeams.GetByGroup( FPTeams.GetGroup( ply2:FPTeam() ) ) ) do
        if not FPTeams.HasInfo( k, FPTeams.INFO_LONER ) then
            _breakTeamNeutrality( k, ply1 )
        end
    end

    if not ply1:IsNeutral( ply2 ) then return end

    _breakPlayerNeutrality( ply1, ply2 )

    if FPTeams.HasInfo( ply2:FPTeam(), FPTeams.INFO_LONER ) then
        ply1:AddKarma( -5 )
    else
        ply1:AddKarma( -25 )
    end
end

function NEUTRALITY.IsBroken( ply1, ply2 )
    local t1, t2 = ply1:FPTeam(), ply2:FPTeam()
    NEUTRALITY.TEAMS[t1] = NEUTRALITY.TEAMS[t1] or {
        TEAMS = {},
        PLAYERS = {}
    }
    NEUTRALITY.PLAYERS[ply1] = NEUTRALITY.PLAYERS[ply1] or {
        TEAMS = {},
        PLAYERS = {}
    }

    return NEUTRALITY.TEAMS[t1].TEAMS[t2]
        or NEUTRALITY.PLAYERS[ply1].TEAMS[t2]
        or NEUTRALITY.TEAMS[t1].PLAYERS[ply2]
        or NEUTRALITY.PLAYERS[ply1].PLAYERS[ply2]
        or false
end

function NEUTRALITY.IsBrokenByTeam( team1, ply2 )
    local team2 = ply2:FPTeam()
    NEUTRALITY.TEAMS[team1] = NEUTRALITY.TEAMS[team1] or {
        TEAMS = {},
        PLAYERS = {}
    }

    return NEUTRALITY.TEAMS[team1].TEAMS[team2]
        or NEUTRALITY.TEAMS[team1].PLAYERS[ply2]
        or false
end

local PLAYER = FindMetaTable( "Player" )

function PLAYER:ResetNeutrality()
    for _, ply in player.Iterator() do
        NEUTRALITY.PLAYERS[ply].PLAYERS[self] = nil
    end

    for k, v in ipairs( NEUTRALITY.TEAMS ) do
        v.PLAYERS[self] = nil
    end
end