SWEP.Base = "fp_scp_swep_base"

SWEP.ViewModelFOV = 70
SWEP.ViewModel = "models/hunter/blocks/cube025x025x025.mdl"
SWEP.ShouldDrawVM = true
SWEP.WorldModel = "models/hunter/blocks/cube025x025x025.mdl"
SWEP.ShouldDrawWM = false
SWEP.SwayScale = 2
SWEP.BobScale = 2

SWEP.HoldType = "normal"

function SWEP:SetupDataTables()
	self:NetworkVar( "Float", 0, "Charge" )
	self:NetworkVar( "Float", 1, "Rage" )
	self:NetworkVar( "Float", 2, "RageBan" )
	self:NetworkVar( "Int", 0, "Kills" )
	self:NetworkVar( "Bool", 0, "Enraged" )

	self:SetCharge( 0 )
	self:SetRage( 0 )
	self:SetRageBan( 0 )
	self:SetKills( 0 )
	self:SetEnraged( false )
end

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )

	self.CalmSpeed = SCPS.SCP096.walkspeed
	self.RageSpeed = self.CalmSpeed * 4
	
	self.ChargeTime = 5
	self.RageTime = 20
	self.AdditionalRageTime = 5
	self.MaxKills = 1
	self.Victims = {}
end

function SWEP:Think()
	local ft = FrameTime()
	local owner = self.Owner

	if SERVER then
		self:ValidateVictimList()

		local charge = self:GetCharge()
		if charge == 0 then
			self:SetRage( math.max( 0, self:GetRage() - ft ) )

			if self:GetRage() > 0 and #self.Victims > 0 then
				if self:GetRageBan() == 0 and not self:GetEnraged() then
					self:BecomeAggressive()
				end
			else
				if self:GetEnraged() then
					self:BecomeCalm()
				end
			end			
		else
			self:SetCharge( math.max( 0, charge - ft ) )
		end

		self:SetRageBan( math.max( 0, self:GetRageBan() - ft ) )

		if self:GetRageBan() == 0 then
			for _, ply in player.Iterator() do
				if owner:TestVisibility( ply, nil, true, 36 ) and not FPTeams.IsAlly( TEAM_SCP, ply:FPTeam() ) and ply != owner then
					self:AddVictim( ply )
				end
			end
		end

		--print( "Charge: "..self:GetCharge(), "Rage: "..self:GetRage(), self:GetRageBan() )
		--PrintTable( self.Victims )
	end
end

function SWEP:AddVictim( ply )
	local victims = self.Victims
	for i, v in ipairs( victims ) do
		if v == ply then return end
	end

	victims[#victims + 1] = ply

	local rage = self:GetRage()
	if self:GetCharge() == 0 and rage == 0 then
		self:TriggerRage()
	else
		self:SetRage( rage + self.AdditionalRageTime )
	end
end

function SWEP:ValidateVictimList()
	for i, v in ipairs( self.Victims ) do
		if not IsValid( v ) or not v:Alive() or FPTeams.IsAlly( TEAM_SCP, v:FPTeam() ) then
			table.remove( self.Victims, i )
		end
	end
end

function SWEP:KillVictim( ply )
	for i, v in ipairs( self.Victims ) do
		if v != ply then continue end

		v:Kill()
		self:SetKills( self:GetKills() + 1 )
		table.remove( self.Victims, i )

		local calmDown = self:GetKills() >= self.MaxKills or #self.Victims == 0

		if calmDown then
			self:BecomeCalm()
		end

		self:ValidateVictimList()
	end
end

function SWEP:BecomeAggressive()
	local owner = self.Owner
	owner:Freeze( false )

	self:SetEnraged( true )

	owner:SetWalkSpeed( self.RageSpeed )
	owner:SetRunSpeed( self.RageSpeed )
end

function SWEP:BecomeCalm()
	local owner = self.Owner
	owner:Freeze( false )

	self:SetEnraged( false )

	owner:SetWalkSpeed( self.CalmSpeed )
	owner:SetRunSpeed( self.CalmSpeed )

	self:SetRageBan( 5 )

	self.Victims = {}
end

function SWEP:TriggerRage()
	self.Owner:Freeze( true )

	self:SetCharge( self.ChargeTime )
	self:SetRage( self.RageTime )
end