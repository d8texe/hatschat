
-----------------------------------------------------
-----------------------------------------
---------------HatsChat 2----------------
-----------------------------------------
--Copyright (c) 2013-2015 my_hat_stinks--
-----------------------------------------


--Request all--
function HatsChat:RequestServerSettings()
	net.Start( "HatsChat_GetConfig" )
		net.WriteUInt( HATSCHAT_NET_ALL, 4 )
	net.SendToServer()
end

local NetTypeToTable = {
	[HATSCHAT_NET_EMOTE] = {"Emote","LuaEmote","restricted"},
	[HATSCHAT_NET_CHATCOL] = {"ChatCol","LuaChatCol","restriction"},
	[HATSCHAT_NET_LINEICON] = {"LineIcon","LuaLineIcon"},
	[HATSCHAT_NET_CHATTAG] = {"Tags","LuaChatTags", sub="ChatTags"},
	[HATSCHAT_NET_FILTER] = {},
	[HATSCHAT_NET_FILTER_CATEGORIES] = {"CategoryData", sub="ChatFilter"},
}
net.Receive( "HatsChat_SetValues", function()
	local typ = net.ReadUInt(3)
	if not typ then return end
	
	local TypeTable = NetTypeToTable[typ]
	if not (TypeTable and TypeTable[1]) then return end
	
	local tbl = net.ReadTable()
	if not tbl then return end
	
	if TypeTable[3] then
		for k,v in pairs(tbl) do
			if v==false then continue end
			if v[TypeTable[3]] then
				v[TypeTable[3]] = (v[TypeTable[3]]==HATSCHAT_PERM_ADMIN and HatsChat.AdminOnly) or
					(v[TypeTable[3]]==HATSCHAT_PERM_DONOR and HatsChat.DonatorOnly) or
					(v[TypeTable[3]]==HATSCHAT_PERM_ALL and nil) or
					(v[TypeTable[3]]~=HATSCHAT_PERM_ALL and v[TypeTable[3]])
			else
				v[TypeTable[3]] = nil
			end
		end
	end
	
	local ItemTable = (TypeTable.sub and HatsChat[TypeTable.sub][TypeTable[1]]) or HatsChat[TypeTable[1]]
	table.Empty( ItemTable )
	if TypeTable[2] then
		table.CopyFromTo( table.Copy(HatsChat[TypeTable[2]]), ItemTable )
	end
	table.Merge( ItemTable, tbl )
	
	if typ==HATSCHAT_NET_FILTER or typ==HATSCHAT_NET_FILTER_CATEGORIES then
		if IsValid(HatsChat.ChatFilter.settingsCategory) then HatsChat.ChatFilter.settingsCategory:Refresh() end
		if IsValid(HatsChat.ChatFilter.settingsWords) then HatsChat.ChatFilter.settingsWords:Refresh() end
		HatsChat.ChatFilter:UpdateFilter()
	end
end)

-- Chat filter --
net.Receive( "HatsChat_SetFilter", function()
	local cat = net.ReadString()
	if (not cat) or #cat==0 then return end
	
	local data = net.ReadTable()
	if (not data) or table.Count(data)==0 then
		HatsChat.ChatFilter.Categories[cat] = nil
		
		if IsValid(HatsChat.ChatFilter.settingsCategory) then HatsChat.ChatFilter.settingsCategory:Refresh() end
		if IsValid(HatsChat.ChatFilter.settingsWords) then HatsChat.ChatFilter.settingsWords:Refresh() end
		HatsChat.ChatFilter:UpdateFilter()
		return
	end
	
	HatsChat.ChatFilter.Categories[cat] = data
	
	if IsValid(HatsChat.ChatFilter.settingsCategory) then HatsChat.ChatFilter.settingsCategory:Refresh() end
	if IsValid(HatsChat.ChatFilter.settingsWords) then HatsChat.ChatFilter.settingsWords:Refresh() end
	HatsChat.ChatFilter:UpdateFilter()
end)
