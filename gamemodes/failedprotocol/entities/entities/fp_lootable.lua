AddCSLuaFile()

ENT.Type = "anim"
ENT.LootTable = {}

function ENT:SetupDataTables()
    self:NetworkVar( "String", 0, "Type" )
end

function ENT:Initialize()
    self:SetModel( "models/hunter/blocks/cube025x025x025.mdl" )

    self:PhysicsInit( SOLID_BBOX )
    self:SetMoveType( MOVETYPE_NONE )
    self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )

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

function ENT:Use( ply, caller )
    net.Start( "FPLoot" )
        net.WriteEntity( self )
    net.Send( ply )
end

if not CLIENT then return end

local icon = Material( "failedprotocol/icons/lens.png" )

function ENT:Draw()
    local ply = LocalPlayer()
    local pos = self:GetPos()
    local dist = ply:EyePos() - pos
    local len = dist:Length()
    local maxlen = MAX_LOOT_DISTANCE * 2

    if len > maxlen then return end

    local clr = color_white:Copy()
    clr.a = ( 1 - ( len / maxlen ) ) * 255

	local ang = dist:Angle()
	ang:RotateAroundAxis( ang:Right(), -90 )
	ang:RotateAroundAxis( ang:Up(), 90 )

	cam.Start3D2D( pos, ang, 0.05 )
        cam.IgnoreZ( true )

        surface.SetDrawColor( clr )
		surface.SetMaterial( icon )
        surface.DrawTexturedRect( -32, -32, 64, 64 )
	
        cam.IgnoreZ( false )
    cam.End3D2D()
end