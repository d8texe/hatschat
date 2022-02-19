
-----------------------------------------------------
------------------------------------
-------------HatsChat 2-------------
------------------------------------
--Copyright (c) 2013 my_hat_stinks--
------------------------------------

--Slide Animated--
------------------
local THEME = {}
THEME.Name = "Slide Animated"
THEME.Main = function( s, w, h )
end
local PromptImg = Material("icon16/comments.png")
local AllchatImg = Material("icon16/world.png")
local TeamImg = Material("icon16/group.png")
THEME.Prompt = function( s,w,h )
	draw.RoundedBox( 4, 0, 0, w, h, HatsChat.ChatBoxCol.Black )
	draw.RoundedBox( 4, 1, 1, w-2, h-2, HatsChat.ChatBoxCol.WhiteSolid )
	
	draw.SimpleText( HatsChat.IsTeam and "Team:" or "Say:", "HatsChatPrompt", 30, 10, HatsChat.ChatBoxCol.BlackSolid, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end
THEME.TextEntry = function( s,w,h )
	derma.SkinHook( "Paint", "TextEntry", s, w, h )
end
local OptionsImg = Material("icon16/cog.png")
THEME.Settings = function( s,w,h )
	surface.SetMaterial( OptionsImg )
	surface.SetDrawColor( HatsChat.ChatBoxCol.WhiteSolid )
	surface.DrawTexturedRect( 2, 2, 16, 16 )
end

THEME.InputPanel = function( s,w,h )
	if s.Anim and s.Anim:Active() then s.Anim:Run() end
	
	draw.RoundedBox( 4, 0, 0, w, h, HatsChat.ChatBoxCol.BG )
end --Frame behind prompt, input, and options button panels

THEME.ScrollMain = function( s,w,h )
	if s.Anim and s.Anim:Active() then s.Anim:Run() end
	
	s:SetTall( HatsChat.Window.ScrollPanel:GetTall() )
end
THEME.ScrollGrip = function(s,w,h)
	draw.RoundedBox( 4, 0, 0, w, h, HatsChat.ChatBoxCol.Black )
	draw.RoundedBox( 4, 1, 1, w-1, h-1, HatsChat.ChatBoxCol.White )
end
THEME.ScrollUp = function(s,w,h)
	draw.RoundedBox( 4, 0, 0, w, h, HatsChat.ChatBoxCol.Black )
	draw.RoundedBox( 4, 1, 1, w-1, h-1, HatsChat.ChatBoxCol.White )
end
THEME.ScrollDown = function(s,w,h)
	draw.RoundedBox( 4, 0, 0, w, h, HatsChat.ChatBoxCol.Black )
	draw.RoundedBox( 4, 1, 1, w-1, h-1, HatsChat.ChatBoxCol.White )
end

THEME.ServerBar = function( s,w,h )
	draw.SimpleText( s.Label or "HatsChat2", "HatsChatPrompt", 6, 1, HatsChat.ChatBoxCol.BlackSolid, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	draw.SimpleText( s.Label or "HatsChat2", "HatsChatPrompt", 5, 0, HatsChat.ChatBoxCol.White, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
end

THEME.PanelBG = function( s,w,h ) end
THEME.PanelCanvas = function( s,w,h ) end

THEME.LinePaint = function( s,w,h ) --Optional func to paint under individual lines
	if not ( (s.Visibility and s.Visibility>0) or HatsChat.Visible) then return end
	
	if s.ANIM_ActiveAnim then
		if (not s.ANIM_ActiveAnim:Active()) and (s.LastPaint or 0)+0.2<CurTime() then
			s.ANIM_ActiveAnim:Start(0.2)
		end
		s.ANIM_ActiveAnim:Run()
	end
	
	s.LastPaint = CurTime()
	
	return {x=s.ANIM_x}
end
THEME.LineAnim = function( s,anim,delta )
	s.ANIM_x = 1 - (s:GetWide()*(1-delta))
end

local function ScrollBarAnim( s, anim, delta, IsSpawning )
	local wnd = HatsChat.Window
	
	delta = (IsSpawning and 1-delta) or delta
	tall = s:GetTall()-1
	s:SetPos( 0, tall*(delta) )
end
local function InputPanelAnim( s, anim, delta, IsSpawning )
	local wnd = HatsChat.Window
	
	delta = (IsSpawning and 1-delta) or delta
	wide = s:GetWide()-1
	if IsValid( HatsChat.Window.ServerBar ) then
		s:SetPos( 0-(wide*(delta)), (HatsChat.Window:GetTall()-(HatsChat.Window.ServerBar:GetTall()+5))-HatsChat.Window.InputPanel:GetTall() )
		HatsChat.Window.ServerBar:SetPos( 0-(wide*(delta)), HatsChat.Window:GetTall()-HatsChat.Window.ServerBar:GetTall() )
	else
		s:SetPos( 0-(wide*(delta)), HatsChat.Window:GetTall()-HatsChat.Window.InputPanel:GetTall() )
	end
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
	HatsChat.Window.InputPanel:Dock( 0 )
	HatsChat.Window.InputPanel:SetPos( 0, HatsChat.Window:GetTall()-HatsChat.Window.InputPanel:GetTall() )
	HatsChat.Window.InputPanel.Anim = Derma_Anim( "HatsChat ThemeSlide InputAnim", HatsChat.Window.InputPanel, InputPanelAnim )
	HatsChat.Window.InputPanel.Anim:Start(0.5, true)
	
	if IsValid( HatsChat.Window.ServerBar ) then
		HatsChat.Window.ServerBar:Dock(0)
		HatsChat.Window.ScrollPanel:DockMargin( 0, 0, 0, HatsChat.Window.InputPanel:GetTall()+HatsChat.Window.ServerBar:GetTall()+5 )
	else
		HatsChat.Window.ScrollPanel:DockMargin( 0, 0, 0, HatsChat.Window.InputPanel:GetTall()+5 )
	end
	
	local scr = HatsChat.Window.ScrollPanel:GetVBar()
	scr:SetTall( HatsChat.Window.ScrollPanel:GetTall() )
	scr:Dock( 0 )
	scr.Anim = Derma_Anim( "HatsChat ThemeSlide ScrollbarAnim", scr, ScrollBarAnim )
	scr.Anim:Start(0.5, true)
	
	timer.Simple(0, function() scr:SetPos(0,0) end) --Fixes the bug where scrollbar is hidden when switching to this theme
	--scr:Dock( LEFT )
	
	hook.Add( "StartChat", "HatsChat ThemeSlide StartChat", function()
		scr:SetPos(0,0)
		scr.Anim:Start( 0.5, true )
		HatsChat.Window.InputPanel.Anim:Start( 0.5, true )
	end)
	hook.Add( "FinishChat", "HatsChat ThemeSlide endChat", function()
		scr.Anim:Start( 0.5, false )
		HatsChat.Window.InputPanel.Anim:Start( 0.5, false )
	end)
	
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
	scr:Dock( RIGHT )
	scr.Anim = nil
	
	HatsChat.Window.ScrollPanel:DockMargin( 0, 0, 0, 0 )
	HatsChat.Window.InputPanel:Dock( BOTTOM )
	
	if IsValid( HatsChat.Window.ServerBar ) then HatsChat.Window.ServerBar:Dock(BOTTOM) end
	
	hook.Remove( "StartChat", "HatsChat ThemeSlide StartChat" )
	hook.Remove( "FinishChat", "HatsChat ThemeSlide endChat" )
	
	local ScrollPan = HatsChat.Window.ScrollPanel
	ScrollPan.PerformLayout = ScrollPan.DefaultPerformLayout or ScrollPan.PerformLayout
	ScrollPan.OnVScroll = ScrollPan.DefaultOnVScroll or ScrollPan.OnVScroll
	ScrollPan:InvalidateLayout()
	HatsChat:DoWindowPos()
end
HatsChat:RegisterTheme( THEME.Name, THEME )
if HatsChat.Settings.ChatTheme:GetString()==THEME.Name then HatsChat:SelectTheme( THEME.Name ) end
