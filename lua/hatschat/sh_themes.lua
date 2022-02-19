
-----------------------------------------------------
-----------------------------------------
---------------HatsChat 2----------------
-----------------------------------------
--Copyright (c) 2013-2015 my_hat_stinks--
-----------------------------------------

--This file used to load themes, now it just loads files

--It's ordered alphabetically, that's why I numbered the themes
--Load order is the order they appear in the settings menu
local Themes = file.Find( "hatschat/themes/*.lua", "LUA", "nameasc" )
if SERVER then --Client will include them at the end of the file, so the theme system can load first
	for i=1,#Themes do AddCSLuaFile( "hatschat/themes/"..Themes[i] ) end
	return --We don't need the server now, we can leave
end

--Themes--
----------
function HatsChat:RegisterTheme( name, theme )
	self.Themes[ name ] = theme
	
	if not table.HasValue( self.ThemeList, name ) then table.insert( self.ThemeList, name ) end --So we can keep order
end
function HatsChat:SelectTheme( name )
	if not (self.Themes and self.Themes[ name ]) then return end
	
	if IsValid(self.Window) and self.ActiveTheme and self.ActiveTheme.End then self.ActiveTheme.End() end
	
	self.ActiveTheme = self.Themes[ name ]
	local thm = self.ActiveTheme
	thm.Name = name
	
	if not IsValid(self.Window) then return end
	
	if thm.Start then thm.Start() end
	
	--Apply theme
	--___________
	self.Window.ThemePaint = thm.Main or self.Window.DefPaint
	self.Window.InputPanel.Paint = thm.InputPanel or function() end
	self.Window.InputPanel.InputType.Paint = thm.Prompt or self.Window.InputPanel.InputType.DefPaint
	self.Window.InputPanel.SettingsButton.Paint = thm.Settings or self.Window.InputPanel.SettingsButton.DefPaint
	self.Window.InputPanel.EmoteButton.Paint = thm.EmoteButton or self.Window.InputPanel.EmoteButton.DefPaint
	self.Window.TextEntry.Paint = thm.TextEntry or self.Window.TextEntry.DefPaint
	
	local scr = self.Window.ScrollPanel:GetVBar()
	scr.Paint = thm.ScrollMain or scr.DefPaint
	scr.btnGrip.Paint = thm.ScrollGrip or scr.btnGrip.DefPaint
	scr.btnUp.Paint = thm.ScrollUp or scr.btnUp.DefPaint
	scr.btnDown.Paint = thm.ScrollDown or scr.btnDown.DefPaint
	
	self.Window.ScrollPanel.BG.Paint = thm.PanelBG or self.Window.ScrollPanel.BG.DefPaint
	self.Window.ScrollPanel.pnlCanvas.Paint = thm.PanelCanvas or function() end
	
	if IsValid(self.Window.ServerBar) then
		self.Window.ServerBar.Paint = thm.ServerBar or self.Window.ServerBar.DefPaint
		
		for i=1,#self.Window.ServerBar.Buttons do
			local btn = self.Window.ServerBar.Buttons[i]
			btn.Paint = thm.ServerButtonPaint or btn.DefaultPaint
		end
	end
	
	self:RefreshLines()
	if not self.Visible then
		self.Window.FadeAnim:Start( 0, false )
	end
end

function HatsChat:GetTheme()
	return self.ActiveTheme
end
function HatsChat:GetThemeName()
	return (self.ActiveTheme and self.ActiveTheme.Name) or false
end

for i=1,#Themes do include( "hatschat/themes/"..Themes[i] ) end