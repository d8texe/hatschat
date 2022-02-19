
-----------------------------------------------------
------------------------------------
-------------HatsChat 2-------------
------------------------------------
--Copyright (c) 2013 my_hat_stinks--
------------------------------------


--Black and Blue--
------------------
local THEME = {}
THEME.Name = "Battenberg"
THEME.Main = function( s, w, h )
end
THEME.Prompt = function( s,w,h )
	draw.SimpleText( HatsChat.IsTeam and "Team:" or "Say:", "HatsChatPrompt", 31, 11, HatsChat.ChatBoxCol.Candy2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	draw.SimpleText( HatsChat.IsTeam and "Team:" or "Say:", "HatsChatPrompt", 30, 10, HatsChat.ChatBoxCol.Candy1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end
THEME.TextEntry = function( s,w,h )
	derma.SkinHook( "Paint", "TextEntry", s, w, h )
end
local OptionsImg = Material("icon16/cake.png")
THEME.Settings = function( s,w,h )
	surface.SetMaterial( OptionsImg )
	surface.SetDrawColor( HatsChat.ChatBoxCol.WhiteSolid )
	surface.DrawTexturedRect( 0, 4, 16, 16 )
end
local EmoteImg = Material("icon16/emoticon_smile.png")
THEME.EmoteButton = function( s,w,h )
	surface.SetMaterial( EmoteImg )
	surface.SetDrawColor( HatsChat.ChatBoxCol.WhiteSolid )
	surface.DrawTexturedRect( 0, 4, 16, 16 )
end

THEME.InputPanel = function( s,w,h )
	draw.RoundedBox( 6, 0, 0, w, h, HatsChat.ChatBoxCol.Candy1 )
	draw.RoundedBox( 6, 3, 3, w-6, h-6, HatsChat.ChatBoxCol.Candy2 )
end --Frame behind prompt, input, and options button panels

THEME.ScrollMain = function( s,w,h ) end
THEME.ScrollGrip = function(s,w,h)
	draw.RoundedBox( 4, 0, 0, w, h, HatsChat.ChatBoxCol.Candy1 )
	draw.RoundedBox( 4, 2, 2, w-4, h-4, HatsChat.ChatBoxCol.Candy2 )
	--draw.RoundedBox( 2, 2, 2, (w-4)/2, (h-4)/2, HatsChat.ChatBoxCol.GoldSolid )
	--draw.RoundedBox( 2, 2 +(w-4)/2, 2 +(h-4)/2, (w-4)/2, (h-4)/2, HatsChat.ChatBoxCol.GoldSolid )
end
THEME.ScrollUp = function(s,w,h)
	draw.RoundedBox( 2, 0, 0, w, h, HatsChat.ChatBoxCol.Candy1 )
	draw.RoundedBox( 2, 2, 2, w-4, h-4, HatsChat.ChatBoxCol.Candy2 )
	draw.RoundedBox( 2, 2 +(w-4)/2, 2, (w-4)/2, (h-4)/2, HatsChat.ChatBoxCol.GoldSolid )
	draw.RoundedBox( 2, 2, 2 +(h-4)/2, (w-4)/2, (h-4)/2, HatsChat.ChatBoxCol.GoldSolid )
end
THEME.ScrollDown = function(s,w,h)
	draw.RoundedBox( 2, 0, 0, w, h, HatsChat.ChatBoxCol.Candy1 )
	draw.RoundedBox( 2, 2, 2, w-4, h-4, HatsChat.ChatBoxCol.Candy2 )
	draw.RoundedBox( 2, 2, 2, (w-4)/2, (h-4)/2, HatsChat.ChatBoxCol.GoldSolid )
	draw.RoundedBox( 2, 2 +(w-4)/2, 2 +(h-4)/2, (w-4)/2, (h-4)/2, HatsChat.ChatBoxCol.GoldSolid )
end

THEME.ServerBar = function( s,w,h )
	draw.RoundedBox( 6, 0, -10, w, h+10, HatsChat.ChatBoxCol.Candy1 )
	draw.RoundedBox( 6, 2, 0, w-4, h-2, HatsChat.ChatBoxCol.Candy2 )
	draw.SimpleText( s.Label or "HatsChat2", "HatsChatPrompt", 6, 1, HatsChat.ChatBoxCol.Candy2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	draw.SimpleText( s.Label or "HatsChat2", "HatsChatPrompt", 5, 0, HatsChat.ChatBoxCol.Candy1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
end

THEME.PanelBG = function( s,w,h )
end
THEME.PanelCanvas = function( s,w,h )
end

local function HatsChatDoWindowPos( self, tbl )
	if not IsValid( self.Window ) then return end
	if not tbl then tbl = {} end
	
	local xpos,ypos = HatsChat.Settings.WindowPosX, HatsChat.Settings.WindowPosY
	local xalign, yalign = HatsChat.Settings.WindowAlignX, HatsChat.Settings.WindowAlignY
	local wide,high = HatsChat.Settings.WindowSizeX, HatsChat.Settings.WindowSizeY
	
	xalign = tbl.xalign or (xalign and xalign:GetBool() or false)
	yalign = tbl.yalign or (yalign and yalign:GetBool() or false)
	
	xpos = math.Clamp( tbl.xpos or xpos and xpos:GetInt() or 0, 0, ScrW() )
	ypos = math.Clamp( tbl.ypos or ypos and ypos:GetInt() or 0, 0, ScrH() )
	
	if IsValid(self.WindowParent) then
		self.WindowParent:SetPos( xalign and (ScrW()-xpos) or xpos, yalign and (ScrH()-ypos) or ypos )
	else
		self.Window:SetPos( xalign and (ScrW()-xpos) or xpos, yalign and (ScrH()-ypos) or ypos )
	end
	
	wide = math.Clamp( tbl.wide or wide and wide:GetInt() or 200, 100, ScrW() )
	high = math.Clamp( tbl.high or high and high:GetInt() or 200, 100, ScrH() )
	
	if IsValid(self.WindowParent) then self.WindowParent:SetSize( wide, high ) end
	self.Window:SetSize( wide, high )
	
	self.Window.InputPanel:SetSize( HatsChat.Window:GetWide()-10, 25 )
	self.Window.ScrollPanel:SetSize( self.Window:GetWide()-10, self.Window:GetTall()-35 )
	
	local wide = self.Window:GetWide() - self.Window.ScrollPanel:GetVBar():GetWide()
	self.MessagePanel:SetWide( wide-15 )
	self.Window.TextEntry:SetWide( ((HatsChat.Window:GetWide()-15) -self.Window.InputPanel.SettingsButton:GetWide()) -self.Window.InputPanel.InputType:GetWide() -self.Window.InputPanel.EmoteButton:GetWide() )
	
	local tall = 0
	for i=1,#self.MessagePanel.Lines do
		tall = tall+ ( IsValid(self.MessagePanel.Lines[i]) and self.MessagePanel.Lines[i]:GetTall() or 0 )
	end
	self.Window.ScrollPanel.BG:SetSize( wide, math.max(tall, self.Window:GetTall()-34) )
	self.MessagePanel:SetTall( tall )
	
	self:RefreshLines()
end
THEME.Start = function()
	local wind = HatsChat.Window
	wind.InputPanel:SetSize( HatsChat.Window:GetWide()-10, 25 )
	wind.TextEntry:Dock( 0 )
	local wide = ((HatsChat.Window:GetWide()-15) -wind.InputPanel.SettingsButton:GetWide()) -wind.InputPanel.InputType:GetWide() -wind.InputPanel.SettingsButton:GetWide()
	wind.TextEntry:SetPos( wind.InputPanel.InputType:GetWide(), 4 )
	wind.TextEntry:SetSize( wide, 17 )
	
	if IsValid(HatsChat.Window.ServerBar) then HatsChat.Window.ServerBar:DockMargin( 5, 0, 10, 0 ) end
	
	local scr = HatsChat.Window.ScrollPanel:GetVBar()
	scr:SetWide( 17 )
	
	HatsChat.DefaultDoWindowPos = HatsChat.DefaultDoWindowPos or HatsChat.DoWindowPos
	HatsChat.DoWindowPos = HatsChatDoWindowPos
end
THEME.End = function()
	local wind = HatsChat.Window
	wind.InputPanel:SetSize( wind:GetWide()-10, 20 )
	wind.TextEntry:Dock( FILL )
	
	if IsValid(HatsChat.Window.ServerBar) then HatsChat.Window.ServerBar:DockMargin( 0, 0, 0, 0 ) end
	
	local scr = HatsChat.Window.ScrollPanel:GetVBar()
	scr:SetWide( 15 )
	
	HatsChat.DoWindowPos = HatsChat.DefaultDoWindowPos or HatsChat.DoWindowPos
end
HatsChat:RegisterTheme( THEME.Name, THEME )
if HatsChat.Settings.ChatTheme:GetString()==THEME.Name then HatsChat:SelectTheme( THEME.Name ) end
