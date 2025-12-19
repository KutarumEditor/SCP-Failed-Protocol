local math = math
local net = net
local surface = surface
local draw = draw
local util = util

local highlightedEnts = { -- "true" for highlighted name and outline, "false" only for highlighted name
	["fp_box"] = true,
}

local curAction, actionsCount = 1, 1

local actTbl = {}

local startAct, oldActY, newActY = 0, -1, -1

function CommitAction( ent, action )
	net.Start( "FPEntityActions" )
		net.WriteEntity( ent )
		net.WriteString( action )
	net.SendToServer()
end

hook.Add( "PlayerBindPress", "TargetActions", function( ply, bind, pressed )
	if bind == "+use" then
		local tr = LocalPlayer():GetEyeTrace()
		local ent = tr.Entity

		if IsValid( ent ) and istable( actTbl ) and istable( actTbl[curAction] ) then
			CommitAction( ent, ent.Actions[actTbl[curAction].origNum].name )
		end
	end

	if not ( actionsCount > 1 ) then return end

	if bind == "invnext" then
		curAction = curAction + 1

		surface.PlaySound( SND_CLICK )
	elseif bind == "invprev" then
		curAction = curAction - 1

		surface.PlaySound( SND_CLICK )
	end

	if curAction > actionsCount then
		curAction = 1
	elseif curAction < 1 then
		curAction = actionsCount
	end
end )

local id_alpha = 0
local id_lerp = 0
local id_target = "ERROR"
local id_ent = nil
function GM:HUDDrawTargetID()
	if not LocalPlayer():Alive() then return end
	
	local tr = util.GetPlayerTrace( LocalPlayer() )
	local trace = util.TraceLine( tr )
	local ent = trace.Entity
	if trace.Hit and ( ent:IsPlayer() and LocalPlayer():EyePos():Distance( trace.HitPos ) <= 200 and LocalPlayer():Alive() or ( highlightedEnts[ent:GetClass()] != nil or
	( ent:GetClass() == "prop_ragdoll" and ent:GetNWString( "name" ) ) ) and LocalPlayer():EyePos():Distance( trace.HitPos ) <= 100 ) then
		id_alpha = math.min( 1, id_alpha + .01 )
		id_lerp = math.ease.OutCirc( id_alpha )

		ent.Actions = ent.Actions or istable( ENTITY_ACTIONS_OVERRIDE[ent:GetClass()] ) and ENTITY_ACTIONS_OVERRIDE[ent:GetClass()] or ent:GetClass() == "prop_ragdoll" and isstring( ent:GetNWString( "name" ) ) and {
			[1] = {
		        name = "check",
		        func = function( ply )

		        end
		    },
		} or {}

		actTbl = {}
		for i, v in ipairs( ent.Actions ) do
			if not isfunction( v.check ) or v.check( LocalPlayer(), ent ) == true then
				local tbl = v
				tbl.origNum = i

				table.insert( actTbl, tbl )
			end
		end

		actionsCount = #actTbl
	else
		id_alpha = 0
		id_lerp = 0

		curAction, actionsCount = 1, 1

		actTbl = {}
	end

	if id_alpha == 0 then return end

	local font = "HUDNormal"
	local clr = color_white

	if trace.Hit then
		if ent:IsPlayer() then
			id_target = ent.known and ( ent:FPName().." "..ent:FPSurname() ) or LANG.Get( "MISC", "unknown_person" )
			id_ent = ent

			if ( LocalPlayer():FPTeam() == TEAM_CRIM and ( ent:FPTeam() == TEAM_CRIM or ent:GetFPClass() == "informator" ) )
				or ( LocalPlayer():FPTeam() == TEAM_LAW and ent:FPTeam() == TEAM_LAW ) then
				clr = Color( 0, 255, 0 )
				ent.known = true
			elseif LocalPlayer():GetFPClass() == "informator" and ent:FPTeam() == TEAM_CRIM then
				clr = Color( 255, 0, 0 )
				ent.known = true
			end
		elseif ent:GetClass() == "prop_ragdoll" and ent:GetNWString( "name" ) then
			id_target = LANG.Get( "ENT", ent:GetClass() )
			id_ent = ent
		elseif highlightedEnts[ent:GetClass()] != nil then
			id_target = LANG.Get( "ENT", ent:GetClass() )
			id_ent = ent
		end
	end

	if not IsValid( id_ent ) then return end

	surface.SetFont( font )
	local tw, th = surface.GetTextSize( id_target )
	local pad = 15

	local MouseX, MouseY = input.GetCursorPos()

	if ( MouseX == 0 && MouseY == 0 || !vgui.CursorVisible() ) then
		MouseX = ScrW()/2
		MouseY = ScrH()/2
	end

	local end_x = MouseX + ScrW()/20 + math.sin( CurTime()/2 ) * 10
	local end_y = MouseY - ScrH()/30 + math.cos( CurTime() ) * 10

	surface.SetDrawColor( Color( clr.r, clr.g, clr.b, 255 * id_alpha ) )
	draw.NoTexture()

	local bone = id_ent:LookupBone( "ValveBiped.Bip01_Spine4" )
	local bone_pos, bone_ang

	if bone != nil then
		bone_pos, bone_ang = id_ent:GetBonePosition( bone )
	end

	local ent_center_pos = id_ent:IsPlayer() and bone != nil and bone_pos or id_ent:LocalToWorld( id_ent:OBBCenter() ) or id_ent:GetPos() or Vector( 0, 0, 0 )
	local ent_sprite_pos = ent_center_pos:ToScreen()

	draw.FramedBox( ent_sprite_pos.x-4, ent_sprite_pos.y-4, 8, 8, 1, 1, Color( clr.r, clr.g, clr.b, 255 * id_alpha ) )

	local w, h = ( tw + pad ) * id_lerp, th

	if end_x > ScrW() - w/2 then end_x = ScrW() - w/2 end
	if end_y < 0 + h then end_y = 0 + h end

	surface.DrawLine( ent_sprite_pos.x, ent_sprite_pos.y, Lerp( id_lerp, ent_sprite_pos.x, end_x ), Lerp( id_lerp, ent_sprite_pos.y, end_y ) )

	render.SetStencilEnable( true )

    render.ClearStencil()
    
    render.SetStencilTestMask( 255 )
    render.SetStencilWriteMask( 255 )

    render.SetStencilPassOperation( STENCILOPERATION_KEEP )
    render.SetStencilZFailOperation( STENCILOPERATION_KEEP )

    render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NEVER )

    render.SetStencilReferenceValue( 9 )
    render.SetStencilFailOperation( STENCILOPERATION_REPLACE )

	draw.RoundedBox( 0, Lerp( id_lerp, ent_sprite_pos.x, end_x ) - w/2, Lerp( id_lerp, ent_sprite_pos.y, end_y ) - h, w, h, LerpColor( .95, Color( clr.r, clr.g, clr.b, 200 * id_alpha ), Color( 0, 0, 0, 215 * id_alpha ) ) )
	
	render.SetStencilFailOperation( STENCILOPERATION_KEEP )

	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )

	draw.RoundedBox( 0, Lerp( id_lerp, ent_sprite_pos.x, end_x ) - w/2, Lerp( id_lerp, ent_sprite_pos.y, end_y ) - h, w, h, LerpColor( .95, Color( clr.r, clr.g, clr.b, 200 * id_alpha ), Color( 0, 0, 0, 215 * id_alpha ) ) )
	surface.SetDrawColor( Color( clr.r, clr.g, clr.b, 5 * id_alpha ) )
	draw.SimpleText( id_target, font, Lerp( id_lerp, ent_sprite_pos.x, end_x ), Lerp( id_lerp, ent_sprite_pos.y, end_y ), Color( clr.r, clr.g, clr.b, 255 * id_alpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

	draw.RoundedBox( 0, Lerp( id_lerp, ent_sprite_pos.x, end_x ) - w/2, Lerp( id_lerp, ent_sprite_pos.y, end_y ) - h, ScreenScale( 1 ), h, Color( clr.r, clr.g, clr.b, 255 * id_alpha ) )
	draw.RoundedBox( 0, Lerp( id_lerp, ent_sprite_pos.x, end_x ) + w/2 - ScreenScale( 1 ), Lerp( id_lerp, ent_sprite_pos.y, end_y ) - h, ScreenScale( 1 ), h, Color( clr.r, clr.g, clr.b, 255 * id_alpha ) )

	render.SetStencilEnable( false )

	draw.FramedBox( Lerp( id_lerp, ent_sprite_pos.x, end_x )-4, Lerp( id_lerp, ent_sprite_pos.y, end_y )-4, 8, 8, 1, 1, Color( clr.r, clr.g, clr.b, 255 * id_alpha ) )
	draw.FramedBox( Lerp( id_lerp, ent_sprite_pos.x, end_x )-4, Lerp( id_lerp, ent_sprite_pos.y, end_y )-4-h, 8, 8, 1, 1, Color( clr.r, clr.g, clr.b, 255 * id_alpha ) )

	if istable( actTbl ) then
		local actPosY = 0
		local startPosY = -( curAction - 1 ) * th

		if ( oldActY == -1 and newActY == -1 ) then
			oldActY = startPosY
			newActY = startPosY
		end

		local smoothActY = Lerp( math.ease.OutCirc( math.min( 1, ( SysTime() - startAct ) / .25 ) ), oldActY, newActY )

		if newActY ~= startPosY then
			if ( smoothActY ~= startPosY ) then
				newActY = smoothActY
			end

			oldActY = newActY
			startAct = SysTime()
			newActY = startPosY
		end

		for i, v in ipairs( actTbl ) do
			draw.SimpleText( LANG.Get( "ACTIONS", ent:GetClass(), v.name ), font, Lerp( id_lerp, ent_sprite_pos.x, end_x + tw/2 + ScreenScale( 4 ) ), Lerp( id_lerp, ent_sprite_pos.y, end_y + actPosY + smoothActY ), Color( clr.r, clr.g, clr.b, 255 * id_alpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
			actPosY = actPosY + th
		end
	end
end

hook.Add( "PostDrawEffects", "OutlinedItem", function()
	local item = LocalPlayer():GetEyeTrace().Entity

	local tr = util.GetPlayerTrace( LocalPlayer() )
	local trace = util.TraceLine( tr )

	local function basicCheck()
		return IsValid( LocalPlayer() ) and LocalPlayer():Alive() and IsValid( item ) and LocalPlayer():EyePos():Distance( trace.HitPos ) <= 100
	end

	if basicCheck() and ( item:IsWeapon() or highlightedEnts[item:GetClass()] ) then
		outline.Add( item, color_white, OUTLINE_MODE_VISIBLE )
	end
end )