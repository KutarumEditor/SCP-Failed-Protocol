local ENTITY = FindMetaTable("Entity")
local PLAYER = FindMetaTable("Player")
local eIsFlagSet = ENTITY.IsFlagSet
local eGetVelocity = ENTITY.GetVelocity
local eGetPos = ENTITY.GetPos
local pGetHull = PLAYER.GetHull
local pGetHullDuck = PLAYER.GetHullDuck
local eManipulateBonePosition = ENTITY.ManipulateBonePosition
local crouchJumpers = {}
local vector_reset = Vector(0,0,0)

local function crouchModelAdjustment(ply)
    if !IsValid(ply) then return end
    local lerpTime = engine.TickInterval()
    if !ply then lerpTime = lerpTime - FrameTime() ply = LocalPlayer() end

    local crouchJumping = !eIsFlagSet(ply, FL_ONGROUND) and eIsFlagSet(ply, FL_ANIMDUCKING)

    if !crouchJumping and crouchJumpers[ply] then
        eManipulateBonePosition(ply, 0, vector_reset)
    end

    crouchJumpers[ply] = crouchJumping or nil

    if crouchJumping then
        local nextPos = eGetVelocity(ply)
        nextPos:Add(physenv.GetGravity())
        nextPos:Mul(lerpTime)

        local plyPos = eGetPos(ply)
        local newPos = plyPos + nextPos

        local _, sMaxs = pGetHull(ply)
        sMaxs.x = 0
        sMaxs.y = 0

        local cMins, cMaxs = pGetHullDuck(ply)
        local endPos = newPos - sMaxs
        local trable = {
            start = plyPos,
            endpos = endPos,
            mins = cMins,
            maxs = cMaxs,
            mask = MASK_PLAYERSOLID,
            filter = ply
        }

        local hullTrace = util.TraceHull(trable)

        local trace = util.TraceLine(trable)

        local total = Lerp((hullTrace.Fraction + trace.Fraction) * 0.5, 0, -cMaxs.z)

        eManipulateBonePosition(ply, 0, Vector(0, 0, total))
    end
end

hook.Add("PlayerPostThink", "CrouchJump_Dejankifier", crouchModelAdjustment)