local PLAYER = FindMetaTable( "Player" )

function PLAYER:SetTerminal( terminal )
    self.Terminal = terminal

    if terminal != nil and terminal:GetClass() == "fp_terminal" then
        terminal:SetUser( self )
    end

    self:SyncTerminal()
end

function PLAYER:SyncTerminal()
    if not SERVER then return end

    local t = self.Terminal
    net.Ping( "SyncTerminalUser", t == nil and "nil" or tostring( t:EntIndex() ) )
end

hook.Add( "StartCommand", "FPTerminalInput", function( ply, cmd )
    local ct = CurTime()
    local term = ply.Terminal

	if term != nil then
        cmd:ClearMovement()

        if not term:IsValid() then
            ply:SetTerminal( nil )
            return
        end

        if CLIENT and ply:KeyPressed( IN_USE ) and ct > ply.LastUseTime + .1 then
            ply.Terminal = nil
            net.Ping( "FPStopTerminalUsage" )
        end
    else
        ply.LastUseTime = ct
    end
end )

AVAILABLE_CHARS = {
    ["1"] = true, ["2"] = true, ["3"] = true, ["4"] = true, ["5"] = true, ["6"] = true, ["7"] = true, ["8"] = true, ["9"] = true, ["0"] = true,
}

MAX_PASSWORD_LENGHT = 8

function GeneratePassword()
    local password = ""

    local keys = table.GetKeys( AVAILABLE_CHARS )

    for i = 1, MAX_PASSWORD_LENGHT do
        password = password .. keys[FPRandom( #keys )]
    end

    return password
end

if not CLIENT then return end

local terminalLerp = 0

function CalcTerminalView( ply, origin, angles, fov, znear, zfar )
    local lply = LocalPlayer()

    terminalLerp = math.min( 1, terminalLerp + FrameTime() * 1.5 )
    local ease = math.ease.OutSine( terminalLerp )

    local terminal = lply.Terminal

    if not terminal:IsValid() then
        local view = {}
        view.origin		=  origin
        view.angles		= angles
        view.fov		= fov
        view.znear		= znear
        view.zfar		= zfar
        view.drawviewer	= false
    return view end

    local tarPos, tarAng = terminal:GetPos(), terminal:GetAngles() - Angle( 0, 180, 0 )

    tarPos = tarPos + tarAng:Forward() * -15 + tarAng:Up() * 12.5

    local view = {}
	view.origin		= LerpVector( ease, origin, tarPos )
	view.angles		= LerpAngle( ease, angles, tarAng )
	view.fov		= Lerp( ease, fov, 95 )
	view.znear		= znear
	view.zfar		= zfar
	view.drawviewer	= false

	return view
end

net.ReceivePing( "SyncTerminalUser", function( data )
    terminalLerp = 0
    local lp = LocalPlayer()
    if data == "nil" then
        lp.Terminal = nil
        gui.EnableScreenClicker( false )
    else
        lp.Terminal = Entity( tonumber( data ) )
        gui.EnableScreenClicker( true )
    end
end )