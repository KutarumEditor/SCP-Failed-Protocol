--[[-------------------------------------------------------------------------
rpairs
---------------------------------------------------------------------------]]
local function rpairs_iter( tab, i )
	i = i - 1
	local v = tab[i]

	if v then
		return i, v
	end
end

function rpairs( tab, i )
	return rpairs_iter, tab, (i or #tab) + 1
end