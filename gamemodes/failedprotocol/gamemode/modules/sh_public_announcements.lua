PA = PA or {
	QUEUE = {},
	NEXT = 0
}

local sound_duration_override = {
	["scpfp/public_announcements/epsilon11_arrival.wav"] = 12.2,
	["scpfp/public_announcements/beta7_arrival.wav"] = 14.7,
	["scpfp/public_announcements/nu7_arrival.wav"] = 14.7,
}

function PA.Play( snd, subs )
	PA.QUEUE[#PA.QUEUE + 1] = {
		snd = snd or "",
		subs = subs or ""
	}
end

function PA.Reset()
	PA.QUEUE = {}

	if SERVER then
		net.Ping( "PAReset" )
	end
end

hook.Add( "Think", "PAThink", function()
	local ct = CurTime()
	if PA.NEXT < ct and PA.QUEUE[1] != nil then
		local q = PA.QUEUE
		local snd = q[1].snd
		PHRASES.Cast( game.GetWorld(), snd, "pa", q[1].subs )

		PA.NEXT = CurTime() + ( sound_duration_override[snd] or SoundDuration( snd ) )

		table.remove( PA.QUEUE, 1 )
	end
end )

if not CLIENT then return end

net.ReceivePing( "PAReset", function()
	PA.QUEUE = {}
end )