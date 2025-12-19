local Vector = FindMetaTable( "Vector" )

function Vector:WithinZone( tbl )
	for i, v in ipairs( tbl ) do
		if self:WithinAABox( v[1], v[2] ) then
			return true
		end
	end

	return false
end