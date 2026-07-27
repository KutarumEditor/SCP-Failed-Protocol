AddCSLuaFile()

ENT.Type = "anim"

ENT.Model = "models/hunter/blocks/cube025x025x025.mdl"

ENT.StoreSounds = "Weapon_SniperRifle.Reload"

ENT.TakeOutSounds = "AlyxEMP.Discharge"

ENT.OpenInfo = {
   time = 3,
   lang = "box",
   clr = Color( 200, 155, 0 )
}

ENT.Items = {}
ENT.Volume = 0

function ENT:Initialize()
    self:SetModel( self.Model )

    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:PhysicsInit( SOLID_BBOX )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetCollisionGroup( COLLISION_GROUP_NONE )
    self:PhysWake()

    if SERVER then
        self:SetUseType( SIMPLE_USE )

        self.Volume = self:InitVolume()
    end
end

function ENT:CheckTotalVolume()
    local total = 0

    for k, v in pairs( self.Items ) do
        local ent = ents.Create( v.class )
        ent:SetModel( v.model )

        total = total + ent:InitVolume()

        ent:Remove()
    end

    return total
end

function ENT:Store( ent, force )
    local tab = ent:Copy()

    if ( self:CheckTotalVolume() + ent:InitVolume() > self.Volume or ent.IsBeingDragged != true or ent:IsDerived( "cv_container_base" ) ) and ( force == nil or force == false ) then return end

    ent:Remove()
    self:EmitSound( istable( self.StoreSounds ) and self.StoreSounds[FPRandom( #self.StoreSounds )] or self.StoreSounds )

    table.insert( self.Items, tab )

    if SERVER then
        self:SyncStorage()
    end
end

function ENT:TakeOut( num, ply )
    local tbl = self.Items[num]

    if not istable( tbl ) then return end

    self.Items[num] = nil

    local ent = ents.Create( tbl.class )
    ent:SetModel( tbl.model )

    local sv1, sv2 = self:GetModelBounds()
    local ev1, ev2 = ent:GetModelBounds()

    ent:SetPos( LerpVector( .5, self:GetPos() + Vector( 0, 0, ( sv2.z - sv1.z )/2 + ( ev2.z - ev1.z )/2 ), ply:GetPos() ) )
    ent:Spawn()
    if ent:IsWeapon() then
        ent:SetClip1( tbl.clip )
    end

    self:EmitSound( istable( self.TakeOutSounds ) and self.TakeOutSounds[FPRandom( #self.TakeOutSounds )] or self.TakeOutSounds )

    self:SyncStorage()
end

function ENT:Use( activator, caller )
    
end

function ENT:PhysicsCollide( data, phys )
    local hitEnt = data.HitEntity

    if hitEnt:EntIndex() != 0 then
        self:Store( hitEnt )
    end
end