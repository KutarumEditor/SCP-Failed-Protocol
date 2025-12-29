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

--[[-------------------------------------------------------------------------
TestVisibility
---------------------------------------------------------------------------]]
local visibility_trace = {}
visibility_trace.output = visibility_trace

local default_mask = bit.bor( CONTENTS_MOVEABLE, CONTENTS_OPAQUE, CONTENTS_SOLID, CONTENTS_BLOCKLOS, CONTENTS_MONSTER )
function ENTITY:TestVisibility( ply, mask, headonly, vlimit, hlimit, z_offset )
	if !IsValid( ply ) then return end
	if SERVER and !ply:TestPVS( self ) then return false end

	local obb_bot, obb_top = self:GetModelBounds()
	local obb_mid = ( obb_bot + obb_top ) * 0.5

	obb_bot.x = obb_mid.x
	obb_bot.y = obb_mid.y
	obb_bot.z = obb_bot.z + 10

	obb_top.x = obb_mid.x
	obb_top.y = obb_mid.y
	obb_top.z = obb_top.z - 10

	local top, mid, bot = self:LocalToWorld( obb_top ), self:LocalToWorld( obb_mid ), self:LocalToWorld( obb_bot )

	local eyepos = ply:EyePos()
	local eyeang = ply:EyeAngles()

	local mid_z = mid:Copy()
	mid_z.z = mid_z.z + ( z_offset or 17.5 )

	local line = ( ( headonly and top or mid_z ) - eyepos ):GetNormalized()
	if vlimit != false and eyeang:Forward():Dot( line ) < 0 then return false end

	local ang = line:Angle()
	local diff = ang - eyeang
	diff:Normalize()

	if vlimit != false and ( math.abs( diff.y ) > ( hlimit or 53 ) or math.abs( diff.p ) > ( vlimit or 43 ) ) then return false end

	visibility_trace.start = eyepos
	visibility_trace.mask = mask or default_mask
	visibility_trace.filter = { self, ply }

	visibility_trace.endpos = top
	util.TraceLine( visibility_trace )

	if !visibility_trace.Hit then return true end
	if headonly then return false end

	visibility_trace.endpos = mid
	util.TraceLine( visibility_trace )

	if !visibility_trace.Hit then return true end

	visibility_trace.endpos = bot
	util.TraceLine( visibility_trace )

	return !visibility_trace.Hit
end