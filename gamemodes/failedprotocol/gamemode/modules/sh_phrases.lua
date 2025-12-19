PHRASES = PHRASES or {
	CUR = {}
}

local sndDurTbl = {
	["scpfp/gocsniper/warning1.wav"] = 1.6,
	["scpfp/gocsniper/warning2.wav"] = 1.95,
	["scpfp/gocsniper/fire1.wav"] = 1.45,
	["scpfp/gocsniper/fire2.wav"] = 1.65,
	["scpfp/gocsniper/scp.wav"] = 1.45,
}

local function castPhraseInternal( sound, sender, text )
	surface.PlaySound( sound )

	PHRASES.PopUp( sender, text, sndDurTbl[sound] or SoundDuration( sound ) )

	print( LANG.Get( "PHRASES", sender, text ) )
end

function PHRASES.Cast( ply, sound, sender, text )
	if SERVER then
		net.Start( "FPPhrases" )
			net.WriteString( sound )
			net.WriteString( sender )
			net.WriteString( text )
		if ply:IsPlayer() then
			net.Send( ply )
		else
			net.Broadcast()
		end
	else
		castPhraseInternal( ply, sound, sender )
	end
end

function PHRASES.PopUp( s, t, d )
	local sn = s.."_name"
	table.insert( PHRASES.CUR, {
		sender = LANG.Get( "PHRASES", sn ),
		text = utf8.force( LANG.Get( "PHRASES", s, t ) ),
		curtext = "",
		nextletter = 0,
		duration = d + 3,
		endtime = CurTime() + d + 3
	} )
end

hook.Add( "HUDPaint", "PhrasesDisplay", function()
	for k, v in ipairs( PHRASES.CUR ) do
		if k > 3 then continue end

		local speed = ( v.duration - 3 ) / #v.text

		if CurTime() >= v.nextletter and #v.curtext != #v.text then
			v.nextletter = CurTime() + speed
			v.curtext = utf8.sub( v.text, 1, utf8.len( v.curtext ) + 1 )
		end

		draw.SimpleTextOutlined( v.sender.." : "..v.curtext, "HUDNormal", ScrW() / 4, ScrH()*3/4 - ( k - 1 ) * ScreenScale( 12 ), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, color_black )
	
		if CurTime() >= v.endtime then
			table.remove( PHRASES.CUR, k )
		end
	end
end )

net.Receive( "FPPhrases", function()
	castPhraseInternal( net.ReadString(), net.ReadString(), net.ReadString() )
end )