
-----------------------------------------------------
------------------------------------
-------------HatsChat 2-------------
------------------------------------
--Copyright (c) 2013 my_hat_stinks--
------------------------------------

--Clasic--  --Designed to be like the original HatsChat
----------
local THEME = {}
THEME.Name = "Classic"
THEME.Main = function( s, w, h ) end
THEME.Prompt = function( s,w,h )
	draw.RoundedBox( 0, 0, 0, w, h, HatsChat.ChatBoxCol.Black )
	draw.RoundedBox( 0, 2, 2, w-4, h-4, HatsChat.ChatBoxCol.WhiteSolid )
	
	draw.SimpleText( HatsChat.IsTeam and "Team:" or "Chat:", "HatsChatPrompt", 30, 10, HatsChat.ChatBoxCol.BlackSolid, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end
THEME.TextEntry = function( s,w,h )
	draw.RoundedBox( 0, 0, 0, w, h, HatsChat.ChatBoxCol.Black )
	draw.RoundedBox( 0, 2, 2, w-4, h-4, HatsChat.ChatBoxCol.WhiteSolid )
	derma.SkinHook( "Paint", "TextEntry", s, w, h )
end
local OptionsImg = Material("icon16/cog.png")
THEME.Settings = function( s,w,h )
	surface.SetMaterial( OptionsImg )
	surface.DrawTexturedRect( 2, 2, 16, 16 )
end

THEME.InputPanel = function( s,w,h ) end --Frame behind prompt, input, and options button panels

THEME.ScrollMain = function( s,w,h )
	draw.RoundedBox( 6, 0, 0, w, h, HatsChat.ChatBoxCol.Black )
end
THEME.ScrollGrip = function(s,w,h)
	draw.RoundedBox( 6, 0, 0, w, h, HatsChat.ChatBoxCol.Black )
end
THEME.ScrollUp = function(s,w,h)
	draw.RoundedBox( 6, 0, 0, w, h, HatsChat.ChatBoxCol.BG )
end
THEME.ScrollDown = function(s,w,h)
	draw.RoundedBox( 6, 0, 0, w, h, HatsChat.ChatBoxCol.BG )
end

THEME.ServerBar = function( s,w,h )
	draw.RoundedBox( 6, 0, 0, w, h, HatsChat.ChatBoxCol.BG )
	draw.SimpleText( s.Label or "HatsChat2", "HatsChatPrompt", 6, 1, HatsChat.ChatBoxCol.BlackSolid, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	draw.SimpleText( s.Label or "HatsChat2", "HatsChatPrompt", 5, 0, HatsChat.ChatBoxCol.White, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
end

THEME.PanelBG = function( s,w,h )
end
THEME.PanelCanvas = function( s,w,h )
	draw.RoundedBox( 8, 0, 0, w-2, h, HatsChat.ChatBoxCol.Black )
end

local function PANELPerformLayout( self )
	local Wide = self:GetWide()
	local YPos = 0
	
	self:Rebuild()
	
	self.VBar:SetUp( self:GetTall(), self.pnlCanvas:GetTall() )
	YPos = self.VBar:GetOffset()
		
	if ( self.VBar.Enabled ) then Wide = Wide - self.VBar:GetWide() end

	self.pnlCanvas:SetPos( self:GetVBar():GetWide()+5, YPos )
	self.pnlCanvas:SetWide( Wide-5 )
	
	self:Rebuild()
end
local function PANELOnVScroll( self, iOffset )
	self.pnlCanvas:SetPos( self:GetVBar():GetWide()+5, iOffset )
end
THEME.Start = function()
	local scr = HatsChat.Window.ScrollPanel:GetVBar()
	scr:SetWide( 20 )
	scr:Dock( LEFT )
	
	local ScrollPan = HatsChat.Window.ScrollPanel
	local wide = HatsChat.Window:GetWide() - ScrollPan:GetVBar():GetWide()
	HatsChat.MessagePanel:SetWide( wide-15 )
	ScrollPan.BG:SetWide( wide )
	
	ScrollPan.DefaultPerformLayout = ScrollPan.DefaultPerformLayout or ScrollPan.PerformLayout
	ScrollPan.DefaultOnVScroll = ScrollPan.DefaultOnVScroll or ScrollPan.OnVScroll
	ScrollPan.PerformLayout = PANELPerformLayout
	ScrollPan.OnVScroll = PANELOnVScroll
	ScrollPan:InvalidateLayout()
	HatsChat:DoWindowPos()
end
THEME.End = function()
	local scr = HatsChat.Window.ScrollPanel:GetVBar()
	scr:SetWide( 15 )
	scr:Dock( RIGHT )
	
	local ScrollPan = HatsChat.Window.ScrollPanel
	ScrollPan.PerformLayout = ScrollPan.DefaultPerformLayout or ScrollPan.PerformLayout
	ScrollPan.OnVScroll = ScrollPan.DefaultOnVScroll or ScrollPan.OnVScroll
	ScrollPan:InvalidateLayout()
	HatsChat:DoWindowPos()
end

HatsChat:RegisterTheme( THEME.Name, THEME )
if HatsChat.Settings.ChatTheme:GetString()==THEME.Name then HatsChat:SelectTheme( THEME.Name ) end
