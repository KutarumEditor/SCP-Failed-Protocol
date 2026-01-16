MENU_CLOSED = MENU_CLOSED or false

local startButtonPressed = false
local menuButtonsDrawn = false

local bg_alpha, text_alpha = 1, 0

local MENU_POS, MENU_ANG = MENU_LOGO_POS[1] or Vector( 1780, -1635, -10 ), MENU_LOGO_POS[2] or Angle( 0, 270, 90 )

local path = MENU_CAM_PATH or {
	{
		time = 1,
		pos = Vector( -2983.405029, -2270.542725, 2943.881348 ),
		ang = Angle( 17.687763, 33.575321, 0.000000 ),
		fov = 90,
		ease = math.ease.InSine
	},
	{
		time = 2,
		pos = Vector( -1525.261597, -1599.632324, -59.687904 ),
		ang = Angle( 30.000000, 0, 0.000000 ),
		fov = 60,
		ease = nil
	},
	{
		time = 3,
		pos = Vector( 1585.577148, -1599.632324, -59.687904 ),
		ang = Angle( 10.000000, 0, 0.000000 ),
		fov = 45,
		ease = math.ease.OutBack
	},
	{
		time = 2,
		pos = Vector( 1609.152588, -1635, -78.077621 ),
		ang = Angle( -10.000000, 0, 0.000000 ),
		fov = 90
	},
}

local show_menu = false

local lerp_acceleration = .25

local lerp = 0

local curFrame, tarFrame = 1, 2

local lasc, lasn = FrameTime() / path[tarFrame].time, FrameTime() / path[tarFrame].time

local easeMethod = path[curFrame].ease
local curPos, curAng, curFov = path[curFrame].pos, path[curFrame].ang, path[curFrame].fov
local tarPos, tarAng, tarFov = path[tarFrame].pos, path[tarFrame].ang, path[tarFrame].fov

local function _openStartMenu()
	if SMENU != nil then
		SMENU:Remove()
	end

	if MMENU != nil then
		MMENU:Remove()
	end

	gui.EnableScreenClicker( true )

	local bg = vgui.Create( "DPanel", nil, "StartMenu" )
	SMENU = bg

	bg:SetPos( 0, 0 )
	bg:SetSize( ScrW(), ScrH() )
	function bg:Paint( w, h )
		if not startButtonPressed then
			bg_alpha = math.min( 1, bg_alpha + .01 )
		else
			bg_alpha = math.max( 0, bg_alpha - .01 )
		end

	    draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 215 * bg_alpha ) )
	end

	local sbut = vgui.Create( "DButton", bg )
	sbut:SetPos( 0, 0 )
	sbut:SetSize( 0, 0 )
	sbut:SetText( "" )
	function sbut:Paint( w, h )
		KMASKS.Start()
            draw.SimpleTextOutlined( LANG.Get( "MENU", "start" ), "HUDBig", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black )
        KMASKS.Source()
            draw.RoundedBox( 0, 0, ( 1 - bg_alpha ) * ( h / 2 ), w, bg_alpha * h, color_black )
        KMASKS.End()
	end
	function sbut:Think()
		surface.SetFont( "HUDBig" )
		local sbw, sbh = surface.GetTextSize( LANG.Get( "MENU", "start" ) )

		sbut:SetSize( sbw, sbh )
		sbut:Center()
	end
	function sbut:DoClick()
		gui.EnableScreenClicker( false )

		sbut:SetEnabled( false )

		surface.PlaySound( "scpfp/menu_cutscene_wind.wav" )

		curFrame, tarFrame = 1, 2

		startButtonPressed = true

		SMENU:Remove()
	end
end

local logoAlpha = .01

local logo_mat = Material( "failedprotocol/menu_logo.png", "smooth" )
local logo_size = 128

local posy = 0

local function _openMainMenu()
	gui.EnableScreenClicker( true )

	local bg = vgui.Create( "DPanel", nil, "StartMenu" )
	MMENU = bg

	bg:SetPos( 0, 0 )
	bg:SetSize( ScrW(), ScrH() )
	function bg:Paint( w, h ) end

	local sbut = vgui.Create( "DButton", bg )
	sbut:SetPos( 0, 0 )
	sbut:SetSize( 0, 0 )
	sbut:SetText( "" )
	function sbut:Paint( w, h )
		KMASKS.Start()
            draw.SimpleTextOutlined( LANG.Get( "MENU", "join" ), "HUDBig", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black )
        KMASKS.Source()
            draw.RoundedBox( 0, 0, ( 1 - logoAlpha ) * ( h / 2 ), w, logoAlpha * h, color_black )
        KMASKS.End()
	end
	function sbut:Think()
		surface.SetFont( "HUDBig" )
		local sbw, sbh = surface.GetTextSize( LANG.Get( "MENU", "join" ) )

		sbut:SetSize( sbw, sbh )
		sbut:Center()
		sbut:SetY( ScrH() / 3 * 2 )
	end
	function sbut:DoClick()
		gui.EnableScreenClicker( false )

		sbut:SetEnabled( false )

		menuButtonsDrawn = false

		surface.PlaySound( "scpfp/signal.wav" )

		LocalPlayer():ScreenFade( SCREENFADE.IN, color_white, 2.5, .5 )

		MENU_CLOSED = true

		show_menu = false
	end
end

local function logoDraw()
	if show_menu then
		logoAlpha = math.min( 1, logoAlpha + FrameTime() / 5 )
	else
		logoAlpha = math.max( 0, logoAlpha - FrameTime() / 5 )
	end

	local ease = math.ease.OutCirc( logoAlpha )

	cam.Start3D2D( MENU_POS, MENU_ANG, 1 )
		render.SetStencilEnable( true )

	    render.ClearStencil()
	    
	    render.SetStencilTestMask( 255 )
	    render.SetStencilWriteMask( 255 )

	    render.SetStencilPassOperation( STENCILOPERATION_KEEP )
	    render.SetStencilZFailOperation( STENCILOPERATION_KEEP )

	    render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NEVER )

	    render.SetStencilReferenceValue( 9 )
	    render.SetStencilFailOperation( STENCILOPERATION_REPLACE )

	    surface.SetDrawColor( color_black )
		surface.DrawRect( -logo_size/2, -logo_size/2 * ease, logo_size, logo_size * ease )

		render.SetStencilFailOperation( STENCILOPERATION_KEEP )

	    render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )

	    surface.SetMaterial( logo_mat )
		surface.SetDrawColor( color_white )
		surface.DrawTexturedRect( -logo_size/2, -logo_size/2, logo_size, logo_size )

	    render.SetStencilEnable( false )	
	cam.End3D2D()

	if MENU_CLOSED and logoAlpha == 0 then
		MMENU:Remove()

		hook.Remove( "PostDrawOpaqueRenderables", "DrawMenuLogo" )
	end
end

if not MENU_CLOSED then
	_openStartMenu()

	hook.Add( "PostDrawOpaqueRenderables", "DrawMenuLogo", logoDraw )
end

function CalcMenuView( ply, origin, angles, fov, znear, zfar )
	if startButtonPressed then
		local newlerp = lerp + FrameTime() / path[tarFrame].time

		if newlerp < 1 then
			lerp = newlerp
		else
			lerp = newlerp - 1

			curFrame = tarFrame
			tarFrame = math.min( tarFrame + 1, #path )

			curPos, curAng, curFov = path[curFrame].pos, path[curFrame].ang, path[curFrame].fov
			tarPos, tarAng, tarFov = path[tarFrame].pos, path[tarFrame].ang, path[tarFrame].fov

			easeMethod = path[curFrame].ease or nil
		end

		if tarFrame == #path and lerp > .5 then
			if not show_menu then
				_openMainMenu()
			end

			show_menu = true

			gui.EnableScreenClicker( true )
		end
	end

	local ease = easeMethod != nil and easeMethod( lerp ) or lerp

	local view = {}
	view.origin		= LerpVector( ease, curPos, tarPos )
	view.angles		= LerpAngle( ease, curAng, tarAng ) + Angle( math.sin( CurTime() / 1.5 ) / 3, math.cos( CurTime() * 2 ) / 3, math.cos( CurTime() ) / 3 )
	view.fov		= Lerp( ease, curFov, tarFov )
	view.znear		= znear
	view.zfar		= zfar
	view.drawviewer	= false

	return view
end