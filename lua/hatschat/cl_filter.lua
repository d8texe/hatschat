
-----------------------------------------------------
-----------------------------------------
---------------HatsChat 2----------------
-----------------------------------------
--Copyright (c) 2013-2015 my_hat_stinks--
-----------------------------------------

HatsChat.ChatFilter = HatsChat.ChatFilter or {}
local CF = HatsChat.ChatFilter

local function IgnoreFilter(ply)
	return (HatsChat.HasPermission( ply, "HatsChat_AvoidFilter", false )) or (not IsValid(ply))
end

CF.CategoryData = CF.CategoryData or {}
CF.Categories = CF.Categories or {}

CF.ActiveFilter = {
	Normal = {},
	Pattern = {},
}
CF.ForceFilter = {
	Normal = {},
	Pattern = {},
}

local function DoReplace( word, startPos, endPos, replaceWith )
	if not (word and startPos and endPos and replaceWith) then return word end
	
	if word:upper()==word then
		replaceWith = replaceWith:upper()
	elseif #word>1 and word[1]:upper()==word[1] then
		replaceWith = replaceWith[1]:upper()..replaceWith:sub(2,-1)
	else
		replaceWith = replaceWith:lower()
	end
	
	return word:sub(0,startPos-1) ..replaceWith.. word:sub(endPos+1,-1)
end
function CF.RunFilter( ply, str )
	-- if IgnoreFilter(ply) then return str end
	
	local patterns = (IgnoreFilter(ply) and CF.ForceFilter.Pattern) or CF.ActiveFilter.Pattern
	for pat,new in pairs(patterns) do
		str = str:gsub( pat, new )
	end
	
	local filter = (IgnoreFilter(ply) and CF.ForceFilter.Normal) or CF.ActiveFilter.Normal
	
	local exp = string.Explode( " ", str )
	for i=1,#exp do
		local gsub = string.gsub( exp[i], "%p", "" ):lower()
		if filter[ gsub ] then
			local StartPos,EndPos = string.find( exp[i]:lower(), gsub, 0, true )
			if StartPos and EndPos then
				exp[i] = DoReplace( exp[i], StartPos, EndPos, filter[ gsub ] )
			else
				--There's something like sh.it here, find it
				local pattern = table.concat( string.ToTable( gsub ), "[%p]*" )
				local StartPos,EndPos = string.find( exp[i]:lower(), pattern )
				if StartPos and EndPos then
					exp[i] = DoReplace( exp[i], StartPos, EndPos, filter[ gsub ] )
				end
			end
		end
	end
	
	return table.concat( exp, " " )
end

local function DateInRange( m,d, StartM,StartD, EndM,EndD )
	local inverse = (StartM>EndM) or (StartM==EndM and StartD>EndD)
	
	if inverse then
		if (m>StartM or m<EndM) or (m==StartM and d>=StartD) or (m==EndM and d<=EndD) then
			return true
		end
		return false
	else
		if (m>StartM and m<EndM) then
			return true
		elseif (StartM==EndM) then
			return (m==StartM) and (d>=StartD) and (d<=EndD)
		elseif (m==StartM and d>=StartD) or (m==EndM and d<=EndD) then
			return true
		end
		return false
	end
end
function CF.UpdateFilter()
	table.Empty(CF.ActiveFilter.Normal)
	table.Empty(CF.ActiveFilter.Pattern)
	table.Empty(CF.ForceFilter.Normal)
	table.Empty(CF.ForceFilter.Pattern)
	
	local active = {}
	local patterns = {}
	
	local month,day = tonumber(os.date("%m")),tonumber(os.date("%d"))
	for k,v in pairs(CF.CategoryData) do
		if not v.RestrictedDates then
			table.insert( v.Pattern and patterns or active, {k,v.Priority,v.Force} )
			continue
		end
		
		if not v.DateRange then continue end
		if DateInRange( month,day, v.DateRange.Start[1],v.DateRange.Start[2], v.DateRange.End[1],v.DateRange.End[2] ) then
			table.insert( v.Pattern and patterns or active, {k,v.Priority,v.Force} )
			continue
		end
	end
	
	table.sort( active, function(a,b)
		return (a[2] or 0)<(b[2] or 0)
	end)
	table.sort( patterns, function(a,b)
		return (a[2] or 0)<(b[2] or 0)
	end)
	
	for i=1,#active do
		table.Merge( CF.ActiveFilter.Normal, CF.Categories[ active[i][1] or "" ] or {} )
		if active[i][3] then
			table.Merge( CF.ForceFilter.Normal, CF.Categories[ active[i][1] or "" ] or {} )
		end
	end
	for i=1,#patterns do
		table.Merge( CF.ActiveFilter.Pattern, CF.Categories[ patterns[i][1] or "" ] or {} )
		if patterns[i][3] then
			table.Merge( CF.ForceFilter.Pattern, CF.Categories[ patterns[i][1] or "" ] or {} )
		end
	end
end
CF.UpdateFilter()
timer.Create( "HatsChat_FilterUpdate", 600, 0, function() CF.UpdateFilter() end )
concommand.Add( "hatschat_updatefilter", function(p) if p==LocalPlayer() then CF.UpdateFilter() end end)
