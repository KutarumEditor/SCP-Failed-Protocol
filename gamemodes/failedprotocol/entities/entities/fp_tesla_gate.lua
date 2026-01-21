AddCSLuaFile()

ENT.Type = "anim"

function ENT:SetupDataTables()
    self:NetworkVar( "Bool", 0, "Shocking" )
    self:NetworkVar( "Float", 0, "Ban" )
    self:NetworkVar( "Float", 1, "NextShock" )

    self:SetShocking( false )
    self:SetBan( 0 )
    self:SetNextShock( CurTime() + 1 )
end

if CLIENT then

ENT.AutomaticFrameAdvance = true

end

function ENT:Initialize()
    if SERVER then
        self:SetModel( "models/kutarum/scpfp/tesla.mdl" )
        
        self.KillerShock = ents.Create( "fp_tesla_killer" )
        local shock = self.KillerShock

        shock:SetParent( self )
        shock:SetLocalPos( Vector() )
        shock:SetLocalAngles( Angle() )
        shock:Spawn()
    end

    self:SetSolid( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_NONE )
    self:SetCollisionGroup( COLLISION_GROUP_NONE )

    local phys = self:GetPhysicsObject()
    if IsValid( phys ) then
        phys:Wake()
        phys:EnableMotion( false )
    end

    self:DrawShadow( false )
end

local windinUp = false
function ENT:Think()
    local ct, ft = CurTime(), FrameTime()
    local active = false
    local pos = self:GetPos()
    for i, ply in ipairs( ents.FindInSphere( self:GetPos(), 200 ) ) do
        if ply:IsPlayer() and ply:Alive() then
            active = true
        end
    end

    if not active or self:GetBan() > ct then
        windinUp = false
        self:StopSound( "scpfp/tesla_gate/windup.wav" )

        self:SetNextShock( ct + .75 )

        self:NextThink( ct + .1 )
        return true
    elseif active then
        if not windinUp then
            windinUp = true
            if SERVER then
                self:EmitSound( "scpfp/tesla_gate/windup.wav" )
            end
        end

        if ct >= self:GetNextShock() then
            self:SetBan( ct + 1.5 )

            self:Shock()

            windinUp = false
            self:SetNextShock( ct + 1 )
        end
    end

    self:NextThink( ct + .1 )

    return true
end

function ENT:Shock()
    self:SetShocking( true )

    if SERVER then
        self:EmitSound( "scpfp/tesla_gate/shock.wav" )
    end

    timer.Simple( 1.25, function()
        if IsValid( self ) then
            self:SetShocking( false )
        end
    end )
end

if not CLIENT then return end

function ENT:Draw()
    self:DrawModel()
end

function ENT:OnRemove()
    if self.KillerShock != nil then
        self.KillerShock:Remove()
    end
end