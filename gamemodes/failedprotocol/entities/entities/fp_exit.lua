AddCSLuaFile()

ENT.Type = "anim"

function ENT:Initialize()
    if SERVER then
        self:SetModel( "models/hunter/blocks/cube025x025x025.mdl" )
        self:SetTrigger( true )
    end

    self:SetSolid( SOLID_BBOX )
    self:SetMoveType( MOVETYPE_NONE )
    self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )

    local phys = self:GetPhysicsObject()
    if IsValid( phys ) then
        phys:Wake()
        phys:EnableMotion( false )
    end

    self:DrawShadow( false )
end

function ENT:Touch( ent )
    if ent:IsPlayer() and ent:Alive() and self:EscapeCheck( ent ) then
        ent:KillSilent()
        ent:SetupSpectator( true )

        self:EscapeCallback( ent )
    end
end

function ENT:EscapeCheck( ply )
    return true
end

function ENT:EscapeCallback( ply )
    --
end

function ENT:Draw()
    --self:DrawModel()
end