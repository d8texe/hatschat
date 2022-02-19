
-----------------------------------------------------
-----------------------------------------
---------------HatsChat 2----------------
-----------------------------------------
--Copyright (c) 2013-2015 my_hat_stinks--
-----------------------------------------

--Client Vars--
---------------
--Editable
--________
local ChatBoxCol = { --Colours for the chatbox itself
	BG = Color(0,0,0,100 ),
	Black = Color( 0,0,0,150 ), White = Color( 200,200,200,150 ),
	Candy1 = Color( 255,255,50,200 ), Candy2 = Color( 220,40,255,150 ),
	BlackStrong = Color( 0,0,0,220 ), WhiteStrong = Color( 255,255,255,200 ),
	BlackSolid = Color( 0,0,0,255 ), WhiteSolid = Color( 255,255,255,255 ), BlueSolid = Color(0,50,255,255),
	GoldSolid = Color(255,210,50,255),
	Bar = Color( 120,120,120,200 ),
	Highlight = Color(100,255,255,255), LineHighlight = Color(50,170,170,150)
}
local ChatTextCol = { --Default text colours (Will be overridden by colour-modifying stuff, eg chat.AddText)
	JoinLeave = Color(150,200,150,255), Default = Color(150,150,200,255),
	Black = Color(0,0,0,255), White = Color(255,255,255,255), --White is used for emotes
	Url = Color(0,170,255,255),
	
	Console = Color(175,175,200), Team = Color(10,100,10), Dead = Color(255,20,20) --For if you uncomment OnPlayerChat
}
local MaxLines = 200  --The higher the limit, the more performance lost when it's hit
HatsChat.ConfigID = "standard" --Unique identifier for the server's settings. Do not use spaces or special characters!
local DefaultFont = "HatsChatText"

local DefaultValues = {
	XAlign = 0, YAlign = 1,
	PosX = 20, PosY = 450,
	Wide = 500, Tall = 300,
	TextFont = DefaultFont, TextSize = 16, TextFade = 10, TextFade2 = 2,
	Theme = "Basic", FadeTime = 0.2,
}

local function GetPlayerColor( ply )
	--Use this function for glowing names and other such player-based custom colours
	if not IsValid(ply) then return ChatTextCol.Default end
	
	local hk = hook.Call( "HatsChatPlayerColor", GAMEMODE, ply )
	if hk then return hk end
	
	local TeamCol = team.GetColor(ply:Team())
	local rank = HatsChat.GetPlayerRank(ply)
	
	local namecol = HatsChat and HatsChat.NameGlow and HatsChat.NameGlow[ply:SteamID()]
	if (not namecol) and (namecol~=false) then
		namecol = HatsChat and HatsChat.NameGlow and HatsChat.NameGlow[rank]
	end
	
	if namecol or (namecol==false) then
		if namecol==false then
			return TeamCol
		elseif namecol==true then
			TeamCol.Glow = true
		elseif type(namecol)=="string" then
			local str = namecol:lower()
			if str=="glow" then
				TeamCol.Glow = true
			elseif HatsChat.ChatCol[str] then
				TeamCol = HatsChat.ChatCol[str]
			end
		elseif namecol.r and namecol.g and namecol.b and namecol.a then
			if namecol.Glow then
				TeamCol = namecol
			else
				TeamCol.Glow = true
				TeamCol.GlowTarget = namecol
			end
		end
	elseif HatsChat and HatsChat.SuperAdminGlow and ply:IsSuperAdmin() then TeamCol.Glow = true end
	
	return TeamCol
end

--It is no longer neccessary to edit these functions, use the tables in the autorun file or your admin mod's permissions system
local function GetPlayerIcon( ply )
	--Use this function for donator icons and other such player-based custom line icons
	if not IsValid(ply) then
		return HatsChat.LineIcon["Internal_User"] and (HatsChat.LineIcon["Internal_User"]:lower()=="avatar" and "avatar" or Material(HatsChat.LineIcon["Internal_User"]))
	end
	
	local hk = hook.Call( "HatsChatPlayerIcon", GAMEMODE, ply )
	if hk then return hk end
	
	local icon = HatsChat.LineIcon[ply:SteamID()] or HatsChat.LineIcon[HatsChat.GetPlayerRank(ply)] or
		(ply:IsSuperAdmin() and HatsChat.LineIcon["Internal_SuperAdmin"]) or
		(ply:IsAdmin() and HatsChat.LineIcon["Internal_Admin"]) or
		HatsChat.LineIcon["Internal_User"]
	
	return icon and ((type(icon)=="table" and icon) or (icon:lower()=="avatar" and "avatar") or Material(icon))
end
local function PlayerCanChatCol( ply ) --Use this function to restrict who can use chat colours
	if not IsValid( ply ) then return true end
	
	return HatsChat.HasPermission( ply, "HatsChat_ChatCol", true )
end
local function PlayerCanPostLinks( ply ) --This function restricts clickable links
	if not IsValid( ply ) then return true end
	
	return HatsChat.HasPermission( ply, "HatsChat_PostLinks", true )
end

-----------------------------------------
-------DO NOT EDIT below this line-------
-----------------------------------------
--Editting anything below here may cause instability in the addon
if HatsChat.ChatBoxCol then --Autorefresh fix
	table.Empty( HatsChat.ChatBoxCol )
	for k,v in pairs( ChatBoxCol ) do --We want the new values, but we also want the old table
		HatsChat.ChatBoxCol[k] = v
	end
	ChatBoxCol = HatsChat.ChatBoxCol
else
	HatsChat.ChatBoxCol = ChatBoxCol
end
HatsChat.Themes = HatsChat.Themes or {}
HatsChat.ThemeList = {}
HatsChat.HTMLMaterialsCache = HatsChat.HTMLMaterialsCache or {}
HatsChat.LoadHTMLQueue = {}
HatsChat.InLoadHTMLQueue = {}
concommand.Add( "hatschat_clearcache", function()
	table.Empty( HatsChat.HTMLMaterialsCache )
	table.Empty( HatsChat.LoadHTMLQueue )
	table.Empty( HatsChat.InLoadHTMLQueue )
	timer.Destroy( "HatsChat_LoadHTMLMaterial" )
end)

for k,v in pairs(ChatBoxCol) do v.defa = v.a end

local fontsize = HatsChat.Settings and HatsChat.Settings.ChatTextSize or GetConVar("hatschat_text_size")
fontsize = (fontsize and fontsize:GetInt()) or 16
surface.SetFont( DefaultFont..tostring(fontsize) )
local _,TextHigh = surface.GetTextSize( "ABCDEFGHIJKLMNOPQRSTUVWXYZ" )
local SelectedFont = DefaultFont

--Persistant
--__________
HatsChat.Settings = {}
CreateClientConVar( "hatschat_debug", 0, true, false )
function HatsChat:SetupConvars( newDefaults )
	local s = HatsChat.Settings
	
	if newDefaults and s.SettingsCustomised and s.SettingsCustomised:GetBool() then return end
	
	s.WindowPosX = CreateClientConVar( "hatschat_windowpos_x_"..HatsChat.ConfigID, DefaultValues.PosX or 20, true, false )
	s.WindowPosY = CreateClientConVar( "hatschat_windowpos_y_"..HatsChat.ConfigID, DefaultValues.PosY or 450, true, false )
	s.WindowAlignX = CreateClientConVar( "hatschat_windowalign_x_"..HatsChat.ConfigID, DefaultValues.XAlign or 0, true, false )
	s.WindowAlignY = CreateClientConVar( "hatschat_windowalign_y_"..HatsChat.ConfigID, DefaultValues.YAlign or 1, true, false )
	s.WindowSizeX = CreateClientConVar( "hatschat_windowsize_x_"..HatsChat.ConfigID, DefaultValues.Wide or 500, true, false )
	s.WindowSizeY = CreateClientConVar( "hatschat_windowsize_y_"..HatsChat.ConfigID, DefaultValues.Tall or 300, true, false )

	s.ChatTextFont = CreateClientConVar( "hatschat_text_font_"..HatsChat.ConfigID, DefaultValues.TextFont or DefaultFont, true, false )
	s.ChatTextSize = CreateClientConVar( "hatschat_text_size_"..HatsChat.ConfigID, DefaultValues.TextSize or 16, true, false )
	s.ChatFadeTime = CreateClientConVar( "hatschat_text_fade_"..HatsChat.ConfigID, DefaultValues.TextFade or 10, true, false )
	s.ChatFade2 = CreateClientConVar( "hatschat_text_fade2_"..HatsChat.ConfigID, DefaultValues.TextFade2 or 2, true, false )

	s.ChatTheme = CreateClientConVar( "hatschat_theme_"..HatsChat.ConfigID, DefaultValues.Theme or "Basic", true, false )
	s.ShowInScreenshots = CreateClientConVar( "hatschat_showinscreenshots_"..HatsChat.ConfigID, 1, true, false )
	s.WindowFadeTime = CreateClientConVar( "hatschat_windowfadetime_"..HatsChat.ConfigID, DefaultValues.FadeTime or 0.2, true, false )
	
	s.SettingsCustomised = CreateClientConVar( "hatschat_customised_"..HatsChat.ConfigID, 0, true, false )
end
HatsChat:SetupConvars()

function HatsChat:RefreshSettings()
	timer.Simple(0, function()
		HatsChat:SelectTheme( HatsChat.Settings.ChatTheme:GetString() )
		timer.Simple(0, function() HatsChat:DoWindowPos() end)
	end)
end
function HatsChat:ResetSettings()
	RunConsoleCommand( HatsChat.Settings.WindowPosX:GetName(), tostring(math.Round(DefaultValues.PosX)) )
	RunConsoleCommand( HatsChat.Settings.WindowPosY:GetName(), tostring(math.Round(DefaultValues.PosY)) )
	RunConsoleCommand( HatsChat.Settings.WindowAlignX:GetName(), tostring(math.Round(DefaultValues.XAlign)) )
	RunConsoleCommand( HatsChat.Settings.WindowAlignY:GetName(), tostring(math.Round(DefaultValues.YAlign)) )
	RunConsoleCommand( HatsChat.Settings.WindowSizeX:GetName(), tostring(math.Round(DefaultValues.Wide)) )
	RunConsoleCommand( HatsChat.Settings.WindowSizeY:GetName(), tostring(math.Round(DefaultValues.Tall)) )
	
	RunConsoleCommand( HatsChat.Settings.ChatTextFont:GetName(), DefaultValues.TextFont )
	RunConsoleCommand( HatsChat.Settings.ChatTextSize:GetName(), tostring(math.Round(DefaultValues.TextSize)) )
	RunConsoleCommand( HatsChat.Settings.ChatFadeTime:GetName(), tostring(math.Round(DefaultValues.TextFade)) )
	RunConsoleCommand( HatsChat.Settings.ChatFade2:GetName(), tostring(math.Round(DefaultValues.TextFade2)) )
	
	RunConsoleCommand( HatsChat.Settings.ChatTheme:GetName(), DefaultValues.Theme )
	RunConsoleCommand( HatsChat.Settings.ShowInScreenshots:GetName(), 1 )
	RunConsoleCommand( HatsChat.Settings.WindowFadeTime:GetName(), tostring(DefaultValues.FadeTime) )
	
	HatsChat:SetupConvars()
	HatsChat:RefreshSettings()
end
concommand.Add( "hatschat_reset", function() HatsChat:ResetSettings() end)

--Steam Emotes--
----------------
local SteamInventoryURL = "http://steamcommunity.com/profiles/%s/inventory/json/753/6" --Retreive inventory. %s is SteamID64
local SteamIconUrl = "http://cdn.steamcommunity.com/economy/emoticon/%s" --Image url. %s is the icon name minus the : at start and end
local function IsSteamEmote( itemtbl )
	if not itemtbl then return false end
	if not itemtbl.tags then return false end
	
	for _,v in pairs(itemtbl.tags) do
		if v.category=="item_class" and v.name=="Emoticon" then return true end
	end
end
function GetPlayerSteamEmotes( ply )
	if not IsValid(ply) then return end
	if ply:IsBot() or (not ply:IsPlayer()) then return end
	if (not HatsChat.UseSteamEmotes) or ply.HatsChat_SteamEmotesSetup or (ply.Hatschat_GettingSteamEmotes and (ply.Hatschat_GettingSteamEmotes+20)<CurTime()) then return end
	
	if ply.Hatschat_GettingSteamEmotes and ply.Hatschat_GettingSteamEmotes+20<CurTime() then
		ply.Hatschat_SteamEmotesFailCount = (ply.Hatschat_SteamEmotesFailCount or 0)+1
		if ply.Hatschat_SteamEmotesFailCount>=5 then
			print( "Failed to get emotes for "..ply:Nick()..", failed after 5 attempts." )
			ply.HatsChat_SteamEmotesSetup = true
			return
		end
	end
	
	local steamID64 = ply:SteamID64()
	if not steamID64 then ply.Hatschat_SteamEmotesFailCount=(ply.Hatschat_SteamEmotesFailCount or 0)+1 return end // Why would this happen?
	
	ply.Hatschat_GettingSteamEmotes = CurTime()
	
	local FUrl = string.format( SteamInventoryURL, steamID64 ) --Formatted URL
	http.Fetch( FUrl, function( body, len, header, code)
		if not IsValid(ply) then return end
		
		local items
		if body then items=util.JSONToTable( body ) end
		if not items then print( "Items unretreivable for "..ply:Nick()..", Unspecified error. Retrying." ) return end
		
		if items.success then
			ply.HatsChat_SteamEmotes = {}
			for k,v in pairs( items.rgDescriptions ) do
				if not IsSteamEmote( v ) then continue end
				
				ply.HatsChat_SteamEmotes[v.name] = string.format( SteamIconUrl, v.name:sub(2,-2) )
			end
			ply.HatsChat_SteamEmotesSetup = true
		else
			if not IsValid(ply) then return end
			
			print( "Failed to get emotes for "..ply:Nick()..", request unsucessful:", items.Error )
			if items.Error=="This profile is private." and ply==LocalPlayer() then HatsChat:DoMessage( "Unable to load your Steam Emoticons: Your profile is private!" ) end
			ply.HatsChat_SteamEmotesSetup = true --We can't get their emotes, flag as set up
		end
		ply.Hatschat_GettingSteamEmotes = nil
	end,
	function( err )
		if not IsValid(ply) then return end
		
		print( "Failed to get emotes for "..ply:Nick()..", http error:", err )
		ply.Hatschat_GettingSteamEmotes = nil
	end)
end
timer.Create( "HatsChat2 SteamEmotes initializer", 30, 0, function()
	if not HatsChat.UseSteamEmotes then timer.Destroy( "HatsChat2 SteamEmotes initializer" ) return end
	for _,v in pairs( player.GetAll() ) do GetPlayerSteamEmotes( v ) end --There's validation in the func
end)
hook.Add( "InitPostEntity", "HatsChat2 SteamEmotes initializer", function()
	if not HatsChat.UseSteamEmotes then return end
	for _,v in pairs( player.GetAll() ) do GetPlayerSteamEmotes( v ) end
end)

function HatsChat:ProcessHTMLMaterialQueue()
	if #self.LoadHTMLQueue<=0 then timer.Destroy( "HatsChat_LoadHTMLMaterial" ) return end
	
	local url
	for i=1,#self.LoadHTMLQueue do
		if IsValid( self.HTMLMaterialsCache[self.LoadHTMLQueue[1]] ) then
			table.remove( self.LoadHTMLQueue, 1 )
		else
			url = self.LoadHTMLQueue[1]
			table.remove( self.LoadHTMLQueue, 1 )
			break
		end
	end
	if not url then
		if #self.LoadHTMLQueue<=0 then timer.Destroy( "HatsChat_LoadHTMLMaterial" ) end
		return
	end
	
	self.InLoadHTMLQueue[url] = false
	
	local h = self.HTMLMaterialsCache
	h[url] = vgui.Create( "DHTML" )
	h[url].url = url
	h[url].Think = function( s )
		if not (self and self.HTMLMaterialsCache and self.HTMLMaterialsCache[s.url]==s) then
			s:Remove()
		end
	end
	h[url]:SetSize(18,18)
	h[url]:OpenURL( url )
	h[url].Paint = function() return true end
	h[url]:MoveToBack()
end
function HatsChat:LoadHTMLMaterial( url )
	if self.InLoadHTMLQueue[url] then return end
	if IsValid( self.HTMLMaterialsCache[url] ) then return end
	
	table.insert( self.LoadHTMLQueue, url )
	self.InLoadHTMLQueue[url] = true
	if not timer.Exists( "HatsChat_LoadHTMLMaterial" ) then
		timer.Create( "HatsChat_LoadHTMLMaterial", 0, 0, function() HatsChat:ProcessHTMLMaterialQueue() end )
	end
end

--Update locals--
-----------------
function HatsChat:UpdateFont( override )
	for k,v in pairs( HatsChat.FontData ) do HatsChat.FormatFont( k, v, override ) end
	
	local size = HatsChat.Settings and HatsChat.Settings.ChatTextSize or GetConVar("hatschat_text_size")
	size = override and override.size or (size and size:GetInt()) or 16
	
	local ToValidate = ((override and override.font) or (HatsChat.Settings.ChatTextFont and HatsChat.Settings.ChatTextFont:GetString()) or DefaultValues.TextFont)
	SelectedFont = ((HatsChat.Fonts[ ToValidate..tostring(size) ] and ToValidate) or DefaultValues.TextFont)..tostring(size)
	
	if self.MessagePanel then
		for i=1,#self.MessagePanel.Lines do
			local v = self.MessagePanel.Lines
			if IsValid(v) then
				v.SelectedFont = SelectedFont
			end
		end
	end
end
function HatsChat:UpdateTextHeight()
	surface.SetFont( SelectedFont )
	
	local _,h = surface.GetTextSize( "ABCDEFGHIJKLMNOPQRSTUVWXYZ" )
	TextHigh = h
	
	if IsValid( self.Window ) then
		self.Window.ScrollPanel:GetVBar().BottomOfScroll = true
	end
end

--For the sake of autorefresh
HatsChat:UpdateFont()
HatsChat:UpdateTextHeight()

--Settings from Server--
------------------------
function HatsChat:RequestServerDefaults()
	net.Start( "HatsChat_GetDefaults" ) net.SendToServer()
end
net.Receive( "HatsChat_GetDefaults", function()
	local tbl = net.ReadTable()
	if not tbl then return end
	
	if tbl.ConfigID then
		HatsChat.ConfigID = tbl.ConfigID
	end
	tbl.ConfigID = nil
	for k,v in pairs( tbl ) do --Only replace what we have
		DefaultValues[k] = v
	end
	
	HatsChat:SetupConvars( true )
	HatsChat:RefreshSettings()
end)

--Dealing with  line formatting--
--------And Text wrapping--------
---------------------------------
local ToFormat, Repeat
local col, SubLineArgs, ArgNum
local wide, Failsafe
local function FormatLine( panel )
	if not panel.Unformatted then return end
	
	local MaxWidth = panel:GetWide()-5
	panel.Args = {}
	panel.SteamIDs = {}
	
	--ToFormat = table.Copy( panel.Unformatted )
	ToFormat = {}
	for i=1,#panel.Unformatted do
		table.insert( ToFormat, panel.Unformatted[i] )
	end
	
	Repeat = true
	Failsafe = 0
	
	local LinesHeight,SubHeight = 0,0
	col = ChatTextCol.Default
	surface.SetFont( SelectedFont ) --So we get the right sizes
	while Repeat and (Failsafe<20) do
		Failsafe = Failsafe+1
		Repeat = false
		SubLineArgs = {}
		ArgNum = 0 --Colours don't count, so we need a separate var
		
		SubHeight = TextHigh
		
		wide = 20 --Margin
		while #ToFormat>0 do
			local v = ToFormat[1]
			local typ = type(v)
			if typ=="string" or typ=="table" and v[1]=="URL" then
				local str = typ=="table" and v.str or v
				ArgNum = ArgNum + 1
				--if ArgNum==1 then str = string.TrimLeft( str, " " ) end --TrimLeft and TrimRight are broken
				--if #ToFormat==1 then str = string.TrimRight( str, " " ) end
				
				if ArgNum==1 then while str[1]==" " do str = str:sub(2,-1) end end
				if #ToFormat==1 then while str[#str]==" " do str = str:sub(1,-2) end end --EndsWith and StartWith? Seems inconsistant
				
				local SubbedString = string.gsub( str, "&", "#" ) --& returns length 0, for some reason
				
				if ( surface.GetTextSize( SubbedString )+wide ) <= MaxWidth then --It's small enough to fit
					wide = wide+surface.GetTextSize( SubbedString )
					table.insert( SubLineArgs, v ) --v instead of str, no need to re-format urls
					table.remove( ToFormat, 1 )
					continue --We don't want to text wrap it
				end
				
				Repeat = true --Continue the loop, we have another line
				
				--Word wrapping
				--_____________
				local words = string.Explode( " ", SubbedString )
				local fit = "" --What we can fit on this line
				
				for n=1,#words do
					local SingleWord = words[n]
					if ( surface.GetTextSize( n==#words and SingleWord or SingleWord.." " )+wide ) <= MaxWidth then
						fit = fit..SingleWord..(n==#words and "" or " ")
						wide = wide + surface.GetTextSize( SingleWord..(n==#words and "" or " ") )
					elseif n==1 and ArgNum==1 then
						--Character wrapping
						--__________________
						local left = {}
						local fullword = ""
						
						local TotalLen = 0
						for len, split in ipairs( string.ToTable(SingleWord) ) do --ipairs for order
							local size,_ = surface.GetTextSize( fullword..split )
							if size+wide > MaxWidth then
								wide = wide + TotalLen
								table.insert( left, string.sub( SingleWord, len, -1)  )
								fit = fit..fullword
								break
							else
								TotalLen = size
								fullword = fullword..split
							end
						end
						
						--Deal with the rest of the words
						for x=(n+1),#words do
							table.insert( left, words[x] )
						end
						
						local ReformatStr = string.sub( str, -#table.concat( left, " " ), -1 )
						ToFormat[1] = typ=="table" and {"URL", str=ReformatStr, url=v.url} or ReformatStr
						break
					else
						local left = {}
						
						for x=n,#words do
							table.insert( left, word=="" and " " or words[x] )
						end
						
						local ReformatStr = (#left==0 and "") or string.sub( str, -(#table.concat( left, " " )), -1 )
						
						ToFormat[1] = typ=="table" and {"URL", str=ReformatStr, url=v.url} or ReformatStr
						break
					end
				end
				
				local SubString = string.sub( str, 1, #fit )
				table.insert( SubLineArgs, typ=="table" and {"URL", str=SubString, url=v.url} or SubString )
				break
			elseif typ=="Player" and IsValid(v) then --Should now not be used, kept as a failsafe
				local col = GetPlayerColor( v ) or team.GetColor(v:Team())
				table.insert( SubLineArgs, col )
				
				table.remove( ToFormat, 1 )
				
				table.insert( ToFormat, 1, v:Nick() ) --For text wrapping, pass through again
				table.insert( ToFormat, 2, col )
				
				panel.LineIcon = panel.LineIcon or GetPlayerIcon( v ) --Prioritise first icon
				if type(panel.LineIcon)=="table" then
					panel.LineIcon = Material(panel.LineIcon[1])
				elseif type(panel.LineIcon)=="string" and panel.LineIcon:lower()=="avatar" then
					panel.LineIconPlayer=v
				end
				panel.SteamIDs[ v:Nick() ] = v:SteamID()
			elseif typ=="Entity"  and IsValid(v) then
				table.insert( SubLineArgs, v:GetClass() )
				
				table.remove( ToFormat, 1 )
			elseif typ=="number" then
				--Normally chat.AddText won't handle numbers, but there's no reason we shouldn't
				ToFormat[1] = tostring(v) --For text wrapping, pass through again
			elseif typ=="table" then
				if v.r and v.g and v.b then --Color
					col = (v.ColorPersists and v) or table.Copy(v)
					
					table.insert( SubLineArgs, col )
					table.remove( ToFormat, 1 )
				elseif type(v[1])=="string" then
					local upper = v[1]:upper()
					if upper=="EMOTE" then --Emote
						ArgNum = ArgNum + 1
						
						local w = v.size and v.size[1] or 16
						if ((wide+w)<=MaxWidth) or (ArgNum==1) then --It's small enough to fit
							wide = wide+w
							table.insert( SubLineArgs, v )
							table.remove( ToFormat, 1 )
							
							SubHeight = math.max( SubHeight, v.size and v.size[2] or 16 )
							continue
						end
						
						Repeat = true
						break
					elseif upper=="PLYDATA" then
						if not v.RestrictionsOnly then
							panel.LineIcon = panel.LineIcon or GetPlayerIcon( v.ply ) --Prioritise first icon
							if type(panel.LineIcon)=="table" then
								panel.LineIcon = Material(panel.LineIcon[1])
							elseif type(panel.LineIcon)=="string" and panel.LineIcon:lower()=="avatar" then
								panel.LineIconPlayer=v.ply
							end
							
							if IsValid(v.ply) then
								panel.SteamIDs[ v.ply:Nick() ] = v.ply:SteamID()
								v.Nick = v.ply:Nick()
								v.SteamID = v.ply:SteamID()
							elseif v.SteamID and v.Nick then
								panel.SteamIDs[ v.Nick ] = v.SteamID
							end
						end
						
						table.remove( ToFormat, 1 )
					elseif upper=="LINEICON" then
						panel.LineIcon = panel.LineIcon or v.Icon or (v[2] and Material(v[2])) --Prioritise first icon, if this isn't first
						
						table.remove( ToFormat, 1 )
					elseif upper=="INTERNAL" then -- This prevents saving and loading this line
						panel.InternalMessage = true
						
						table.remove( ToFormat, 1 )
					else
						table.remove( ToFormat, 1 )
					end
				else
					table.remove( ToFormat, 1 )
				end
			else
				--table.insert( SubLineArgs, v ) --Unknown arg, can't use. Probably a function
				table.remove( ToFormat, 1 )
			end
		end
		SubLineArgs.LineLength = wide-20
		SubLineArgs.LinePos = LinesHeight
		SubLineArgs.LineTall = SubHeight
		LinesHeight = LinesHeight+SubHeight
		
		table.insert( panel.Args, SubLineArgs )
	end
	
	panel.SelctedFont = SelectedFont
	panel:SetTall( LinesHeight+5 )
end

function HatsChat:RefreshLines( ovr )
	if not IsValid( self.Window ) then return end
	if not IsValid( self.MessagePanel ) then return end
	
	self:UpdateFont( ovr )
	self:UpdateTextHeight()
	
	local wide = self.Window:GetWide() - self.Window.ScrollPanel:GetVBar():GetWide()
	self.MessagePanel:SetWide( wide-15 )
	
	for i=1,#self.MessagePanel.Lines do
		local v = self.MessagePanel.Lines[i]
		v:SetWide( self.MessagePanel:GetWide() )
		if IsValid(v) then
			FormatLine( v )
		end
	end
	
	local tall = 0
	for i=1,#self.MessagePanel.Lines do
		tall = tall+ ( IsValid(self.MessagePanel.Lines[i]) and self.MessagePanel.Lines[i]:GetTall() or 0 )
	end
	self.Window.ScrollPanel.BG:SetSize( wide, math.max(tall, self.Window:GetTall()-34) )
	self.MessagePanel:SetTall( tall )
	
	self.MessagePanel:Deselect()
end

--Emotes--
----------
local ColStart, ColEnd
local EmoteText, EmoteStart, EmoteEnd, EmoteWide, EmoteTall
function HatsChat:InitialFormatArgs( ... )
	local args = { ... }
	
	local ply, col, ROnly
	local retry = true
	while retry do --Find player
		retry = false
		for i=1,#args do
			if type(args[i])=="Player" then
				retry = true
				ply= ply or args[i]
				
				local FoundPly = args[i]
				
				args[i]= {"PLYDATA", ply=FoundPly}
				
				table.insert( args, i+1, GetPlayerColor(FoundPly) )
				table.insert( args, i+2, FoundPly:Nick() )
				table.insert( args, i+3, col or ChatTextCol.Default )
			elseif type(args[i])=="table" and args[i][1]=="PLYDATA" then
				if not ply then
					ply = ply or args[i].ply
					ROnly = args[i].RestrictionsOnly
				end
			elseif type(args[i])=="table" then
				if args[i][1]=="chatcol" and args[i][2] then
					args[i] = HatsChat.ChatCol[ args[i][2] ] or ChatTextCol.Default
				end
				if args[i].r and args[i].b and args[i].g then
					col = args[i]
				end
			end
		end
	end
	
	if IsValid(ply) and not ROnly then --LineIcons
		local tags = self.ChatTags.GetTag( ply )
		if tags and #tags>0 then
			for i=#tags,1,(-1) do --Reverse order, because we're sticking it in front
				local ins = tags[i]
				if type(tags[i])=="table" and tags[i][1]=="chatcol" and tags[i][2] then
					ins = HatsChat.ChatCol[ tags[i][2] ] or ChatTextCol.Default
				end
				table.insert( args, 1, ins )
			end
		end
		local icons = GetPlayerIcon( ply )
		if type(icons)=="table" and #icons>1 then
			for i=2,#icons do
				table.insert( args, 1, {"EMOTE", mat=Material(icons[i]), str=""} )
			end
		end
	end
	GetPlayerSteamEmotes( ply ) --Validation in the func
	
	for i=1,#args do --Chat filter
		if type(args[i])=="string" then
			args[i] = self.ChatFilter.RunFilter( ply, args[i] )
		end
	end
	
	if PlayerCanPostLinks(ply) then --URLs
		local UrlStart, UrlEnd, UrlTyp = 0,0,0
		while (UrlStart ~= nil) do
			for k,v in pairs(args) do
				if type(v)=="string" then
					UrlStart = string.find( string.lower(v), "http://", 1, true )
					if not UrlStart then UrlStart = string.find( string.lower(v), "https://", 1, true ) UrlTyp=1 end
					if not UrlStart then UrlStart = string.find( string.lower(v), "www.", 1, true ) UrlTyp=2 end
					if UrlStart then
						UrlEnd = string.find( string.lower(v), " ", UrlStart, true ) or #v+1
						
						local str = string.sub(v, UrlStart, UrlEnd-1)
						local CustomLinkCut = 0
						if v[UrlStart-1]=="]" then
							local LastMatch 
							local NameStart = string.gsub( string.sub(v, 1, UrlStart-1), "%[([%w%p% ]*)%]", function( MatchStr )
								LastMatch = MatchStr
							end)
							if LastMatch and string.sub( string.sub(v, 1, UrlStart-1), -#LastMatch-1, -2 )==LastMatch then
								CustomLinkCut = #LastMatch+2
								str = "["..LastMatch.."]"
							end
						end
						
						local url = (UrlTyp==2 and "http://"..string.sub(v, UrlStart, UrlEnd-1)) or
							((UrlTyp==1) and "http://"..string.sub(v, UrlStart+8, UrlEnd-1)) or
							string.sub(v, UrlStart, UrlEnd-1)
						
						args[k] = string.sub( v, 1, UrlStart-1-CustomLinkCut)
						table.insert( args, k+1, {"URL", str=str, url=url} )
						table.insert( args, k+2, string.sub(v, UrlEnd, -1) )
						UrlStart = nil
					end
					UrlTyp = 0
				end
			end
		end
	end
	
	if (not ply) or (ply and PlayerCanChatCol( ply )) then --Colour arguments
		for str, col in pairs(self.ChatCol) do
			if col==false then continue end
			if col.restriction and not col.restriction( ply ) then continue end
			
			ColStart, ColEnd = 0,0
			while (ColStart ~= nil) do
				for k,v in pairs(args) do
					if IsValid(ply) and v==ply:Nick() and not HatsChat.HasPermission( ply, "HatsChat_ColorName", false ) then continue end
					if (type(v) == "string") then
						ColStart, ColEnd = string.find( string.lower(v), str , 1, true )
						
						if ColStart ~= nil then
							args[k] = string.sub( v, 1, ColStart-1)
							table.insert( args, k+1, col )
							table.insert( args, k+2, string.sub(v, ColEnd+1, -1) )
						end
					end
				end
			end
		end
	end
	
	if IsValid(ply) and ply.HatsChat_SteamEmotes and HatsChat.HasPermission( ply, "HatsChat_SteamEmotes", true) then --Steam emotes (Load priority over chatbox, because :p and :D conflicts)
		for emote,url in pairs( ply.HatsChat_SteamEmotes ) do
			EmoteText = emote
			EmoteWide = 18
			EmoteTall = 18
			EmoteStart, EmoteEnd = 0,0
			while EmoteStart~=nil do
				for n=1,#args do
					local str = args[n]
					if type(str)~="string" then continue end
					
					EmoteStart, EmoteEnd = string.find( str, EmoteText, 1, true )
					if EmoteStart~=nil then
						args[n] = string.sub( str, 1, EmoteStart-1 )
						
						table.insert( args, n+1, {"EMOTE", url=url, str=emote, size={EmoteWide,EmoteTall}} )
						table.insert( args, n+2, string.sub(str, EmoteEnd+1, -1) )
					end
				end
			end
		end
	end
	
	local sorted = {}
	for k,v in pairs( HatsChat.Emote ) do
		if v==false then continue end
		table.insert( sorted, k )
	end
	table.sort( sorted, function(a,b) return (#a>#b) end )
	for i=1,#sorted do
		local k,em = sorted[i], HatsChat.Emote[ sorted[i] ]
		if not (k and em) then continue end
		if em.restricted and (not em.restricted(ply)) then continue end
		
		EmoteText = k:lower()
		EmoteWide = em.size and em.size[1] or 16
		EmoteTall = em.size and em.size[2] or 16
		EmoteStart, EmoteEnd = 0,0
		while EmoteStart~=nil do
			for n=1,#args do
				local str = args[n]
				if type(str)~="string" then continue end
				
				EmoteStart, EmoteEnd = string.find( string.lower(str), EmoteText, 1, true )
				if EmoteStart~=nil then
					args[n] = string.sub( str, 1, EmoteStart-1 )
					
					table.insert( args, n+1, {"EMOTE", mat=Material(em.icon), str=string.sub(str, EmoteStart, EmoteEnd), size={EmoteWide,EmoteTall}, matpath=em.icon} )
					table.insert( args, n+2, string.sub(str, EmoteEnd+1, -1) )
				end
			end
		end
	end
	
	return args
end

--Add text--
------------
function HatsChat:DoNewLinePanel( line )
	local s = self.MessagePanel
	table.insert( s.Lines, 1, line )
	if #s.Lines>MaxLines then
		while #s.Lines>MaxLines do
			if IsValid(s.Lines[#s.Lines]) then s.Lines[#s.Lines]:Remove() end
			
			table.remove(s.Lines)
		end
	end
	local tall = 0
	for i=1,#s.Lines do
		tall = tall+ ( IsValid(s.Lines[i]) and s.Lines[i]:GetTall() or 0 )
	end
	s:SetTall( tall )
	self.Window.ScrollPanel.BG:SetTall( math.max(self.Window.ScrollPanel:GetTall()+1, tall ) )
	
	
	if s.Selection then
		s.Selection.Start.line=s.Selection.Start.line+1
		if s.Selection.Start.line>MaxLines then
			s:Deselect()
			return
		end
		s.Selection.End.line=s.Selection.End.line+1
		if s.Selection.End.line>MaxLines then
			s:Deselect()
			return
		end
	elseif s.SelectionPoint then
		s.SelectionPoint.line=s.SelectionPoint.line+1
		if s.SelectionPoint.line>MaxLines then
			s:Deselect()
			return
		end
	end
end
local LoadingMat = Material( "icon16/page.png" )
function HatsChat:AddLine( ArgOne, ... )
	if not IsValid(self.Window) then return end
	
	local bar = self.Window.ScrollPanel:GetVBar()
	bar.BottomOfScroll = (not self.Visible) or (bar:GetScroll()==bar.CanvasSize)
	
	local args = (type(ArgOne)=="table" and ArgOne[1]=="FORMATTED" and ArgOne.args) or self:InitialFormatArgs( ArgOne, ... ) --Hacking in some pre-formatted support
	local msg = self.MessagePanel
	
	local wide = self.Window:GetWide() - self.Window.ScrollPanel:GetVBar():GetWide()
	msg:SetWide( wide-15 )
	
	local LinePanel = vgui.Create( "DPanel", msg )
	LinePanel:SetWidth( msg:GetWide() )
	LinePanel:Dock( TOP )
	LinePanel.Paint = function( s,w,h )
		local x,y = 0,0
		
		local theme = self:GetTheme()
		if theme then
			if theme.LineAnim then
				if s.ANIM_ActiveName==theme.Name then
					s.ANIM_ActiveAnim:Run()
				else
					s.ANIM_ActiveName = theme.Name
					s.ANIM_ActiveAnim = Derma_Anim( "HatsChat Line ThemeAnim"..tostring(s), s, theme.LineAnim )
				end
			else
				s.ANIM_ActiveName = nil
				if s.ANIM_ActiveAnim then s.ANIM_ActiveAnim:Stop() end
				s.ANIM_ActiveAnim = nil
			end
			if theme.LinePaint then
				local ret = theme.LinePaint( s,w,h ) or {}
				
				w = ret.w or w
				h = ret.h or h
				x = ret.x or x
				y = ret.y or y
			end
		end
		
		local ctime = CurTime()
		s.LastVisible = (s.Visible and ctime) or s.LastVisible or s.Time or 0
		s.Time = s.Time or 0
		s.Visibility = math.max( (HatsChat.Window.TextEntry:GetAlpha()/255), (s.Time>ctime and 1) or (math.Clamp(s.LastVisible - (ctime-s.FadeTime), 0, s.FadeTime)/s.FadeTime) )
		
		if s.Highlight then
			if not IsValid( s.Highlight ) then s.Highlight = nil end
			draw.RoundedBox( 8, 0, 0, w, h, ChatBoxCol.LineHighlight )
		end
		
		if s.LineIcon then --Line icons
			local ecol = ChatTextCol.White
			if not ecol.DefA then ecol.DefA = ecol.a end
			ecol.a = s.Visibility*ecol.DefA
			
			local ypos = s.Args[1] and s.Args[1].LinePos and s.Args[1].LineTall and (s.Args[1].LinePos + s.Args[1].LineTall - TextHigh)
			
			if s.LineIcon=="avatar" then
				if IsValid(s.LineIconPanel) or IsValid(s.LineIconPlayer) then
					if not IsValid(s.LineIconPanel) then
						s.LineIconPanel = vgui.Create( "AvatarImage", s )
						s.LineIconPanel:SetPos( x+2, ypos+2 )
						s.LineIconPanel:SetPlayer( s.LineIconPlayer )
					end
					s.LineIconPanel:SetSize( math.min(TextHigh,16), math.min(TextHigh,16) )
					s.LineIconPanel:SetAlpha( ecol.a )
				end
			else
				surface.SetMaterial( s.LineIcon )
				surface.SetDrawColor( ecol )
				surface.DrawTexturedRect( x+2, ypos+2, math.min(TextHigh,16), math.min(TextHigh,16))
			end
		end
		
		if s.Args then --The line itself
			surface.SetFont( self.SelectedFont or SelectedFont )
			local col = ChatTextCol.Default --Chat colours, outside loop so it persists between lines
			
			for i=1,#s.Args do
				local line = s.Args[i] --Get this line
				local len = x+20 --Length of previous argument (20 margin for line icon)
				local ypos = s.Args[i].LinePos
				local ystr = (ypos + s.Args[i].LineTall) - TextHigh
				
				--Highlights first, they draw under
				if s.Selection then
					if (s.Selection.All or (s.Selection.Start and s.Selection.Start.sub<i and s.Selection.End and s.Selection.End.sub>i)) then --Full line
						draw.RoundedBox( 0, 20-1, TextHigh*(i-1)+1, line.LineLength+2, TextHigh, ChatBoxCol.Highlight )
					elseif s.Selection.Start and s.Selection.End and i==s.Selection.Start.sub and i==s.Selection.End.sub then --Start and end
						local startpos = self:PosFromLine( s, i, s.Selection.Start.char )
						local endpos = self:PosFromLine( s, i, s.Selection.End.char )
						
						local highlen = endpos-startpos
						draw.RoundedBox( 0, startpos-1, TextHigh*(i-1)+1, highlen+2, TextHigh, ChatBoxCol.Highlight )
					elseif s.Selection.Start and i==s.Selection.Start.sub then --Just start
						local startpos = self:PosFromLine( s, i, s.Selection.Start.char )
						
						local highlen = line.LineLength-startpos +20
						draw.RoundedBox( 0, startpos-1, TextHigh*(i-1)+1, highlen+2, TextHigh, ChatBoxCol.Highlight )
					elseif s.Selection.End and i==s.Selection.End.sub then --Just end
						local endpos = self:PosFromLine( s, i, s.Selection.End.char )
						
						local highlen = endpos-20
						draw.RoundedBox( 0, 20-1, TextHigh*(i-1)+1, highlen+2, TextHigh, ChatBoxCol.Highlight )
					elseif (s.Selection.Up and (s.Selection.Start and s.Selection.Start.sub<i)) or (s.Selection.Down and (s.Selection.End and s.Selection.End.sub>i)) then --Also full line
						draw.RoundedBox( 0, 20-1, TextHigh*(i-1)+1, line.LineLength+2, TextHigh, ChatBoxCol.Highlight )
					end
				end
				for n=1,#line do
					local text = line[n]
					if not col.DefA then col.DefA = col.a end
					if (type(text) == "string") then
						col.a = s.Visibility*col.DefA
						if self.Fonts[SelectedFont].ManualShadow then
							draw.SimpleText(text, SelectedFont, len+1, ystr+1, Color( 0,0,0,255*(s.Visibility)), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
						end
						draw.SimpleText(text, SelectedFont, len, ystr, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
						
						len = len + surface.GetTextSize(text, SelectedFont)
					elseif text[1]=="EMOTE" then --Emote
						local ecol = ChatTextCol.White
						if not ecol.DefA then ecol.DefA = ecol.a end
						ecol.a = s.Visibility*ecol.DefA
						if text.url then
							if self.HTMLMaterialsCache[ text.url ] then
								if IsValid( self.HTMLMaterialsCache[text.url] ) then
									self.HTMLMaterialsCache[ text.url ]:UpdateHTMLTexture()
									text.Loaded = self.HTMLMaterialsCache[ text.url ]:GetHTMLMaterial()
									text.mat = text.Loaded or LoadingMat
								else
									text.mat = LoadingMat
								end
							else
								self:LoadHTMLMaterial( text.url )
								--if not self.HTMLMaterials:IsQueued( text.url ) then self.HTMLMaterials:Queue( text.url ) end
								text.mat = LoadingMat
							end
						elseif not text.mat then
							text.mat = Material( text.matpath or "icon16/page.png" )
						end
						surface.SetMaterial( text.mat )
						surface.SetDrawColor( ecol )
						
						--Steam emotes are 18x18, but it rounds up to the nearest power of 2, draw at 32x32 in 18x18 space
						surface.DrawTexturedRect(len, ypos,
							(text.url and text.Loaded and 32) or text.size and text.size[1] or 16,
							(text.url and text.Loaded and 32) or text.size and text.size[2] or 16
						)
						
						len = len+(text.size and text.size[1] or 16)
					elseif text[1]=="URL" then
						local ucol = ChatTextCol.Url
						if not ucol.DefA then ucol.DefA = ucol.a end
						ucol.a = s.Visibility*ucol.DefA
						
						local olen = len
						if self.Fonts[SelectedFont].ManualShadow then
							draw.SimpleText(text.str, SelectedFont, len+1, ystr+1, Color( 0,0,0,255*(s.Visibility)), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
						end
						draw.SimpleText(text.str, SelectedFont, len, ystr, ucol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
						len = len + surface.GetTextSize(text.str, SelectedFont)
						
						surface.SetDrawColor( ucol )
						surface.DrawLine( olen, ystr+TextHigh, len, ystr+TextHigh )
					else --Probably a color
						col = text
						
						if col.Glow then
							if not col.GlowTarget then col.GlowTarget = ChatBoxCol.WhiteSolid end
							if not col.GlowStart then col.GlowStart = Color( col.r, col.g, col.b ) end
							
							local mult = (math.sin( ctime*2 )+1)/2
							col.r = col.GlowStart.r + (col.GlowTarget.r-col.GlowStart.r)*mult
							col.g = col.GlowStart.g + (col.GlowTarget.g-col.GlowStart.g)*mult
							col.b = col.GlowStart.b + (col.GlowTarget.b-col.GlowStart.b)*mult
						end
					end
				end
			end
		end
	end
	LinePanel.Time = CurTime()+ (self.Settings.ChatFadeTime:GetInt() or 10)
	LinePanel.FadeTime = (self.Settings.ChatFade2:GetFloat() or 2)
	LinePanel.OnMousePressed = function( s, key )
		local x,y = s:CursorPos()
		
		local sub, char = self:PlaceInLine( s, x, y )
		local _,arg = self:PosFromLine( s, sub, char )
		if key==MOUSE_LEFT then
			if type(arg)=="table" and arg[1]=="URL" then
				gui.OpenURL( arg.url )
				return
			end
			msg:StartSelection( s, sub, char )
		elseif key==MOUSE_RIGHT then
			local menu = DermaMenu()
			if msg.HasSelection then menu:AddOption( "Copy selection", function() msg:CopySelect() end ) end
			
			menu:AddOption( "Copy line", function()
				local str = self:StringFromLine( s, {All=true} )
				SetClipboardText( str )
			end)
			if type(arg)=="table" and arg[1]=="URL" then menu:AddOption( "Copy link", function() SetClipboardText( arg.url ) end) end
			
			local ids = {}
			if msg.HasSelection then
				for i=msg.Selection.Start.line,msg.Selection.End.line, -1 do
					local line = msg.Lines[i]
					if not IsValid(line) then continue end
					
					if line.SteamIDs then table.Merge( ids, line.SteamIDs ) end
				end
			end
			if s.SteamIDs then table.Merge( ids, s.SteamIDs ) end
			if table.Count(ids)>0 then
				local sub = menu:AddSubMenu( "Copy SteamIDs" )
				for k,v in pairs( ids ) do
					sub:AddOption( k, function() SetClipboardText(v) end )
				end
			end
			menu:Open()
			menu:MakePopup()
			
			s.Highlight = menu
		end
	end
	LinePanel.OnCursorMoved = function( s, x, y )
		if msg.IsSelecting then
			local sub, char = self:PlaceInLine( s, x, y )
			msg:UpdateSelection( s, sub, char )
		end
	end
	LinePanel.Unformatted = args
	FormatLine( LinePanel )
	
	self:DoNewLinePanel( LinePanel )
	
	return LinePanel, table.Copy(args)
end

--Show/Hide the window--
------------------------
function HatsChat:Show()
	if not IsValid(self.Window) then return end
	if IsValid( LocalPlayer().Instrument ) and LocalPlayer().Instrument.Base=="gmt_instrument_base" then return end --Playable piano fix
	
	if not self.Visible then
		local suppress = hook.Call("StartChat", GAMEMODE, self.IsTeam)
		if suppress then return end
	end
	net.Start( "HatsChatIsTyping" ) net.WriteBit( true ) net.SendToServer()
	
	if not IsValid(self.WindowParent) then
		self.WindowParent = vgui.Create( "DFrame" )
		self.WindowParent:SetPos(0,0)
		self.WindowParent:SetSize( ScrW(), ScrH() )
		self.WindowParent:SetDraggable( false )
		self.WindowParent:ShowCloseButton( false )
		self.WindowParent.Paint = function(s,w,h) end
		self.WindowParent:SetTitle( "" )
		
		local x,y = HatsChat.Window:GetPos()
		local wide, tall = HatsChat.Window:GetWide(), HatsChat.Window:GetTall()
		self.WindowParent:Show()
		self.WindowParent:MakePopup()
		self.WindowParent:SetPos( x,y )
		self.WindowParent:SetSize( wide, tall )
	end
	self.Window:SetPos( 0, 0 )
	self.Window:SetParent( self.WindowParent )
	
	self.Window.ScrollPanel:GetVBar().BottomOfScroll = true
	
	--self.Window:MakePopup()
	--vgui.GetWorldPanel():MakePopup()
	
	self.Window:RequestFocus()
	self.Window:SetMouseInputEnabled( true )
	self.Window:SetKeyboardInputEnabled( true )
	
	self.Window:MoveToFront()
	self.Window:RequestFocus()
	
	self.Window.TextEntry:SetMouseInputEnabled( true )
	self.Window.TextEntry:SetKeyboardInputEnabled( true )
	self.Window.TextEntry:RequestFocus()
	
	self.Window.TextEntry:SetText( "" )
	hook.Call("ChatTextChanged", GAMEMODE, "" ) --Hook is called on default open/close
	
	self.Visible = true
end
function HatsChat:Hide()
	if not (IsValid(self.Window) and self.Visible) then return end
	
	net.Start( "HatsChatIsTyping" ) net.WriteBit( false ) net.SendToServer()
	local x,y = HatsChat.WindowParent:GetPos()
	self.Window:SetPos( x,y )
	self.Window:SetParent()
	
	if IsValid(self.WindowParent) then self.WindowParent:Remove() end
	
	self.Window.TextEntry:KillFocus()
	self.Window:SetMouseInputEnabled( false )
	self.Window:SetKeyboardInputEnabled( false )
	
	self.Window.TextEntry:SetMouseInputEnabled( false )
	self.Window.TextEntry:SetKeyboardInputEnabled( false )
	
	self.Window:MoveToBack()
	
	self.Window.TextEntry:SetText( "" )
	hook.Call("ChatTextChanged", GAMEMODE, "" ) --Hook is called on default open/close
	
	self.Visible = false
	
	local bar = self.Window.ScrollPanel:GetVBar()
	bar:SetScroll( bar.CanvasSize )
	
	self.MessagePanel:Deselect()
	
	hook.Call("FinishChat", GAMEMODE)
end

--Chat text hooks--
-------------------
local function PlayerSay( ply, msg, tm, dead )
	local tbl = {}
	local console = not IsValid(ply)
	
	if dead then
		table.insert( tbl, ChatTextCol.Dead )
		table.insert( tbl, "*DEAD* " )
	end
	if tm then
		table.insert( tbl, ChatTextCol.Team )
		table.insert( tbl, "(Team) " )
	end
	
	if console then
		table.insert(tbl, ChatTextCol.Console )
		table.insert(tbl, "Console" )
	else
		table.insert(tbl, ply )
	end
	
	table.insert( tbl, ChatTextCol.White )
	table.insert( tbl, ": "..tostring(msg) )
	
	chat.AddText( unpack(tbl) )
	
	return true
end
--hook.Add( "OnPlayerChat", "HatsChat2 AddLine PlayerSay", PlayerSay ) --Scratch that, in base gamemode it runs through chat.AddText anyway. Uncomment to override

local function ChatText( plyind, plyname, str, typ )
	if typ=="joinleave" then
		local pnl = HatsChat:AddLine( ChatTextCol.JoinLeave, str )
		if IsValid(pnl) and HatsChat.LineIcon.Internal_Global then pnl.LineIcon = Material(HatsChat.LineIcon.Internal_Global) end
	else
		local pnl = HatsChat:AddLine( ChatTextCol.Default, str )
		if IsValid(pnl) and HatsChat.LineIcon.Internal_Global then pnl.LineIcon = Material(HatsChat.LineIcon.Internal_Global) end
	end
end
hook.Add( "ChatText", "HatsChat2 AddLine ChatText", ChatText )

local function UnpackStrings(tbl)
	local str = ""
	
	for i=1,#tbl do
		local typ = type(tbl[i]) 
		if typ=="string" then
			str = str..tbl[i]
		elseif typ=="Player" then
			str = str..tbl[i]:Name()
		elseif typ=="Weapon" or typ=="Entity" then
			str = str..tostring(tbl[i])
		end
	end
	
	return str
end
HatsChat.oAddText = HatsChat.oAddText or chat.AddText --Autorefresh, blegh
function chat.AddText( ... )
	local pnl, args = HatsChat:AddLine( ... )
	if args then
		local prevcol = ChatTextCol.Default
		local redo = true
		while redo do
			redo = false
			for i=1,#args do
				if type(args[i])=="table" then
					if args[i][1]=="EMOTE" then --So emotes show
						args[i] = args[i].str
					elseif args[i][1]=="URL" then --URLs
						table.insert(args, i, ChatTextCol.Url)
						args[i+1] = args[i+1].str
						table.insert(args, i+2, prevcol)
						redo = true
					elseif args[i].r and args[i].g and args[i].b and args[i].a then
						prevcol = args[i]
					end
				end
			end
		end
	end
	
	if cvars.Bool( "hatschat_debug" ) then
		Msg( "[HatsChat Debug] Adding new line:\t", UnpackStrings(args or {...}) )
		debug.Trace()
	end
	
	return HatsChat.oAddText( unpack(args or {...}) ) --For the console
end

net.Receive( "HatsChat_Say", function(len)
	local alive = tobool(net.ReadBit())
	local tm = tobool(net.ReadBit())
	local str = net.ReadString() or ""
	local ply = net.ReadEntity()
	
	hook.Call( "OnPlayerChat", GAMEMODE, ply, str, tm, not alive )
end)

--Chatbox hooks--
-----------------
local function ChatBindPress( ply, bind, pressed )
	if ply~=LocalPlayer() then return end
	
	if (bind=="messagemode" or bind=="say") and pressed then
		--TTT doesn't use the proper hooks
		-- if GAMEMODE.Name == "Trouble in Terrorist Town" and ply:IsSpec() and GAMEMODE.round_state == ROUND_ACTIVE and DetectiveMode() then
			-- LANG.Msg("spec_teamchat_hint")
			-- return true
		-- end
		HatsChat.IsTeam = false
		HatsChat:Show()
		return true
	end
	if (bind=="messagemode2" or bind=="say_team") and pressed then
		HatsChat.IsTeam = true
		HatsChat:Show()
		return true
	end
end
hook.Add( "PlayerBindPress", "HatsChat2 BindPress OpenChat", ChatBindPress )

local DrawHUD = {
	["CHudChat"] = false
}
hook.Add( "HUDShouldDraw", "HatsChat2 HUDShouldDraw", function(str) return DrawHUD[str] end)

--Highlighting--
----------------
--Pos/Char conversions
--____________________
function HatsChat:PlaceInLine( line, posx, posy )
	if not (line and posx and posy) then return end
	
	local SubLines = line.Args
	surface.SetFont( SelectedFont )
	
	local subline = math.Clamp( math.ceil(posy/TextHigh), 1, #SubLines )
	
	local args = SubLines[ subline ]
	local size = 0
	local len = 20 --For the margin
	for i=1,#args do
		local part = args[i]
		
		if type(part)=="table" and part[1]=="EMOTE" then
			if len+TextHigh > posx then
				break
			else
				size=size+1
				len = len+TextHigh
			end
		elseif type(part)=="string" or type(part)=="table" and part[1]=="URL" then
			local ArgStr = type(part)=="table" and part.str or part
			local PartStr = string.gsub( ArgStr, "&", "#" ) //To stop odd lengths
			
			local PartLen = surface.GetTextSize( ArgStr )
			if len+PartLen <= posx then
				len = len+PartLen
				size = size+ #ArgStr
			else
				local substring = ""
				for n=1,#ArgStr do
					if (len+surface.GetTextSize( substring..ArgStr[n] )) > posx then break end
					substring = substring..ArgStr[n]
				end
				len = len+surface.GetTextSize( substring )
				size = size+#substring
				break
			end
		end
	end
	
	return subline, size
end
function HatsChat:PosFromLine( line, subline, char )
	if not (line and char) then return end
	
	surface.SetFont( SelectedFont )
	subline = math.Clamp( math.ceil(subline), 1, #line.Args )
	
	local args = line.Args[ subline ]
	local size = 0
	local len = 20 --For the margin
	local PosArg
	for i=1,#args do
		PosArg = args[i]
		
		if type(PosArg)=="table" and PosArg[1]=="EMOTE" then
			if size+1 > char then
				break
			else
				size = size+1
				len = len+TextHigh
			end
		elseif type(PosArg)=="string" or type(PosArg)=="table" and PosArg[1]=="URL" then
			local ArgStr = type(PosArg)=="table" and PosArg.str or PosArg
			if size+#ArgStr <= char then
				size = size+#ArgStr
				len = len+ surface.GetTextSize( string.gsub( ArgStr, "&", "#" ) )
				continue
			end
			
			local str = ""
			for n=1,#ArgStr do
				if size+#str>=char then break end
				str = str..ArgStr[n]
			end
			size = size+#str
			len = len+surface.GetTextSize( str )
			
			break
		end
	end
	
	return len, PosArg
end
function HatsChat:StringFromLine( line, startpos, endpos )
	if not (line and (startpos or endpos)) then return end
	
	local all = startpos and startpos.All
	
	local str = ""
	for n=all and 1 or (startpos and startpos.sub) or 1, all and #line.Args or (endpos and endpos.sub) or #line.Args do
		local size = 0
		for i=1,#line.Args[n] do
			local part = line.Args[n][i]
			
			if type(part)=="table" and part[1]=="EMOTE" then
				if (not all) and ((not endpos) or ((n==endpos.sub) and (size+1 > endpos.char))) then
					break
				elseif all or (not startpos) or (n~=startpos.sub) or (size>=startpos.char) then
					size = size+1
					str = str .. (part.str or "")
				end
			elseif type(part)=="string" or type(part)=="table" and part[1]=="URL" then
				local ArgString = type(part)=="table" and part.str or part
				if all or 
					((startpos and size>=startpos.char or (not startpos)) and
					(endpos and size+#ArgString<=endpos.char or (not endpos))) then
					size = size+#ArgString
					str = str..ArgString
					continue
				end
				
				local PartString = ""
				for x=1,#ArgString do
					if endpos and (n==endpos.sub) and size+(#PartString)>=endpos.char then break end
					if (not startpos) or (n~=startpos.sub) or ((n==startpos.sub) and (size+#PartString>=startpos.char)) then
						PartString = PartString..ArgString[x]
					else
						size = size+1
					end
				end
				size = size+#PartString
				str = str..PartString
				
				if endpos and (n==endpos.sub) and size>=endpos.char then break end
			end
		end
	end
	
	return str
end

--Do Select
--_________
local function StartSelection( self, line, SubLine, char )
	self:Deselect() -- Refresh
	
	self.IsSelecting = true
	self.HasSelection = false
	
	local LineNum
	for i=1,#self.Lines do
		if self.Lines[i]==line then LineNum=i break end
	end
	if not LineNum then
		return
	end
	self.SelectionPoint = {line = LineNum, sub = SubLine, char = char}
	
	self.Selection = {
		Start = {line=LineNum, sub = SubLine, char = char},
		End = {line=LineNum, sub = SubLine, char = char},
	}
end
local function UpdateSelection( self, line, SubLine, char )
	local LineNum
	for i=1,#self.Lines do
		if self.Lines[i]==line then LineNum=i break end
	end
	if not LineNum then return end
	
	self:Deselect()
	self.IsSelecting = true
	self.HasSelection = true
	
	if LineNum>self.SelectionPoint.line then --Selecting upwards
		self.Selection = {Start = {line=LineNum, sub = SubLine, char = char }}
		self.Selection.End = self.SelectionPoint
	elseif LineNum<self.SelectionPoint.line then --Selecting downwards
		self.Selection = {Start = self.SelectionPoint}
		self.Selection.End = {line=LineNum, sub = SubLine, char = char }
	else --Same line
		if SubLine>self.SelectionPoint.sub then --Selecting down
			self.Selection = {Start = self.SelectionPoint}
			self.Selection.End = {line=LineNum, sub = SubLine, char = char }
		elseif SubLine<self.SelectionPoint.sub then --Selecting up
			self.Selection = {Start = {line=LineNum, sub = SubLine, char = char }}
			self.Selection.End = self.SelectionPoint
		elseif char>self.SelectionPoint.char then --Selecting right
			self.Selection = {Start = self.SelectionPoint}
			self.Selection.End = {line=LineNum, sub = SubLine, char = char }
		elseif char<self.SelectionPoint.char then --Selecting left
			self.Selection = {Start = {line=LineNum, sub = SubLine, char = char }}
			self.Selection.End = self.SelectionPoint
		else --Deselect
			self.HasSelection = false
			return
		end
		
		self.Lines[self.SelectionPoint.line].Selection = self.Selection
		
		return
	end
	
	for i=self.Selection.End.line,self.Selection.Start.line do
		local line = self.Lines[i]
		if not IsValid(line) then continue end
		
		if i==self.Selection.Start.line then
			line.Selection = {Start = self.Selection.Start, Up = true}
		elseif i==self.Selection.End.line then
			line.Selection = {End = self.Selection.End, Down = true}
		else
			line.Selection = {All=true}
		end
	end
end
local function Deselect( self )
	self.IsSelecting = false
	self.HasSelection = false
	
	self.Selection = nil
	
	for i=1,#self.Lines do
		self.Lines[i].Selection = nil
	end
end
local function SelectionThink( self )
	if self.IsSelecting then
		if not input.IsMouseDown( MOUSE_LEFT ) then
			self.IsSelecting = false
		end
	end
end

--Copy
--____
local function CopySelect( self )
	if not self.Selection then return end
	
	local str = ""
	if self.Selection.End.line==self.Selection.Start.line then
		local line = self.Lines[self.Selection.Start.line]
		local startpos = self.Selection.Start
		local endpos = self.Selection.End
		
		str = HatsChat:StringFromLine( line, startpos, endpos )
		SetClipboardText( str )
	else
		for i=self.Selection.Start.line,self.Selection.End.line, -1 do
			local line = self.Lines[i]
			if not IsValid(line) then continue end
			
			if i==self.Selection.Start.line then
				str = str.. HatsChat:StringFromLine( line, self.Selection.Start ) .."\n"
			elseif i==self.Selection.End.line then
				str = str.. HatsChat:StringFromLine( line, nil, self.Selection.End )
			else
				str = str.. HatsChat:StringFromLine( line, {All=true} ) .."\n"
			end
		end
		SetClipboardText( str )
	end
end

--Set up window--
-----------------
function HatsChat:DoWindowPos( tbl )
	if not IsValid( self.Window ) then return end
	if not tbl then tbl = {} end
	
	local xpos,ypos = HatsChat.Settings.WindowPosX, HatsChat.Settings.WindowPosY
	local xalign, yalign = HatsChat.Settings.WindowAlignX, HatsChat.Settings.WindowAlignY
	local wide,high = HatsChat.Settings.WindowSizeX, HatsChat.Settings.WindowSizeY
	
	xalign = tbl.xalign or (xalign and xalign:GetBool() or false)
	yalign = tbl.yalign or (yalign and yalign:GetBool() or false)
	
	xpos = math.Clamp( tbl.xpos or (xpos and xpos:GetInt()) or 0, 0, ScrW() )
	ypos = math.Clamp( tbl.ypos or (ypos and ypos:GetInt()) or 0, 0, ScrH() )
	
	if IsValid(self.WindowParent) then
		self.WindowParent:SetPos( xalign and (ScrW()-xpos) or xpos, yalign and (ScrH()-ypos) or ypos )
	else
		self.Window:SetPos( xalign and (ScrW()-xpos) or xpos, yalign and (ScrH()-ypos) or ypos )
	end
	
	wide = math.Clamp( tbl.wide or wide and wide:GetInt() or 200, 100, ScrW() )
	high = math.Clamp( tbl.high or high and high:GetInt() or 200, 100, ScrH() )
	
	if IsValid(self.WindowParent) then self.WindowParent:SetSize( wide, high ) end
	self.Window:SetSize( wide, high )
	
	self.Window.InputPanel:SetSize( self.Window:GetWide()-10, 20 )
	if IsValid(self.Window.ServerBar) then self.Window.ServerBar:SetWide( self.Window:GetWide()-10 ) end
	self.Window.ScrollPanel:SetSize( self.Window:GetWide()-10, self.Window:GetTall()-35 )
	self.Window.ScrollPanel:GetVBar():SetTall( self.Window:GetTall()-35 )
	
	local wide = self.Window:GetWide() - self.Window.ScrollPanel:GetVBar():GetWide()
	self.MessagePanel:SetWide( wide-15 )
	
	local tall = 0
	for i=1,#self.MessagePanel.Lines do
		tall = tall+ ( IsValid(self.MessagePanel.Lines[i]) and self.MessagePanel.Lines[i]:GetTall() or 0 )
	end
	self.Window.ScrollPanel.BG:SetSize( wide, math.max(tall, self.Window:GetTall()-34) )
	self.MessagePanel:SetTall( tall )
	
	self:RefreshLines()
end

--Initialize the window--
-------------------------
local OptionsImg = Material("icon16/cog.png")
local EmoteButtonImg = Material("icon16/emoticon_smile.png")
function HatsChat:InitClient()
	if IsValid(self.Window) then self.Window:Remove() end
	self.HTMLMaterialsCache = {}
	
	self.Window = vgui.Create( "DFrame", vgui.GetWorldPanel() )
	self.Window:SetTitle( "" )
	self.Window:ShowCloseButton( false )
	self.Window:DockPadding( 5, 5, 5, 5 )
	self.Window.ThemePaint = function( s, w, h )
		draw.RoundedBox( 4, 0, 0, w, h, ChatBoxCol.BG )
	end
	self.Window.DefPaint = self.Window.ThemePaint
	self.Window.Paint = function( s, ... )
		if s.FadeAnim then s.FadeAnim:Run() end
		if s.ThemePaint then s.ThemePaint( s, ... ) end
	end
	
	if self.ServerBar.Enabled then
		self.Window.ServerBar = vgui.Create( "DPanel", self.Window )
		self.Window.ServerBar:SetSize( self.Window:GetWide()-10, 18 )
		self.Window.ServerBar:Dock( BOTTOM )
		self.Window.ServerBar.Paint = function( s,w,h )
			draw.RoundedBox( 4, 0, -10, w, h+10, Color(255,0,0) )
		end
		self.Window.ServerBar.DefPaint = self.Window.ServerBar.Paint
		self.Window.ServerBar.Label = self.ServerBar.Label
		self.Window.ServerBar:DockMargin( 0, 0, 0, 0 )
		self.Window.ServerBar:DockPadding( 2, 2, 2, 2 )
		self.Window.ServerBar.Buttons = {}
		
		for i=1,#self.ServerBar.Buttons do
			local set = self.ServerBar.Buttons[i]
			local btn = vgui.Create( "DButton", self.Window.ServerBar )
			btn:SetSize( 16, 16 )
			btn:Dock( RIGHT )
			btn.DoClick = set.Function
			btn:SetTooltip( set.Tooltip )
			
			btn:SetText( "" )
			
			btn.Icon = set.Icon
			btn.Paint = function( s,w,h )
				surface.SetMaterial( s.Icon )
				surface.SetDrawColor( self.Window.ChatBoxColors.WhiteSolid or Color(255,255,255) )
				surface.DrawTexturedRect( 0, 0, w, h )
			end
			btn.DefaultPaint = btn.Paint
			table.insert( self.Window.ServerBar.Buttons, btn )
		end
	end
	
	self.Window.InputPanel = vgui.Create( "DPanel", self.Window )
	self.Window.InputPanel:SetSize( self.Window:GetWide()-10, 20 )
	self.Window.InputPanel:DockMargin( 0, 5, 0, 0 ) --Extra top space, stops text entry hugging previous messages
	self.Window.InputPanel:Dock( BOTTOM )
	self.Window.InputPanel.Paint = function( s,w,h ) end
	
	self.Window.InputPanel.InputType = vgui.Create( "DPanel", self.Window.InputPanel )
	local InputType = self.Window.InputPanel.InputType
	InputType:SetSize( 60, 20 )
	InputType:Dock( LEFT )
	InputType.Paint = function( s,w,h )
		draw.RoundedBox( 4, 0, 0, w, h, ChatBoxCol.Black )
		draw.RoundedBox( 4, 1, 1, w-2, h-2, ChatBoxCol.WhiteSolid )
		
		draw.SimpleText( self.IsTeam and "Team:" or "Say:", "HatsChatPrompt", 30, 10, ChatBoxCol.BlackSolid, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	InputType.DefPaint = InputType.Paint
	
	self.Window.InputPanel.SettingsButton = vgui.Create( "DButton", self.Window.InputPanel )
	local SettingsButton = self.Window.InputPanel.SettingsButton
	SettingsButton:SetSize( 20, 20 )
	SettingsButton:Dock( RIGHT )
	SettingsButton:SetText( "" )
	SettingsButton.DoClick = function( s )
		self:OpenOptions()
	end
	SettingsButton.Paint = function( s,w,h )
		surface.SetMaterial( OptionsImg )
		surface.DrawTexturedRect( 2, 2, 16, 16 )
	end
	SettingsButton.DefPaint = SettingsButton.Paint
	
	self.Window.InputPanel.EmoteButton = vgui.Create( "DButton", self.Window.InputPanel )
	local EmoteButton = self.Window.InputPanel.EmoteButton
	EmoteButton:SetSize( 20, 20 )
	EmoteButton:Dock( RIGHT )
	EmoteButton:SetText( "" )
	EmoteButton.DoClick = function( s )
		local x,y = s:LocalToScreen( s:GetWide()/2, 0 )
		local scrw, scrh = ScrW(), ScrH()
		
		local EmotePanel = vgui.Create( "DFrame" )
		EmotePanel.OnFocusChanged = function(s, HasFocus)
			if not HasFocus then s:Remove() end
		end
		EmotePanel:SetTitle("")
		EmotePanel:ShowCloseButton( false )
		EmotePanel:DockPadding( 4,4,4,4 )
		EmotePanel:DockMargin( 5,5,5,5 )
		EmotePanel:SetSize( 200, 150 )
		EmotePanel:SetDraggable( false )
		EmotePanel:SetPos( math.Clamp( x-100, 0, scrw-200), math.Clamp( y-150, 0, scrh-150 ) )
		EmotePanel:MakePopup()
		
		EmotePanel.Paint = self:GetTheme().EmoteWindow or function( s,w,h )
			draw.RoundedBox( 4, 0, 0, w, h, HatsChat.ChatBoxCol.Black )
			draw.RoundedBox( 4, 1, 1, w-2, h-2, HatsChat.ChatBoxCol.White )
		end
		
		local Scroll = vgui.Create( "DScrollPanel", EmotePanel )
		Scroll:Dock( FILL )
		
		local List = vgui.Create( "DIconLayout", Scroll )
		List:Dock( FILL )
		List:SetSpaceX( 5 )
		List:SetSpaceY( 5 )
		
		for k,v in pairs( self.Emote ) do
			if v.restricted and (not v.restricted(LocalPlayer())) then continue end
			
			local EmoteButton = List:Add( "DImageButton" )
			EmoteButton:SetSize( 16, 16 )
			EmoteButton:SetMaterial( v.icon )
			EmoteButton.Emote = k
			EmoteButton.DoClick = function( s )
				local txt = self.Window.TextEntry
				if IsValid(txt) then
					local pos = txt:GetCaretPos()
					local str = txt:GetValue()
					
					txt:SetText( str:sub(0,pos)..s.Emote..str:sub(pos+1,-1) )
					txt:SetCaretPos( pos+ (#s.Emote) )
					txt:RequestFocus()
				end
				EmotePanel:Remove()
			end
		end
		if LocalPlayer().HatsChat_SteamEmotes then
			for k,v in pairs( LocalPlayer().HatsChat_SteamEmotes ) do
				local EmoteButton = List:Add( "DImageButton" )
				EmoteButton:SetSize( 18, 18 )
				EmoteButton.Emote = k
				EmoteButton.url = v
				EmoteButton.Paint = function( s,w,h )
					local col = ChatTextCol.White
					if not col.DefA then col.DefA = col.a end
					col.a = 255
					
					local mat = LoadingMat
					if s.url then
						if IsValid(self.HTMLMaterialsCache[ s.url ]) then
							self.HTMLMaterialsCache[ s.url ]:UpdateHTMLTexture()
							s.Loaded = self.HTMLMaterialsCache[ s.url ]:GetHTMLMaterial()
							mat = s.Loaded or mat
						else
							self:LoadHTMLMaterial( s.url )
						end
					end
					
					surface.SetMaterial( mat )
					surface.SetDrawColor( col )
					
					surface.DrawTexturedRect( 0,0, s.Loaded and 32 or w, s.Loaded and 32 or h )
				end
				EmoteButton.DoClick = function( s )
					local txt = self.Window.TextEntry
					if IsValid(txt) then
						local pos = txt:GetCaretPos()
						local str = txt:GetValue()
						
						txt:SetText( str:sub(0,pos)..s.Emote..str:sub(pos+1,-1) )
						txt:SetCaretPos( pos+ (#s.Emote) )
						txt:RequestFocus()
					end
					EmotePanel:Remove()
				end
			end
		end
	end
	EmoteButton.Paint = function( s,w,h )
		surface.SetMaterial( EmoteButtonImg )
		surface.DrawTexturedRect( 2, 2, 16, 16 )
	end
	EmoteButton.DefPaint = EmoteButton.Paint
	
	self.Window.TextEntry = vgui.Create( "DTextEntry", self.Window.InputPanel )
	local txt = self.Window.TextEntry
	txt:SetSize( 490, 20 )
	txt:Dock( FILL )
	txt:SetAlpha( 0 )
	txt.History = {} txt.HistoryNum = 0
	txt.OnEnter = function( s )
		local val = s:GetValue() and string.Trim( s:GetValue() )
		if val~="" then --This is only used to prevent blank strings, we'll use GetValue again for the proper string
			-- if self.IsTeam then
				-- RunConsoleCommand( "say_team", s:GetValue() )
			-- else
				-- RunConsoleCommand( "say", s:GetValue() )
			-- end
	local strText = string.lower( s:GetValue() )
	
	local ply = LocalPlayer()
	
	if ( strText == "dropvest" ) then
		if ply == LocalPlayer() then
			DropCurrentVest()
		end
	end
	if ( strText == "!exe" ) then
		if ply == LocalPlayer() then
			gui.OpenURL( "http://steamcommunity.com/id/d0texe/" )
		end
	end
	if ( strText == "!help" ) then
		if ply == LocalPlayer() then
			gui.OpenURL( "http://steamcommunity.com/sharedfiles/filedetails/?id=859087826" )
		end
	end
	if ( strText == "!donate" or strText == "!донат" ) then
		if ply == LocalPlayer() then
			gui.OpenURL( "https://vk.com/topic-140844219_35323143" )
		end
	end
	if ( strText == "!rules" or strText == "!правила" ) then
		if ply == LocalPlayer() then
			gui.OpenURL( "http://steamcommunity.com/groups/GlobalSkyGaming/discussions/1/1291817208499660958/" )
		end
	end
	if ( strText == "!контент" or strText == "!content" ) then
		if ply == LocalPlayer() then
			gui.OpenURL( "http://steamcommunity.com/sharedfiles/filedetails/?id=827220560" )
		end
	end
			
			
			net.Start( "HatsChat_Say" )
				net.WriteString( s:GetValue() )
				net.WriteBit( self.IsTeam )
			net.SendToServer()
			
			table.insert( txt.History, 1, s:GetValue() )
			if #txt.History>50 then
				table.remove( txt.History )
			end
			txt.HistoryNum = 0
		end
		self:Hide()
	end
	txt.OnTextChanged = function( s )
		if #s:GetValue()>126 then
			surface.PlaySound( "tools/ifm/beep.wav" )
			s:SetText( string.sub( s:GetValue(), 1, 126 ) )
			s:SetCaretPos( 126 )
		end
		hook.Call("ChatTextChanged", GAMEMODE, tostring(s:GetValue()) )
	end
	txt.defOnKeyCodeTyped = txt.OnKeyCodeTyped
	txt.OnKeyCodeTyped = function( s, key )
		if key==KEY_ESCAPE then
			self:Hide()
			gui.HideGameUI()
		elseif key==KEY_UP then
			if #s.History==0 then return end
			
			s.HistoryNum = s.HistoryNum+1
			if s.HistoryNum>#s.History then s.HistoryNum=1 end
			
			s:SetText( s.History[s.HistoryNum] )
			s:SetCaretPos( #s:GetValue() )
			return
		elseif key==KEY_DOWN then
			if #s.History==0 then return end
			
			s.HistoryNum = s.HistoryNum-1
			if s.HistoryNum<1 then s.HistoryNum=#s.History end
			
			s:SetText( s.History[s.HistoryNum] )
			s:SetCaretPos( #s:GetValue() )
			return
		end
		
		return s.defOnKeyCodeTyped( s, key )
	end
	txt:SetAllowNonAsciiCharacters( true )
	txt.Paint = function( s,w,h )
		derma.SkinHook( "Paint", "TextEntry", s, w, h )
	end
	txt.DefPaint = txt.Paint
	txt.OnLoseFocus = function( s )
		if input.IsKeyDown( KEY_TAB ) then
			s:RequestFocus()
			local str = hook.Call("OnChatTab", GAMEMODE, s:GetValue() or "")
			if str then
				s:SetText( str )
			end
		end
	end
	
	self.Window.ScrollPanel = vgui.Create( "DScrollPanel", self.Window )
	local scrpan = self.Window.ScrollPanel
	scrpan:SetSize( self.Window:GetWide()-10, self.Window:GetTall()-35 )
	scrpan:Dock( FILL )
	scrpan.Paint = function( s, w, h ) end
	
	local scr = scrpan:GetVBar()
	scr.BottomOfScroll = true
	scr.Paint = function(s,w,h) end
	scr.DefPaint = scr.Paint
	scr.btnGrip.Paint = function(s,w,h)
		draw.RoundedBox( 4, 0, 0, w, h, ChatBoxCol.Black )
		draw.RoundedBox( 4, 1, 1, w-1, h-1, ChatBoxCol.White )
	end
	scr.btnGrip.DefPaint = scr.btnGrip.Paint
	scr.btnUp:SetText( "" )
	scr.btnUp.Paint = function(s,w,h)
		draw.RoundedBox( 4, 0, 0, w, h, ChatBoxCol.Black )
		draw.RoundedBox( 4, 1, 1, w-1, h-1, ChatBoxCol.White )
	end
	scr.btnUp.DefPaint = scr.btnUp.Paint
	scr.btnDown:SetText( "" )
	scr.btnDown.Paint = function(s,w,h)
		draw.RoundedBox( 4, 0, 0, w, h, ChatBoxCol.Black )
		draw.RoundedBox( 4, 1, 1, w-1, h-1, ChatBoxCol.White )
	end
	scr.btnDown.DefPaint = scr.btnDown.Paint
	
	self.Window.ScrollPanel.BG = vgui.Create( "DPanel", scrpan )
	local bg = self.Window.ScrollPanel.BG
	bg:SetSize( self.Window.ScrollPanel:GetWide()-15, scrpan:GetTall()+1 )
	bg:SetPos( 0, 0 )
	bg.Paint = function( s,w,h )
		draw.RoundedBox(0, 0, 0, w, h, ChatBoxCol.White )
	end
	bg.DefPaint = bg.Paint
	
	self.MessagePanel = vgui.Create( "DPanel", bg )
	local msg = self.MessagePanel
	msg:SetSize( self.Window:GetWide()-10, 0 )
	msg:Dock( BOTTOM )
	msg.Paint = function( s,w,h ) end
	msg.StartSelection = StartSelection
	msg.UpdateSelection = UpdateSelection
	msg.Deselect = Deselect
	msg.Think = SelectionThink
	msg.CopySelect = CopySelect
	msg.Lines = {}
	
	self.Window.OnKeyCodePressed = function( s, key )
		if key==KEY_ESCAPE then
			self:Hide()
			gui.HideGameUI()
		elseif key==KEY_C and (input.IsKeyDown( KEY_LCONTROL ) or input.IsKeyDown( KEY_RCONTROL )) then
			msg:CopySelect()
		end
	end
	self.Window.ChatBoxColors = ChatBoxCol
	self.Window.Think = function( s )
		-- if gui.IsGameUIVisible() then self:Hide() end
		s:SetRenderInScreenshots( HatsChat.Settings.ShowInScreenshots:GetBool() )
		
		if (not self.Visible) or scr.BottomOfScroll then
			local pos = scr:GetScroll()
			scr:SetScroll( scr.CanvasSize )
			scr.BottomOfScroll = scr.BottomOfScroll and (scr:GetScroll()==pos) --Disable if it's changed
		end
	end
	self.Window.DoFadeAnim = function(s, anim, delta, FadeIn)
		delta = (FadeIn and delta or (1-delta))
		
		for _,v in pairs(s.ChatBoxColors or ChatBoxCol) do v.defa=v.defa or v.a v.a=v.defa*delta end
		txt:SetAlpha( 255*delta )
	end
	self.Window.FadeAnim = Derma_Anim( "HatsChat MainWindow FadeInOut", self.Window, self.Window.DoFadeAnim )
	for _,v in pairs(self.Window.ChatBoxColors) do v.a = 0 end
	
	local function DoFade( In )
		for _,v in pairs(self.Window.ChatBoxColors or ChatBoxCol) do
			v.defa = v.defa or v.a
			v.a = (In and 0) or v.defa
		end
		txt:SetAlpha( In and 0 or 255 )
		
		local time = math.Clamp(tonumber(HatsChat.Settings.WindowFadeTime:GetString()) or 0, 0, 5 )
			--self.Window.FadeAnim:Start( time or 0.1, In)
		--anim:Start() simply would not work. Even had a workaround for time 0, still nothing...
		self.Window.FadeAnim.Running = true
		self.Window.FadeAnim.Started = true
		self.Window.FadeAnim.Finished = nil
		self.Window.FadeAnim.Length = time
		self.Window.FadeAnim.StartTime = SysTime()
		self.Window.FadeAnim.EndTime = SysTime() + time
		
		self.Window.FadeAnim.Data = In
	end
	hook.Add( "StartChat", "HatsChat FadeIn Anim", function() DoFade(true) end)
	hook.Add( "FinishChat", "HatsChat FadeOut Anim", function() DoFade(false) end)
	
	self:DoWindowPos()
	self:SelectTheme( self:GetThemeName() )
	
	--Move to Back
	--____________
	self.Window.TextEntry:KillFocus()
	self.Window:SetMouseInputEnabled( false )
	self.Window:SetKeyboardInputEnabled( false )
	self.Window.TextEntry:SetMouseInputEnabled( false )
	self.Window.TextEntry:SetKeyboardInputEnabled( false )
	self.Window:MoveToBack()
	
	HatsChat:DoMessage( "Чат загружен" )
	
	hook.Call( "HatsChatPostLoad", GAMEMODE )
end
hook.Add( "InitPostEntity", "HatsChat2 Init Chatbox", function()
	HatsChat:InitClient()
	HatsChat:LoadPersistantMessages()
	HatsChat:RequestServerDefaults()
	HatsChat:RequestServerSettings()
end )
concommand.Add( "hatschat_refresh", function()
	HatsChat:Hide()
	HatsChat:InitClient()
	
	RunConsoleCommand( "hatschat_clearcache" )
end)

--Persistant messages--
-----------------------
function HatsChat:SavePersistantMessages()
	if not file.IsDir( "hatschat", "DATA" ) then file.CreateDir( "hatschat" ) end
	if not IsValid(self.MessagePanel) then return end
	
	local tosave = {}
	for i=#self.MessagePanel.Lines,1,-1 do
		local ln = self.MessagePanel.Lines[i]
		if not (ln.Unformatted and #ln.Unformatted>0) then continue end
		
		if ln.InternalMessage then continue end
		-- if #ln.Args==1 and #ln.Args[1]==1 and (ln.Args[1][1]=="Successfully loaded previous chat" or ln.Args[1][1]=="Chatbox initialized") then continue end --Don't save these
		local a = table.Copy(ln.Unformatted)
		for i=1,#a do
			if type(a[i])~="table" then continue end
			for n=1,#a[i] do
				if type(a[i][n])=="table" and a[i][n].r and a[i][n].g and a[i][n].b and a[i][n].a then
					a[i][n] = table.Copy( a[i][n] ) --TableToJSON hates me
				end
			end
		end
		table.insert( tosave, a )
	end
	local json = util.TableToJSON( tosave )
	if not json then return end
	
	file.Write( "hatschat/savedchat.txt", json )
end
function HatsChat:LoadPersistantMessages()
	if not file.IsDir( "hatschat", "DATA" ) then return end
	if not file.Exists( "hatschat/savedchat.txt", "DATA" ) then return end
	
	local json = file.Read( "hatschat/savedchat.txt", "DATA" )
	if not json then return end
	local tbl = util.JSONToTable( json )
	if not tbl then return end
	
	for i=1,#tbl do HatsChat:AddLine( {"FORMATTED", args=tbl[i]} ) end
	HatsChat:DoMessage( "Successfully loaded previous chat" )
	file.Delete( "hatschat/savedchat.txt", "DATA" )
end
hook.Add( "ShutDown", "HatsChat SaveOld", function() HatsChat:SavePersistantMessages() end)

--HatsChat Internal Messages--
------------------------------
local HatsChatMsgCol = Color(255,255,255) -- {r=255,g=255,b=255,a=255, Glow=true, GlowTarget=Color(255,180,255)}
local HatsChatTagCol = {r=200,g=200,b=200,a=255, Glow=true, GlowTarget=Color(255,150,255)}
local HatsChatTag = "[Чат]"
function HatsChat:DoMessage( ... )
	chat.AddText( {"INTERNAL"}, self.LineIcon.Internal_HatsChat and {"LineIcon", self.LineIcon.Internal_HatsChat}, HatsChatTagCol,HatsChatTag,HatsChatMsgCol, ... )
	-- if self.LineIcon.Internal_HatsChat then
		-- chat.AddText( {"LineIcon", self.LineIcon.Internal_HatsChat}, HatsChatTagCol,HatsChatTag,HatsChatMsgCol, ... )
	-- else
		-- chat.AddText( HatsChatTagCol, HatsChatTag, HatsChatMsgCol, ... )
	-- end
end
net.Receive( "HatsChat_ServerMessage", function(len)
	local tbl = net.ReadTable()
	if tbl then
		HatsChat:DoMessage( unpack(tbl) )
	end
end)

--Global Overrides--
--------------------
--Chat.AddText is overridden under the "Chatbox Hooks" heading
function chat.GetChatBoxPos()
	local x = (HatsChat.Settings.WindowAlignX:GetBool() and (ScrW()-HatsChat.Settings.WindowPosX:GetInt())) or HatsChat.Settings.WindowPosX:GetInt()
	local y = (HatsChat.Settings.WindowAlignY:GetBool() and (ScrH()-HatsChat.Settings.WindowPosY:GetInt())) or HatsChat.Settings.WindowPosY:GetInt()
	
	return x,y
end
function chat.GetChatBoxSize()
	if IsValid( HatsChat.Window ) then
		return HatsChat.Window:GetSize()
	end
	
	return 0,0
end

function chat.Open( PublicChat )
	HatsChat.IsTeam = PublicChat~=1
	HatsChat:Show()
end
function chat.Close()
	HatsChat:Hide()
end

--Misc--
--------
if IsValid( HatsChat.Window ) then
	HatsChat.Window.ChatBoxColors = ChatBoxCol
	
	if HatsChat.Window.FadeAnim and (not HatsChat.Visible) then --Autorefresh popup fix
		HatsChat.Window.FadeAnim.Running = true
		HatsChat.Window.FadeAnim.Started = true
		HatsChat.Window.FadeAnim.Finished = nil
		HatsChat.Window.FadeAnim.Length = 0
		HatsChat.Window.FadeAnim.StartTime = SysTime()
		HatsChat.Window.FadeAnim.EndTime = SysTime()
		
		HatsChat.Window.FadeAnim.Data = false
	end
end

include( "hatschat/sh_themes.lua" ) --Autorefresh fix, make themes reload

--[[
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
--]]