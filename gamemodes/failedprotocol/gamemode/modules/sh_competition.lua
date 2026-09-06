RIVALRY = {
    TEAMS = {}
}

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