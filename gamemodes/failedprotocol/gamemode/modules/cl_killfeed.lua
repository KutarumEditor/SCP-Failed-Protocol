KILLFEED = KILLFEED or {
    REG = {}
}

local inf_clr = Color( 240, 240, 100 )
local team_death_clr = Color( 155, 0, 0 )
hook.Add( "FPHUD", "FPKillfeed", function()
    if LocalPlayer():FPTeam() == TEAM_SPEC then
        for _, v in ipairs( KILLFEED.REG ) do
            local deathtype = v.deathtype or "suicide"

            if v.endtime > CurTime() then
                v.alpha = math.min( 1, v.alpha + FrameTime() )
            else
                v.alpha = v.alpha - FrameTime()
                if v.alpha <= 0 then
                    table.remove( KILLFEED.REG, _ )
                    continue
                end
            end

            local text = LANG.Get( "KILLFEED", deathtype ) or "%a killed %v with %i"
            local fintext = {}
            local current_alpha = 255 * v.alpha

            local function addTextPart( str, color )
                if not str or str == "" then return end
                table.insert( fintext, Color( color.r, color.g, color.b, current_alpha ) )
                table.insert( fintext, str )
            end

            local lastPos = 1
            while true do
                local startPos, endPos, placeholder = string.find( text, "(%%[avi])", lastPos )
                if not startPos then break end

                if startPos > lastPos then
                    local plainText = string.sub( text, lastPos, startPos - 1 )
                    addTextPart( plainText,  color_white )
                end

                if placeholder == "%a" then
                    addTextPart( v.attacker:IsPlayer() and v.attacker:Nick() or "Unknown", FPTeams.GetColor( v.att_team ) )
                elseif placeholder == "%v" then
                    addTextPart( v.victim:IsPlayer() and v.victim:Nick() or "Unknown", FPTeams.GetColor( v.vic_team ) )
                elseif placeholder == "%i" then
                    addTextPart( v.inflictor, inf_clr )
                end

                lastPos = endPos + 1
            end

            if lastPos <= #text then
                local plainText = string.sub( text, lastPos )
                addTextPart( plainText,  color_white )
            end

            if v.last  then
                addTextPart( " "..v.last, team_death_clr )
            end

            draw.MultiColorText( 
                "HUDMedium", 
                ScrW() - ScreenScale( 4 ), 
                _ * ScreenScale( 6 ), 
                TEXT_ALIGN_RIGHT, 
                TEXT_ALIGN_CENTER, 
                0, 
                color_white, 
                unpack( fintext ) 
            )
        end
    end
end )

local function KillfeedAdd( attacker, victim, inflictor, reason )
    local att_team, vic_team = TEAM_SPEC, TEAM_SPEC

    if attacker:IsValid() then
        att_team = attacker:FPTeam()
    end

    if victim:IsValid() then
        vic_team = victim:FPTeam()
    end

    local inf = inflictor
    local inf_lang = LANG.Get( "WEP", inf:GetClass() )
    if inf_lang != "NULL_LANG" then
        inf = inf_lang
    elseif inf.PrintName then
        inf = inf.PrintName
    else
        inf = inf:GetClass()
    end

    local alive_teammates = {}
    for i, v in player.Iterator() do
		if v:FPTeam() == vic_team and v:Alive() then
			table.insert( alive_teammates, v )
		end
	end

    local reas = reason
    if !attacker:IsValid() then
        reas = "suicide"
    end

    table.insert( KILLFEED.REG, {
        attacker = attacker,
        att_team = att_team,
        victim = victim,
        vic_team = vic_team,
        deathtype = reas,
        last = #alive_teammates <= 1 and table.Random( LANG.REG[CUR_LANG].DEATHQUOTES[vic_team] ) or nil,
        inflictor = inf,
        endtime = CurTime() + 10,
        alpha = 0
    } )
end

net.Receive( "FPKillfeed", function()
    local att = net.ReadPlayer()
    local vic = net.ReadPlayer()
    local inf = net.ReadEntity()
    local reason = net.ReadString()

    KillfeedAdd( att, vic, inf, reason )
end )