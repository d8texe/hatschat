
-----------------------------------------------------
-----------------------------------------
---------------HatsChat 2----------------
-----------------------------------------
--Copyright (c) 2013-2015 my_hat_stinks--
-----------------------------------------

--Gamemode Overrides--
----------------------
function HatsChat:DoGamemodeOverrides()
	-- DarkRP 2.4
	--____________
	local function AddToChat(msg)
		local col1 = Color(msg:ReadShort(), msg:ReadShort(), msg:ReadShort())
		
		local prefixText = msg:ReadString()
		local ply = msg:ReadEntity()
		ply = IsValid(ply) and ply or LocalPlayer()
		
		prefixText = prefixText or ""
		if prefixText == "" or not prefixText then
			prefixText = ply:Nick()
			prefixText = prefixText ~= "" and prefixText or ply:SteamName()
		end
		
		local col2 = Color(msg:ReadShort(), msg:ReadShort(), msg:ReadShort())

		local text = msg:ReadString()
		local shouldShow
		if text and text ~= "" then
			if IsValid(ply) then
				shouldShow = hook.Call("OnPlayerChat", nil, ply, text, false, not ply:Alive(), prefixText, col1, col2)
				if shouldShow ~= true then
					local pos = string.find( prefixText, ply:Name(), 1, true )
					if pos then
						chat.AddText({"PLYDATA",ply=ply}, col1, prefixText:sub(1, pos-1), ply, col2, ": "..text)
					else
						chat.AddText({"PLYDATA",ply=ply}, col1, prefixText, col2, ": "..text)
					end
				end
			else
				if shouldShow ~= true then
					chat.AddText(col1, prefixText, col2, ": "..text)
				end
			end
		else
			chat.AddText(col1, prefixText)
		end
		chat.PlaySound()
	end
	usermessage.Hook("DarkRP_Chat", AddToChat)
	
	-- DarkRP 2.5
	--____________
	local function AddToChat()
		local col1 = Color(net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8))

		local prefixText = net.ReadString()
		local ply = net.ReadEntity()
		ply = IsValid(ply) and ply or LocalPlayer()
		
		if prefixText == "" or not prefixText then
			prefixText = ply:Nick()
			prefixText = prefixText ~= "" and prefixText or ply:SteamName()
		end
		local col2 = Color(net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8))

		local text,shouldShow = net.ReadString()
		if text and text ~= "" then
			if IsValid(ply) then
				shouldShow = hook.Call("OnPlayerChat", nil, ply, text, false, not ply:Alive(), prefixText, col1, col2)
				if shouldShow ~= true then
					local pos = string.find( prefixText, ply:Name(), 1, true )
					if pos then
						chat.AddText({"PLYDATA",ply=ply}, col1, prefixText:sub(1, pos-1), ply, col2, ": "..text)
					else
						chat.AddText({"PLYDATA",ply=ply}, col1, prefixText, col2, ": "..text)
					end
				end
			else
				if shouldShow ~= true then chat.AddText({"PLYDATA",ply=ply}, col1, prefixText, col2, ": "..text) end
			end
		else
			chat.AddText(col1, prefixText)
		end
		chat.PlaySound()
	end
	net.Receive("DarkRP_Chat", AddToChat)
	
	-- Trouble in Terrorist Town
	--___________________________
	local function RoleChatRecv(um)
		local role = um:ReadChar()
		local sender = um:ReadEntity()
		if not IsValid(sender) then return end
		
		local text = um:ReadString()
		
		if role == ROLE_TRAITOR then
			chat.AddText( {"PLYDATA",ply=sender}, Color( 255, 30, 40 ), Format("(%s) ", string.upper(LANG.GetTranslation("traitor"))), Color( 255, 200, 20), sender:Nick(), Color( 255, 255, 200), ": " .. text)
		elseif role == ROLE_DETECTIVE then
			chat.AddText( {"PLYDATA",ply=sender}, Color( 20, 100, 255 ), Format("(%s) ", string.upper(LANG.GetTranslation("detective"))), Color( 25, 200, 255), sender:Nick(), Color( 200, 255, 255), ": " .. text)
		end
	end
	usermessage.Hook("role_chat", RoleChatRecv)
	hook.Add( "OnPlayerChat", "HatsChat2 Override Terrortown DetChat", function( ply, text, teamchat, dead )
		if IsValid(ply) and ply.IsActiveDetective and ply:IsActiveDetective() then
			chat.AddText( {"PLYDATA",ply=ply}, Color(50, 200, 255), ply:Nick(), Color(255,255,255), ": " .. text)
			return true
		end
	end)
	
	-- Murder
	--________
	local ColWhite = Color(255,255,255)
	net.Receive( "HatsChat_MurderChat", function()
		local msg = {
			net.ReadTable(), net.ReadString(),
			ColWhite, ": ", net.ReadString(),
		}
		
		local ply = net.ReadEntity()
		if IsValid(ply) then table.insert(msg, 1, {"PLYDATA",ply=ply}) end
		
		chat.AddText( unpack(msg) )
	end)
	
	//*
	--Fretta (Why even use this?)
	--___________________________
	function GAMEMODE:TeamChangeNotification( ply, oldteam, newteam )
		if( ply && ply:IsValid() ) then
			local nick = ply:Nick();
			local oldTeamColor = team.GetColor( oldteam );
			local newTeamName = team.GetName( newteam );
			local newTeamColor = team.GetColor( newteam );
			
			if( newteam == TEAM_SPECTATOR ) then
				chat.AddText( {"PLYDATA",ply=ply,RestrictionsOnly=true}, oldTeamColor, nick, color_white, " joined the ", newTeamColor, newTeamName ); 
			else
				chat.AddText( {"PLYDATA",ply=ply,RestrictionsOnly=true}, oldTeamColor, nick, color_white, " joined ", newTeamColor, newTeamName );
			end
			
			chat.PlaySound( "buttons/button15.wav" );
		end
	end
	usermessage.Hook( "fretta_teamchange", function( um )  if( GAMEMODE && um ) then  GAMEMODE:TeamChangeNotification( um:ReadEntity(), um:ReadShort(), um:ReadShort() ) end end ) //*/
end
hook.Add( "Initialize", "HatsChat gamemode overrides", function() HatsChat:DoGamemodeOverrides() end )
