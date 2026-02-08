if CLIENT then

local utf8 = utf8
local draw = draw

net.ReceivePing( "PhrasesReset", function()
	PHRASES.CUR = {}
end )

end

PHRASES = PHRASES or {
	CUR = {}
}

local sndDurTbl = {
	["scpfp/gocsniper/warning1.wav"] = 1.6,
	["scpfp/gocsniper/warning2.wav"] = 1.95,
	["scpfp/gocsniper/fire1.wav"] = 1.45,
	["scpfp/gocsniper/fire2.wav"] = 1.65,
	["scpfp/gocsniper/scp.wav"] = 1.45,
	["scpfp/public_announcements/malfunction.wav"] = 6.5,
	["scpfp/public_announcements/breach.wav"] = 14.6,
	["scpfp/public_announcements/epsilon11_arrival.wav"] = 12,
	["scpfp/public_announcements/1_scp.wav"] = 3.5,
	["scpfp/public_announcements/2_scp.wav"] = 3.5,
	["scpfp/public_announcements/3_scp.wav"] = 3.5,
}

local senderColor = {
	pa = Color( 93, 122, 184 ),
	gocsniper = Color( 97, 132, 149 ),
	gruspy = Color( 158, 145, 99 ),
}

local function castPhraseInternal( sound, sender, text )
	surface.PlaySound( sound )

	PHRASES.PopUp( sender, text, sndDurTbl[sound] or SoundDuration( sound ) )
end

function PHRASES.Cast( ply, sound, sender, text )
	if SERVER then
		net.Start( "FPPhrases" )
			net.WriteString( sound or "" )
			net.WriteString( sender )
			net.WriteString( text )
		if ply:IsPlayer() then
			net.Send( ply )
		else
			net.Broadcast()
		end
	else
		castPhraseInternal( sound or "", sender, text )
	end
end

function PHRASES.PopUp( s, t, d )
	local sn = s.."_name"
	table.insert( PHRASES.CUR, {
		sender = LANG.Get( "PHRASES", sn ),
		color = senderColor[s] or color_white,
		text = utf8.force( LANG.Get( "PHRASES", s, t ) ),
		curtext = "",
		nextletter = 0,
		duration = d + 3,
		endtime = CurTime() + d + 3
	} )
end

function PHRASES.Clear( sync )
	PHRASES.CUR = {}

	if SERVER and sync then
		net.Ping( "PhrasesReset" )
	end
end

local line = 0
hook.Add( "RenderScreenspaceEffects", "PhrasesDisplay", function()
	if #PHRASES.CUR == 0 then return end

	line = 0

	local ct = CurTime()
	for k, v in ipairs( PHRASES.CUR ) do
		if k > 3 then continue end

		local speed = ( v.duration - 3 ) / utf8.len( v.text )

		if #v.curtext != #v.text and ct >= v.nextletter then
			v.nextletter = ct + speed
			v.curtext = v.curtext..utf8.GetChar( v.text, utf8.len( v.curtext ) + 1 )
		end

		local txt_tbl = string.Explode( "\n", v.curtext )

		for i, t in ipairs( txt_tbl ) do
			local text = i == 1 and { v.color, v.sender, color_white, " : "..t } or { color_white, t }
			draw.MultiColorText( "HUDNormal", ScrW() / 4, ScrH()*3/4 + line * ScreenScale( 12 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 0, color_black, unpack( text ) )
			line = line + 1
		end

		if ct >= v.endtime then
			table.remove( PHRASES.CUR, k )
		end
	end
end )

net.Receive( "FPPhrases", function()
	castPhraseInternal( net.ReadString(), net.ReadString(), net.ReadString() )
end )