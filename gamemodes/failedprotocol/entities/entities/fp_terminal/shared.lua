AddCSLuaFile()

ENT.Type = "anim"

ENT.Data = {}

ENT.Scale = .05

function ENT:SetupDataTables()
    self:NetworkVar( "Bool", 0, "Active" )
    self:NetworkVar( "Bool", 1, "Infected" )
    self:NetworkVar( "Bool", 2, "Show" )

    self:NetworkVar( "Entity", 0, "User" )

    self:SetActive( false )
    self:SetInfected( false )
    self:SetShow( false )

    self:SetUser( NULL )
end

function ENT:Initialize()
    self:SetModel( "models/unconid/pc_models/monitors/lcd_acer_16x9.mdl" )

    if SERVER then
        self.Password = GeneratePassword()
        print( self.Password )
    end

    self:PhysicsInit( SOLID_BBOX )
    self:SetMoveType( MOVETYPE_NONE )

    if SERVER then
        self:SetUseType( SIMPLE_USE )
    end

    local phys = self:GetPhysicsObject()
    if IsValid( phys ) then
        phys:Wake()
        phys:EnableMotion( false )
    end

    self:DrawShadow( false )
end