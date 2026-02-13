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
	self:NetworkVar( "Float", 0, "NextScreech" )

	self:SetHits( 0 )
	self:SetNextScreech( CurTime() + 5 )
end

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
end

function SWEP:Think()
	local ft, ct = FrameTime(), CurTime()
	local owner = self.Owner

	if SERVER then
		if ct > self:GetNextScreech() then
			owner:EmitSound( "scpfp/scp/008/screech"..FPRandom( 1, 16 )..".wav", 60 )

			self:SetNextScreech( ct + FPRandom( 3, 5 ) )
		end
	end
end