AddCSLuaFile()

ENT.Type = "anim"

ENT.Info = {}

function ENT:SetupDataTables()
    self:NetworkVar( "Bool", 0, "Active" )
    self:NetworkVar( "Bool", 1, "Show" )

    self:SetActive( false )
    self:SetShow( false )
end

function ENT:Initialize()
    self:SetModel( "models/kutarum/scpfp/monitor.mdl" )

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

function ENT:Use()
    timer.Remove( self:EntIndex().."_Usage" )
    self:SetActive( !self:GetActive() )
    
    timer.Simple( 0, function()
        if self:GetActive() then
            timer.Create( self:EntIndex().."_Usage", 3, 1, function()
                if self:IsValid() then
                    self:SetShow( true )
                    timer.Create( self:EntIndex().."_Usage", 17, 1, function()
                        if self:IsValid() then
                            self:DisableScreen()
                        end
                    end )
                end
            end )
        else
            self:DisableScreen()
        end
    end )
end

function ENT:DisableScreen()
    self:SetActive( false )
    self:SetShow( false )
end

if not CLIENT then return end

ENT.InfoCheck = {
    classd = function( plys )
        local escaped = false
        for i, ply in ipairs( plys ) do
            if ply:GetFPClass() == "gruagent" or ply:FPTeam() == TEAM_CLASSD then
                escaped = true
            end
        end
        return escaped
    end,
    scp008 = function( plys )
        local breached = false
        for i, ply in ipairs( plys ) do
            if ply:GetFPClass() == "SCP008" then
                breached = true
            end
        end
        if ROUNDPROP.Get( "MASS008" ) == true then
            breached = true
        end
        return breached
    end,
}

ENT.Updated = false
function ENT:UpdateInfo()
    local plys = player:GetAll()
    self.Info = {}
    for k, v in pairs( self.InfoCheck ) do
        if v( plys ) then
            self.Info[#self.Info + 1] = k
        end
    end
    self.Updated = true
end

local TEX_WIDTH, TEX_HEIGHT = 840, 540

ENT.loadingState = 1
ENT.loadingNext = 0
local loadingTbl = {
    "0oooo",
    "o0ooo",
    "oo0oo",
    "ooo0o",
    "oooo0",
    "ooo0o",
    "oo0oo",
    "o0ooo",
}

local glitchMaxSize = 3
local glitchClr = Color( 10, 20, 45 )
local textClr = Color( 75, 125, 255 )

function ENT:RenderScreen( w, h )
    local ct = CurTime()

    if self:GetActive() then
        draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 20 ) )

        for i = 1, 3 do
            local y, height = FPRandom( h ), FPRandom( glitchMaxSize )
            draw.RoundedBox( 0, 0, y, w, height, glitchClr )
        end

        if self:GetShow() then
            if not self.Updated then
                self:UpdateInfo()
            end

            draw.SimpleText( "STATUS", "HUDBig", w / 2, h * 0.09, textClr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

            local ypos = h * 0.2
            for i, v in ipairs( self.Info ) do
                draw.SimpleText( v, "HUDNormal", w / 2, ypos, textClr, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
                ypos = ypos + 32
            end
        else
            if ct > self.loadingNext then
                self.loadingState = ( self.loadingState % #loadingTbl ) + 1
                self.loadingNext = ct + .125
            end

            draw.SimpleText( loadingTbl[self.loadingState], "HUDBig", w / 2, h / 2, textClr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            draw.SimpleText( "Refreshing...", "HUDNormal", w / 2, h / 2 - 16, textClr, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
        end

        local lineInterval = 5
        local linePos = 0
        local lines = h / lineInterval

        surface.SetDrawColor( Color( 0, 0, 0, 125 ) )
        for i = 1, lines do
            surface.DrawLine( 0, linePos, w, linePos )
            linePos = linePos + lineInterval
        end
    else
        self.loadingState = 1
        self.Updated = false
    end
end

function ENT:Draw()
    self:DrawModel()

    local ang = self:GetAngles()
    local pos = self:GetPos()

    pos = pos + ang:Forward() * -.65 + ang:Right() * -21 + ang:Up() * 13.5

    ang:RotateAroundAxis( ang:Forward(), 90 )
    ang:RotateAroundAxis( Vector( 0, 0, 1 ), -90 )

    cam.Start3D2D( pos, ang, 0.05 )
        self:RenderScreen( TEX_WIDTH, TEX_HEIGHT )
    cam.End3D2D()
end