local table = table
local math = math
local draw = draw
local surface = surface
local color_white = color_white

function draw.Circle( x, y, radius, seg )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

function table.MaxNumeric(tbl)
    if not tbl or #tbl == 0 then return nil end
    
    local maxValue = tbl[1]
    
    for i = 2, #tbl do
        if tbl[i] > maxValue then
            maxValue = tbl[i]
        end
    end
    
    return maxValue
end

local vector = FindMetaTable( "Vector" )

function vector:Copy()
	return Vector( self.x, self.y, self.z )
end

--[[-------------------------------------------------------------------------
TestVisibility
---------------------------------------------------------------------------]]
local ENTITY = FindMetaTable( "Entity" )

local visibility_trace = {}
visibility_trace.output = visibility_trace

local default_mask = bit.bor( CONTENTS_MOVEABLE, CONTENTS_OPAQUE, CONTENTS_SOLID, CONTENTS_BLOCKLOS, CONTENTS_MONSTER )
function ENTITY:TestVisibility( ply, mask, headonly, vlimit, hlimit, z_offset )
	if !IsValid( ply ) then return end
	if SERVER and !ply:TestPVS( self ) then return false end

	local dist = self:GetPos():DistToSqr( ply:GetPos() )

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

function draw.FramedBox( x, y, w, h, outline, gap, color, frame_color )
	draw.RoundedBox( 0, x, y, w, outline, frame_color or color or color_white )
	draw.RoundedBox( 0, x, y+outline, outline, h-outline*2, frame_color or color or color_white )
	draw.RoundedBox( 0, x, y+h-outline, w, outline, frame_color or color or color_white )
	draw.RoundedBox( 0, x+w-outline, y+outline, outline, h-outline*2, frame_color or color or color_white )
	draw.RoundedBox( 0, x+outline+gap, y+outline+gap, w-(outline+gap)*2, h-(outline+gap)*2, color or color_white )
end

local animLines = {}
function draw.HAnimatedLines( id, interval, speed )
	animLines[id] = animLines[id] or {}
	local lid = animLines[id]
	lid.interval = lid.interval or interval
	lid.startpos = lid.startpos or 0
	lid.curpos = lid.curpos or 0

	local s = FrameTime() * speed
	local lines = math.ceil( ScrW() / lid.interval )
	for i = 1, lines do
		local x = lid.startpos + lid.curpos
		surface.DrawLine( x, 0, x, ScrH() )
		lid.curpos = lid.curpos + lid.interval
	end
	lid.curpos = 0

	lid.startpos = lid.startpos + s

	if lid.startpos >= lid.interval then
		lid.startpos = lid.startpos - lid.interval
	end
end

function draw.VAnimatedLines( id, interval, speed )
	animLines[id] = animLines[id] or {}
	local lid = animLines[id]
	lid.interval = lid.interval or interval
	lid.startpos = lid.startpos or 0
	lid.curpos = lid.curpos or 0

	local s = FrameTime() * speed
	local lines = math.ceil( ScrH() / lid.interval )
	for i = 1, lines do
		local y = lid.startpos + lid.curpos
		surface.DrawLine( 0, y, ScrW(), y )
		lid.curpos = lid.curpos + lid.interval
	end
	lid.curpos = 0

	lid.startpos = lid.startpos + s

	if lid.startpos >= lid.interval then
		lid.startpos = lid.startpos - lid.interval
	end
end

function draw.MultiColorText( Font, x, y, xAlign, yAlign, outlinewidth, outlinecolor, ... )
	surface.SetFont( Font )
	local CurX = x
	local CurColor = nil
	local AllText = ""
	for k, v in pairs{ ... } do
		if not IsColor( v ) then
			AllText = AllText .. tostring( v )
		end
	end

	local steps = ( outlinewidth * 2 ) / 3
	if ( steps < 1 ) then steps = 1 end

	for _x = -outlinewidth, outlinewidth, steps do
		for _y = -outlinewidth, outlinewidth, steps do
			draw.SimpleText( AllText, Font, x + _x, y + _y, outlinecolor, xAlign, yAlign )
		end
	end

	local w, h = surface.GetTextSize( AllText )
	if xAlign == TEXT_ALIGN_CENTER then
		CurX = x - w / 2
	elseif xAlign == TEXT_ALIGN_RIGHT then
		CurX = x - w
	end

	if yAlign == TEXT_ALIGN_CENTER then
		y = y - h / 2
	elseif yAlign == TEXT_ALIGN_BOTTOM then
		y = y - h
	end

	for k, v in pairs{ ... } do
		if IsColor(v) then
			CurColor = v
			continue
		elseif CurColor == nil then
			CurColor = color_white
		end
		local Text = tostring( v )
		surface.SetTextColor( CurColor )
		surface.SetTextPos( CurX, y )
		surface.DrawText( Text )
		CurX = CurX + surface.GetTextSize( Text )
	end

	return AllText
end

local SHADER_MATERIAL = CreateMaterial("fp_circle_"..SysTime(), "screenspace_general", {
	["$pixshader"] = "fp_circle_shader_ps30",
	["$vertexshader"] = "fp_circle_shader_vs30",

	["$basetexture"] = "",
	["$texture1"] = "",
	["$texture2"] = "",
	["$texture3"] = "",

	["$ignorez"] = "1",
	["$vertexcolor"] = "1",
	["$vertextransform"] = "1",

	["$copyalpha"] = "0",
	["$alpha_blend_color_overlay"] = "0",
	["$alphablend"] = "1",

	["$linearwrite"] = "1",
	["$linearread_basetexture"] = "1",
	["$linearread_texture1"] = "1",
	["$linearread_texture2"] = "1",
	["$linearread_texture3"] = "1",
})

local SHADER_MATRIX = Matrix()

local function draw_circle_shader(
	x, 			y, 				size,
	radius, 	inner_radius, 	cap_radius,
	fill, 		rotation, 		outline,
	outline_r,	outline_g, 		outline_b,
	texture
)
	local angle = fill * math.pi
	local mid_r = ( radius + inner_radius ) * 0.5

	local h = ( radius - inner_radius ) * 0.5
	if cap_radius > h then cap_radius = h end

	local maxcap = angle * mid_r
	if cap_radius > maxcap then cap_radius = maxcap end

	local ratio = cap_radius / mid_r
	if ratio > 1 then ratio = 1 end

	local cap_angle = math.asin( ratio );

	local corrected_angle = angle - cap_angle * ( 1 - fill )
	if corrected_angle < 0 then corrected_angle = 0 end

	local rotation_rad = math.rad( rotation ) - math.pi - corrected_angle - cap_angle

	local r_eff = radius - cap_radius
	local i_eff = inner_radius + cap_radius
	local h_eff = (r_eff - i_eff) * 0.5

	SHADER_MATRIX:SetUnpacked(
		radius, 		cap_radius,	math.sin( rotation_rad ),		outline_r / 255,
		inner_radius, 	r_eff,		math.cos( rotation_rad ),		outline_g / 255,
		outline, 		i_eff,		math.sin( corrected_angle ), 	outline_b / 255,
		angle,			h_eff,		math.cos( corrected_angle ),	texture and 1 or 0
	)

	SHADER_MATERIAL:SetMatrix( "$viewprojmat", SHADER_MATRIX )

	surface.SetMaterial( SHADER_MATERIAL )
	surface.DrawTexturedRectUV( x, y, size, size, -0.015625, -0.015625, 1.015625, 1.015625 )
end

function FPDrawRing( x, y, radius, thickness, fill, rotation, cap_radius, outline, outline_r, outline_g, outline_b )
	if radius <= 0 or thickness <= 0 then return end

	if !cap_radius or cap_radius < 0 then cap_radius = 0 end
	if !outline or outline < 0 then outline = 0 end

	if thickness > radius then
		thickness = radius
		cap_radius = 0
	end

	fill = fill and math.Clamp( fill, 0, 1 ) or 1

	if istable(outline_r) then
		outline_g = outline_r.g
		outline_b = outline_r.b
		outline_r = outline_r.r
	end

	draw_circle_shader(
		x - radius, 	y - radius, 		radius * 2,
		radius, 		radius - thickness, cap_radius * thickness,
		fill, 			rotation or 0, 		outline,
		outline_r or 0, outline_g or 0, 	outline_b or 0
	)
end