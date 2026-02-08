AddCSLuaFile()

ENT.Type = "anim"

function ENT:Initialize()
    if SERVER then
        self:SetModel( "models/kutarum/scpfp/tesla_strike.mdl" )
    end

    self:SetSolid( SOLID_NONE )
    self:SetMoveType( MOVETYPE_NONE )
    self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )

    local phys = self:GetPhysicsObject()
    if IsValid( phys ) then
        phys:Wake()
        phys:EnableMotion( false )
    end

    self:DrawShadow( false )
end

function ENT:Think()
    if CLIENT then return end

    local gate = self:GetParent()
    local pos, ang = self:GetPos(), self:GetAngles()
    local min, max = self:OBBMins(), self:OBBMaxs()
    min:Rotate( ang )
    max:Rotate( ang )
    if IsValid( gate ) and gate:GetShocking() then
        local d = DamageInfo()
        d:SetDamage( 500 )
        d:SetAttacker( self )
        d:SetDamageType( DMG_ENERGYBEAM )
        for i, ent in ipairs( ents.FindInBox( pos + min, pos + max ) ) do
            ent:TakeDamageInfo( d )
        end
    end

    self:NextThink( CurTime() )

    return true
end

if not CLIENT then return end

function ENT:Draw()
    local gate = self:GetParent()
    if IsValid( gate ) and gate:GetShocking() then
        self:DrawModel()
        local dlight = DynamicLight( self:EntIndex() )
        if ( dlight ) then
            dlight.pos = self:GetPos() + self:OBBCenter()
            dlight.r = 0
            dlight.g = 125
            dlight.b = 255
            dlight.brightness = 3
            dlight.decay = 6400
            dlight.size = 512
            dlight.dietime = CurTime() + 1
        end
    end
end