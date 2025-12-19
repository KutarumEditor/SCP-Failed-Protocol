local table = table
local math = math
local draw = draw
local surface = surface
local color_white = color_white

PARTICLE_DEBUG = false

DRAWN_PARTICLES = DRAWN_PARTICLES or {}

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

function draw.FramedBox( x, y, w, h, outline, gap, color, frame_color )
	draw.RoundedBox( 0, x, y, w, outline, frame_color or color or color_white )
	draw.RoundedBox( 0, x, y+outline, outline, h-outline*2, frame_color or color or color_white )
	draw.RoundedBox( 0, x, y+h-outline, w, outline, frame_color or color or color_white )
	draw.RoundedBox( 0, x+w-outline, y+outline, outline, h-outline*2, frame_color or color or color_white )
	draw.RoundedBox( 0, x+outline+gap, y+outline+gap, w-(outline+gap)*2, h-(outline+gap)*2, color or color_white )
end

function draw.MultiColorText( Font, x, y, xAlign, yAlign, ... )
	surface.SetFont( Font )
	local CurX = x
	local CurColor = nil
	local AllText = ""
	for k, v in pairs{ ... } do
		if not IsColor( v ) then
			AllText = AllText .. tostring( v )
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
end

DRAWN_PARTICLES.SPARKLES = DRAWN_PARTICLES.SPARKLES or {}
local SPARKLES = DRAWN_PARTICLES.SPARKLES
function DrawSparkles( id, material, x, y, w, h, dist, cooldown, lifetime, size )
	SPARKLES[id] = SPARKLES[id] or {
		cd = 0,
		sp = {}
	}

	local clr = surface.GetDrawColor()

    for _, v in pairs( SPARKLES[id].sp ) do
    	v.lt = v.lt or 0
    	v.et = v.et or 0
    	v.kt = v.kt or CurTime() + 1

    	if ( not isnumber( v.lt ) or v.lt <= 0 ) or ( not isnumber( v.et ) or v.et <= 0 ) or v.kt <= CurTime() then
    		SPARKLES[id].sp[_] = nil
    	end

    	local lerp = 1 - math.max( 0, ( v.lt / v.et ) )
    	local eased = math.ease.InCubic( lerp )

    	v.lt = v.lt - FrameTime()
    	v.kt = CurTime() + 1

    	surface.SetDrawColor( clr.r, clr.g, clr.b, Lerp( eased, clr.a, 0 ) )
    	surface.SetMaterial( material )
    	surface.DrawTexturedRect( v.x - size/2, Lerp( eased, v.y, v.y - v.d ) - size/2, size, size )
    end

    surface.SetDrawColor( clr )

    if SPARKLES[id].cd < CurTime() then
    	SPARKLES[id].cd = CurTime() + cooldown

    	local width, height = x + w, y + h

    	table.insert( SPARKLES[id].sp, {
    		et = lifetime,
    		lt = lifetime,
    		kt = CurTime() + 1,
    		x = math.random( x, width ),
    		y = math.random( y, height ),
    		d = dist,
    	} )
    end
end

hook.Add( "HUDPaint", "SparklesThink", function()
	for k, v in pairs( SPARKLES ) do
		for _, spark in pairs( SPARKLES[k].sp ) do
			if spark.kt <= CurTime() then
				SPARKLES[k].sp[_] = nil
			end
	    end
	end

	if not PARTICLE_DEBUG then return end

	local pc = 0
	for k, v in pairs( SPARKLES ) do
		for _, spark in pairs( SPARKLES[k].sp ) do
			local lerp = 1 - math.max( 0, ( spark.lt / spark.et ) )
    		local eased = math.ease.InCubic( lerp )

	    	surface.SetDrawColor( color_white )
	    	surface.DrawOutlinedRect( spark.x - 4, Lerp( eased, spark.y, spark.y - spark.d ) - 4, 8, 8 )

	    	pc = pc + 1
	    end
	end

	draw.SimpleTextOutlined( "Particles in total: "..pc, "DebugFixed", ScreenScale( 4 ), ScreenScale( 4 ), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black )
end )