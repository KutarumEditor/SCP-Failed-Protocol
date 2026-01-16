local draw = draw
local vgui = vgui
local ScrW = ScrW
local ScrH = ScrH
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
local lply
local lrag

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
		surface.DrawOutlinedRect( 25, h/2 - 50, 100, 100, outline )

		draw.SimpleText( target:Nick(), "YoFont", 140, h/2-25, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		draw.SimpleText( LANG.Get( "MISC", "class" )..": "..LANG.Get( "CLASSES", target:GetFPClass() ), "YoFont", 140, h/2+25, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	end

	local mdl = vgui.Create( "DModelPanel", INSPECT_PANEL )

	mdl:SetPos( 25 + outline, 75 - 50 + outline )
	mdl:SetSize( 100 - outline*2, 100 - outline*2 )

	mdl:SetModel( target:GetModel() )

	mdl.Entity:SetSkin( target:GetSkin() )

	mdl:SetFOV( 15 )

	local vec = Vector( 0, 0, -23 )

	local seq = mdl.Entity:LookupSequence( "idle" )

	mdl.LayoutEntity = function( self, ent )
		ent:SetPos(vec)
		ent:SetAngles( Angle( -5, 45, 0 ) )
	end

	for i = 0, target:GetNumBodyGroups() do
		mdl.Entity:SetBodygroup( i, target:GetBodygroup( i ) )
	end
end

local drawTable = {
	--[[{
		mat = Material( "failedprotocol/020_horror_face.png" ),
		clr = color_white,
		time = 3,
		x = ScrW() / 2,
		y = ScrH() / 2,
		w = 256,
		h = 256
	}]]
}

function DrawSprite( data )
	table.insert( drawTable, data )
end

local hud_hidden = false
local hud_hide_alpha = 1

local hud_shake = 0
local alpha_death_mult = 1

local total_alpha_mult = 1 * alpha_death_mult * hud_hide_alpha
function GM:HUDPaint()
	lply = lply or LocalPlayer()

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
			clr = Color( 95, 95, 95 ),
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
	}

	if not CL_SETTINGS.Get( "fp_disable_vignette", "bool" ) then
		surface.SetDrawColor( 0, 0, 0, 240 )
		surface.SetMaterial( vignette_mat )
		surface.DrawTexturedRect( -1, -1, ScrW() + 2, ScrH() + 2 )
	end

	for i, elem in ipairs( drawTable ) do
		surface.SetDrawColor( elem.clr )
		surface.SetMaterial( elem.mat )
		surface.DrawTexturedRect( elem.x, elem.y, elem.w, elem.h )

		elem.time = elem.time - FrameTime()

		if elem.time <= 0 then
			drawTable[i] = nil
		end
	end

	if hud_hidden then
		hud_hide_alpha = math.max( 0, hud_hide_alpha - .01 )
	else
		hud_hide_alpha = math.min( 1, hud_hide_alpha + .01 )
	end

	alpha_death_mult = ( lply:Alive() or lply:FPTeam() == TEAM_SPEC ) and 1 or math.max( alpha_death_mult - FrameTime(), 0 )

	total_alpha_mult = 1 * alpha_death_mult * hud_hide_alpha

	if total_alpha_mult == 0 then return end

	if not MENU_CLOSED then return end

	hook.Run( "HUDDrawTargetID" )

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
	for _, bar in ipairs( bars ) do
		if bar.show() == false then continue end

		randShake = math.Rand( -hud_shake, hud_shake )
		local clr = LerpColor( .9, Color( bar.clr.r, bar.clr.g, bar.clr.b ), Color( 15, 15, 15 ) )
		clr.a = 225 * total_alpha_mult
		local text = tostring( math.ceil( bar.curvalue ) )
		local hCoef = 1
		if isnumber( bar.maxvalue ) then
			text = text.."/"..tostring( bar.maxvalue )
			hCoef = math.min( bar.curvalue / bar.maxvalue, 1 )
		end
		--Icon
		surface.SetDrawColor( clr )
	    surface.DrawRect( 8 + randShake + ind, startY - ( 8 + randShake ) + ind, h - ind*2, h - ind*2 )

	    KMASKS.Start()
			draw.RoundedBox( rad - ind, 8 + randShake + ind + h, startY - ( 8 + randShake ) + ind + ( h - ind*2 )/2 - bar_height/2, ( w - ind*2 ) * hCoef, bar_height, bar.clr )
		KMASKS.Source()
		    surface.SetDrawColor( 0, 0, 0, 125 * total_alpha_mult )
			surface.DrawRect( 8 + randShake + ind, startY - ( 8 + randShake ) + ind, h - ind*2, h - ind*2 )
		KMASKS.End()

		surface.SetDrawColor( 255, 255, 255, 255 * total_alpha_mult )
		surface.SetMaterial( bar.icon )
		surface.DrawTexturedRect( 8 + randShake + ind + outline + gap, startY - ( 8 + randShake ) + ind + outline + gap, h - ind*2 - ( outline + gap )*2, h - ind*2 - ( outline + gap )*2 )
		-- Main bar
		draw.RoundedBox( rad - ind, 8 + randShake + ind + h, startY - ( 8 + randShake ) + ind, ( w - ind*2 ), h - ind*2, clr )

		KMASKS.Start()
			draw.RoundedBox( rad - ind, 8 + randShake + ind + h + ScreenScale( 2 ), startY - ( 8 + randShake ) + ind + ( h - ind*2 )/2 - bar_height/2, ( w - ind*2  - ScreenScale( 4 ) ) * hCoef, bar_height, bar.clr )
			draw.RoundedBox( rad - ind, 8 + randShake + ind + h + ScreenScale( 1 ), startY - ( 8 + randShake ) + ind + ( h - ind*2 )/2 - bar_height/2 - ScreenScale( 1 ), ScreenScale( 1 ), bar_height + ScreenScale( 2 ), color_white )
			draw.RoundedBox( rad - ind, 8 + randShake + ind + h + ScreenScale( 2 ) + ( w - ind*2  - ScreenScale( 4 ) ), startY - ( 8 + randShake ) + ind + ( h - ind*2 )/2 - bar_height/2 - ScreenScale( 1 ), ScreenScale( 1 ), bar_height + ScreenScale( 2 ), color_white )
	    KMASKS.Source()
		    draw.RoundedBox( rad - ind, 8 + randShake + ind + h, startY - ( 8 + randShake ) + ind, ( w - ind*2 ), h - ind*2, clr )
	    KMASKS.End()

	    draw.SimpleTextOutlined( text, "HUDSmall", ( 8 + randShake + ind ) + ( w - ind*2 )/2 + h, startY - ( 8 + randShake ) + h/2, Color( 255, 255, 255, 255 * total_alpha_mult ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 125 * total_alpha_mult ) )

		startY = startY - h
	end

	--Class bar
	local team_clr = FPTeams.GetColor( lply:FPTeam() )
	local clr = LerpColor( .9, Color( team_clr.r, team_clr.g, team_clr.b ), Color( 15, 15, 15 ) )
	clr.a = 225 * total_alpha_mult

	surface.SetDrawColor( clr )
    surface.DrawRect( 8 + randShake + ind, startY - ( 8 + randShake ) - h + ind, w - ind*2 + h, h*2 - ind*2 )

    KMASKS.Start()
		surface.SetDrawColor( 0, 0, 0, 125 * total_alpha_mult )

	    surface.SetFont( "HUDNormal" )
	    local tx, ty = surface.GetTextSize( LANG.Get( "CLASSES", lply:GetFPClass() ) )

	    surface.SetDrawColor( color_white )
	    surface.DrawRect( 8 + randShake + ind + ( w - ind*2 + h ) - ScreenScale( 2 ), startY - ( 8 + randShake ) - h + ind + ( h*2 - ind*2 )/2 - ty/3, ScreenScale( 1 ), ty/1.5 )
	    surface.DrawRect( 8 + randShake + ind + ScreenScale( 1 ), startY - ( 8 + randShake ) - h + ind + ( h*2 - ind*2 )/2 - ty/3, ScreenScale( 1 ), ty/1.5 )

	    draw.SimpleTextOutlined( LANG.Get( "CLASSES", lply:GetFPClass() ), "HUDNormal", ( 8 + randShake + ind ) + ( w - ind*2 + h )/2, startY - ( 8 + randShake ) - h/2 + ind + (h - ind*2)/2, Color( team_clr.r, team_clr.g, team_clr.b, team_clr.a * total_alpha_mult ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 125 * total_alpha_mult ) )
	KMASKS.Source()
	    surface.DrawRect( 8 + randShake + ind, startY - ( 8 + randShake ) - h + ind, w - ind*2 + h, h*2 - ind*2 )
	KMASKS.End()

    startY = startY - h*2

    --Name bar
    if lply:FPTeam() != TEAM_SPEC and lply:FPTeam() != TEAM_SCP then
		local clr = Color( 75, 75, 75 )
		local bg_clr = Color( 5, 5, 5 )
		bg_clr.a = 225 * total_alpha_mult

		surface.SetDrawColor( bg_clr )
	    surface.DrawRect( 8 + randShake + ind, startY - ( 8 + randShake ) - h + ind, w - ind*2 + h, h*2 - ind*2 )

	    KMASKS.Start()
			surface.SetDrawColor( 0, 0, 0, 125 * total_alpha_mult )

		    surface.SetFont( "HUDNormal" )
		    local tx, ty = surface.GetTextSize( LANG.Get( "CLASSES", lply:GetFPClass() ) )

		    surface.SetDrawColor( color_white )
		    surface.DrawRect( 8 + randShake + ind + ( w - ind*2 + h ) - ScreenScale( 2 ), startY - ( 8 + randShake ) - h + ind + ( h*2 - ind*2 )/2 - ty/3, ScreenScale( 1 ), ty/1.5 )
		    surface.DrawRect( 8 + randShake + ind + ScreenScale( 1 ), startY - ( 8 + randShake ) - h + ind + ( h*2 - ind*2 )/2 - ty/3, ScreenScale( 1 ), ty/1.5 )

		    draw.SimpleTextOutlined( lply:FPName().." "..lply:FPSurname(), "HUDNormal", ( 8 + randShake + ind ) + ( w - ind*2 + h )/2, startY - ( 8 + randShake ) - h/2 + ind + (h - ind*2)/2, Color( clr.r, clr.g, clr.b, clr.a * total_alpha_mult ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 125 * total_alpha_mult ) )
		KMASKS.Source()
		    surface.DrawRect( 8 + randShake + ind, startY - ( 8 + randShake ) - h + ind, w - ind*2 + h, h*2 - ind*2 )
		KMASKS.End()
	end

	--Spectate Info
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

local nametag_alpha_mult = 1
hook.Add( "PostPlayerDraw", "PlayerSpecInfo", function( ply )
	lply = lply or LocalPlayer()

	if lply:FPTeam() != TEAM_SPEC or lply:GetObserverTarget() == ply then return end
	if ply:GetPos():Distance( EyePos() ) > 256 then return end
	if ply == lply then return end

	nametag_alpha_mult = ( 256 - ply:GetPos():Distance( EyePos() ) ) / 256
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

local narcosis = false
local narcosis_mult = 0

local moveroll_mult = 0

local Ang0, curang, curviewbob = Angle( 0, 0, 0 ), Angle( 0, 0, 0 ), Angle( 0, 0, 0 )
function GM:CalcView( ply, origin, angles, fov, znear, zfar )
	lrag = ply:GetPlayerRagdoll()

	if not MENU_CLOSED then
		return CalcMenuView( ply, origin, angles, fov, znear, zfar )
	end

	local view = {}
	view.origin		= origin
	view.angles		= angles
	view.fov		= fov
	view.znear		= znear
	view.zfar		= zfar
	view.drawviewer	= false

	if IsValid( lrag ) then
		if !ply:Alive() and ply:FPTeam() != TEAM_SPEC then
			if fullRagdollCheck( ply ) then
				lrag:ManipulateBoneScale( lrag:LookupBone( "ValveBiped.Bip01_Head1" ), Vector( 0, 0, 0 ) )
			end

			return FirstPersonDeath( ply, view )
		else
			lrag:ManipulateBoneScale( lrag:LookupBone( "ValveBiped.Bip01_Head1" ), Vector( 1, 1, 1 ) )
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

	ws = ply:GetWalkSpeed()
	vel = ply:GetVelocity():Length()

	local intensity = 1.5

	if ply:OnGround() and vel > ws * 0.3 then
		if vel < ws * 1.2 then
			cos1 = math.cos( CurTime() * 15 )
			cos2 = math.cos( CurTime() * 12 )
			curviewbob.p = cos1 * 0.15 * intensity
			curviewbob.y = cos2 * 0.1 * intensity
		else
			cos1 = math.cos( CurTime() * 20 )
			cos2 = math.cos( CurTime() * 15 )
			curviewbob.p = cos1 * 0.25 * intensity
			curviewbob.y = cos2 * 0.15 * intensity
		end
	else
		curviewbob = LerpAngle( FrameTime() * 10, curviewbob, Ang0 )
	end

	narcosis_mult = math.Clamp( narcosis_mult + ( narcosis and .001 or -.001 ), 0, 1 )

	if ply:KeyDown( IN_MOVERIGHT ) then
		moveroll_mult = math.min( 1, moveroll_mult + .05 )
	elseif ply:KeyDown( IN_MOVELEFT ) then
		moveroll_mult = math.max( -1, moveroll_mult - .05 )
	else
		if moveroll_mult > 0 then
			moveroll_mult = math.max( 0, moveroll_mult - .05 )
		else
			moveroll_mult = math.min( 0, moveroll_mult + .05 )
		end
	end

	view.angles	= view.angles + curviewbob * 1.25 + Angle( 0, 0, math.cos( CurTime()/2 )*narcosis_mult ) + Angle( 0, 0, 1 * moveroll_mult )

	local fov_add = math.Clamp( Lerp( FrameTime() * 10, ply.LastFOV or 0, ply:GetVelocity():Length() / math.max( 225, ply:GetRunSpeed() ) * 2.5 ), 0, 10 )
	ply.LastFOV = fov_add
	view.fov = ( view.fov or fov ) - 5 + fov_add + math.sin( CurTime() )*3*narcosis_mult

	view.fov = CalcRussianFOV( view.fov )

	return view
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

function GM:RenderScreenspaceEffects()
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

net.ReceivePing( "StartRoundAmbient", function()
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