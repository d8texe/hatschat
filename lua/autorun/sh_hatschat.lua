
-----------------------------------------

---------------HatsChat 2----------------

-----------------------------------------

--Copyright (c) 2013-2015 my_hat_stinks--

-----------------------------------------



HatsChat = HatsChat or {} --Autorefresh goes weird without the "HatsChat or"

HatsChat.GetPlayerRank = function(ply)

	return (exsto and ply.GetRank and ply:GetRank()) or --Exsto

		(ply.EV_GetRank and ply:EV_GetRank()) or --Evolve

		(ply.GetUserGroup and ply:GetUserGroup()) or --ULX

		"" --Failed

end



--Enums--

HATSCHAT_PERM_ALL = 0

HATSCHAT_PERM_DONOR = 1

HATSCHAT_PERM_ADMIN = 2



HATSCHAT_NET_ALL = 0

HATSCHAT_NET_EMOTE = 1

HATSCHAT_NET_CHATCOL = 2

HATSCHAT_NET_LINEICON = 3

HATSCHAT_NET_CHATTAG = 4

HATSCHAT_NET_FILTER = 5

HATSCHAT_NET_FILTER_CATEGORIES = 6



--Editable Vars--

-----------------

--Every variable must keep the same format when you edit it--



--Restrictions

--------------

local function AdminOnly(ply) return IsValid(ply) and HatsChat.HasPermission(ply, "HatsChatRank_Admin", ply:IsAdmin()) end --Just an example. Remember, this is client side!

local function DonatorOnly(ply) return IsValid(ply) and HatsChat.HasPermission(ply, "HatsChatRank_Donator", ply:IsSuperAdmin()) end



HatsChat.AdminOnly = AdminOnly

HatsChat.DonatorOnly = DonatorOnly

--Line Icons

------------

HatsChat.LineIcon = {

	["donator"] = "materials/icon16/coins.png", --Rank example. Always use lower-case.

	["donatorplus"] = "materials/icon16/money.png",

--	["STEAM_0:0:0"] = "materials/icon16/shield.png", --SteamID Example

	["STEAM_0:0:176860337"] = {"materials/icon16/heart.png","materials/icon16/shield_add.png"}, --Multi-icon example. Experimental.

--	["STEAM_0:0:0"] = "AVATAR", --Avatars example. Not case sensitive.

	

	

	--Defaults

	--These are used if the rank check fails, or if there's no icon for the rank

	["Internal_SuperAdmin"] = "materials/icon16/shield_add.png",

	["Internal_Admin"] = "materials/icon16/shield.png",

	["Internal_User"] = "materials/icon16/user.png", --Remove this line if you don't want standard users to have line icons

	

	Internal_Global = "materials/icon16/world.png", --This icon is used for global messages, not player lines

	Internal_HatsChat = "materials/icon16/comments.png", --Icon used for HatsChat2 messages

}



--Name glows

------------

HatsChat.SuperAdminGlow = true --Runs a ply:IsSuperAdmin() check, not rank sepcific

HatsChat.NameGlow = { --Player name colours

	["superadmin"] = "[gold]",

	["owner"] = true,			--Standard glow, goes white

	["coowner"] = Color(0,0,0),	--Glows black

	["leader"] = "[rainbow]",	--You can use chat colours in here too, as you would in-game. This example is Rainbow

	["STEAM_0:0:0"] = "glow",	--SteamID example. "Glow" is a standard white glow

}



--Chat Colors

-------------

HatsChat.ChatCol = {

	--Standard colours

	 ["[red]"] = Color(255,0,0,255), --Minimal example
	 
	 ["[green]"] = Color(0,255,0,255), --Minimal example
	 
	 ["[blue]"] = Color(0,0,255,255), --Minimal example
	 
	 ["[yellow]"] = Color(255,255,0,255), --Minimal example
	 
	 ["[wblue]"] = Color(0,255,255,255), --Minimal example
	 
	 ["[orange]"] = Color(255,100,0,255), --Minimal example
	 
	 ["[pink]"] = Color(255,0,255,255), --Minimal exampl
	 
	 ["[purple]"] = Color(100,0,255,255), --Minimal example

	 ["[gray]"] = {r=150,g=150,b=150,a=255, restriction=AdminOnly}, --Restrictions example

	 ["[gold]"] = {r=255,g=210,b=50,a=255, restriction=AdminOnly, Glow=true}, --Glows example
	 
	["[white]"] = Color(255,255,255,255), --Minimal example
	
	["[black]"] = Color(0,0,0,255), --Minimal example
	
	["[nigga]"] = {r=50, g=30,b= 0,a=255, Glow=true}, --Minimal example

	["[rainbow]"] = {r=255,g=0,b=0,a=255}, --Just for fun
	
	["[EXE]"] = {r=255,g=0,b=0,a=255}, --Just for fun

	["[rainbow2]"] = {r=255,g=0,b=0,a=255}, --Using WTE's method
	
	["[rainbows]"] = {r=255,g=0,b=0,a=255}, --Using WTE's method

}



--Emotes

--------

HatsChat.UseSteamEmotes = true

HatsChat.Emote = {

	-- [":tux:"] = {icon="materials/icon16/tux.png"}, --Minimal Example

	[":tux:"] = {icon="materials/icon16/tux.png", size={16,16}}, --Size modifier Example

	-- [":tux:"] = {icon="materials/icon16/tux.png", restricted=AdminOnly}, --Restricted Example

}



--Fonts

-------

--*NOTE* Autmatic fastdl scripts might not add fonts!

HatsChat.FontData = { --Fonts for chatbox output

	--ManualShadow draws via lua, looks a lot sharper. Without it, most fonts are unusable

	--You can use standard shadows if you wish

	["HatsChatText"] = {font = "Arial", ManualShadow = true}, --Used as a default, don't remove without changing the default in cl_init.lua!

	["Coolvetica"] = {font = "Coolvetica", weight = 500, ManualShadow = true},

	

	["Roboto"] = {font = "Roboto Bk", weight = 500, ManualShadow = true},

	

	["Reactor Sans"] = {filename = "resource/fonts/Reactor-Sans.ttf", font = "Reactor Sans", ManualShadow = true}, --filename arg is for custom fonts

	["Pricedown"] = {filename = "resource/fonts/pricedown bl.ttf", font = "pricedown bl", ManualShadow = true},

	["Steelfish"] = {filename = "resource/fonts/steelfish rg.ttf", font = "steelfish rg", ManualShadow = true},

	["Liberation Sans"] = {filename = "resource/fonts/LiberationSans-Regular.ttf", font = "Liberation Sans", ManualShadow = true},

	["Monofur"] = {filename = "resource/fonts/monof55.ttf", font = "monofur", ManualShadow = true},

	["Philosopher"] = {filename = "resource/fonts/Philosopher-Regular.ttf", font = "Philosopher", ManualShadow = true},

}



-----------------------------------------

-------DO NOT EDIT below this line-------

-----------------------------------------

--Editting anything below here may cause instability in the addon



if CLIENT then --For Rainbows!

	local status, inv = 0
	
	local cls = 0
		
	
	hook.Add( "Think", "HatsChat ChatCol ModifyColours", function()

		local rbow = HatsChat.ChatCol["[rainbow]"]

		if rbow or HatsChat.ChatCol["[EXE]"] then

			local mod = inv and 255-((math.sin( CurTime()*2 )+1) * 127.5) or ((math.sin( CurTime()*2 )+1) * 127.5)

			if status==0 then

				if mod>240 then status = 1 end

				rbow.r = mod --[[High]] rbow.g = 255-mod --[[Low]] rbow.b = 0  --[[Next]]

			elseif status==1 then

				if mod<20 then status = 2 end

				rbow.r = mod  --[[Low]] rbow.g = 0 --[[Next]] rbow.b = 255-mod --[[High]]

			elseif status==2 then

				if mod>240 then status = 3 end

				rbow.r = 0 --[[Next]] rbow.g = mod --[[High]] rbow.b = 255-mod --[[Low]]

			elseif status==3 then

				if mod<20 then status = 1 inv=not inv end

				rbow.r = 255-mod --[[High]] rbow.g = mod --[[Low]] rbow.b = 0 --[[Next]]

			end

		end

		

		local rbow2 = HatsChat.ChatCol["[rainbow2]"]

		if rbow2 then

			rbow2.r = 255*math.abs(math.sin(CurTime()))

			rbow2.g = 255*math.abs(math.sin(CurTime()+1.8))

			rbow2.b = 255*math.abs(math.sin(CurTime()+2.6))

		end
		
		local rbows = HatsChat.ChatCol["[rainbows]"]

		if rbows then
			local col = HSVToColor(cls,1,1)
			
			rbows.r = col.r

			rbows.g = col.g

			rbows.b = col.b
			
			if(cls>=360) then cls = 0 else cls = cls + 1 end

		end

	end)

end



--Fixing tables--

--Here we try and find common mistakes to correct then

for i=1,#HatsChat.ChatCol do

	local tbl = HatsChat.ChatCol[i]

	if type(tbl)=="table" and not (tbl.r and tbl.g and tbl.b) then

		local str, col

		for k,v in pairs(tbl) do

			if type(v)=="string" then

				str = v

			elseif type(v)=="table" and (v.r and v.g and v.b) then

				col = v

			end

		end

		if str and col then

			HatsChat.ChatCol[ str ] = col

			print( "HatsChat.ChatCol badly formatted! Line reformatted to:\t\t[\""..str.."\"] = Color( "..tostring(col.r)..", "..tostring(col.g)..", "..tostring(col.b).."),")

		end

	end

	HatsChat.ChatCol[i] = nil

end

for i=1,#HatsChat.Emote do

	local tbl = HatsChat.Emote[i]

	if type(tbl)=="table" and tbl.icon then

		if tbl.text or tbl.str then

			HatsChat.Emote[ tbl.text or tbl.str ] = tbl

			print( "HatsChat.Emote badly formatted! Line reformatted to:\t\t[\""..(tbl.text or tbl.str).."\"] = {icon=\"".. tbl.icon .. "\"}," )

			tbl.text = nil

			tbl.str = nil

		end

	end

	HatsChat.Emote[i] = nil

end

for i=1,#HatsChat.FontData do

	local tbl = HatsChat.FontData[i]

	if type(tbl)=="table" and tbl.icon then

		if tbl.name then

			HatsChat.FontData[ tbl.name ] = tbl

			print( "HatsChat.FontData badly formatted! Line reformatted to:\t\t[\""..(tbl.name).."\"] = {font=\"".. tbl.font .. "\"}," )

			tbl.name = nil

		end

	end

	HatsChat.FontData[i] = nil

end





if CLIENT then

	HatsChat.Fonts = {}

	function HatsChat.FormatFont( k, v, ovr )

		ovr = ovr or {}

		

		local size = HatsChat.Settings and HatsChat.Settings.ChatTextSize or GetConVar("hatschat_text_size")

		size = ovr.size or (size and size:GetInt()) or 16

		

		local fontname = k..tostring(size)

		if not HatsChat.Fonts[ fontname ] then

			local font = surface.CreateFont( fontname, {

				font = v.font,

				size = math.Clamp(v.size or size,10,200), --Font size overrides settings size

				weight = v.weight or 600,

				blursize = v.blursize or 0,

				scanlines = v.scanlines or 0,

				antialias = v.antialias or true,

				underline = v.underline or false,

				italic = v.italic or false,

				strikeout = v.strikeout or false,

				symbol = v.symbol or false,

				rotary = v.rotary or false,

				shadow = v.shadow or false,

				additive = v.additive or false,

				outline = v.outline or false

			})

		end

		HatsChat.Fonts[ fontname ] = {ManualShadow = v.ManualShadow}

	end

	surface.CreateFont( "HatsChatPrompt", {

		font = "Arial",

		size = 15,

		weight = 600,

	})

	HatsChat.Fonts[ "HatsChatPrompt" ] = {ManualShadow = true}

	

	for k,v in pairs( HatsChat.FontData ) do HatsChat.FormatFont( k, v ) end --Format fonts

--	for _,v in pairs( HatsChat.Emote ) do v.text = string.lower( v.text ) end --Format emotes

	for k,v in pairs( HatsChat.ChatCol ) do --Format colours

		local str = string.lower( k )

		if str~=k then

			HatsChat.ChatCol[k] = nil

			HatsChat.ChatCol[str] = v

		end

		v.ColorPersists = true

	end

	hook.Add( "InitPostEntity", "HatsChat2 TextSize Init", function() --Re-size and refresh fonts

		for k,v in pairs( HatsChat.FontData ) do HatsChat.FormatFont( k, v ) HatsChat:RefreshLines() end

	end)

else

	for _,v in pairs( HatsChat.FontData ) do if v.filename then resource.AddFile( v.filename ) end end --Add font files

	for _,v in pairs( HatsChat.Emote ) do if v.icon then resource.AddFile( v.icon ) end end --Add emote materials

	for _,v in pairs( HatsChat.LineIcon ) do if v then

		if type(v)=="table" then

			for i=1,#v do resource.AddFile(v[i]) end

		else resource.AddFile( v ) end

	end end --Add icon materials

end



HatsChat.LuaEmote = table.Copy( HatsChat.Emote )

HatsChat.LuaChatCol = table.Copy( HatsChat.ChatCol )

HatsChat.LuaLineIcon = table.Copy( HatsChat.LineIcon )

if SERVER then table.Empty(HatsChat.Emote) table.Empty(HatsChat.LineIcon) table.Empty(HatsChat.ChatCol) end --We won't send anything already in lua



if SERVER then

	util.AddNetworkString( "HatsChatIsTyping" )

	net.Receive( "HatsChatIsTyping", function( len, ply )

		if not IsValid(ply) then return end

		local Typing = tobool(net.ReadBit())

		ply:SetNWBool("HatsChat_IsTyping", Typing)

	end)

end

local PLAYER = FindMetaTable( "Player" )

if PLAYER then

	function PLAYER:IsTyping()

		if LocalPlayer and self==LocalPlayer() then

			return HatsChat.Visible --More reliable

		end

		if not IsValid(self) then return false end

		return self:GetNWBool( "HatsChat_IsTyping", false )

	end

end



if SERVER then

	AddCSLuaFile()

	

	AddCSLuaFile( "hatschat/cl_init.lua" )

	AddCSLuaFile( "hatschat/cl_options.lua" )

	AddCSLuaFile( "hatschat/cl_serverbar.lua" )

	AddCSLuaFile( "hatschat/cl_filter.lua" )

	AddCSLuaFile( "hatschat/cl_net.lua" )

	

	AddCSLuaFile( "hatschat/sh_permissions.lua" )

	AddCSLuaFile( "hatschat/sh_themes.lua" )

	AddCSLuaFile( "hatschat/sh_chattags.lua" )

	AddCSLuaFile( "hatschat/cl_overrides.lua" )

	

	include( "hatschat/sv_init.lua" )

	include( "hatschat/sh_permissions.lua" )

	include( "hatschat/sh_themes.lua" )

	

	include( "hatschat/sh_chattags.lua" ) --We need this now

elseif CLIENT then

	include( "hatschat/cl_init.lua" )

	include( "hatschat/cl_options.lua" )

	include( "hatschat/cl_serverbar.lua" )

	include( "hatschat/cl_filter.lua" )

	include( "hatschat/cl_net.lua" )

	

	include( "hatschat/sh_permissions.lua" )

	--Client-side sh_themes.lua is included at the bottom of cl_init.lua (autorefresh fix)

	include( "hatschat/sh_chattags.lua" )

	include( "hatschat/cl_overrides.lua" )

end



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