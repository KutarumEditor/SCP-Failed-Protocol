local ents = ents
local CLASSES = CLASSES
local timer = timer


function GM:PlayerInitialSpawn( ply )
	ply:DataTables()
end

function GM:PlayerSpawn( ply )
	if !ply.InitialSpawn then
		ply.InitialSpawn = true

		ply:KillSilent()
		ply:SetupSpectator()

		return
	end

	ply:AddEFlags( EFL_NO_DAMAGE_FORCES )

	ply:SetCustomCollisionCheck( true )
	ply:SetCollisionGroup( COLLISION_GROUP_PLAYER )
end

function GM:GetFallDamage(ply, speed)
	return 0
end

function GM:OnPlayerHitGround( ply, in_water, on_floater, speed )
	if in_water or not IsValid( ply ) then return end

	local damage = ( speed - 526.5 ) * ( 100 / 396 )

	if on_floater then damage = damage / 2 end

	local ground = ply:GetGroundEntity()
	if IsValid( ground ) and ground:IsPlayer() then
		if math.floor( damage ) > 0 then
			local att = ply

			local push = ply.was_pushed
			if push then
				if math.max( push.t or 0, push.hurt or 0 ) > CurTime() - 4 then
					att = push.att
	            end
			end

			local dmg = DamageInfo()

			if att == ply then
				dmg:SetDamageType( DMG_CRUSH + DMG_PHYSGUN )
			else
	            dmg:SetDamageType( DMG_CRUSH )
			end

			dmg:SetAttacker( att )
			dmg:SetInflictor( att )
			dmg:SetDamageForce( Vector(0,0,-1) )
			dmg:SetDamage( damage )

			ground:TakeDamageInfo( dmg )
		end

		damage = damage / 3
	end

	if math.floor( damage ) > 0 then
		local dmg = DamageInfo()
		dmg:SetDamageType( DMG_FALL )
		dmg:SetAttacker (game.GetWorld() )
		dmg:SetInflictor( game.GetWorld() )
		dmg:SetDamageForce( Vector(0,0,1) )
		dmg:SetDamage( damage )

		ply:TakeDamageInfo( dmg )

		ply:EmitSound( damage > 35 and "scpfp/humans/fall_sound.wav" or "scpfp/humans/fall_sound_soft.wav" )
	end
end

function GM:AllowPlayerPickup( ply, ent )
	return false
end

local PLAYER = FindMetaTable( "Player" )

function PLAYER:CreatePlayerRagdoll()
	local body = ents.Create( "prop_ragdoll" )
	body:SetPos( self:GetPos() )
	body:SetAngles( self:GetAngles() )
	body:SetModel( self:GetModel() )
	body:SetSkin( self:GetSkin() )
	
	for i = 0, self:GetNumBodyGroups() - 1 do
		body:SetBodygroup( i, self:GetBodygroup( i ) )
	end

	body:SetOwner( self )

	body:Spawn()
	body:Activate()

	body:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
	body:CollisionRulesChanged()

	body:SetNWString( "name", self:FPName() )
	body:SetNWString( "surname", self:FPSurname() )
	body:SetNWInt( "invslots", self:GetInvSlots() )
	body:SetNWFloat( "time", CurTime() )

	local velocity = self:GetVelocity() * .25
	if ( body and IsValid( body ) ) then
		for i = 1, body:GetPhysicsObjectCount() do
			local physicsObject = body:GetPhysicsObjectNum( i )
			local boneIndex = body:TranslatePhysBoneToBone( i )
			local position, angle = self:GetBonePosition( boneIndex )
	
			if ( IsValid( physicsObject ) ) then
				physicsObject:SetPos( position )
				physicsObject:SetMass( 27.5 )
				physicsObject:SetAngles( angle )
				physicsObject:SetVelocity( velocity )
			end
		end
	end

	self:SetNWEntity( "CorpseEnt", body )

	body.Actions = {
		[1] = {
	        name = "check",
	        func = function( ply )
	        	
	        end
	    },
	}

	return body
end

function PLAYER:SetDeathReason( reason, pro_only )
	local tbl = self:GetProperty( "DeathReason", {
		default = "",
		pro = ""
	} )

	if not pro_only then
		tbl.default = reason
	end

	tbl.pro = reason

	self:SetProperty( "DeathReasonPro", tbl, true )
end

function PLAYER:Heal( hp, effs )
	self:SetHealth( math.min( self:Health() + hp, self:GetMaxHealth() ) )

	if istable( effs ) then
		for k, v in pairs( effs ) do
			self:RemoveEffect( v )
		end
	elseif isstring( effs ) then
		self:RemoveEffect( effs )
	end
end

function PLAYER:PopupInfo( time, data )
	if not IsValid( self ) or not self:IsPlayer() then return end

	net.Start( "FPInfoPopup", true )
		net.WriteTable( data, true )
		net.WriteFloat( CurTime() + time )
	net.Send( self )
end

function PLAYER:PopupStartInfo()
	self:PopupInfo( 15, {
		{
			text = { { "CLASSES", self:GetFPClass() } },
			font = "RoundStartInfoBig",
			color = FPTeams.GetColor( self:FPTeam() ),
			ugap = -8,
			lgap = 4
		},
		{
			text = { { "DESC", self:GetFPClass() } },
			font = "RoundStartInfoExtraSmall",
			color = color_white,
			ugap = -8,
			lgap = 4
		},
	} )
end

function PLAYER:HideHUD( b, instant )
	local i = instant or false

	net.Ping( "HideHUD", tostring( b ).."_"..tostring( i ), self )
end

function PLAYER:PopupEndInfo()
	if not IsValid( self ) or not self:IsPlayer() then return end
	
	net.Ping( "EndRoundPopup", nil, self )
end

function PLAYER:Cleanup()
	if not IsValid( self ) or not self:IsPlayer() then return end

	self:SetParent( NULL )
	self:SetMoveType( MOVETYPE_WALK )
	self:SetExhausted( false )
	self:SetStamina( 100 )
	self:SetMaxStamina( 100 )
	self:SetSatiety( 100 )
	self:SetMaxSatiety( 100 )
	self:SetMoney( 0 )
	self:SetJob( "" )

	self:SetRenderMode( RENDERMODE_NORMAL )
	self:SetColor( Color( 255, 255, 255, 255 ) )
	self:SetSubMaterial()
	self:SetMaterial( "" )
	self:DrawShadow( false )

	self:SetSkin( 0 )
	for i = 1, self:GetNumBodyGroups() do
		self:SetBodygroup( i, 0 )
	end

	for i, v in ipairs( self:GetChildren() ) do
		if v:GetClass() == "fp_bonemerge" then
			v:Remove()
		end
	end

	self:SetDSP( 0 )
	self:SetModelScale( 1 )
	self:Freeze( false )
	self:SetNoDraw( false )
	self:SetCustomCollisionCheck( true )
	self:SetCollisionGroup( COLLISION_GROUP_PLAYER )
	self:SetSolid( SOLID_BBOX )
	self:SetCanZoom( false )
	self:Extinguish()
	self:GodDisable()
	self:SetFPArmor( "vest", nil, 0 )
	self:SetFPArmor( "helmet", nil, 0 )
	self:RemoveEffect()
	ABILITIES.Clear( self )

	self.amnesicrussian = false
end

-- ply:Setup( class, spawn_override, instant )
-- ply:Setup( class, instant )
function PLAYER:Setup( class, spawn_override, instant )
	if not IsValid( self ) or not self:IsPlayer() then return end

	local inst = instant or false
	local class_tab = CLASSES[class]
	local spawn = isvector( spawn_override ) and spawn_override or istable( class_tab.spawn ) and table.Random( class_tab.spawn ) or isvector( class_tab.spawn ) and class_tab.spawn or istable( SPAWNGROUPS[class_tab.spawngroup].spawn ) and table.Random( SPAWNGROUPS[class_tab.spawngroup].spawn ) or SPAWNGROUPS[class_tab.spawngroup].spawn
	local eyeang = self:EyeAngles()

	if isvector( spawn_override ) then
		spawn = spawn_override
	else
		inst = spawn_override

		if inst then
			spawn = self:GetPos()
		end
	end

	local n, sn = self:GeneratePersona()

	self:SetFPClass( class )
	self:SetFPTeam( class_tab.team )

	self:UnSpectate()
	self:Cleanup()

	self:Spawn()
	self:RemoveAllDecals()

	self:SetModel( istable( class_tab.model ) and table.Random( class_tab.model ) or class_tab.model )

	self:SetupHands()

	self:StripWeapons()
	self:StripAmmo()

	self:SetInvSlots( class_tab.inv_slots or 8 )

	self:Give( "fp_hands" )

	for _, v in pairs( class_tab.weps ) do
		self:Give( v )
	end

	for k, v in pairs( class_tab.ammo ) do
		self:GiveAmmo( v, k, true )
	end

	timer.Simple( .01, function()
		net.Ping( "SyncInvServerside", "", self )
	end )

	local vest, helmet = class_tab.vest, class_tab.helmet
	self:SetFPArmor( "vest", vest, vest and REGISTERED_ARMOR[vest].durability or 0 )
	self:SetFPArmor( "helmet", helmet, helmet and REGISTERED_ARMOR[helmet].durability or 0 )

	self:SetMaxHealth( class_tab.maxhp or 100 )
	self:SetHealth( class_tab.hp or 100 )

	self:SetMaxSatiety( class_tab.maxsatiety or 100 )
	self:SetSatiety( class_tab.satiety or 100 )

	self:SetMaxStamina( class_tab.maxstamina or 100 )
	self:SetStamina( class_tab.stamina or 100 )

	self:SetMoney( class_tab.start_balance or 0 )

	self:SetWalkSpeed( class_tab.walkspeed or 125 )
	self:SetCrouchedWalkSpeed( class_tab.crouchspeed or .5 )
	self:SetSlowWalkSpeed( class_tab.slowwalkspeed or 85 )
	self:SetRunSpeed( class_tab.runspeed or 225 )
	self:SetJumpPower( class_tab.jumppower or 175 )

	if isfunction( class_tab.callback ) then
		class_tab.callback( self )
	end

	if not inst then
		if !isvector( spawn ) then
			print( "Failed to assign "..class.." class" )
			print( "\nReason: No spawn info" )
			return
		end
	else
		self:SetEyeAngles( eyeang )
	end

	self:SetPos( spawn )

	net.Ping( "OnSpawnCS", "", self )

	print( "Assigned "..self:Nick().." ("..n.." "..sn..") to '"..class.."' class" )
end

function PLAYER:SetupSCP( class, instant )
	local class_tab = SCPS[class]
	local spawn = _G[class.."_SPAWN"]

	self:GeneratePersona()

	self:SetFPClass( class )
	self:SetFPTeam( TEAM_SCP )

	self:UnSpectate()
	self:Cleanup()
	
	self:Spawn()
	self:RemoveAllDecals()

	self:SetModel( istable( class_tab.model ) and table.Random( class_tab.model ) or class_tab.model )
	self:SetupHands()

	self:StripWeapons()
	self:StripAmmo()

	self:Give( class_tab.swep )
	self:SelectWeapon( class_tab.swep )

	timer.Simple( .01, function()
		net.Ping( "SyncInvServerside", "", self )
	end )

	self:SetMaxHealth( class_tab.maxhp or 100 )
	self:SetHealth( class_tab.hp or 100 )

	self:SetMaxStamina( class_tab.maxstamina or 100 )
	self:SetStamina( class_tab.stamina or 100 )

	self:SetWalkSpeed( class_tab.walkspeed or 175 )
	self:SetCrouchedWalkSpeed( class_tab.crouchspeed or .5 )
	self:SetSlowWalkSpeed( class_tab.slowwalkspeed or class_tab.walkspeed or 85 )
	self:SetRunSpeed( class_tab.runspeed or class_tab.walkspeed or 175 )
	self:SetJumpPower( class_tab.jumppower or 175 )

	if isfunction( class_tab.callback ) then
		class_tab.callback( self )
	end

	if not instant then
		if !isvector( spawn ) then
			print( "Failed to assign "..class.." class" )
			print( "\nReason: No spawn info" )
			return
		else
			self:SetPos( spawn )
		end
	end

	net.Ping( "OnSpawnCS", "", self )

	print( "Assigned "..self:Nick().." to '"..class.."' class" )
end