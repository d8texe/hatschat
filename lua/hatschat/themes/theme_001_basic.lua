
------------------------------------

-------------HatsChat 2-------------

------------------------------------

--Copyright (c) 2013 my_hat_stinks--

------------------------------------



--Spin Animated--

-----------------

local THEME = {}

THEME.Name = "Spin Animated"

THEME.Main = function( s, w, h )

end

local PromptImg = Material("icon16/comments.png")

local AllchatImg = Material("icon16/world.png")

local TeamImg = Material("icon16/group.png")

THEME.Prompt = function( s,w,h )

	s.Anim_Img = s.Anim_Img or (HatsChat.IsTeam and TeamImg) or AllchatImg

	local high = (math.sin(CurTime()*8)+1)*8

	surface.SetMaterial( s.Anim_Img )

	surface.SetDrawColor( HatsChat.ChatBoxCol.WhiteSolid )

	surface.DrawTexturedRect( 8, (h/2)-(high/2), 16, high )

	

	if high>(s.Anim_OldHigh or 0) and not s.Anim_Growing then

		

		s.Anim_Img = (s.Anim_Img~=PromptImg and PromptImg) or (HatsChat.IsTeam and TeamImg) or AllchatImg

	end

	s.Anim_Growing = high>(s.Anim_OldHigh or 0)

	s.Anim_OldHigh = high

end

THEME.TextEntry = function( s,w,h )

	derma.SkinHook( "Paint", "TextEntry", s, w, h )

end

local OptionsImg = Material("icon16/cog.png")

local OptionsImg2 = Material("icon16/color_wheel.png")

THEME.Settings = function( s,w,h )

	s.Anim_Img = s.Anim_Img or OptionsImg

	surface.SetMaterial( s.Anim_Img )

	surface.SetDrawColor( HatsChat.ChatBoxCol.WhiteSolid )

	local width = (math.sin(CurTime()*8)+1)*8.5

	surface.DrawTexturedRect( 10-(width/2), 2, width, 16 )

	

	if width>(s.Anim_OldWidth or 0) and not s.Anim_Growing then

		s.Anim_Img = (s.Anim_Img==OptionsImg) and OptionsImg2 or OptionsImg

	end

	s.Anim_Growing = width>(s.Anim_OldWidth or 0)

	s.Anim_OldWidth = width

end



THEME.InputPanel = function( s,w,h )

	draw.RoundedBox( 4, 0, 0, w, h, HatsChat.ChatBoxCol.BG )

end --Frame behind prompt, input, and options button panels



THEME.ScrollMain = function( s,w,h ) end

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

THEME.ServerButtonPaint = function( s,w,h )

	s.Rate = s.Rate or math.random(7,12)

	surface.SetMaterial( s.Icon )

	surface.SetDrawColor( HatsChat.ChatBoxCol.WhiteSolid )

	local width = (math.sin(CurTime()*s.Rate)+1)*8.5

	surface.DrawTexturedRect( (w/2)-(width/2), 0, width, h )

end



THEME.PanelBG = function( s,w,h )

end

THEME.PanelCanvas = function( s,w,h )

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

	hook.Add( "StartChat", "HatsChat AnimatedTheme StartChat", function() --After IsTeam is set, but before box is visible

		HatsChat.Window.InputPanel.InputType.Anim_Img = (HatsChat.Window.InputPanel.InputType.Anim_Img==PromptImg and PromptImg) or (HatsChat.IsTeam and TeamImg) or AllchatImg

	end)

	HatsChat.Window.InputPanel.InputType:SetWidth(32)

	

	local scr = HatsChat.Window.ScrollPanel:GetVBar()

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

	hook.Remove( "StartChat", "HatsChat AnimatedTheme StartChat" )

	

	HatsChat.Window.InputPanel.InputType:SetWidth(60)

	

	local scr = HatsChat.Window.ScrollPanel:GetVBar()

	scr:Dock( RIGHT )

	

	local ScrollPan = HatsChat.Window.ScrollPanel

	ScrollPan.PerformLayout = ScrollPan.DefaultPerformLayout or ScrollPan.PerformLayout

	ScrollPan.OnVScroll = ScrollPan.DefaultOnVScroll or ScrollPan.OnVScroll

	ScrollPan:InvalidateLayout()

	HatsChat:DoWindowPos()

end

HatsChat:RegisterTheme( THEME.Name, THEME )

if HatsChat.Settings.ChatTheme:GetString()==THEME.Name then HatsChat:SelectTheme( THEME.Name ) end

