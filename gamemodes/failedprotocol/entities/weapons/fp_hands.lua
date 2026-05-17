SWEP.Base = "fp_swep_base"

SWEP.ViewModel = "models/hunter/blocks/cube025x025x025.mdl"
SWEP.ShouldDrawVM = true
SWEP.WorldModel = "models/hunter/blocks/cube025x025x025.mdl"
SWEP.ShouldDrawWM = false

SWEP.AutoSwitchTo = true
SWEP.Weight = 999

SWEP.Droppable = false

SWEP.ReachDistance = 100

SWEP.CantBeCarried = {
	["player"] = true,
	["cv_pickup_point_table"] = true,
	["func_lod"] = true,
	["func_brush"] = true,
	["func_detail"] = true,
	["func_breakable"] = true,
	["func_breakable_surf"] = true,
	["func_rot_button"] = true,
	["func_button"] = true,
	["class C_BaseToggle"] = true, --clientside button
	["func_door"] = true,
	["func_door_rotating"] = true,
	["prop_door_rotating"] = true,
	["prop_dynamic"] = true,
	["cv_blood"] = true,
	["cv_armor"] = true,
	["cv_delivery_point"] = true,
	["cv_deliverer_locker"] = true,
	["cv_fading_bag"] = true,
	["fp_tesla_gate"] = true,
	["fp_tesla_killer"] = true,
	["fp_lootable"] = true,
}

function SWEP:SetupDataTables()
	self:NetworkVar( "Bool", 0, "IsCarrying" )
	self:NetworkVar( "Bool", 1, "Cuffed" )
	self:NetworkVar( "Float", 0, "UncuffTime" )
	self:NetworkVar( "Entity", 0, "Cuffer" )

	self:SetCuffed( false )
	self:SetUncuffTime( 0 )
	self:SetCuffer( nil )
end

function SWEP:Initialize()
	self:InitLang()

	self:DrawShadow( false )

	self:SetHoldType( self.HoldType )
end

function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then return end
	local owner = self.Owner

	self:SetCarrying()
	local tr = owner:GetEyeTraceNoCursor()

	if IsValid( tr.Entity ) and self:CanPickup( tr.Entity ) then
		local Dist = ( owner:GetShootPos() - tr.HitPos ):Length()

		if Dist < self.ReachDistance then
			sound.Play( "Flesh.ImpactSoft", owner:GetShootPos(), 65, math.random( 90, 110 ) )

			self:SetCarrying( tr.Entity, tr.PhysicsBone, tr.HitPos, Dist )

			tr.Entity.Touched = true
		end
	end
end

function SWEP:SecondaryAttack()
	if not IsFirstTimePredicted() then return end
	local ply = self.Owner

	local tr = ply:GetEyeTraceNoCursor()

	local ent = tr.Entity
	if IsValid( ent ) then
		if ent:IsPlayer() then
			print( ent:Health().." HP\n" )
			print( tostring( ent:GetWeapon( CLASSES[ent:GetFPClass()].hands_override or "fp_hands" ):GetCuffed() ) )
			return
		end

		ply:ChatPrint( tostring( ent:GetPos() ).." "..tostring( ent:GetAngles() ) )

		ply:ChatPrint( ent:MapCreationID(), ent:GetClass() )

		if ent:GetClass() == "prop_dynamic" then
			ply:ChatPrint( ent:GetModel() )
		end

		--ent:Remove()
	else
		if not SERVER then return end

		ply:ChatPrint( "Vector( "..tr.HitPos.x..", "..tr.HitPos.y..", "..tr.HitPos.z.." )," )
	end
end

function SWEP:GetCarrying()
	return self.CarryEnt
end

function SWEP:SetCarrying( ent, bone, pos, dist )	
	if IsValid( ent ) then
		self.CarryEnt = ent
		self.CarryBone = bone
		self.CarryDist = dist

		ent.IsBeingDragged = true

		if not ( ent:GetClass() == "prop_ragdoll" ) then
			self.CarryPos = ent:WorldToLocal( pos )
		else
			self.CarryPos = nil
		end
	else
		if IsValid( self.CarryEnt ) then
			self.CarryEnt.IsBeingDragged = false
		end

		self.CarryEnt = nil
		self.CarryBone = nil
		self.CarryPos = nil
		self.CarryDist = nil
	end
end

function SWEP:CanPickup( ent )
	if self:GetCuffed() then return false end
	if ent:IsNPC() then return false end
	if ent:IsWorld() then return false end
	local class = ent:GetClass()
	if self.CantBeCarried[class] != nil then return false end
	if CLIENT then return true end
	if ent:IsPlayerHolding() then return false end
	if IsValid( ent:GetPhysicsObject() ) and ent:GetPhysicsObject():IsMotionEnabled() then return true end

	print( "can be picked up: "..ent:GetClass() )

	return false
end

function SWEP:ApplyForce()
	if not SERVER then return end

	local target = self.Owner:GetAimVector() * self.CarryDist + self.Owner:GetShootPos() + Vector( 0, 0, 5 )
	local phys = self.CarryEnt:GetPhysicsObjectNum( self.CarryBone )

	if IsValid(phys) then
		local TargetPos = phys:GetPos()

		if self.CarryPos then
			TargetPos = self.CarryEnt:LocalToWorld(self.CarryPos)
		end

		local vec = target - TargetPos
		local len, mul = vec:Length(), self.CarryEnt:GetPhysicsObject():GetMass()

		local StandingEnt = self.Owner:GetGroundEntity()
		local StandingOn = IsValid( StandingEnt ) and ( ( StandingEnt == self.CarryEnt ) or ( StandingEnt:IsConstrained() and table.HasValue( constraint.GetAllConstrainedEntities( StandingEnt ), self.CarryEnt ) ) )
		local PlyIn = ( self.CarryEnt == self.Owner:GetVehicle() )
		if len > self.ReachDistance or StandingOn or PlyIn then
			self:SetCarrying()

			return
		end

		if self.CarryEnt:GetClass() == "prop_ragdoll" then
			mul = mul * 10
		end

		vec:Normalize()
		local plyVel = self.Owner:GetVelocity()
		local avec, velo = vec * len^1.5, phys:GetVelocity() - (plyVel * 2)
		local Force = ( avec - velo / 2 ) * mul
		local ForceNormal = Force:GetNormalized()
		local ForceMagnitude = Force:Length()
		ForceMagnitude = math.Clamp( ForceMagnitude, 0, 2000 )
		Force = ForceNormal * ForceMagnitude

		local CounterDir, CounterAmt = velo:GetNormalized(), velo:Length()

		if self.CarryPos then
			phys:ApplyForceOffset( Force, self.CarryEnt:LocalToWorld( self.CarryPos ) )
		else
			phys:ApplyForceCenter( Force )
		end

		phys:ApplyForceCenter( Vector( 0, 0, mul ) )
		phys:AddAngleVelocity( -phys:GetAngleVelocity() / 10 )
	end
end

function SWEP:Think()
	local owner = self.Owner
	if not self:GetCuffed() then
		if IsValid( owner ) and owner:KeyDown( IN_ATTACK ) then
			if IsValid( self.CarryEnt ) then
				self:ApplyForce()
			end
		elseif self.CarryEnt then
			self:SetCarrying()
		end
	end

	local holdType = "normal"
	if self.CarryEnt then
		holdType = "pistol"
	end

	if SERVER then
		self:SetHoldType( holdType )

		local cuffer = self:GetCuffer()
		if CurTime() > self:GetUncuffTime() and ( not cuffer:IsValid() or cuffer == owner or owner:GetPos():Distance( cuffer:GetPos() ) ) then
			owner:Undetain()
		end
	end
end

function SWEP:Holster( wep )
	if self:GetCuffed() then return end

	return true
end

if not CLIENT then return end

local ScreenScale = ScreenScale

local hand_default_mat = Material( "crimeville/misc/hand_default.png", "smooth" )
local hand_grab_mat = Material( "crimeville/misc/hand_grab.png", "smooth" )

function SWEP:DrawHUD()
	local ply = LocalPlayer()
	local tr = ply:GetEyeTraceNoCursor()

	if ( IsValid( tr.Entity ) and self.CantBeCarried[tr.Entity:GetClass()] != true ) or IsEntity( self:GetCarrying() ) then
		local Dist = ( ply:GetShootPos() - tr.HitPos ):Length()

		if Dist < self.ReachDistance or IsEntity( self:GetCarrying() ) then
			if IsEntity( self:GetCarrying() ) then
				surface.SetMaterial( hand_grab_mat )
			else
				surface.SetMaterial( hand_default_mat )
			end

			surface.SetDrawColor( color_white )
			surface.DrawTexturedRect( ScrW() / 2 - ScreenScale( 5 ), ScrH() / 2 - ScreenScale( 5 ), ScreenScale( 10 ), ScreenScale( 10 ) )
		end
	end

	if self:GetCuffed() then
		draw.SimpleTextOutlined( LANG.Get( "MISC", "cuffed" ), "HUDBig", ScrW() / 2, ScrH() * 4 / 7, Color( 125, 0, 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black )
	end
end