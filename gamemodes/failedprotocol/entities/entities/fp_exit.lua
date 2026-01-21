AddCSLuaFile()

ENT.Type = "anim"

function ENT:SetupDataTables()
    self:NetworkVar( "String", 0, "Name" )
end

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

function ENT:StartTouch( ply )
    local name = self:GetName()
    print( name )
    if ply:IsPlayer() and ply:Alive() and EXITS[name].check( ply ) then
        ply:KillSilent()
        ply:SetupSpectator( true )

        EXITS[name].callback( ply )
    end
end

function ENT:Draw()
    --
end