ENT.Type = "anim"
ENT.PrintName = "GOC Sniper"
ENT.Radius = 2400

function ENT:SetupDataTables()
	self:NetworkVar( "Bool", 0, "Triggered" )
	self:NetworkVar( "Bool", 1, "Aggressive" )
	self:NetworkVar( "Entity", 0, "Target" )

	self:SetTriggered( false )
	self:SetAggressive( false )
end

function ENT:Initialize()
    self:SetModel( "models/hunter/blocks/cube025x025x025.mdl" )
    self:PhysicsInit( SOLID_NONE )
    self:SetMoveType( MOVETYPE_NONE )
    self:SetSolid( SOLID_NONE )

    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end
end