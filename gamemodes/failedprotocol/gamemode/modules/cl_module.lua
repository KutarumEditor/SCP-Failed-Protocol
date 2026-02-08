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
		fade = 3,
		x = ScrW() / 2,
		y = ScrH() / 2,
		w = 256,
		h = 256
	}]]
}

function DrawSprite( data )
	local d = {}
	d.mat = data.mat or Material( "failedprotocol/menu_logo.png" )
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

hook.Add( "DrawFPHUD", "MainHUD", function()
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
		if bar.textoverride != nil then
			text = bar.textoverride( bar.curvalue, bar.maxvalue )
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
	local eff_size, eff_gap, eff_outline = ScreenScale( 16 ), ScreenScale( 4 ), ScreenScale( 2 )
	local effs = lply:GetProperty( "Effects", {} )
	local total_space = #effs * eff_size + ( #effs - 1 ) * eff_gap
	local start_pos = ( ScrH() - total_space )/2

	for k, v in pairs( effs ) do
		KMASKS.Start()
            local clr = LerpColor( .9, REGISTERED_EFFECTS[k].color, Color( 15, 15, 15 ) )
			clr.a = 225
			draw.RoundedBox( 0, eff_gap, start_pos, eff_size, eff_size, clr )

			surface.SetDrawColor( Color( 0, 0, 0, 125 ) )

			surface.SetDrawColor( REGISTERED_EFFECTS[k].color )
			surface.SetMaterial( REGISTERED_EFFECTS[k].icon )
			surface.DrawTexturedRect( eff_gap + eff_outline, start_pos + eff_outline, eff_size - eff_outline * 2, eff_size - eff_outline * 2 )
        KMASKS.Source()
            draw.RoundedBox( 0, eff_gap, start_pos, eff_size, eff_size, color_white )
        KMASKS.End()

		start_pos = start_pos + ( eff_size + eff_gap )
	end
end

function DrawFPAbilities()
	local ct = CurTime()
	local abs = lply.FPAbilities or {}

	local size = ScreenScale( 20 )
	local gap = ScreenScale( 15 )
	local total_space = #abs * size + ( #abs - 1 ) * gap
	local start_pos = ( ScrW() - total_space )/2

	for k, v in pairs( abs ) do
		local name = v.name

		local ratio = math.min( 1, ( abs[k].next - ct ) / ABILITIES.REG[name].cooldown )

		local time = math.max( 0, abs[k].next - ct )
		if time > 0 then
			draw.SimpleTextOutlined( math.Round( time, time < 10 and 1 or 0 ), "HUDSmall", start_pos + size/2, ScrH() - size - gap*6/5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black )
		end

		local uses = v.uses
		if uses > -1 then
			draw.SimpleTextOutlined( uses, "HUDSmall", start_pos + size/2, ScrH() - gap*4/5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black )
		end

		KMASKS.Start()
            local clr = ABILITIES.REG[name].color
			local lerpclr = LerpColor( .9, clr, Color( 15, 15, 15 ) )
			lerpclr.a = 225
			draw.RoundedBox( 0, start_pos, ScrH() - size - gap, size, size, lerpclr )
			draw.RoundedBox( 0, start_pos, ScrH() - size - gap, size, size * ratio, Color( 5, 5, 5, 175 ) )

			local lerpclr = LerpColor( ratio, clr, Color( 45, 45, 45 ) )
			surface.SetDrawColor( lerpclr )
			surface.SetMaterial( ABILITIES.REG[name].icon )
			surface.DrawTexturedRect( start_pos + ScreenScale( 1 ), ScrH() - size - gap + ScreenScale( 1 ), size - ScreenScale( 2 ), size - ScreenScale( 2 ) )

			draw.SimpleTextOutlined( string.upper( input.GetKeyName( ABILITIES.REG[name].button ) ), "HUDMedium", start_pos + size/2, ScrH() - size/2 - gap, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black )

			draw.RoundedBox( 0, start_pos, ScrH() - size - gap, ScreenScale( 5 ), ScreenScale( 1 ), lerpclr )
			draw.RoundedBox( 0, start_pos + size - ScreenScale( 5 ), ScrH() - ScreenScale( 1 ) - gap, ScreenScale( 5 ), ScreenScale( 1 ), lerpclr )
			draw.RoundedBox( 0, start_pos, ScrH() - size - gap, ScreenScale( 1 ), ScreenScale( 5 ), lerpclr )
			draw.RoundedBox( 0, start_pos + size - ScreenScale( 1 ), ScrH() - ScreenScale( 5 ) - gap, ScreenScale( 1 ), ScreenScale( 5 ), lerpclr )
        KMASKS.Source()
            draw.RoundedBox( 0, start_pos, ScrH() - size - gap, size, size, color_white )
        KMASKS.End()

		start_pos = start_pos + ( size + gap )
	end
end

function GM:HUDPaint()
	lply = lply or LocalPlayer()

	ft = FrameTime()

	if not CL_SETTINGS.Get( "fp_disable_vignette", "bool" ) then
		surface.SetDrawColor( 0, 0, 0, 240 )
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

	hook.Run( "DrawFPHUD" )

	DrawFPSpectateInfo()

	DrawFPEffects()

	DrawFPAbilities()
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

local timeScale = GetConVar( "host_timescale" )
local viewBobTime = 0
local viewBobIntensity = 1
local originalPos = Vector()
local originalAng = Angle()
local bobEyeFocus, minFocus = 512, 128
local lastCalcViewBob = 0
local rateMul = CreateClientConVar("cl_cbob_rate", 1.0, true, false, "Multiplies the rate viewbob occurs at.", 0.1, 5)
local moveRW = false
local ISCALC = false

local function DoViewbob( ply, pos, ang, time, intensity, moveType )
	local tr = ply:GetEyeTraceNoCursor()

	if !tr or !tr.HitPos then
        return
    end

    originalAng:Set( ang )

    local sysTime = SysTime()
    local delta = math.min( sysTime - lastCalcViewBob, ft or FrameTime(), 1 / 30 )
    delta = ( delta * timeScale:GetFloat() ) * game.GetTimeScale()

    moveType = moveType or ply:GetMoveType()

    local right = vector_origin

    if moveType != MOVETYPE_LADDER then
        right = originalAng:Right()
    end

    originalPos:Set( pos )

    local up = originalAng:Up()
	local focusDist = tr.HitPos:Distance( pos )

	if focusDist <= 0 then
		local focusEnt = tr.Entity

		if !( IsValid( focusEnt ) and !focusEnt:IsWorld() ) then
			focusEnt = nil
		end

        local nextTr = util.TraceLine( {
            start = pos,
            endpos = originalAng:Forward() * 1048575,
            filter = { ply, focusEnt }
        } )

		focusDist = nextTr.HitPos:Distance( pos )
	end

	focusDist = math.max( focusDist, minFocus )
	bobEyeFocus = math.Approach( bobEyeFocus, focusDist, ( focusDist - bobEyeFocus ) * delta * 5 )

    pos:Add( up * math.sin( ( time + 0.5 ) * ( 4 * math.pi ) ) * 0.3 * intensity * -7 )
    pos:Add( right * math.sin( ( time + 0.5 ) * ( 2 * math.pi ) ) * 0.3 * intensity * -7 )

    local fw = originalAng:Forward()

    fw:Mul(bobEyeFocus)
    originalPos:Add(fw)
    originalPos:Sub(pos)

    local newAng = originalPos:GetNormalized():Angle()
    originalAng:Normalize()
    newAng:Normalize()

    local bobFac = math.Clamp( 1 - math.pow( math.abs( originalAng.p ) / 90, 3 ), 0, 1 )
    ang.y = ang.y - math.Clamp( math.AngleDifference( originalAng.y, newAng.y ), -2, 2 ) * bobFac
    ang.p = ang.p - math.Clamp( math.AngleDifference( originalAng.p, newAng.p ), -2, 2 ) * bobFac

    lastCalcViewBob = sysTime
end

local narcosis = false
local narcosis_mult = 0

local moveroll_mult = 0

local Ang0, curang, curviewbob = Angle( 0, 0, 0 ), Angle( 0, 0, 0 ), Angle( 0, 0, 0 )
function GM:CalcView( ply, origin, angles, fov, znear, zfar )
	local ct = CurTime()
	ft = FrameTime()
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

	--=======================================================================================================--
	--============================================ cBobbing code ============================================-- Thanks to TFA and this guy (https://steamcommunity.com/id/laboratorymember001)
	--=======================================================================================================--

	if ply != GetViewEntity() then
        return
    end

    local moveType = ply:GetMoveType()

    if moveType == MOVETYPE_NOCLIP or not ply:Alive() then
        return
    end

    local airWalkScale = ply:IsFlagSet( FL_ONGROUND ) and 1 or 0.2

    local runSpeed = ply:GetRunSpeed()

    local velocity = ply:GetVelocity()
    local velocityFrac = math.max( velocity:Length2D() * airWalkScale - velocity.z * 0.5, 0 )
    local rate = math.Clamp( math.sqrt( velocityFrac / runSpeed ) * 1.75, 0.15, 2 )

    viewBobTime = viewBobTime + ft * rate
    viewBobIntensity = 0.15 + velocityFrac / runSpeed

    DoViewbob( ply, origin, angles, viewBobTime, viewBobIntensity, moveType, ft )
    ISCALC = true

    --=======================================================================================================--

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

	view.angles	= view.angles + Angle( 0, 0, math.cos( ct/2 )*narcosis_mult ) + Angle( 0, 0, 1 * moveroll_mult )

	local fov_add = math.Clamp( Lerp( ft * 10, ply.LastFOV or 0, velocity:Length() / math.max( 225, ply:GetRunSpeed() ) * 2.5 ), 0, 10 )
	ply.LastFOV = fov_add
	view.fov = ( view.fov or fov ) - 5 + fov_add + math.sin( ct )*3*narcosis_mult

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
}

function GM:CalcViewModelView( wep, vm, oldEyePos, oldEyeAng, eyePos, eyeAng )
	if !IsValid( wep ) then return end

	lply = lply or LocalPlayer()

	local vm_origin, vm_angles = eyePos, eyeAng

	local pos, ang
	local func = wep.GetViewModelPosition
	if func then
		pos, ang = func( wep, eyePos * 1, eyeAng * 1 )
		vm_origin = pos or vm_origin
		vm_angles = ang or vm_angles
	end

	func = wep.CalcViewModelView
	if func then
		local pos, ang = func( wep, vm, oldEyePos * 1, oldEyeAng * 1, eyePos * 1, eyeAng * 1 )
		vm_origin = pos or vm_origin
		vm_angles = ang or vm_angles
	end

	if excludeBases[wep.Base] != true and ISCALC and vm:GetOwner() == lply and lply:GetMoveType() != MOVETYPE_NOCLIP and !lply:ShouldDrawLocalPlayer() then
		DoViewbob( lply, pos, ang, viewBobTime, viewBobIntensity )
    	ISCALC = false
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

function GM:RenderScreenspaceEffects()
	if lply:HasGasmask() then
		DrawGasmask()
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