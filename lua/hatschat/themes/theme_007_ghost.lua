
-----------------------------------------------------
------------------------------------
-------------HatsChat 2-------------
------------------------------------
--Copyright (c) 2013 my_hat_stinks--
------------------------------------

--Ghost--
---------
local THEME = {}
THEME.Name = "Ghost"
THEME.Main = function( s, w, h )
	draw.RoundedBox( 4, 0, 0, w, h, HatsChat.ChatBoxCol.White )
end
THEME.Prompt = function( s,w,h )
	draw.RoundedBox( 4, 0, 0, w, h, HatsChat.ChatBoxCol.White )
	draw.RoundedBox( 4, 1, 1, w-2, h-2, HatsChat.ChatBoxCol.WhiteSolid )
	
	draw.SimpleText( HatsChat.IsTeam and "Team:" or "Say:", "HatsChatPrompt", 30, 10, HatsChat.ChatBoxCol.BlackStrong, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end
local OptionsImg = Material("icon16/eye.png")
THEME.Settings = function( s,w,h )
	surface.SetMaterial( OptionsImg )
	surface.DrawTexturedRect( 2, 2, 16, 16 )
end
local EmoteImg = Material("icon16/contrast_low.png")
THEME.EmoteButton = function( s,w,h )
	surface.SetMaterial( EmoteImg )
	surface.DrawTexturedRect( 2, 2, 16, 16 )
end

THEME.ScrollGrip = function(s,w,h)
	draw.RoundedBox( 4, 0, 0, w, h, HatsChat.ChatBoxCol.White )
	draw.RoundedBox( 4, 1, 1, w-1, h-1, HatsChat.ChatBoxCol.WhiteStrong )
end
THEME.ScrollUp = function(s,w,h)
	draw.RoundedBox( 4, 0, 0, w, h, HatsChat.ChatBoxCol.White )
	draw.RoundedBox( 4, 1, 1, w-1, h-1, HatsChat.ChatBoxCol.WhiteStrong )
end
THEME.ScrollDown = function(s,w,h)
	draw.RoundedBox( 4, 0, 0, w, h, HatsChat.ChatBoxCol.White )
	draw.RoundedBox( 4, 1, 1, w-1, h-1, HatsChat.ChatBoxCol.WhiteStrong )
end

THEME.ServerBar = function( s,w,h )
	draw.RoundedBox( 4, 0, 0, w, h, HatsChat.ChatBoxCol.White )
	draw.SimpleText( s.Label or "HatsChat2", "HatsChatPrompt", 5, 0, HatsChat.ChatBoxCol.Black, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
end
THEME.EmoteWindow = function( s,w,h )
	draw.RoundedBox( 4, 0, 0, w, h, HatsChat.ChatBoxCol.White )
	draw.RoundedBox( 4, 1, 1, w-2, h-2, HatsChat.ChatBoxCol.WhiteSolid )
end

local function GhostAnim( s, anim, delta, pos )
	s.Delta = delta
	local x = pos.Start.x - (pos.Start.x-pos.End.x)*delta
	local y = pos.Start.y - (pos.Start.y-pos.End.y)*delta
	s:SetPos( x,y )
end

local GhostSounds = { "ambient/wind/wind_moan1.wav",  "ambient/wind/wind_moan2.wav", "ambient/wind/wind_moan4.wav" }
local timername = "HatsChat Halloween GhostTheme MakeGhost"
local function GhostTimer()
	if not IsValid( THEME.GhostPanel ) then timer.Remove( timername ) return end
	
	local Start = {x=math.random(0, HatsChat.Window:GetWide()-30), y=math.random(0, HatsChat.Window:GetTall()-30)}
	local End = {x=math.random(0, HatsChat.Window:GetWide()-30), y=math.random(0, HatsChat.Window:GetTall()-30)}
	THEME.GhostPanel.Anim:Start( 5, {Start=Start, End=End} )
	sound.Play( table.Random(GhostSounds), LocalPlayer():GetPos(), 75, 100, 0.2 )
	
	timer.Create( timername, math.random( 5, 45 ), 0, GhostTimer )
end

local GhostWhite = Color(255,255,255,255)
local GhostBlack = Color(0,0,0,255)
local GhostText = surface.GetTextureID( "vgui/white" )
local GhostPoly = {
	{["x"]=0,	["y"]=25,	["u"]=0,		["v"]=0.833},
	{["x"]=2,	["y"]=10,	["u"]=0.067,	["v"]=0.333},
	{["x"]=4,	["y"]=7,	["u"]=0.13,		["v"]=0.233},
	{["x"]=7,	["y"]=4,	["u"]=0.2,		["v"]=0.13},
	{["x"]=11,	["y"]=1,	["u"]=0.267,	["v"]=0.033},
	
	{["x"]=15,	["y"]=0,	["u"]=0.333,	["v"]=0},
	
	{["x"]=19,	["y"]=1,	["u"]=0.633,	["v"]=0.033},
	{["x"]=23,	["y"]=3,	["u"]=0.766,	["v"]=0.1},
	{["x"]=26,	["y"]=7,	["u"]=0.866,	["v"]=0.233},
	{["x"]=28,	["y"]=10,	["u"]=0.933,	["v"]=0.333},
	{["x"]=29,	["y"]=25,	["u"]=0.966,	["v"]=0.833},
}
local GhostTri1 = { {["x"]=5,["y"]=30,["u"]=0.5,["v"]=1}, {["x"]=0,["y"]=25,["u"]=0,["v"]=0}, {["x"]=10,["y"]=25,["u"]=1,["v"]=0}, }
local GhostTri2 = { {["x"]=15,["y"]=30,["u"]=0.5,	["v"]=1}, {["x"]=10,["y"]=25,["u"]=0,["v"]=0}, {["x"]=20,["y"]=25,["u"]=1,["v"]=0}, }
local GhostTri3 = { {["x"]=25,["y"]=30,["u"]=0.5,["v"]=1}, {["x"]=20,["y"]=25,["u"]=0,["v"]=0}, {["x"]=29,["y"]=25,["u"]=1,["v"]=0}, }
local GhostEye1 = {
	{["x"]=9,	["y"]=10,	["u"]=0.5,		["v"]=1},
	{["x"]=6,	["y"]=7,	["u"]=0,		["v"]=0.5},
	{["x"]=9,	["y"]=4,	["u"]=0.5,		["v"]=0},
	{["x"]=12,	["y"]=7,	["u"]=1,		["v"]=0.5},
}
local GhostEye2 = {
	{["x"]=21,	["y"]=10,	["u"]=0.5,		["v"]=1},
	{["x"]=18,	["y"]=7,	["u"]=0,		["v"]=0.5},
	{["x"]=21,	["y"]=4,	["u"]=0.5,		["v"]=0},
	{["x"]=24,	["y"]=7,	["u"]=1,		["v"]=0.5},
}
THEME.Start = function()
	THEME.GhostPanel = vgui.Create( "DPanel", HatsChat.Window )
	local ghost = THEME.GhostPanel
	ghost:SetSize( 30,30 )
	ghost.Delta = 0
	ghost.Paint = function( s,w,h )
		s.Anim:Run()
		
		local a = s.Delta*300
		if a>150 then a=300-a end
		GhostWhite.a = a
		GhostBlack.a = a
		
		surface.SetDrawColor( GhostWhite )
		surface.SetTexture( GhostText )
		surface.DrawPoly( GhostPoly )
		surface.DrawPoly( GhostTri1 ) surface.DrawPoly( GhostTri2 ) surface.DrawPoly( GhostTri3 )
		
		surface.SetDrawColor( GhostBlack )
		surface.DrawPoly( GhostEye1 ) surface.DrawPoly( GhostEye2 )
		surface.DrawRect( 10, 16, 10, 3 )
	end
	ghost:MoveToBack()
	
	ghost.Anim = Derma_Anim( "HatsChat Halloween GhostTheme", ghost, GhostAnim )
	GhostTimer()
end
THEME.End = function()
	if IsValid( THEME.GhostPanel ) then THEME.GhostPanel:Remove() end
end

HatsChat:RegisterTheme( THEME.Name, THEME )
if HatsChat.Settings.ChatTheme:GetString()==THEME.Name or os.date( "%m%d" )=="1031" then HatsChat:SelectTheme( THEME.Name ) end
