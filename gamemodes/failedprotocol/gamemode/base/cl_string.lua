function string.Wrap( font, text, width )
	surface.SetFont( font )
		
	local sw = surface.GetTextSize( ' ' )
	local ret = {}
		
	local w = 0
	local s = ''

	local t = string.Explode( '\n', text )
	for i = 1, #t do
		local t2 = string.Explode( ' ', t[i], false )
		for i2 = 1, #t2 do
			local neww = surface.GetTextSize( t2[i2] )
				
			if ( w + neww >= width ) then
				ret[#ret + 1] = s
				w = neww + sw
				s = t2[i2] .. ' '
			else
				s = s .. t2[i2] .. ' '
				w = w + neww + sw
			end
		end
		ret[#ret + 1] = s
		w = 0
		s = ''
	end
		
	if (s ~= '') then
		ret[#ret + 1] = s
	end

	return ret
end

function string.PhoneWrap( font, text, width )
	local txt = text
	local tbl = {}
	
	local i = 1
	local cl = 1

	surface.SetFont( font )
	repeat
		local tt = string.Left( txt, i )
		local tw, th = surface.GetTextSize( tt.."A" )

		if tw >= width then
			tbl[cl] = tt
			cl = cl + 1
			txt = string.Right( txt, #txt - i )
			i = 1
		elseif tt == txt then
			tbl[cl] = tt
			txt = ""
		else
			i = i + 1
		end
	until #txt == 0

	return tbl
end