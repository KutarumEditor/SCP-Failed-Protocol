EXITS = {
	["main"] = {
		bounds = {
			Vector( -2255.96875, 2457.5732421875, -4031.8469238281 ),
			Vector( -2175.8520507813, 2623.96875, -3873.8884277344 ),
		},
		time = 10,
		check = function( ply )
			return true
		end,
		callback = function( ply )
			print( ply:Nick() .. " escaped through the main exit!" )
		end
	},
}
