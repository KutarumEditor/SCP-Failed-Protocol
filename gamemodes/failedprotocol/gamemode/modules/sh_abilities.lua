local check_mat = Material( "failedprotocol/abilities/check.png" )

local availableForMobilization = {
	[TEAM_CLASSD] = true,
	[TEAM_SCI] = true
}

ABILITIES = {
	REG = {
		["gruspycheck"] = {
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
					ABILITIES.Remove( ply, "gruspycheck" )
					ABILITIES.Remove( ply, "gruspylocate" )

					net.Ping( "FoundRussian", tostring( ent:UserID() ), ply )

					local n = FPRandom( 1, 3 )
					PHRASES.Cast( ply, "scpfp/gruspy/found"..n..".wav", "gruspy", "found"..n )

					ply:PopupInfo( 10, {
						{
							text = { { "MISC", "grubackup" } },
							font = "RoundStartInfoExtraSmall",
							color = Color( 125, 255, 125 ),
							ugap = 0,
							lgap = 0
						}
					} )

					ent:RevealRussian( ply )
				else
					ply:PopupInfo( 5, {
						{
							text = { { "MISC", "gruwrongtarget" } },
							font = "RoundStartInfoExtraSmall",
							color = Color( 255, 125, 125 ),
							ugap = 0,
							lgap = 0
						}
					} )

					net.Ping( "RemoveForGRULocator", tostring( ent:UserID() ), ply )
				end
			end
		},
		["gruspylocate"] = {
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
		},
		["shmobilize"] = {
			icon = check_mat,
			color = Color( 0, 215, 175 ),
			cooldown = 5,
			uses = 3,
			button = KEY_N,
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
				if availableForMobilization[ent:FPTeam()] == true then
					ply:PopupInfo( 5, {
						{
							text = { { "MISC", "shmobilized" } },
							font = "RoundStartInfoExtraSmall",
							color = Color( 155, 255, 125 ),
							ugap = 0,
							lgap = 0
						}
					} )

					ent:SerpentMobilize()

					ABILITIES.Spend( ply, "shmobilize", 1 )
				else
					ply:PopupInfo( 5, {
						{
							text = { { "MISC", "shnotmobilized" } },
							font = "RoundStartInfoExtraSmall",
							color = Color( 255, 125, 125 ),
							ugap = 0,
							lgap = 0
						}
					} )
				end
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

net.Receive( "FPAbilities", function()
	net.ReadPlayer().FPAbilities = net.ReadTable()
end )

end