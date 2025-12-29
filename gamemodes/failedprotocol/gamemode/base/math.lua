function IsEven( num )
	return num % 2 == 0
end

function HUToMeters( hu )
    return hu / 39.37008
end

function WithinValues( val, min, max )
	return val >= min and val <= max
end

function LerpColor( t, clr1, clr2 )
	return Color( Lerp( t, clr1.r, clr2.r ), Lerp( t, clr1.g, clr2.g ), Lerp( t, clr1.b, clr2.b ), Lerp( t, clr1.a, clr2.a ) )
end

-- Thanks, GPT
function ClosestPointOnLine( point, lineStart, lineEnd )
    local p = Vector( point.x, point.y, point.z )
    local a = Vector( lineStart.x, lineStart.y, lineStart.z )
    local b = Vector( lineEnd.x, lineEnd.y, lineEnd.z )

    local ab = b - a

    if ab:Length() == 0 then
        return a
    end

    local ap = p - a
    local abNormalized = ab:GetNormalized()
    local projectionLength = ap:Dot( abNormalized )

    if projectionLength < 0 then
        return a
    elseif projectionLength > ab:Length() then
        return b
    end

    local closestPointOnLine = a + abNormalized * projectionLength

    return closestPointOnLine
end

function ProjectPointOnPlane( point, planeNormal, planePoint )
    local p = Vector( point.x, point.y, point.z )
    local n = Vector( planeNormal.x, planeNormal.y, planeNormal.z ):GetNormalized()
    local a = Vector( planePoint.x, planePoint.y, planePoint.z )

    local ap = p - a

    local distance = ap:Dot( n )

    local projectedPoint = p - n * distance

    return projectedPoint
end

local VECTOR = FindMetaTable( "Vector" )

function VECTOR:Copy()
    return Vector( self.x, self.y, self.z )
end