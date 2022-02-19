
-----------------------------------------------------
-----------------------------------------
---------------HatsChat 2----------------
-----------------------------------------
--Copyright (c) 2013-2015 my_hat_stinks--
-----------------------------------------

--Editable lines are at he bottom of the file, don't edit this top stuff
HatsChat.ServerBar = {}
local SBar = HatsChat.ServerBar

SBar.Enabled = true --Change this to false to disable

SBar.Buttons = {}
local function AddButton( button )
	if button.ChatCommand then
		button.Function = function()
			local ply = LocalPlayer()
			if IsValid(ply) then RunConsoleCommand( "say", button.ChatCommand ) end
		end
	elseif button.ConCommand then
		button.Function = function()
			local ply = LocalPlayer()
			local tbl = string.Explode( " ", button.ConCommand )
			if IsValid(ply) and (#tbl>0) then
				local comm = tbl[1]
				table.remove( tbl, 1 )
				RunConsoleCommand( comm, unpack(tbl) )
			end
		end
	elseif button.URL then
		button.Function = function() gui.OpenURL( button.URL ) end
	elseif not button.Function then
		print( "Button missing function!" )
		PrintTable( button )
		button.Icon = button.Icon or Material( "materials/icon16/error.png" )
		button.Tooltip = "Undefined Button"
		button.Function = function() end
	end
	button.Icon = button.Icon or Material( "materials/icon16/emoticon_smile.png" )
	button.Tooltip = button.Tooltip or ""
	
	table.insert( SBar.Buttons, button )
end

--Editable stuff under this line--
----------------------------------
SBar.Label = "By .exe" --The text that should appear

AddButton( {Tooltip="Донат", ChatCommand = "!donate", Icon = Material( "materials/icon16/shield.png" )} )
AddButton( {Tooltip="VK", URL = "http://vk.com/skyygaming", Icon = Material( "materials/icon16/help.png" )} )
AddButton( {Tooltip="Смайлы", Function = function()
	local str = ""
	for i=1,#HatsChat.Emote do
		local emote = HatsChat.Emote[i]
		if emote.restricted and not emote.restricted(LocalPlayer()) then continue end
		
		str = str.. emote.text .." "
	end
	if IsValid(LocalPlayer()) and LocalPlayer().HatsChat_SteamEmotes then
		for k,v in pairs(LocalPlayer().HatsChat_SteamEmotes) do str = str..k.." " end
	end
	chat.AddText( {"PLYDATA", ply=LocalPlayer(), RestrictionsOnly=true}, str )
end, Icon = Material( "materials/icon16/emoticon_smile.png" )} )
