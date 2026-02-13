local math = math
local string = string
local ScreenScale = ScreenScale
local Color = Color
local surface = surface
local render = render
local draw = draw
local net = net

local info_active = false
local info_end = 0
local info_mult = 0

local info_tbl = {}

hook.Add( "HUDPaint", "InfoPopup", function()
	if CurTime() >= info_end then
		info_active = false
	end

	if info_active then
		info_mult = math.min( info_mult + .01, 1 )
	else
		info_mult = math.max( info_mult - .01, 0 )
	end

	if info_mult == 0 then return end

	local info_eased = math.ease.OutCirc( info_mult )

	local width = ScrW()/3*2
	local text, font, clr, ugap, ugap, lgap
	local tw, th

	local totalH, totalW = 0, 0
	local StartY = 0

	for i, tbl in ipairs( info_tbl ) do
		text = isfunction( tbl.text ) and tbl.text() or tbl.text
		font = isfunction( tbl.font ) and tbl.font() or tbl.font
		ugap = isfunction( tbl.ugap ) and tbl.ugap() or tbl.ugap or 0
		lgap = isfunction( tbl.lgap ) and tbl.lgap() or tbl.lgap or 0

		surface.SetFont( font )

		local lines = string.Wrap( font, text, width - ScreenScale( 16 ) )

		totalH = totalH + ugap

		for _, v in ipairs( lines ) do
			tw, th = surface.GetTextSize( v )

			totalH = totalH + th

			totalW = math.max( totalW, tw + ScreenScale( 16 ) )
		end

		totalH = totalH + lgap
	end

	StartY = ScrH() / 6

	draw.RoundedBox( 0, ( ScrW() - totalW * info_eased ) / 2 - ScreenScale( 1 ), StartY, ScreenScale( 1 ), totalH, color_white )
    draw.RoundedBox( 0, ( ScrW() + totalW * info_eased ) / 2, StartY, ScreenScale( 1 ), totalH, color_white )

    --[[KMASKS.Start()
        draw.RoundedBox( 0, ( ScrW() - totalW ) / 2, StartY, totalW, totalH, Color( 15, 15, 15, 225 * info_eased ) )

	    surface.SetDrawColor( Color( 0, 0, 0, 125 ) )

		for i, tbl in ipairs( info_tbl ) do
			text = isfunction( tbl.text ) and tbl.text() or tbl.text
			font = isfunction( tbl.font ) and tbl.font() or tbl.font
			ugap = isfunction( tbl.ugap ) and tbl.ugap() or tbl.ugap or 0
			lgap = isfunction( tbl.lgap ) and tbl.lgap() or tbl.lgap
			clr = isfunction( tbl.color ) and tbl.color() or tbl.color
			clr.a = 255 * info_mult

			surface.SetFont( font )
			tw, th = surface.GetTextSize( text )

			local lines = string.Wrap( font, text, width - ScreenScale( 16 ) )

			StartY = StartY + ugap

			for _, v in ipairs( lines ) do
				draw.SimpleTextOutlined( v, font, ScrW() / 2, StartY, clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, 125 * info_mult ) )
				
				StartY = StartY + th
			end

			StartY = StartY + lgap
		end
    KMASKS.Source()
        draw.RoundedBox( 0, ( ScrW() - totalW * info_eased ) / 2, StartY, totalW * info_eased, totalH, color_white )
    KMASKS.End()

    - Why is it impossible?
    - It's just not...
    - Why not, you stupid bastard?]]

    render.SetStencilEnable( true )

    render.ClearStencil()
    
    render.SetStencilTestMask( 255 )
    render.SetStencilWriteMask( 255 )

    render.SetStencilPassOperation( STENCILOPERATION_KEEP )
    render.SetStencilZFailOperation( STENCILOPERATION_KEEP )

    render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NEVER )

    render.SetStencilReferenceValue( 9 )
    render.SetStencilFailOperation( STENCILOPERATION_REPLACE )

    draw.RoundedBox( 0, ( ScrW() - totalW * info_eased ) / 2, StartY, totalW * info_eased, totalH, color_white )

    render.SetStencilFailOperation( STENCILOPERATION_KEEP )

    render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )

    draw.RoundedBox( 0, ( ScrW() - totalW ) / 2, StartY, totalW, totalH, Color( 15, 15, 15, 225 * info_eased ) )

    surface.SetDrawColor( Color( 0, 0, 0, 125 ) )

	for i, tbl in ipairs( info_tbl ) do
		text = isfunction( tbl.text ) and tbl.text() or tbl.text
		font = isfunction( tbl.font ) and tbl.font() or tbl.font
		ugap = isfunction( tbl.ugap ) and tbl.ugap() or tbl.ugap or 0
		lgap = isfunction( tbl.lgap ) and tbl.lgap() or tbl.lgap
		clr = isfunction( tbl.color ) and tbl.color() or tbl.color:Copy()
		clr.a = 255 * info_mult

		surface.SetFont( font )
		tw, th = surface.GetTextSize( text )

		local lines = string.Wrap( font, text, width - ScreenScale( 16 ) )

		StartY = StartY + ugap

		for _, v in ipairs( lines ) do
			draw.SimpleTextOutlined( v, font, ScrW() / 2, StartY, clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, 125 * info_mult ) )
			
			StartY = StartY + th
		end

		StartY = StartY + lgap
	end

	render.SetStencilEnable( false )
end )

function PopupInfo( time, tbl )
	info_tbl = tbl

	for i, v in ipairs( info_tbl ) do
		txt_tbl = info_tbl[i].text

		info_tbl[i].text = ""

		for _, t in ipairs( txt_tbl ) do
			if istable( t ) then
				local text = {}

				for _, sub in ipairs( t ) do
					text[#text + 1] = tostring( sub )
				end

				info_tbl[i].text = info_tbl[i].text .. LANG.Get( unpack( text ) )
			else
				info_tbl[i].text = info_tbl[i].text .. t
			end
		end

		info_tbl[i].ugap = ScreenScale( info_tbl[i].ugap )
		info_tbl[i].lgap = ScreenScale( info_tbl[i].lgap )

		print( info_tbl[i].text.."\n" )
	end

	info_end = CurTime() + time
	info_active = true
	info_mult = 0
end

function ClearInfoPopup()
	info_end = 0
	info_active = false
	info_mult = 0
end

net.Receive( "FPInfoPopup", function()
	local time, tbl = net.ReadFloat(), net.ReadTable( true )
	PopupInfo( time, tbl )
end )