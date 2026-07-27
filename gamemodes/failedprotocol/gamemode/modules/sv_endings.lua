function SelectEnding( plys )
	for i, v in ipairs( ENDINGS[ROUND.type] ) do
		print( v.lang )
		if v.check( plys ) == true then
			net.Ping( "ShowEnding", v.lang )
			v.callback()
		break end
	end
end