-----------------------------------------
---------------HatsChat 2----------------
-----------------------------------------
--Copyright (c) 2013-2015 my_hat_stinks--
-----------------------------------------

--Network Strings--
-------------------
util.AddNetworkString( "HatsChat_ServerMessage" ) -- Chat message from Server
util.AddNetworkString( "HatsChat_Say" ) -- Player said stuff

util.AddNetworkString( "HatsChat_SetDefaults" )	util.AddNetworkString( "HatsChat_GetDefaults" ) --Default settings for the server

util.AddNetworkString( "HatsChat_SetValues" )
util.AddNetworkString( "HatsChat_SetFilter" )

util.AddNetworkString( "HatsChat_GetConfig" ) --Get values

--Initialization--
------------------
HatsChat.ChatFilter = HatsChat.ChatFilter or {} -- Chat filters are never used anywhere else serverside
HatsChat.ChatFilter.CategoryData = HatsChat.ChatFilter.CategoryData or {}
HatsChat.ChatFilter.Categories = HatsChat.ChatFilter.Categories or {}

--Utility--
-----------
function HatsChat:ServerMessage( ply, ... )
	if not IsValid(ply) then return end
	
	local send = {...}
	for i=#send,1,-1 do
		local typ = type(send[i])
		if typ~="string" and typ~="table" and typ~="Player" and typ~="number" then table.remove( send, i ) end --It's something we don't support (eg a func)
	end
	
	net.Start( "HatsChat_ServerMessage" )
		net.WriteTable( send )
	net.Send( ply )
end

--Chat--
--------
net.Receive( "HatsChat_Say", function( len,ply )
	if not IsValid(ply) then return end
	
	local str = net.ReadString() or ""
	local tm = tobool(net.ReadBit())
	
	local newStr = hook.Call( "PlayerSay", GAMEMODE, ply, str, tm )
	
	if newStr==true then
		newStr = str
	elseif newStr==false then
		return
	elseif type(newStr)~="string" then
		ErrorNoHalt( "Error: hook->PlayerSay returned a non-string!\n" )
		newStr = str
	end
	
	if (not newStr) or newStr=="" then return end
	
	local SendTo = {}
	for _,v in pairs(player.GetAll()) do
		if v==ply or hook.Call( "PlayerCanSeePlayersChat", GAMEMODE, newStr, tm, v, ply ) then
			table.insert( SendTo, v )
		end
	end
	
	if #SendTo>0 then
		net.Start( "HatsChat_Say" )
			net.WriteBit( ply:Alive() )
			net.WriteBit( tm )
			net.WriteString( newStr )
			net.WriteEntity( ply )
		net.Send( SendTo )
	end
end)

--Default Values--
------------------
local DefaultsTable = {}
local function SendDefaults( ply )
	net.Start( "HatsChat_GetDefaults" )
		net.WriteTable( DefaultsTable )
	if IsValid(ply) then net.Send(ply) else net.Broadcast() end
end

net.Receive( "HatsChat_SetDefaults", function( len, ply )
	if not IsValid(ply) then return end
	if not HatsChat.HasPermission( ply, "HatsChatAdmin_Config", ply:IsSuperAdmin() ) then
		HatsChat:ServerMessage( ply, "You are not allowed to do this." )
	end
	
	local id = net.ReadString()
	local tbl = net.ReadTable()
	
	if not (id and tbl) then return HatsChat:ServerMessage( ply, "An error occured! (Data missing)" ) end
	tbl.ConfigID = string.gsub(id, "[^%a_]", ""):lower() --Lower case alphabetic and underscores only
	if tbl.ConfigID=="standard" then return HatsChat:ServerMessage( ply, "You must change \"Server Config ID\" first!" ) end
	
	local str = util.TableToJSON( tbl )
	if not str then return HatsChat:ServerMessage( ply, "An error occured! (Json missing)" ) end
	
	DefaultsTable = tbl
	
	if not file.IsDir( "hatschat", "DATA" ) then file.CreateDir( "hatschat" ) end
	file.Write( "hatschat/sv_chatconfig.txt", str )
	
	HatsChat:ServerMessage( ply, "Update successful." )
	SendDefaults()
end)
net.Receive( "HatsChat_GetDefaults", function( len, ply )
	if not IsValid( ply ) then return end
	
	SendDefaults( ply )
end)
if file.IsDir( "hatschat", "DATA" ) and file.Exists( "hatschat/sv_chatconfig.txt", "DATA" ) then
	local str = file.Read( "hatschat/sv_chatconfig.txt", "DATA" )
	if not str then return end
	
	local tbl = util.JSONToTable( str )
	if not tbl then return end
	
	DefaultsTable = tbl
end

--Client Update Request--
-------------------------
net.Receive( "HatsChat_GetConfig", function(len, ply)
	if not IsValid(ply) then return end
	
	local typ = net.ReadUInt( 4 )
	if (not typ) then return end
	
	HatsChat:UpdateValues( ply, typ )
end)

--Server values persistance--
-----------------------------
function HatsChat:SaveServerValues( typ )
	typ = typ or HATSCHAT_NET_ALL
	if not file.IsDir( "hatschat", "DATA" ) then file.CreateDir( "hatschat" ) end
	
	if typ==HATSCHAT_NET_ALL or typ==HATSCHAT_NET_EMOTE then
		local json = util.TableToJSON( self.Emote )
		if json then file.Write( "hatschat/sv_config_emote.txt", json ) end
	end
	if typ==HATSCHAT_NET_ALL or typ==HATSCHAT_NET_CHATCOL then
		local json = util.TableToJSON( self.ChatCol )
		if json then file.Write( "hatschat/sv_config_chatcol.txt", json ) end
	end
	if typ==HATSCHAT_NET_ALL or typ==HATSCHAT_NET_LINEICON then
		local json = util.TableToJSON( self.LineIcon )
		if json then file.Write( "hatschat/sv_config_lineicon.txt", json ) end
	end
	if typ==HATSCHAT_NET_ALL or typ==HATSCHAT_NET_CHATTAG then
		local json = util.TableToJSON( self.ChatTags.Tags )
		if json then file.Write( "hatschat/sv_config_chattag.txt", json ) end
	end
	if typ==HATSCHAT_NET_ALL or typ==HATSCHAT_NET_FILTER or typ==HATSCHAT_NET_FILTER_CATEGORIES then
		for k in pairs(self.ChatFilter.Categories) do
			if not self.ChatFilter.CategoryData[k] then self.ChatFilter.Categories[k] = nil end
		end
		local json = util.TableToJSON( self.ChatFilter )
		if json then file.Write( "hatschat/sv_config_chatfilter.txt", json ) end
	end
end
function HatsChat:LoadServerValues( typ )
	typ = typ or HATSCHAT_NET_ALL
	if not file.IsDir( "hatschat", "DATA" ) then file.CreateDir( "hatschat" ) end
	
	if typ==HATSCHAT_NET_ALL or typ==HATSCHAT_NET_EMOTE then
		if file.Exists( "hatschat/sv_config_emote.txt", "DATA" ) then
			local str = file.Read( "hatschat/sv_config_emote.txt", "DATA" )
			if str then
				local tbl = util.JSONToTable( str )
				if tbl then self.Emote = tbl end
			end
		elseif file.Exists( "data/hatschat/default_config_emote.txt", "GAME" ) then
			local str = file.Read( "data/hatschat/default_config_emote.txt", "GAME" )
			if str then
				file.Write( "hatschat/sv_config_emote.txt", str )
				local tbl = util.JSONToTable( str )
				if tbl then self.Emote = tbl end
			end
		end
	end
	if typ==HATSCHAT_NET_ALL or typ==HATSCHAT_NET_CHATCOL then
		if file.Exists( "hatschat/sv_config_chatcol.txt", "DATA" ) then
			local str = file.Read( "hatschat/sv_config_chatcol.txt", "DATA" )
			if str then
				local tbl = util.JSONToTable( str )
				if tbl then self.ChatCol = tbl end
			end
		elseif file.Exists( "data/hatschat/default_config_chatcol.txt", "GAME" ) then
			local str = file.Read( "data/hatschat/default_config_chatcol.txt", "GAME" )
			if str then
				file.Write( "hatschat/sv_config_chatcol.txt", str )
				local tbl = util.JSONToTable( str )
				if tbl then self.ChatCol = tbl end
			end
		end
	end
	if typ==HATSCHAT_NET_ALL or typ==HATSCHAT_NET_LINEICON then
		if file.Exists( "hatschat/sv_config_lineicon.txt", "DATA" ) then
			local str = file.Read( "hatschat/sv_config_lineicon.txt", "DATA" )
			if str then
				local tbl = util.JSONToTable( str )
				if tbl then self.LineIcon = tbl end
			end
		elseif file.Exists( "data/hatschat/default_config_lineicon.txt", "GAME" ) then
			local str = file.Read( "data/hatschat/default_config_lineicon.txt", "GAME" )
			if str then
				file.Write( "hatschat/sv_config_lineicon.txt", str )
				local tbl = util.JSONToTable( str )
				if tbl then self.LineIcon = tbl end
			end
		end
	end
	if typ==HATSCHAT_NET_ALL or typ==HATSCHAT_NET_CHATTAG then
		if file.Exists( "hatschat/sv_config_chattag.txt", "DATA" ) then
			local str = file.Read( "hatschat/sv_config_chattag.txt", "DATA" )
			if str then
				local tbl = util.JSONToTable( str )
				if tbl and self.ChatTags then self.ChatTags.Tags = tbl end
			end
		elseif file.Exists( "data/hatschat/default_config_chattag.txt", "GAME" ) then
			local str = file.Read( "data/hatschat/default_config_chattag.txt", "GAME" )
			if str then
				file.Write( "hatschat/sv_config_chattag.txt", str )
				local tbl = util.JSONToTable( str )
				if tbl and self.ChatTags then self.ChatTags.Tags = tbl end
			end
		end
	end
	if typ==HATSCHAT_NET_ALL or typ==HATSCHAT_NET_FILTER or typ==HATSCHAT_NET_FILTER_CATEGORIES then
		if file.Exists( "hatschat/sv_config_chatfilter.txt", "DATA" ) then
			local str = file.Read( "hatschat/sv_config_chatfilter.txt", "DATA" )
			if str then
				local tbl = util.JSONToTable( str )
				if tbl then self.ChatFilter = tbl end
			end
		elseif file.Exists( "data/hatschat/default_config_chatfilter.txt", "GAME" ) then
			local str = file.Read( "data/hatschat/default_config_chatfilter.txt", "GAME" )
			if str then
				file.Write( "hatschat/sv_config_chatfilter.txt", str )
				local tbl = util.JSONToTable( str )
				if tbl then self.ChatFilter = tbl end
			end
		end
	end
end
HatsChat:LoadServerValues()
timer.Simple(0, function() HatsChat:LoadServerValues( HATSCHAT_NET_CHATTAG ) end) --Not loaded yet

--Add new files
for _,v in pairs( HatsChat.FontData ) do if v.filename then resource.AddFile( v.filename ) end end --Add font files
for _,v in pairs( HatsChat.Emote ) do if v.icon then resource.AddFile( v.icon ) end end --Add emote materials
for _,v in pairs( HatsChat.LineIcon ) do
	if v then
		if type(v)=="table" then
			for i=1,#v do resource.AddFile(v[i]) end
		else resource.AddFile( v ) end
	end
end
----

--Set Values--
--------------
local NetTypeToTable = {
	[HATSCHAT_NET_EMOTE] = {"Emote","LuaEmote"},
	[HATSCHAT_NET_CHATCOL] = {"ChatCol","LuaChatCol"},
	[HATSCHAT_NET_LINEICON] = {"LineIcon","LuaLineIcon"},
	[HATSCHAT_NET_CHATTAG] = {"Tags","LuaChatTags", sub="ChatTags"},
	[HATSCHAT_NET_FILTER] = {},
	[HATSCHAT_NET_FILTER_CATEGORIES] = {"CategoryData", sub="ChatFilter"},
}
function HatsChat:UpdateValues( ply, typ )
	typ = typ or HATSCHAT_NET_ALL
	self:SaveServerValues( typ )
	
	if typ==HATSCHAT_NET_ALL then
		for k in pairs(NetTypeToTable) do
			self:UpdateValues( ply, k )
		end
		
		return
	elseif typ==HATSCHAT_NET_FILTER then
		for k,v in pairs(self.ChatFilter.Categories) do
			net.Start("HatsChat_SetFilter")
				net.WriteString(k)
				net.WriteTable(v)
			if IsValid(ply) then net.Send(ply) else net.Broadcast() end
		end
		return
	end
	
	if not (NetTypeToTable[typ] and NetTypeToTable[typ][1]) then return end
	
	net.Start( "HatsChat_SetValues" )
		net.WriteUInt( typ, 3 )
		if NetTypeToTable[typ].sub then
			net.WriteTable( self[ NetTypeToTable[typ].sub ][ NetTypeToTable[typ][1] ] )
		else
			net.WriteTable( self[ NetTypeToTable[typ][1] ] )
		end
	if IsValid(ply) then net.Send(ply) else net.Broadcast() end
end

local IDFormat = {
	[HATSCHAT_NET_EMOTE] = function(id) return id:lower() end,
	[HATSCHAT_NET_CHATCOL] = function(id) return id:lower() end,
	[HATSCHAT_NET_LINEICON] = function(id) return (string.match( id:upper(), "STEAM_0:[0-1]:[0-9]*") and id:upper()) or 
		(id:sub(1,9):lower()=="internal_" and id:sub(1,1):upper()..id:sub(2,8):lower()..id:sub(9,-1)) or
		id
	end,
	[HATSCHAT_NET_CHATTAG] = function(id) return string.match( id:upper(), "STEAM_0:[0-1]:[0-9]*") and id:upper() or id end,
	[HATSCHAT_NET_FILTER_CATEGORIES] = function(id) return id end,
}
net.Receive( "HatsChat_SetValues", function( len, ply )
	if not (IsValid(ply) and HatsChat.HasPermission( ply, "HatsChatAdmin_Config", ply:IsSuperAdmin() )) then return end
	
	local typ = net.ReadUInt( 3 )
	if not typ then return end
	
	local TypeTable = NetTypeToTable[typ]
	if not (TypeTable and TypeTable[1]) then return end
	
	local ItemTable
	if TypeTable.sub then
		ItemTable = HatsChat[TypeTable.sub] and HatsChat[TypeTable.sub][ TypeTable[1] ]
	else
		ItemTable = HatsChat[ TypeTable[1] ]
	end
	if not ItemTable then return HatsChat:ServerMessage( ply, "Invalid update type." ) end
	
	local id = net.ReadString()
	local tbl = net.ReadTable()
	if not id then return HatsChat:ServerMessage( ply, "Missing ID." ) end
	id = IDFormat[typ](id)
	
	if (not tbl) or table.Count(tbl)==0 then
		if TypeTable[2] and HatsChat[TypeTable[2]][id] then
			ItemTable[id] = false
		else
			ItemTable[id] = nil
		end
		HatsChat:UpdateValues( nil, typ )
		HatsChat:ServerMessage( ply, "Removed "..TypeTable[1].." "..id )
		return
	end
	
	ItemTable[id] = (tbl.SingleValue and tbl.val) or tbl
	HatsChat:UpdateValues( nil, typ )
	HatsChat:ServerMessage( ply, "Added "..TypeTable[1].." "..id ) 
end)

--Filter Values--
-----------------
net.Receive( "HatsChat_SetFilter", function(len,ply)
	if not (IsValid(ply) and HatsChat.HasPermission( ply, "HatsChatAdmin_Config", ply:IsSuperAdmin() )) then return end
	
	local cat = net.ReadString()
	if (not cat) or #cat==0 then return HatsChat:ServerMessage( ply, "Invalid filter category." ) end
	if not HatsChat.ChatFilter.CategoryData[cat] then return HatsChat:ServerMessage( ply, "Invalid filter category." ) end
	
	local triggerWord = net.ReadString()
	if (not triggerWord) then return HatsChat:ServerMessage( ply, "Missing trigger word." ) end
	triggerWord = triggerWord:lower():gsub( "[ %p]", "" )
	if #triggerWord==0 then return HatsChat:ServerMessage( ply, "Invalid trigger word." ) end
	
	HatsChat.ChatFilter.Categories[cat] = HatsChat.ChatFilter.Categories[cat] or {}
	
	local replaceWord = net.ReadString()
	if (not replaceWord) or (#replaceWord==0) then
		HatsChat.ChatFilter.Categories[cat][triggerWord] = nil
		if table.Count(HatsChat.ChatFilter.Categories[cat])==0 then
			HatsChat.ChatFilter.Categories[cat] = nil
		end
		HatsChat:SaveServerValues( HATSCHAT_NET_FILTER )
		net.Start("HatsChat_SetFilter")
			net.WriteString(cat)
			net.WriteTable( HatsChat.ChatFilter.Categories[cat] or {} )
		net.Broadcast()
		HatsChat:ServerMessage( ply, "Removed filter word "..triggerWord )
		return
	end
	
	HatsChat.ChatFilter.Categories[cat][triggerWord] = replaceWord
	HatsChat:SaveServerValues( HATSCHAT_NET_FILTER )
	net.Start("HatsChat_SetFilter")
		net.WriteString(cat)
		net.WriteTable(HatsChat.ChatFilter.Categories[cat])
	net.Broadcast()
	HatsChat:ServerMessage( ply, "Added filter word "..triggerWord )
end)
