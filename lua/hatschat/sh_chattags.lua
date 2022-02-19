
-----------------------------------------------------
-----------------------------------------
---------------HatsChat 2----------------
-----------------------------------------
--Copyright (c) 2013-2015 my_hat_stinks--
-----------------------------------------

HatsChat.ChatTags = {}
local CT = HatsChat.ChatTags

CT.Enabled = false
CT.Tags = {
--	["owner"] = {Color(85,0,150), "[Owner]"}, --Minimal example
--	["STEAM_0:0:0"] = {Color(255,255,255), "[SteamID]"}, --SteamID Example
}

HatsChat.LuaChatTags = table.Copy( CT.Tags )
if SERVER then table.Empty( CT.Tags ) return end

function CT.GetTag( ply )
	if not CT.Enabled then return end
	if not IsValid(ply) then return end
	
	if wyozite then --Wyozi Tag Editor support
		local str = ply:GetNWString("wte_sbtstr")
		local col = ply:GetNWVector("wte_sbtclr", Vector(-1,-1,-1))
		if (not col) or col[1]<0 or col[2]<0 or col[3]<0 then
			col = ply:GetNWVector("wte_sbclr", Vector(-1,-1,-1))
			if col[1]<0 or col[2]<0 or col[3]<0 then col = nil end
		end
		if col and str and #str>0 then
			local glow = ply:GetNWVector("wte_sbtclr2")
			if col==Vector(255,255,255) and glow==Vector(255,255,255) then
				return {
					HatsChat.ChatCol["[rainbow2]"] or HatsChat.ChatCol["[rainbow]"],
					"["..str.."]"
				}
			else
				return {
					{r=col[1], g=col[2], b=col[3], a=255, Glow = glow~=Vector(0,0,0), GlowTarget = glow},
					"["..str.."]"
				}
			end
		end
	end
	
	local rank = HatsChat.GetPlayerRank(ply)
	return CT.Tags[ply:SteamID()] or CT.Tags[rank]
end
