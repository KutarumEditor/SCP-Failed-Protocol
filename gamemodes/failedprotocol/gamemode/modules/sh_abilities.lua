local check_mat = Material( "failedprotocol/abilities/check.png" )

ABILITIES = {
	REG = {
		--[[["test_ability1"] = {
			icon = Material( "failedprotocol/icons/bleeding.png", "noclamp" ),
			color = Color( 0, 225, 0 ),
			cooldown = 3,
			uses = 3,
			button = KEY_B,
			check = function( ply )
				local tr = util.TraceLine( {
					start = ply:GetShootPos(),
					endpos = ply:GetShootPos() + ply:GetAimVector() * 100,
					filter = function( ent ) return ent:IsPlayer() and ent != ply end
				} )

				return tr.Entity != NULL
			end,
			callback = function( ply )
				ply:ChatPrint( "ПЕРЕОДЕЛИ НАХРЕН" )

				local tr = util.TraceLine( {
					start = ply:GetShootPos(),
					endpos = ply:GetShootPos() + ply:GetAimVector() * 100,
					filter = function( ent ) return ent:IsPlayer() and ent != ply end
				} )

				tr.Entity:Setup( "classd", true )

				ABILITIES.Spend( ply, "test_ability1" )
			end
		},]]
		["grucheck"] = {
			icon = check_mat,
			color = Color( 255, 125, 0 ),
			cooldown = 3,
			button = KEY_B,
			check = function( ply )
				local tr = util.TraceLine( {
					start = ply:GetShootPos(),
					endpos = ply:GetShootPos() + ply:GetAimVector() * 100,
					filter = function( ent )
						return ent:IsPlayer() and ent:Alive() and ent != ply
					end
				} )

				return tr.Entity:IsValid()
			end,
			callback = function( ply )
				local tr = util.TraceLine( {
					start = ply:GetShootPos(),
					endpos = ply:GetShootPos() + ply:GetAimVector() * 100,
					filter = function( ent ) return ent:IsPlayer() and ent != ply end
				} )

				local ent = tr.Entity
				if ent.amnesicrussian then
					ABILITIES.Remove( ply, "grucheck" )
					ABILITIES.Remove( ply, "grulocate" )

					net.Ping( "FoundRussian", tostring( ent:UserID() ), ply )

					local n = FPRandom( 1, 3 )
					PHRASES.Cast( ply, "scpfp/gruspy/found"..n..".wav", "gruspy", "found"..n )

					ent:RevealRussian( ply )
				else
					ply:FPServerMessage( Color( 255, 125, 125 ), "$MISC.gruwrongtarget" )

					net.Ping( "RemoveForGRULocator", tostring( ent:UserID() ), ply )
				end
			end
		},
		["grulocate"] = {
			icon = check_mat,
			color = Color( 215, 175, 0 ),
			cooldown = 20,
			button = KEY_N,
			check = function( ply )
				return true
			end,
			callback = function( ply )
				net.Ping( "RussianLocator", nil, ply )
			end
		}
	}
}

function ABILITIES.GetAll()
	return ABILITIES.REG
end

function ABILITIES.GetByName( ply, name )
	for _, tbl in pairs( ply.FPAbilities ) do
		if tbl.name == name then
			return _
		end
	end
end

function ABILITIES.GetByKey( ply, button )
	local tbl = {}

	for i, _ in pairs( ply.FPAbilities ) do
		if ABILITIES.REG[_.name].button == button then
			tbl[#tbl + 1] = _.name
		end
	end

	return tbl
end

if SERVER then

function ABILITIES.Sync( ply )
	net.Start( "FPAbilities" )
		net.WritePlayer( ply )
		net.WriteTable( ply.FPAbilities )
	net.Broadcast()
end

function ABILITIES.Setup( ply, name )
	ply.FPAbilities[#ply.FPAbilities + 1] = {
		name = name,
		next = 0,
		uses = ABILITIES.REG[name].uses or -1
	}

	ABILITIES.Sync( ply )
end

function ABILITIES.Remove( ply, name )
	ply.FPAbilities[ABILITIES.GetByName( ply, name )] = nil
	
	ABILITIES.Sync( ply )
end

function ABILITIES.Clear( ply )
	ply.FPAbilities = {}

	ABILITIES.Sync( ply )
end

function ABILITIES.Spend( ply, name, num )
	local eff = ABILITIES.GetByName( ply, name )
	
	if ply.FPAbilities[eff].uses > 0 then
		ply.FPAbilities[eff].uses = ply.FPAbilities[eff].uses - ( num or 1 )

		if ply.FPAbilities[eff].uses == 0 then
			ABILITIES.Remove( ply, name )
		end
	end
end

function ABILITIES.Use( ply, name )
	local ct = CurTime()

	local eff = ABILITIES.GetByName( ply, name )
	ply.FPAbilities[eff].next = ct + ABILITIES.REG[name].cooldown,

	ABILITIES.REG[name].callback( ply )

	ABILITIES.Sync( ply )
end

hook.Add( "PlayerButtonDown", "FPUseAbility", function( ply, button )
	local efftbl = ABILITIES.GetByKey( ply, button )

	for i, v in ipairs( efftbl ) do
		if ply.FPAbilities[ABILITIES.GetByName( ply, v)].next < CurTime() and ( !isfunction( ABILITIES.REG[v].check ) or ABILITIES.REG[v].check( ply ) ) then
			ABILITIES.Use( ply, v )
		end
	end
end)

else

hook.Add( "HUDPaint", "HUDAbilities", function()
	local ply = LocalPlayer()
	local abs = ply.FPAbilities or {}

	local size = ScreenScale( 20 )
	local gap = ScreenScale( 15 )
	local total_space = #abs * size + ( #abs - 1 ) * gap
	local start_pos = ( ScrW() - total_space )/2

	for k, v in pairs( abs ) do
		local name = v.name

		local ratio = math.min( 1, ( abs[k].next - CurTime() ) / ABILITIES.REG[name].cooldown )

		local time = math.max( 0, abs[k].next - CurTime() )
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
end )

net.Receive( "FPAbilities", function()
	net.ReadPlayer().FPAbilities = net.ReadTable()
end )

end