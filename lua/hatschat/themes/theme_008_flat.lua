
-----------------------------------------------------
------------------------------------
-------------HatsChat 2-------------
------------------------------------
--Copyright (c) 2013 my_hat_stinks--
------------------------------------

local THEME = {}
THEME.Name = "Flat"

surface.CreateFont( "HatsChatFlatThemeButton", {
	font = "Trebuchet24", size = 35, weight = 500,
})
THEME.Col = {
	FlatBase = Color( 40,40,40 ), FlatSecondary = Color( 60, 60, 60 ),
	FlatInteract = Color( 150,0,0 ),
	
	txtDefault = Color(200,200,200), txtScroll = Color(150,150,150, 50),
}
for i=1,#THEME.Col do THEME.Col[i].DefA = THEME.Col[i].a end

THEME.Main = function( s, w, h ) --Background to the whole chatbox
	surface.SetDrawColor( THEME.Col.FlatBase )
	surface.DrawRect( 0,0, w,h )
end
THEME.Prompt = function( s,w,h ) --The "Team" or "Say" prompt
	surface.SetDrawColor( THEME.Col.FlatSecondary )
	surface.DrawRect( 0,0, w,h )
	
	draw.SimpleText( HatsChat.IsTeam and "Team:" or "Say:", "HatsChatPrompt", 30, 10, THEME.Col.txtDefault, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end

local OptionsImg = Material("icon16/cog.png")
THEME.Settings = function( s,w,h ) --Settings button, opens the settings window
	draw.SimpleText( "☼", "HatsChatFlatThemeButton", w/2, h/2-2, THEME.Col.txtDefault, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end
local EmoteImg = Material("icon16/emoticon_smile.png")
THEME.EmoteButton = function( s,w,h ) --Emote button, opens the emote panel
	draw.SimpleText( "☻", "HatsChatFlatThemeButton", w/2, h/2-1, THEME.Col.txtDefault, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end

THEME.InputPanel = function( s,w,h ) end --Frame behind prompt, input, and options button panels

THEME.ScrollMain = function( s,w,h )
	surface.SetDrawColor( THEME.Col.FlatSecondary )
	surface.DrawRect( 0,0, w,h )
end --Behind the full scroll bar
THEME.ScrollGrip = function(s,w,h) --The scrollbar grip (the bit you can grab)
	surface.SetDrawColor( THEME.Col.FlatInteract )
	surface.DrawRect( 0,0, w,h )
end
THEME.ScrollUp = function(s,w,h) --Scrollbar "Up" button
	surface.SetDrawColor( THEME.Col.FlatInteract )
	surface.DrawRect( 0,0, w,h )
	
	draw.SimpleText( "▲", "Trebuchet18", w/2+1, h/2, THEME.Col.txtScroll, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end
THEME.ScrollDown = function(s,w,h) --Scrollbar "Down" button
	surface.SetDrawColor( THEME.Col.FlatInteract )
	surface.DrawRect( 0,0, w,h )
	
	draw.SimpleText( "▼", "Trebuchet18", w/2+1, h/2, THEME.Col.txtScroll, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end

THEME.ServerBar = function( s,w,h ) --The ServerBar background, if ServerBar is enabled
	surface.SetDrawColor( THEME.Col.FlatSecondary )
	surface.DrawRect( 0,0, w,h )
	
	draw.SimpleText( s.Label or "Flat Theme", "HatsChatPrompt", 5, 0, THEME.Col.txtDefault, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
end
THEME.EmoteWindow = function( s,w,h ) --Emote selection popup panel
	surface.SetDrawColor( THEME.Col.FlatBase )
	surface.DrawRect( 0,0, w,h )
end

THEME.PanelBG = function( s,w,h ) --ScrollPanel background, the bit behind the line panels
end
THEME.PanelCanvas = function( s,w,h )
	surface.SetDrawColor( THEME.Col.FlatSecondary )
	surface.DrawRect( 0,0, w-5,h )
end

THEME.LinePaint = function( s,w,h ) end --Paints under individual lines
THEME.LineAnim = function( s,anim,delta ) end --Individual line animations. Automatically ran, but not automatically started.

THEME.Start = function()
	local scr = HatsChat.Window.ScrollPanel:GetVBar()
	scr:SetWide( 20 )
	scr:DockMargin( 5,0,0,0 )
	-- scr:Dock( LEFT )
	
	if IsValid( HatsChat.Window ) then
		if HatsChat.Window.ChatBoxColors then
			THEME.DefaultColors = table.Copy(HatsChat.Window.ChatBoxColors)
			for k,v in pairs(THEME.Col) do
				HatsChat.Window.ChatBoxColors[k] = v
			end
		end
		
		if IsValid( HatsChat.Window.ServerBar ) then
			HatsChat.Window.ServerBar:DockMargin( 0,5,0,0 )
		end
	end
	
	HatsChat:DoWindowPos()
end
THEME.End = function()
	local scr = HatsChat.Window.ScrollPanel:GetVBar()
	scr:SetWide( 15 )
	scr:DockMargin( 0,0,0,0 )
	-- scr:Dock( RIGHT )
	
	if IsValid( HatsChat.Window ) then
		if THEME.DefaultColors and HatsChat.Window.ChatBoxColors then
			table.Empty( HatsChat.Window.ChatBoxColors )
			for k,v in pairs(THEME.DefaultColors) do
				HatsChat.Window.ChatBoxColors[k] = v
			end
		end
		
		if IsValid( HatsChat.Window.ServerBar ) then
			HatsChat.Window.ServerBar:DockMargin( 0,0,0,0 )
		end
	end
	
	HatsChat:DoWindowPos()
end

HatsChat:RegisterTheme( THEME.Name, THEME )
if HatsChat.Settings.ChatTheme:GetString()==THEME.Name then HatsChat:SelectTheme( THEME.Name ) end
