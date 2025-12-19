AddCSLuaFile()

ENT.Type = "anim"
ENT.Model = nil

function ENT:Initialize()
    if SERVER then
        self:SetModel( self.Model )
    end

    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetSolid( SOLID_NONE )
    self:SetMoveType( MOVETYPE_NONE )
    self:SetCollisionGroup( COLLISION_GROUP_NONE )

    self:DrawShadow( false )

    self:AddEffects( EF_BONEMERGE )
end

function ENT:Use( activator, caller )

end

function ENT:Draw()
    self:DrawModel()
end