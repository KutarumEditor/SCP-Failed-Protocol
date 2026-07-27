AddCSLuaFile()

ENT.Type = "anim"
ENT.ArmorType = nil

function ENT:SetupDataTables()
    self:NetworkVar( "String", 0, "Type" )
    self:NetworkVar( "Float", 0, "Durability" )
end

function ENT:Initialize()
    self:SetModel( REGISTERED_ARMOR[self:GetType()].floor_model or "models/items/vest.mdl" )

    self:PhysicsInit( SOLID_BBOX )
    self:SetMoveType( MOVETYPE_NONE )
    self:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR )

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

function ENT:Use( activator, caller )
    if activator.FPArmor[self.ArmorType].name != nil then
        return
    end

    local plyclass = activator:GetFPClass()
    if CLASSES[plyclass] != nil then
        if self.ArmorType == "helmet" and CLASSES[plyclass].blockhelmet == true then
            return
        end

        if self.ArmorType == "vest" and CLASSES[plyclass].blockvest == true then
            return
        end
    end

    activator:TimedTask( "armor_equip", 5, Color( 200, 155, 0 ),
    function()
        return IsValid( self ) and IsValid( activator ) and activator.FPArmor[self.ArmorType].name == nil and
            activator:EyePos():Distance( activator:GetEyeTrace().HitPos ) < 100 and activator:GetEyeTrace().Entity == self
    end, function()
        activator:SetFPArmor( self.ArmorType, self:GetType(), self:GetDurability() )

        activator:EmitSound( "scpfp/armor/armor_pickup.wav" )

        SafeRemoveEntity( self )
    end )
end

local offset = 0
function ENT:DrawArmorInfo()
    local ply = LocalPlayer()
    local info = REGISTERED_ARMOR[self:GetType()]

    vec1, vec2 = self:GetModelBounds()

    local pos = self:GetPos() + Vector( 0, 0, ( vec2.z - vec1.z ) + 10 )

    local scr = pos:ToScreen()

    if not scr.visible then return end

    local alpha = 1 - math.Clamp( pos:Distance( ply:EyePos() )/64 - 2, 0, 1 )

    if alpha <= 0 then return end

    local text = LANG.Get( "ARMOR", self:GetType() ).." | "..math.Round( self:GetDurability() / REGISTERED_ARMOR[self:GetType()].durability * 100, 1 ).."%"

    local ang = ( pos - EyePos() ):GetNormalized():Angle()
    ang = Angle( 0, ang.y, 0 )
    ang:RotateAroundAxis( ang:Up(), -90 )
    ang:RotateAroundAxis( ang:Forward(), 90 )

    cam.Start3D2D( pos, ang, .15 )
        surface.SetFont( "YoFont" )
        local tW, tH = surface.GetTextSize( text )

        local padX = 20
        local padY = -5

        surface.SetDrawColor( 5, 5, 5, 200 * alpha )
        surface.DrawRect( ( -tW / 2 - padX ) * alpha, -padY, ( tW + padX * 2 ) * alpha, tH + padY * 2 )

        render.SetStencilEnable( true )

        render.ClearStencil()
        
        render.SetStencilTestMask( 255 )
        render.SetStencilWriteMask( 255 )

        render.SetStencilPassOperation( STENCILOPERATION_KEEP )
        render.SetStencilZFailOperation( STENCILOPERATION_KEEP )

        render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NEVER )

        render.SetStencilReferenceValue( 9 )
        render.SetStencilFailOperation( STENCILOPERATION_REPLACE )

        surface.DrawRect( ( -tW / 2 - padX ) * alpha, -padY, ( tW + padX * 2 ) * alpha, tH + padY * 2 )

        render.SetStencilFailOperation( STENCILOPERATION_KEEP )

        render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )

        draw.SimpleText( text, "YoFont", -tW / 2, 0, Color( 255, 255, 255, 155 * alpha ) )

        render.SetStencilEnable( false )

        surface.SetDrawColor( Color( 255, 255, 255, 155 * alpha ) )
        surface.DrawRect( ( -tW / 2 - padX ) * alpha - 1, -padY, 2, tH + padY * 2 )
        surface.DrawRect( ( -tW / 2 - padX ) * alpha - 1 + ( tW + padX * 2 ) * alpha, -padY, 2, tH + padY * 2 )
    cam.End3D2D()
end

function ENT:Draw()
    self:DrawModel()

    self:DrawArmorInfo()
end