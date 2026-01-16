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

	PA.NEXT = CurTime() + ( sound_duration_override[snd] or SoundDuration( snd ) )
end

local nextThink = 0
hook.Add( "Think", "PAThink", function()
	local ct = CurTime()
	if nextThink < ct and PA.NEXT < ct and PA.QUEUE[1] != nil then
		local q = PA.QUEUE
		for i, ply in player.Iterator() do
			PHRASES.Cast( ply, q[1].snd, "pa", q[1].subs )
		end

		nextThink = ct + 3
	end
end )