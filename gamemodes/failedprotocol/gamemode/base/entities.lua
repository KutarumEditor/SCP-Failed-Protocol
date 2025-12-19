local ENTITY = FindMetaTable( "Entity" )

--[[-------------------------------------------------------------------------
IsDerived
---------------------------------------------------------------------------]]
function ENTITY:IsDerived( class )
	local base = self
	
	repeat
		if base.ClassName == class then return true end
		if base == base.BaseClass then return false end
		
		base = base.BaseClass
	until !base

	return false
end

function ENTITY:InitVolume()
    local vec1, vec2 = self:GetModelBounds()
    local x, y, z = vec2.x - vec1.x, vec2.y - vec1.y, vec2.z - vec1.z

    return x * y * z
end

function ENTITY:Copy()
	local tbl = {}

	tbl.class = self:GetClass()
	tbl.model = self:GetModel()
	if self:IsWeapon() then
		tbl.clip = self:Clip1()
		tbl.name = self:GetPrintName()
	end

	return tbl
end