SWEP.Base = "fp_scp_swep_base"

SWEP.ViewModelFOV = 70
SWEP.ViewModel = "models/hunter/blocks/cube025x025x025.mdl"
SWEP.ShouldDrawVM = true
SWEP.WorldModel = "models/hunter/blocks/cube025x025x025.mdl"
SWEP.ShouldDrawWM = false
SWEP.SwayScale = 2
SWEP.BobScale = 2

SWEP.HoldType = "knife"

function SWEP:SetupDataTables()
	self:NetworkVar( "Int", 0, "Hits" )
	self:NetworkVar( "Float", 0, "NextLoop" )

	self:SetHits( 0 )
	self:SetNextLoop( 0 )
end

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
end

function SWEP:Think()
	local ft, ct = FrameTime(), CurTime()
	local owner = self.Owner

	if SERVER then
		if ct > self:GetNextLoop() then
			owner:EmitSound( "scpfp/scp/457/fireloop.wav", 60 )

			self:SetNextLoop( ct + 9.9 )
		end

		self.nextPhrase = self.nextPhrase or 0
		self.nextIgnite = self.nextIgnite or 0

		if ct > self.nextIgnite then
			for i, ply in ipairs( ents.FindInSphere( owner:GetPos() + owner:OBBCenter(), 128 ) ) do
				if !ply:IsPlayer() or ply == owner then continue end

				self.nextIgnite = ct + 1

				local dmg = DamageInfo()
				dmg:SetDamage( 4 )
				dmg:SetDamageType( DMG_BURN )
				dmg:SetInflictor( self )
				dmg:SetAttacker( owner )
				ply:TakeDamageInfo( dmg )

				ply:Burn( 3, 64, owner, 1, false, false )
				--print( ply:Nick().." BURNED!" )
			end
		end
	else
		local dlight = DynamicLight( owner:EntIndex() )
		if ( dlight ) then
			dlight.pos = owner:GetPos() + Vector( 0, 0, 32 )
			dlight.r = 255
			dlight.g = 125
			dlight.b = 0
			dlight.brightness = 3
			dlight.decay = 1000
			dlight.size = 360
			dlight.dietime = CurTime() + 1
		end
	end
end

hook.Add( "CanArmorRegen", "457PreventNaturalArmorRegen", function( ply )
	if ply:GetFPClass() == "SCP457" then
		return false
	end
end )

hook.Add( "FPPlayerFootstep", "457PreventFootsteps", function( ply )
	if ply:GetFPClass() == "SCP457" then
		return true
	end
end )