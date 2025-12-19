SWEP.Base = "fp_swep_base"

SWEP.ViewModel = "models/kutarum/crimeville/weapons/c_knife_base.mdl"
SWEP.ShouldDrawVM = true
SWEP.WorldModel = "models/kutarum/crimeville/weapons/w_kit_knife.mdl"
SWEP.ShouldDrawWM = false

SWEP.Primary.Automatic = true

SWEP.HoldType = "knife"

SWEP.Damage = { 30, 40 }

SWEP.Blood = SWEP.Blood or {}

SWEP.VElements = SWEP.VElements or {
	["knife"] = { type = "Model", model = "models/kutarum/crimeville/weapons/w_kit_knife.mdl", bone = "v_weapon.knife", rel = "", pos = Vector(0, -3.25, 0), angle = Angle(-90, 180, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
SWEP.WElements = SWEP.WElements or {
	["knife"] = { type = "Model", model = "models/kutarum/crimeville/weapons/w_kit_knife.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.5, 1.5, -4.5), angle = Angle(0, 180, 90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

function SWEP:SetupDataTables()
	self:NetworkVar( "Float", 0, "IdleTime" )
end

function SWEP:EntityFaceBack(ent)
	local angle = self.Owner:GetAngles().y - ent:GetAngles().y
	if angle < -180 then angle = 360 + angle end
	if angle <= 90 and angle >= -90 then return true end
	return false
end

function SWEP:Deploy()
	self:SendWeaponAnim( ACT_VM_DRAW )
	self:SetIdleTime( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
	
	return true
end

function SWEP:Think()
	if CurTime() >= self:GetIdleTime() then
		self:SendWeaponAnim( ACT_VM_IDLE )
		self:SetIdleTime( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
	end
end

function SWEP:PrimaryAttack()
	local ply = self:GetOwner()

	self:EmitSound( "crimeville/knife/swing"..math.random( 1, 3 )..".wav", 45, math.random( 95, 105 ), 1, CHAN_WEAPON, 0, 1, nil )

	ply:SetAnimation( PLAYER_ATTACK1 )

	self:SendWeaponAnim( ACT_VM_MISSCENTER )

	local tracedata = {}
	tracedata.start = ply:GetShootPos()
	tracedata.endpos = ply:GetShootPos() + ply:GetAimVector() * 75
	tracedata.filter = ply
	tracedata.mins =  Vector( -8 , -8 , -8 )
	tracedata.maxs =  Vector( 8 , 8 , 8 )

	if ( ply:IsPlayer() ) then
		ply:LagCompensation( true )
	end

	local tr = util.TraceHull( tracedata )

	if ( ply:IsPlayer() ) then
		ply:LagCompensation( false )
	end

	if tr.Hit then
		if IsValid( tr.Entity ) then
			self:SendWeaponAnim( ACT_VM_HITCENTER )

			local damage = util.SharedRandom( CurTime(), self.Damage[1], self.Damage[2] )

			if tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity:GetClass() == "prop_ragdoll" then
				if SERVER then
					EmitSound( "crimeville/knife/hitflesh"..math.random( 1, 2 )..".wav", self:GetPos(), self:EntIndex(), CHAN_AUTO, 1, 45, 0, math.random( 95, 105 ) )
				end

				if SERVER and tr.Entity:IsPlayer() then
					tr.Entity:ApplyEffect( "bleeding" )
				end

				if self:EntityFaceBack( tr.Entity ) then
					damage = damage * 5
				end

				if damage >= tr.Entity:Health() and tr.Entity:IsPlayer() then
					self:SendWeaponAnim( ACT_VM_SWINGHARD )
				end

				if tr.Entity:IsPlayer() then
					self.Blood[tr.Entity:UserID()] = true
				end

				self.VElements.knife.skin = 1
				self.WElements.knife.skin = 1
				self:SetSkin( 1 )
			else
				if SERVER then
					EmitSound( "crimeville/knife/hitworld"..math.random( 1, 3 )..".wav", self:GetPos(), self:EntIndex(), CHAN_AUTO, 1, 45, 0, math.random( 95, 105 ) )
				end
			end

			if SERVER then
				local dmg = DamageInfo()
				dmg:SetDamage( damage )
				dmg:SetAttacker( ply )
				dmg:SetInflictor( self )
				dmg:SetDamageType( DMG_SLASH )

				tr.Entity:TakeDamageInfo( dmg )
			end
		else
			if SERVER then
				EmitSound( "crimeville/knife/hitworld"..math.random( 1, 3 )..".wav", self:GetPos(), self:EntIndex(), CHAN_AUTO, 1, 45, 0, math.random( 95, 105 ) )
			end
		end
	end

	ply:ViewPunch( Angle( table.Random( { -1, 1 } ), table.Random( { -1, 1 } ), table.Random( { -1, 1 } ) ) )

	self:SetIdleTime( CurTime() + ply:GetViewModel():SequenceDuration() )
	self:SetNextPrimaryFire( CurTime() + .5 )
end