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

NEUTRALITY = {
    TEAMS = {},
    PLAYERS = {}
}

function NEUTRALITY.Reset()
    NEUTRALITY = {
        TEAMS = {},
        PLAYERS = {}
    }
end

function NEUTRALITY.Break( ply1, ply2 )
    local t1, t2 = ply1:FPTeam(), ply2:FPTeam()

    if not ply1:IsNeutral( ply2 ) then return end

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

    --TODO: Reduce karma
end

function NEUTRALITY.IsBroken( ply1, ply2 )
    local state = NEUTRALITY.TEAMS[ply1:FPTeam()].TEAMS[ply2:FPTeam()]
        or NEUTRALITY.PLAYERS[ply1].TEAMS[ply2:FPTeam()]

    return state or false
end