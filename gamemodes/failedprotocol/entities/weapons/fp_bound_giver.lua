AddCSLuaFile()

SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

SWEP.UseHands = true

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.StartPos = nil

function SWEP:PrimaryAttack()
    if not CLIENT then return end
    
    local tr = LocalPlayer():GetEyeTrace()

    if self.StartPos == nil then
        self.StartPos = tr.HitPos

        surface.PlaySound( "buttons/button15.wav" )

        print( "First position set!" )

        return
    end

    local pos1 = tr.HitPos
    local pos2 = self.StartPos

    local p1, p2 = Vector(), Vector()

    if pos1.x <= pos2.x then
        p1.x, p2.x = pos1.x, pos2.x
    else
        p2.x, p1.x = pos1.x, pos2.x
    end

    if pos1.y <= pos2.y then
        p1.y, p2.y = pos1.y, pos2.y
    else
        p2.y, p1.y = pos1.y, pos2.y
    end

    if pos1.z <= pos2.z then
        p1.z, p2.z = pos1.z, pos2.z
    else
        p2.z, p1.z = pos1.z, pos2.z
    end

    chat.AddText( "{ Vector( "..p1.x..", "..p1.y..", "..p1.z.." ), Vector( "..p2.x..", "..p2.y..", "..p2.z.." ) }," )

    surface.PlaySound( "buttons/blip1.wav" )

    self.StartPos = nil
end

function SWEP:SecondaryAttack()
    if not CLIENT then return end

    self.StartPos = nil

    surface.PlaySound( "buttons/button1.wav" )

    print( "Position reset!" )
end

function SWEP:DrawHUD()
    local pos2 = self.StartPos
    if pos2 == nil then return end

    local tr = self.Owner:GetEyeTrace()

    local pos1 = tr.HitPos
    local p1, p2 = Vector(), Vector()

    if pos1.x <= pos2.x then
        p1.x, p2.x = pos1.x, pos2.x
    else
        p2.x, p1.x = pos1.x, pos2.x
    end

    if pos1.y <= pos2.y then
        p1.y, p2.y = pos1.y, pos2.y
    else
        p2.y, p1.y = pos1.y, pos2.y
    end

    if pos1.z <= pos2.z then
        p1.z, p2.z = pos1.z, pos2.z
    else
        p2.z, p1.z = pos1.z, pos2.z
    end

    local boxsize = p2 - p1

    cam.Start3D()
        render.SetColorMaterial()

        render.DrawWireframeBox( p1, Angle(), Vector(), boxsize )

        render.DrawBox( p1, Angle(), Vector( -.5, -.5, -.5 ), Vector( .5, .5, .5 ), Color( 255, 0, 0 ) )
        render.DrawBox( p2, Angle(), Vector( -.5, -.5, -.5 ), Vector( .5, .5, .5 ), Color( 0, 0, 255 ) )
    cam.End3D()
end