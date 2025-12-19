ROUND = ROUND or {
	type = "numb",
	aftermath = false,
	frozen = false,
	starttime = 0,
	finishtime = 0,
}

net.Receive( "RoundDataSync", function()
	ROUND = net.ReadTable()
end )

function CurRound()
	return ROUND.type
end