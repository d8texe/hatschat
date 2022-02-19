
-----------------------------------------------------
-----------------------------------------
---------------HatsChat 2----------------
-----------------------------------------
--Copyright (c) 2013-2016 my_hat_stinks--
-----------------------------------------

--This file sets up permissions
function HatsChat.SetupPermission( Permission, DefaultGroup, Help, Cat )
	if ULib then
		local grp = DefaultGroup or ULib.ACCESS_ALL
		
		return ULib.ucl.registerAccess( Permission, grp, Help, Cat )
	end
	if evolve and evolve.privileges then
		table.Add( evolve.privileges, {Permission} )
		table.sort( evolve.privileges )
		return
	end
	if exsto then
		exsto.CreateFlag( Permission:lower(), Help )
		return
	end
	if serverguard and serverguard.permission then
		serverguard.permission:Add(Permission)
		return
	end
end
function HatsChat.HasPermission( ply, Permission, Default )
	if not IsValid(ply) then return Default end
	
	if ULib then
		return ULib.ucl.query( ply, Permission, true )
	end
	if ply.EV_HasPrivilege then
		return ply:EV_HasPrivilege( Permission )
	end
	if exsto then
		return ply:IsAllowed( Permission:lower() ) --This probably works, can't find a reasonably working exsto version to test properly...
	end
	if serverguard and serverguard.player then
		return serverguard.player:HasPermission(ply, Permission)
	end
	
	return Default
end

if CLIENT then return end
hook.Add( "Initialize", "HatsChat SetupPermissions", function() --Short delay, to load after admin mods
	if not (HatsChat and HatsChat.SetupPermission) then return end --Just in case
	
	--Links
	HatsChat.SetupPermission( "HatsChat_PostLinks", nil, "User can post clickable links in chat", "HatsChat2" )
	--Emotes
	HatsChat.SetupPermission( "HatsChat_SteamEmotes", nil, "User can use Steam emotes", "HatsChat2" )
	--Colours
	HatsChat.SetupPermission( "HatsChat_ChatCol", nil, "User can use ChatColours", "HatsChat2" )
	HatsChat.SetupPermission( "HatsChat_ColorName", nil, "User can use ChatColours in their name", "HatsChat2" )
	--Filters
	HatsChat.SetupPermission( "HatsChat_AvoidFilter", ULib and ULib.ACCESS_ADMIN, "User's chat ignores the chat filter", "HatsChat2" )
	
	--Admin
	HatsChat.SetupPermission( "HatsChatAdmin_Config", ULib and ULib.ACCESS_SUPERADMIN, "User can modify Server-Side HatsChat2 settings", "HatsChat2" )
	
	--Rank
	HatsChat.SetupPermission( "HatsChatRank_Admin", ULib and ULib.ACCESS_ADMIN, "Grant access to Admin-Only features", "HatsChat2" )
	HatsChat.SetupPermission( "HatsChatRank_Donator", ULib and ULib.ACCESS_SUPERADMIN, "Grant access to Donor-Only features", "HatsChat2" )
end)
