local draw = draw
local vgui = vgui
local ScrW = ScrW
local ScrH = ScrH
local ScreenScale = ScreenScale
local surface = surface
local hook = hook
local tostring = tostring
local Vector = Vector
local Color = Color
local render = render
local Material = Material
local math = math
local net = net
local Angle = Angle
local Vector = Vector
local KMASKS = KMASKS

local LerpColor = LerpColor
local lply, lrag
local ft = FrameTime()

local hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudDamageIndicator"] = true,
	["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true,
	["CHudZoom"] = true,
	["CHudWeaponSelection"] = true,
	["CHUDQuickInfo"] = true,
	["CHudHistoryResource"] = true,
	["CHUDAutoAim"] = true,
	["CHudPoisonDamageIndicator"] = true,
	["CHudSquadStatus"] = true,
	["CHudTrain"] = true,
	["CHudVehicle"] = true,
	["CHudCloseCaption"] = true,
	["CHudGeiger"] = true,
	--[""] = true,
}

hook.Add( "HUDShouldDraw", "FPHideHUD", function( name )
	if ( hide[ name ] ) then
		return false
	end
end )

local vignette_mat = Material( "vignette/vignette.png" )
local hp_mat = Material( "failedprotocol/icons/health.png" )
local stam_mat = Material( "failedprotocol/icons/stamina.png" )
local armor_mat = Material( "failedprotocol/icons/armor.png" )
local disg_mat = Material( "failedprotocol/icons/disguise.png" )

local mat_tbl = {
	[TEAM_CLASSD] = Material( "failedprotocol/emblems/classd.png" ),
	[TEAM_SCI] = Material( "failedprotocol/emblems/personnel.png" ),
	[TEAM_SD] = Material( "failedprotocol/emblems/sd.png" ),
	[TEAM_MTF] = Material( "failedprotocol/emblems/ntf.png" ),
	[TEAM_GOC] = Material( "failedprotocol/emblems/goc.png" ),
	[TEAM_SPEAR] = Material( "failedprotocol/emblems/spear.png" ),
	[TEAM_GRU] = Material( "failedprotocol/emblems/gru.png" ),
	[TEAM_CI] = Material( "failedprotocol/emblems/ci.png" ),
	[TEAM_CBG] = Material( "failedprotocol/emblems/cbg.png" ),
	[TEAM_SH] = Material( "failedprotocol/emblems/sh.png" ),
	[TEAM_SCP] = Material( "failedprotocol/emblems/scp.png" ),
}

current_observer = current_observer || nil
function inspectPanel( target )
	current_observer = target

	if IsValid( INSPECT_PANEL ) then INSPECT_PANEL:Remove() end

	INSPECT_PANEL = vgui.Create("DPanel")
	INSPECT_PANEL:SetSize( 400, 150 )
	INSPECT_PANEL:SetPos( ScrW() - 500, ( ScrH() - 150 )/2 )

	INSPECT_PANEL.Think = function( self )
		if lply:FPTeam() != TEAM_SPEC or lply:GetObserverTarget() != target then
			self:Remove()
		end
	end

	local outline = 1
	function INSPECT_PANEL:Paint( w, h )
		draw.FramedBox( 0, 0, w, h, 2, 1, Color( 15, 15, 15, 225 ) )

		surface.SetDrawColor( 255, 255, 255, 255 )

		draw.SimpleText( target:Nick(), "YoFont", 140, h/2-25, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		draw.SimpleText( LANG.Get( "MISC", "class" )..": "..LANG.Get( "CLASSES", target:GetFPClass() ), "YoFont", 140, h/2+25, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	end

	local mdl = vgui.Create( "DPanel", INSPECT_PANEL )

	mdl:SetPos( 25 + outline, 75 - 50 + outline )
	mdl:SetSize( 100 - outline*2, 100 - outline*2 )

	function mdl:Paint( w, h )
		if not IsValid( current_observer ) then return end

		surface.SetMaterial( mat_tbl[current_observer:FPTeam()] )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
end

local drawTable = {
	--[[{
		mat = Material( "failedprotocol/020_horror_face.png" ),
		clr = color_white,
		time = 3,
		fade = 3,
		x = ScrW() / 2,
		y = ScrH() / 2,
		w = 256,
		h = 256
	}]]
}

local def_sprite = Material( "failedprotocol/menu_logo.png" )
function DrawSprite( data )
	local d = {}
	d.mat = data.mat or def_sprite
	d.clr = data.clr:Copy() or color_white
	d.time = data.time or 1
	d.x = data.x or ScrW() / 2
	d.y = data.y or ScrH() / 2
	d.w = data.w or 256
	d.h = data.h or 256

	local f = data.fade or 0
	d.fade = f
	d.fade_total = f

	table.insert( drawTable, d )
end

local hud_hidden = false
local hud_hide_alpha = 1

local hud_shake = 0
local alpha_death_mult = 1

local total_alpha_mult = 1 * alpha_death_mult * hud_hide_alpha

hook.Add( "FPHUD", "MainHUD", function()
	local disg = lply:GetProperty( "FPDisguise", {
		0,
		0
	} )

	local bars = {
		[2] = {	--Health
			icon = hp_mat,
			clr = Color( 65, 175, 105 ),
			curvalue = math.max( lply:Health(), 0 ),
			maxvalue = lply:GetMaxHealth(),
			show = function() return lply:FPTeam() != TEAM_SPEC end,
		},
		[1] = {	--Stamina
			icon = stam_mat,
			clr = Color( 155, 155, 155 ),
			curvalue = math.max( lply:GetStamina(), 0 ),
			maxvalue = lply:GetMaxStamina(),
			show = function() return lply:FPTeam() != TEAM_SPEC and ( lply:FPTeam() != TEAM_SCP or SCPS[lply:GetFPClass()].has_stamina == true ) end,
		},
		[3] = {	--Armor
			icon = armor_mat,
			clr = Color( 65, 105, 175 ),
			curvalue = lply:Armor(),
			maxvalue = lply:GetMaxArmor(),
			show = function() return lply:Armor() > 0 and lply:FPTeam() != TEAM_SPEC end,
		},
		[4] = {	--Disguise
			icon = disg_mat,
			clr = Color( 81, 60, 143 ),
			curvalue = disg[1] - CurTime(),
			maxvalue = disg[2],
			textoverride = function( cur, max ) return disg[1] == -1 and "∞" or tostring( math.ceil( cur ) ) end,
			show = function() return disg[1] > CurTime() or disg[1] == -1 end,
		},
	}

	local scrw = ScrW()
	local scrh = ScrH()

	--Main
	local rad = 0
	local w, h, outline, gap = ScreenScale( 120 ), ScreenScale( 10 ), 2, 1
	hud_shake = math.max( hud_shake - .1, 0 )

	local ind = 3
	local startY = scrh - h
	local randShake = 0
	local bar_height = ScreenScale( 1 )
	local bar_pos = {
		x = 8 + randShake + ind,
		y = startY - ( 8 + randShake ) - h + ind
	}
	local bar_size = {
		w = w - ind*2 + h,
		h = h*1.5 - ind*2
	}
	local outline_size = 1

	for _, bar in ipairs( bars ) do
		if bar.show() == false then continue end

		randShake = math.Rand( -hud_shake, hud_shake )
		local clr = LerpColor( .95, Color( bar.clr.r, bar.clr.g, bar.clr.b ), Color( 0, 0, 0 ) )
		clr.a = 225 * total_alpha_mult
		local text = tostring( math.ceil( bar.curvalue ) )
		local hCoef = 1
		if isnumber( bar.maxvalue ) then
			text = text.."/"..tostring( bar.maxvalue )
			hCoef = math.min( bar.curvalue / bar.maxvalue, 1 )
		end
		if bar.textoverride != nil then
			text = bar.textoverride( bar.curvalue, bar.maxvalue )
		end

		local bar_x, bar_y = 8 + randShake + ind + h, startY - ( 8 + randShake ) + ind
		local bar_w, bar_h = ( w - ind*2 ), h - ind*2
		--Icon
		surface.SetDrawColor( clr )
	    surface.DrawRect( 8 + randShake + ind, startY - ( 8 + randShake ) + ind, bar_h, bar_h )

		surface.SetDrawColor( bar.clr )
		surface.DrawRect( 8 + randShake + ind, startY - ( 8 + randShake ) + ind, outline_size, bar_h )
		surface.DrawRect( 8 + randShake + ind, startY - ( 8 + randShake ) + ind, ScreenScale( 2 ), outline_size )
		surface.DrawRect( 8 + randShake + ind, startY - ( 8 + randShake ) + ind + bar_h - outline_size, ScreenScale( 2 ), outline_size )
		surface.DrawRect( 8 + randShake + ind + bar_h - outline_size, startY - ( 8 + randShake ) + ind, outline_size, bar_h )
		surface.DrawRect( 8 + randShake + ind + bar_h - ScreenScale( 2 ), startY - ( 8 + randShake ) + ind, ScreenScale( 2 ), outline_size )
		surface.DrawRect( 8 + randShake + ind + bar_h - ScreenScale( 2 ), startY - ( 8 + randShake ) + ind + bar_h - outline_size, ScreenScale( 2 ), outline_size )

	    KMASKS.Start()
			draw.RoundedBox( rad - ind, 8 + randShake + ind + h, startY - ( 8 + randShake ) + ind + ( bar_h )/2 - bar_height/2, ( w - ind*2 ) * hCoef, bar_height, bar.clr )
			KMASKS.Source()
			surface.DrawRect( 8 + randShake + ind, startY - ( 8 + randShake ) + ind, bar_h, bar_h )
		KMASKS.End()

		surface.SetDrawColor( bar.clr.r, bar.clr.g, bar.clr.b, 255 * total_alpha_mult )
		surface.SetMaterial( bar.icon )
		surface.DrawTexturedRect( 8 + randShake + ind + outline + gap, startY - ( 8 + randShake ) + ind + outline + gap, bar_h - ( outline + gap )*2, bar_h - ( outline + gap )*2 )
		-- Main bar
		draw.RoundedBox( rad - ind, bar_x, bar_y, bar_w, bar_h, clr )

		surface.SetDrawColor( bar.clr )
		surface.DrawRect( bar_x, startY - ( 8 + randShake ) + ind, outline_size, bar_h )
		surface.DrawRect( bar_x, startY - ( 8 + randShake ) + ind, ScreenScale( 2 ), outline_size )
		surface.DrawRect( bar_x, startY - ( 8 + randShake ) + ind + bar_h - outline_size, ScreenScale( 2 ), outline_size )

		surface.DrawRect( bar_x + bar_w - outline_size, startY - ( 8 + randShake ) + ind, outline_size, bar_h )
		surface.DrawRect( bar_x + bar_w - ScreenScale( 2 ), startY - ( 8 + randShake ) + ind, ScreenScale( 2 ), outline_size )
		surface.DrawRect( bar_x + bar_w - ScreenScale( 2 ), startY - ( 8 + randShake ) + ind + bar_h - outline_size, ScreenScale( 2 ), outline_size )

		KMASKS.Start()
			surface.SetDrawColor( Color( bar.clr.r, bar.clr.g, bar.clr.b, 25 ) )

			draw.HAnimatedLines( _.."bar", ScreenScale( 4 ), 10 )

			draw.RoundedBox( rad - ind, 8 + randShake + ind + h + ScreenScale( 2 ), startY - ( 8 + randShake ) + ind + ( bar_h )/2 - bar_height/2, ( w - ind*2  - ScreenScale( 4 ) ) * hCoef, bar_height, bar.clr )
			draw.RoundedBox( rad - ind, 8 + randShake + ind + h + ScreenScale( 2 ), startY - ( 8 + randShake ) + ind + ( bar_h )/2 - bar_height/2 - outline_size, outline_size, bar_height + ScreenScale( 1 ), color_white )
			draw.RoundedBox( rad - ind, 8 + randShake + ind + h + ScreenScale( 2 ) + ( w - ind*2  - ScreenScale( 4 ) ), startY - ( 8 + randShake ) + ind + ( bar_h )/2 - bar_height/2 - outline_size, outline_size, bar_height + ScreenScale( 1 ), color_white )
	    KMASKS.Source()
		    draw.RoundedBox( rad - ind, 8 + randShake + ind + h, startY - ( 8 + randShake ) + ind, ( w - ind*2 ), bar_h, clr )
	    KMASKS.End()

	    draw.SimpleTextOutlined( text, "HUDSmall", ( 8 + randShake + ind ) + ( w - ind*2 )/2 + h, startY - ( 8 + randShake ) + h/2, Color( 255, 255, 255, 255 * total_alpha_mult ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 125 * total_alpha_mult ) )

		startY = startY - h
	end

	startY = startY + h*.5

	local bar_pos = {
		x = 8 + randShake + ind,
		y = startY - ( 8 + randShake ) - h + ind
	}
	local bar_size = {
		w = w - ind*2 + h,
		h = h*1.5 - ind*2
	}

	--Class bar
	local team_clr = FPTeams.GetColor( lply:FPTeam() )
	local clr = LerpColor( .95, Color( team_clr.r, team_clr.g, team_clr.b ), Color( 0, 0, 0 ) )
	clr.a = 225 * total_alpha_mult
	

	surface.SetDrawColor( clr )
    surface.DrawRect( bar_pos.x, bar_pos.y, bar_size.w, bar_size.h )

    KMASKS.Start()
	    surface.SetFont( "HUDNormal" )
	    local tx, ty = surface.GetTextSize( LANG.Get( "CLASSES", lply:GetFPClass() ) )

		surface.SetDrawColor( Color( team_clr.r, team_clr.g, team_clr.b, 25 ) )

		draw.HAnimatedLines( "classbar", ScreenScale( 4 ), 10 )

	    surface.SetDrawColor( team_clr )
	    surface.DrawRect( bar_pos.x, bar_pos.y, outline_size, bar_size.h )
		surface.DrawRect( bar_pos.x, bar_pos.y, ScreenScale( 2 ), outline_size )
		surface.DrawRect( bar_pos.x, bar_pos.y + bar_size.h - outline_size, ScreenScale( 2 ), outline_size )
		surface.DrawRect( bar_pos.x + bar_size.w - outline_size, bar_pos.y, outline_size, bar_size.h )
		surface.DrawRect( bar_pos.x + bar_size.w - ScreenScale( 2 ), bar_pos.y, ScreenScale( 2 ), outline_size )
		surface.DrawRect( bar_pos.x + bar_size.w - ScreenScale( 2 ), bar_pos.y + bar_size.h - outline_size, ScreenScale( 2 ), outline_size )

	    draw.SimpleTextOutlined( string.upperPlus( LANG.Get( "CLASSES", lply:GetFPClass() ) ), "HUDNormal", bar_pos.x + ( bar_size.w )/2, startY - ( 8 + randShake ) - h/1.5 + ind + (h - ind*2)/2 - ScreenScale( .5 ), Color( team_clr.r, team_clr.g, team_clr.b, team_clr.a * total_alpha_mult ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 125 * total_alpha_mult ) )
	KMASKS.Source()
	    surface.DrawRect( bar_pos.x, bar_pos.y, bar_size.w, bar_size.h )
	KMASKS.End()

    startY = startY - h*1.5

	local bar_pos = {
		x = 8 + randShake + ind,
		y = startY - ( 8 + randShake ) - h + ind
	}
	local bar_size = {
		w = w - ind*2 + h,
		h = h*1.5 - ind*2
	}

    --Name bar
    if lply:FPTeam() != TEAM_SPEC and lply:FPTeam() != TEAM_SCP then
		local clr = Color( 125, 125, 125 )
		local bg_clr = Color( 5, 5, 5 )
		bg_clr.a = 225 * total_alpha_mult

		surface.SetDrawColor( bg_clr )
	    surface.DrawRect( bar_pos.x, bar_pos.y, bar_size.w, bar_size.h )

		KMASKS.Start()
			surface.SetFont( "HUDNormal" )
			local tx, ty = surface.GetTextSize( LANG.Get( "CLASSES", lply:GetFPClass() ) )

			surface.SetDrawColor( Color( clr.r, clr.g, clr.b, 25 ) )

			draw.HAnimatedLines( "namebar", ScreenScale( 4 ), 10 )

			surface.SetDrawColor( clr )
			surface.DrawRect( bar_pos.x, bar_pos.y, outline_size, bar_size.h )
			surface.DrawRect( bar_pos.x, bar_pos.y, ScreenScale( 2 ), outline_size )
			surface.DrawRect( bar_pos.x, bar_pos.y + bar_size.h - outline_size, ScreenScale( 2 ), outline_size )
			surface.DrawRect( bar_pos.x + bar_size.w - outline_size, bar_pos.y, outline_size, bar_size.h )
			surface.DrawRect( bar_pos.x + bar_size.w - ScreenScale( 2 ), bar_pos.y, ScreenScale( 2 ), outline_size )
			surface.DrawRect( bar_pos.x + bar_size.w - ScreenScale( 2 ), bar_pos.y + bar_size.h - outline_size, ScreenScale( 2 ), outline_size )

			draw.SimpleTextOutlined( string.upperPlus( lply:FPName().." "..lply:FPSurname() ), "HUDNormal", bar_pos.x + ( bar_size.w )/2, startY - ( 8 + randShake ) - h/1.5 + ind + (h - ind*2)/2 - ScreenScale( .5 ), Color( clr.r, clr.g, clr.b, clr.a * total_alpha_mult ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 125 * total_alpha_mult ) )
		KMASKS.Source()
			surface.DrawRect( bar_pos.x, bar_pos.y, bar_size.w, bar_size.h )
		KMASKS.End()
	end
end )

function DrawFPSpectateInfo()
	if lply:FPTeam() == TEAM_SPEC then
		local ent = lply:GetObserverTarget()
		if IsValid( ent ) then
			if ent:IsPlayer() and current_observer != ent then
				inspectPanel( lply:GetObserverTarget() )
			end
		else
			current_observer = nil
		end
	end
end

function DrawFPEffects()
	local outline_size = 1
	local eff_size, eff_gap, eff_outline = ScreenScale( 12 ), ScreenScale( 4 ), ScreenScale( 2 )
	local effs = lply:GetProperty( "Effects", {} )
	local total_space = #effs * eff_size + ( #effs - 1 ) * eff_gap
	local start_pos = ( ScrH() - total_space )/2

	for k, v in pairs( effs ) do
		KMASKS.Start()
			local effclr = REGISTERED_EFFECTS[k].color
            local clr = LerpColor( .95, effclr, Color( 0, 0, 0 ) )
			clr.a = 225
			draw.RoundedBox( 0, eff_gap, start_pos, eff_size, eff_size, clr )

			surface.SetDrawColor( Color( effclr.r, effclr.g, effclr.b, 25 ) )

			draw.HAnimatedLines( k.."effect", ScreenScale( 2 ), 10 )

			surface.SetDrawColor( effclr )

			surface.DrawRect( eff_gap, start_pos, outline_size, eff_size )
			surface.DrawRect( eff_gap, start_pos, ScreenScale( 2 ), outline_size )
			surface.DrawRect( eff_gap, start_pos + eff_size - outline_size, ScreenScale( 2 ), outline_size )
			surface.DrawRect( eff_gap + eff_size - outline_size, start_pos, outline_size, eff_size )
			surface.DrawRect( eff_gap + eff_size - ScreenScale( 2 ), start_pos, ScreenScale( 2 ), outline_size )
			surface.DrawRect( eff_gap + eff_size - ScreenScale( 2 ), start_pos + eff_size - outline_size, ScreenScale( 2 ), outline_size )
			
			surface.SetDrawColor( effclr )
			surface.SetMaterial( REGISTERED_EFFECTS[k].icon )
			surface.DrawTexturedRect( eff_gap + eff_outline, start_pos + eff_outline, eff_size - eff_outline * 2, eff_size - eff_outline * 2 )
        KMASKS.Source()
            draw.RoundedBox( 0, eff_gap, start_pos, eff_size, eff_size, color_white )
        KMASKS.End()

		start_pos = start_pos + ( eff_size + eff_gap )
	end
end

function GM:HUDPaint()
	lply = lply or LocalPlayer()

	ft = FrameTime()

	if not CL_SETTINGS.Get( "fp_disable_vignette", "bool" ) then
		surface.SetDrawColor( 0, 0, 0, 75 )
		surface.SetMaterial( vignette_mat )
		surface.DrawTexturedRect( -1, -1, ScrW() + 2, ScrH() + 2 )
	end

	for i, elem in ipairs( drawTable ) do
		local clr = elem.clr
		surface.SetDrawColor( clr.r, clr.g, clr.b, clr.a * ( elem.fade / elem.fade_total ) )
		surface.SetMaterial( elem.mat )
		surface.DrawTexturedRect( elem.x, elem.y, elem.w, elem.h )

		elem.time = elem.time - ft

		if elem.time <= 0 then
			elem.fade = elem.fade - ft

			if elem.fade <= 0 then
				table.remove( drawTable, i )
			end
		end
	end

	hook.Run( "PreFPHUD" )

	if hud_hidden then
		hud_hide_alpha = math.max( 0, hud_hide_alpha - .01 )
	else
		hud_hide_alpha = math.min( 1, hud_hide_alpha + .01 )
	end

	alpha_death_mult = ( lply:Alive() or lply:FPTeam() == TEAM_SPEC ) and 1 or math.max( alpha_death_mult - ft, 0 )

	total_alpha_mult = alpha_death_mult * hud_hide_alpha

	if total_alpha_mult == 0 then return end

	if not MENU_CLOSED then return end

	hook.Run( "HUDDrawTargetID" )

	hook.Run( "FPHUD" )

	DrawFPSpectateInfo()

	DrawFPEffects()
end

local nametag_alpha_mult = 1
hook.Add( "PostPlayerDraw", "PlayerSpecInfo", function( ply )
	lply = lply or LocalPlayer()

	local dist = ply:GetPos():Distance( EyePos() )
	if lply:FPTeam() != TEAM_SPEC or lply:GetObserverTarget() == ply then return end
	if dist > 256 then return end
	if ply == lply then return end

	nametag_alpha_mult = ( 256 - dist ) / 256
	local pos = ply:GetPos() + ply:GetUp() * ( ply:OBBMaxs().z + 5 )
	local angle = ( pos - EyePos() ):GetNormalized():Angle()
	angle = Angle( 0, angle.y, 0 )
	angle:RotateAroundAxis( angle:Up(), -90 )
	angle:RotateAroundAxis( angle:Forward(), 90 )

	cam.Start3D2D( pos, angle, 0.05 )
		surface.SetFont( "NametagFont" )
		local tW, tH = surface.GetTextSize( ply:Nick().." | "..ply:FPName().." "..ply:FPSurname() )
		draw.SimpleText( ply:Nick().." | "..ply:FPName().." "..ply:FPSurname(), "NametagFont", -tW / 2, 0, Color( color_white.r, color_white.g, color_white.b, color_white.a * nametag_alpha_mult ) )
	cam.End3D2D()

	pos = pos - Vector( 0, 0, 3 )
end )

local function fullRagdollCheck( ply )
	return IsValid( lrag ) and istable( lrag:GetAttachment( lrag:LookupAttachment( "eyes" ) ) )
end

local function FirstPersonDeath( ply, oldview )
	local view = {}

	view.origin = fullRagdollCheck( ply ) and ( lrag:GetAttachment( lrag:LookupAttachment( "eyes" ) ).Pos + lrag:GetAttachment( lrag:LookupAttachment( "eyes" ) ).Ang:Forward() * -3 ) or oldview.origin
	view.angles = fullRagdollCheck( ply ) and lrag:GetAttachment( lrag:LookupAttachment( "eyes" ) ).Ang or oldview.angles
	view.fov = oldview.fov
	view.drawviewer	= true

	return view
end

CL_VIEW = {}
CL_VIEW.timeScale = GetConVar( "host_timescale" )
CL_VIEW.narcosis = false
CL_VIEW.narcosis_mult = 0
CL_VIEW.moveroll_mult = 0

CL_VIEW.bobPos = Vector(0, 0, 0)
CL_VIEW.bobAng = Angle(0, 0, 0)
local walkTimer = 0
local bobIntensity = 0

local function ApplyProceduralBob( ply, viewPos, viewAng, ft )
    local bobPos = Vector(0, 0, 0)
    local bobAng = Angle(0, 0, 0)

	if hook.Run( "FPShouldDisableBobbing", ply ) != true then
		if ply:GetMoveType() == MOVETYPE_NOCLIP or not ply:IsFlagSet( FL_ONGROUND ) or not ply:Alive() then
			bobIntensity = Lerp( ft * 5, bobIntensity, 0 )
		else
			local vel = ply:GetVelocity():Length2D()
			local runSpeed = ply:GetRunSpeed()

			if vel > 10 then
				local speedFrac = math.Clamp( vel / runSpeed, 0.2, 1.2 )
				walkTimer = walkTimer + ( ft * 10 * speedFrac * CL_VIEW.timeScale:GetFloat() * game.GetTimeScale() )
				
				local targetIntensity = speedFrac * ( ply:KeyDown( IN_SPEED ) and 1.5 or 1.0 )
				bobIntensity = Lerp( ft * 10, bobIntensity, targetIntensity )
			else
				bobIntensity = Lerp( ft * 5, bobIntensity, 0 )
			end
		end

		if bobIntensity > 0.01 then
			bobPos.z = math.sin( walkTimer * 2 ) * 1.2 * bobIntensity
			bobPos.x = math.cos( walkTimer ) * 0.8 * bobIntensity

			bobAng.p = math.sin( walkTimer * 2 ) * 0.6 * bobIntensity
			bobAng.y = math.cos( walkTimer ) * 0.4 * bobIntensity
			bobAng.r = math.sin( walkTimer ) * 0.5 * bobIntensity
		end

		CL_VIEW.bobPos = bobPos
		CL_VIEW.bobAng = bobAng
	end

	local right = viewAng:Right()
	local up = viewAng:Up()

    viewPos:Add( up * bobPos.z )
    viewPos:Add( right * bobPos.x )
    viewAng:Add( bobAng )

    return viewPos, viewAng
end

function GM:CalcView( ply, origin, angles, fov, znear, zfar )
	local lply = lply or LocalPlayer()
	local ct = CurTime()
	ft = FrameTime()
	lrag = ply:GetPlayerRagdoll()

	if not MENU_CLOSED then
		return CalcMenuView( ply, origin, angles, fov, znear, zfar )
	end

	if lply.Terminal != nil and lply.Terminal:GetUser() == lply then
		if lply:Alive() then
			return CalcTerminalView( ply, origin, angles, fov, znear, zfar )
		else
			lply.Terminal = nil
			gui.EnableScreenClicker( false )
		end
	end

	local view = {}
	view.origin		= origin
	view.angles		= angles
	view.fov		= fov
	view.znear		= znear
	view.zfar		= zfar
	view.drawviewer	= false

	if IsValid( lrag ) then
		local headBone = lrag:LookupBone( "ValveBiped.Bip01_Head1" )
		if !ply:Alive() and ply:FPTeam() != TEAM_SPEC then
			if headBone != nil then
				if fullRagdollCheck( ply ) then
					lrag:ManipulateBoneScale( headBone, Vector( 0, 0, 0 ) )
				end

				return FirstPersonDeath( ply, view )
			end
		else
			if headBone != nil then
				lrag:ManipulateBoneScale( headBone, Vector( 1, 1, 1 ) )
			end
		end
	end

	local vehicle = ply:GetVehicle()
	if IsValid( vehicle ) then return hook.Run( "CalcVehicleView", vehicle, ply, view ) end

	local weapon = ply:GetActiveWeapon()
	if IsValid( weapon ) and weapon.CalcView then
		local norig, nang, nfov, draw_viewer = weapon:CalcView( ply, origin * 1, angles * 1, fov, view )
		if norig then view.origin = norig end
		if nang then view.angles = nang end
		if nfov then view.fov = nfov end
		if draw_viewer then view.drawviewer = true end
	end

	player_manager.RunClass( ply, "CalcView", view )

	local velocity = ply:GetVelocity()
	
	if ply == GetViewEntity() and ply:Alive() then
        view.origin, view.angles = ApplyProceduralBob( ply, view.origin, view.angles, ft )
    end

	CL_VIEW.narcosis_mult = math.Clamp( CL_VIEW.narcosis_mult + ( CL_VIEW.narcosis and .001 or -.001 ), 0, 1 )

	if ply:KeyDown( IN_MOVERIGHT ) then
		CL_VIEW.moveroll_mult = math.min( 1, CL_VIEW.moveroll_mult + .05 )
	elseif ply:KeyDown( IN_MOVELEFT ) then
		CL_VIEW.moveroll_mult = math.max( -1, CL_VIEW.moveroll_mult - .05 )
	else
		if CL_VIEW.moveroll_mult > 0 then
			CL_VIEW.moveroll_mult = math.max( 0, CL_VIEW.moveroll_mult - .05 )
		else
			CL_VIEW.moveroll_mult = math.min( 0, CL_VIEW.moveroll_mult + .05 )
		end
	end

	view.angles	= view.angles + Angle( 0, 0, math.cos( ct / 2 ) * CL_VIEW.narcosis_mult ) + Angle( 0, 0, 1 * CL_VIEW.moveroll_mult )

	local fov_add = math.Clamp( Lerp( ft * 10, ply.LastFOV or 0, velocity:Length() / math.max( 205, ply:GetRunSpeed() ) * 2.5 ), 0, 20 )
	ply.LastFOV = fov_add
	view.fov = ( view.fov or fov ) - 5 + fov_add + math.sin( ct ) * 3 * CL_VIEW.narcosis_mult

	view.fov = CalcRussianFOV( view.fov )

	return view
end

local excludeBases = {
	["tfa_gun_base"] = true,
	["tfa_melee_base"] = true,
	["tfa_bash_base"] = true,
	["tfa_bow_base"] = true,
	["tfa_knife_base"] = true,
	["tfa_nade_base"] = true,
	["tfa_sword_advanced_base"] = true,
	["tfa_ins2_base"] = true,
	["tfa_fp_base"] = true,
}

function GM:CalcViewModelView( wep, vm, oldEyePos, oldEyeAng, eyePos, eyeAng )
	if !IsValid( wep ) then return end

	lply = lply or LocalPlayer()

	local vm_origin, vm_angles = eyePos, eyeAng

	local pos, ang = Vector(), Angle()
	local func = wep.GetViewModelPosition
	if func then
		pos, ang = func( wep, eyePos * 1, eyeAng * 1 )
		vm_origin = pos or vm_origin
		vm_angles = ang or vm_angles
	end

	func = wep.CalcViewModelView
	if func then
		local p, a = func( wep, vm, oldEyePos * 1, oldEyeAng * 1, eyePos * 1, eyeAng * 1 )
		vm_origin = p or vm_origin
		vm_angles = a or vm_angles
	end

	local bobMult = .75
	if excludeBases[wep.Base] == true then
		bobMult = 1
	end

	if vm:GetOwner() == lply and lply:GetMoveType() != MOVETYPE_NOCLIP and !lply:ShouldDrawLocalPlayer() then
        if CL_VIEW.bobPos and CL_VIEW.bobAng then
            vm_origin:Add( vm_angles:Up() * ( CL_VIEW.bobPos.z * bobMult ) )
            vm_origin:Add( vm_angles:Right() * ( CL_VIEW.bobPos.x * bobMult ) )
            
            vm_angles:Add( CL_VIEW.bobAng )
        end
	end

	return vm_origin, vm_angles
end

local tab = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_contrast"] = .75,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

local dmg_blur = 0

net.Receive( "DamageBlur", function()
	dmg = net.ReadFloat()

	hud_shake = math.Clamp( hud_shake + dmg, 0, 2.5 )
	dmg_blur = math.Clamp( dmg_blur + dmg, 0, 4 )
end )

local gasmask_mat = Material( "kutarum/failed_protocol/glass_overlay.png" )
local function DrawGasmask()
	DrawMaterialOverlay( "kutarum/failed_protocol/glass_overlay", 0.01 )
end

ExplosionFadeOut = 0

local lostsignal_mat = Material( "failedprotocol/signal_lost" )
local explosionFadeRatio = 0
function GM:RenderScreenspaceEffects()
	lply = lply or LocalPlayer()

	if lply:HasGasmask() then
		DrawGasmask()
	end

	if ROUNDPROP.Get( "WarheadDetonated" ) then
        surface.SetMaterial( lostsignal_mat )
        surface.SetDrawColor( color_white )
        surface.DrawTexturedRect( -1, -1, ScrW()+2, ScrH()+2 )
    end

    if CurTime() > ExplosionFadeOut then
        explosionFadeRatio = math.max( explosionFadeRatio - FrameTime() / 4, 0 )
    else
        explosionFadeRatio = 1
    end

    if explosionFadeRatio > 0 then
        local clr = Color( 255, 255, 255, 255 * explosionFadeRatio )
        surface.SetDrawColor( clr )
        surface.DrawRect( 0, 0, ScrW(), ScrH() )
    end

	tab["$pp_colour_brightness"], tab["$pp_colour_colour"] = CalcRussianScreenEffects( 0, .85 )

	DrawColorModify( tab )

	if not CL_SETTINGS.Get( "fp_disable_postfx" ) then
		DrawToyTown( 1, ScrH() / 5 )
		DrawSharpen( 1, .25 )
		DrawBloom( .75, 1, 8, 8, 1, 1, 1, 1, 1 )
	end

	dmg_blur = math.max( dmg_blur - FrameTime() * 8, 0 )

	if dmg_blur > 0 then
		DrawBokehDOF( dmg_blur, 1, 12 )
	end

	DisplayPhrases()
end

function HideHUD( bool, instant )
	hud_hidden = bool

	if instant then
		if bool then
			hud_hide_alpha = 0
		else
			hud_hide_alpha = 1
		end
	end
end

net.ReceivePing( "HideHUD", function( data )
	local tbl = string.Explode( "_", data )

	HideHUD( tobool( tbl[1] ), tobool( tbl[2] ) )
end )

function OnDeath()
	AMBIENT.TIME = 0
	AMBIENT.Restart( "sound/scpfp/ambience/death.mp3" )
end

net.ReceivePing( "ClientDeath", function()
	OnDeath()
end )

net.ReceivePing( "ClearCSData", function()
    for i, ply in ipairs( player.GetAll() ) do
    	ply.known = false
    	ply.grulocated = false
    end
end )

net.ReceivePing( "OnSpawnCS", function()
    hook.Run( "OnSpawn" )
end )

net.ReceivePing( "RoundStart", function()
	RoundStartCutscene()
end )

hook.Add( "OnSpawn", "FPFlashWindow", function()
	system.FlashWindow()
end )

concommand.Add( "remove_clientside_models", function()
	for i, v in ipairs( ents.GetAll() ) do
		if v:GetClass() == "C_BaseFlex" then
			v:Remove()
		end
	end
end )