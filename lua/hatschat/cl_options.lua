
-----------------------------------------------------
-----------------------------------------
---------------HatsChat 2----------------
-----------------------------------------
--Copyright (c) 2013-2015 my_hat_stinks--
-----------------------------------------

--You probably don't want to edit this file, it's just the settings window
--Emotes, fonts, and LineIcons are in autorun/sh_hatschats.lua
--Chat filters are in cl_filter.lua
--Chat tags are in cl_chattags.lua
--Themes system is in sh_themes.lua, and themes are in /themes/

--Colours for Painting--
local WindowCol = {
	MainBG = Color(120,130,130), MainLight = Color(150,160,160), MainShadow = Color(60,60,60), Image = Color(255,255,255),
}
local BTxt = {
	Disabled = Color(82,82,82,179), Normal = Color(255,255,255,255), Hover = Color(85,190,150,255), Down = Color(82,82,82,255),
}
--Paint functions--
-------------------
local function PaintMain( s,w,h )
	surface.SetDrawColor( WindowCol.MainShadow )
	surface.DrawRect( 0,0, w,h )
	surface.SetDrawColor( WindowCol.MainLight )
	surface.DrawRect( 0,0, w-1,h-1 )
	surface.SetDrawColor( WindowCol.MainBG )
	surface.DrawRect( 1,1, w-2,h-2 )
	
	surface.SetDrawColor( WindowCol.MainShadow )
	surface.DrawRect( 3,2, w-6,21 )
	surface.SetDrawColor( WindowCol.MainLight )
	surface.DrawRect( 3,2, w-7,20 )
	surface.SetDrawColor( WindowCol.MainBG )
	surface.DrawRect( 4,3, w-8,19 )
end
local function PaintForm( s,w,h )
	surface.SetDrawColor( WindowCol.MainShadow )
	surface.DrawRect( 0,2, w,17 )
	surface.SetDrawColor( WindowCol.MainLight )
	surface.DrawRect( 0,2, w-1,16 )
	surface.SetDrawColor( WindowCol.MainBG )
	surface.DrawRect( 1,3, w-2,15 )
	
	surface.SetDrawColor( WindowCol.MainLight )
	surface.DrawRect( 0,19, w,math.max(0, h-19) )
	surface.SetDrawColor( WindowCol.MainShadow )
	surface.DrawRect( 0,19, w-1,math.max(0, h-20) )
	surface.SetDrawColor( WindowCol.MainBG )
	surface.DrawRect( 1,20, w-2, math.max(0, h-21) )
end
local function PaintFrame( s,w,h )
	surface.SetDrawColor( WindowCol.MainLight )
	surface.DrawRect( 0,0, w,h )
	surface.SetDrawColor( WindowCol.MainShadow )
	surface.DrawRect( 0,0, w-1,h-1 )
	surface.SetDrawColor( WindowCol.MainBG )
	surface.DrawRect( 1,1, w-2,h-2 )
end
local function PaintOutdent( s,w,h )
	surface.SetDrawColor( WindowCol.MainShadow )
	surface.DrawRect( 0,0, w,h )
	surface.SetDrawColor( WindowCol.MainLight )
	surface.DrawRect( 0,0, w-1,h-1 )
	surface.SetDrawColor( WindowCol.MainBG )
	surface.DrawRect( 1,1, w-2,h-2 )
end
local function PaintButton( s,w,h )
	if s.Depressed or s.m_bSelected then
		surface.SetDrawColor( WindowCol.MainLight )
		surface.DrawRect( 0,0, w,h )
		
		surface.SetDrawColor( WindowCol.MainShadow )
		surface.DrawRect( 0,0, w-1,h-1 )
	else
		surface.SetDrawColor( WindowCol.MainShadow )
		surface.DrawRect( 0,0, w,h )
		
		surface.SetDrawColor( WindowCol.MainLight )
		surface.DrawRect( 0,0, w-1,h-1 )
	end
	surface.SetDrawColor( WindowCol.MainBG )
	surface.DrawRect( 1,1, w-2,h-2 )
end
local function ButtonTxt( s,skin )
	if ( s:GetDisabled() )						then return s:SetTextStyleColor( BTxt.Disabled ) end
	if ( s.Depressed || s.m_bSelected )		then return s:SetTextStyleColor( BTxt.Down ) end
	if ( s.Hovered )								then return s:SetTextStyleColor( BTxt.Hover ) end
	
	return s:SetTextStyleColor( BTxt.Normal )
end

--Utility--
-----------
local function DScrollList( parent )
	--DListLayout doesn't scroll. DScrollPanel doesn't pad. Do I really need three different panels? :/
	local frm = vgui.Create( "DPanel", parent )
	frm.Paint = PaintFrame
	frm:Dock( FILL )
	frm:DockPadding(2,2,2,2)
	
	local scrframe = vgui.Create( "DScrollPanel", frm )
	scrframe:Dock( FILL )
	--scrframe:DockPadding( 5,5,5,5 )
	scrframe.Paint = function() end
	scrframe.VBar.btnUp.Paint = PaintOutdent
	scrframe.VBar.btnDown.Paint = PaintOutdent
	scrframe.VBar.btnGrip.Paint = PaintOutdent
	
	local SettingsFrame = vgui.Create( "DListLayout", scrframe )
	SettingsFrame:Dock( FILL )
	SettingsFrame.Paint = function() end
	SettingsFrame.PerformLayout = function( s )
		s:SizeToChildren( false, true )
		scrframe:InvalidateLayout()
	end
	SettingsFrame:DockPadding( 2,2,2,2 )
	
	return SettingsFrame, frm
end
local function LabeledTextEntry( parent, label, DefaultText )
	local pnl = vgui.Create( "DPanel", parent )
	pnl:SetTall( 20 )
	pnl.Paint = function() end
	
	local lbl = vgui.Create( "DLabel", pnl )
	lbl:SetDark( true )
	lbl:SetText( label )
	lbl:SizeToContents()
	lbl:Dock( LEFT )
	lbl:DockMargin( 0,0,10,0 )
	
	local txt = vgui.Create( "DTextEntry", pnl )
	txt:Dock( FILL )
	txt:SetValue( DefaultText or "" )
	
	return pnl, txt, lbl
end

local function dateOpenMenu( self, pControlOpener ) -- Override because of a bad sort
	if ( pControlOpener ) and ( pControlOpener == self.TextEntry ) then return end
	if ( #self.Choices == 0 ) then return end
	if ( IsValid( self.Menu ) ) then self.Menu:Remove() self.Menu = nil end
	self.Menu = DermaMenu()
	local sorted = {} for k, v in pairs( self.Choices ) do table.insert( sorted, { id = k, data = v } ) end
	for k, v in SortedPairsByMemberValue( sorted, "id" ) do
		self.Menu:AddOption( v.data, function() self:ChooseOption( v.data, v.id ) end )
	end
	local x, y = self:LocalToScreen( 0, self:GetTall() ) self.Menu:SetMinimumWidth( self:GetWide() ) self.Menu:Open( x, y, false, self )
end

--Options Window--
------------------
function HatsChat:PopulateOptions( SettingsFrame )
	local scrw, scrh = ScrW(), ScrH()
	--Server settings
	--_______________
	if HatsChat.HasPermission(LocalPlayer(), "HatsChatAdmin_Config", LocalPlayer():IsSuperAdmin()) then
		local set = vgui.Create("DForm", SettingsFrame)
		set:SetName( "Admin Settings" )
		set.Paint = PaintForm
		
		local pnl = vgui.Create( "DPanel", SettignsFrame )
		pnl:SetTall( 15 )
		pnl.Paint = function() end
		
		local lbl = vgui.Create( "DLabel", pnl )
		lbl:SetDark( true )
		lbl:SetText( "If you want to use custom defaults, change this!" )
		lbl:SizeToContents()
		lbl:Dock( FILL )
		lbl:DockMargin( 0,0,10,0 )
		
		set:AddItem( pnl )
		
		local pnl,txt = LabeledTextEntry( SettingsFrame, "Server Config ID", HatsChat.ConfigID )
		SettingsFrame.ConfigIDPnl = txt
		SettingsFrame.ConfigIDPnl.OnTextChanged = function( s ) --We'll validate server-side too, when it's sent
			local str = string.gsub(s:GetValue() or "", "[^%a_]", ""):lower() --Permit alphabetic characters and underscores only
			if str~=s:GetValue() then --We need to change something here
				local pos = s:GetCaretPos()
				s:SetText( str ) --Stick our fixed value in there
				s:SetCaretPos( math.min(pos, #str) ) --Stay in position if possible. This isn't neccessarily accurate, but it's quick
			end
		end
		
		set:AddItem( pnl )
	end
	
	--Chatbox Window Settings
	--_______________________
	local set = vgui.Create("DForm", SettingsFrame)
	set:SetName( "Chatbox Window" )
	set.Paint = PaintForm
	
	--So we can do it in order instead of having it all mixed up
	local BottomAlignBox,VertPosSlide,RightAlignBox,HoriPosSlide,WindHighSlide,WindWideSlide
	
	BottomAlignBox = set:CheckBox( "Align to Bottom", HatsChat.Settings.WindowAlignY:GetName() )
	BottomAlignBox.OnChange = function( s,data )
		HatsChat.Settings.SettingsCustomised:SetBool( 1 )
		
		HatsChat:DoWindowPos( {yalign = data} )
		if IsValid(VertPosSlide) then
			local val = s.PrevValue or VertPosSlide:GetValue()
			if data~=s.PrevData then --Called twice, for some reason
				s.PrevValue = VertPosSlide:GetValue()
				s.PrevData = data
			end
			if data then
				VertPosSlide:SetMin( HatsChat.Settings.WindowSizeY:GetInt() )
				VertPosSlide:SetMax( scrh )
			else
				VertPosSlide:SetMax( scrh-HatsChat.Settings.WindowSizeY:GetInt() )
				VertPosSlide:SetMin( 0 )
			end
			VertPosSlide:SetValue( math.Clamp(val or VertPosSlide:GetValue(), VertPosSlide:GetMin(), VertPosSlide:GetMax()) )
		end
	end
	
	VertPosSlide = set:NumSlider( "Vertical Position", HatsChat.Settings.WindowPosY:GetName(), 0, scrh, 0)
	if VertPosSlide.Label then
		VertPosSlide.Label:SetWrap(true)
	end
	VertPosSlide.OnValueChanged = function( s,data )
		HatsChat.Settings.SettingsCustomised:SetBool( 1 )
		HatsChat:DoWindowPos( {ypos = data} )
	end
	VertPosSlide:SetTooltip( "Chatbox Position" )
	
	RightAlignBox = set:CheckBox( "Align to Right", HatsChat.Settings.WindowAlignX:GetName() )
	RightAlignBox.OnChange = function( s,data )
		HatsChat.Settings.SettingsCustomised:SetBool( 1 )
		
		HatsChat:DoWindowPos( {xalign = data} )
		if IsValid(HoriPosSlide) then
			local val = s.PrevValue or HoriPosSlide:GetValue()
			if data~=s.PrevData then --Called twice, for some reason
				s.PrevValue = HoriPosSlide:GetValue()
				s.PrevData = data
			end
			if data then
				HoriPosSlide:SetMin( HatsChat.Settings.WindowSizeX:GetInt() )
				HoriPosSlide:SetMax( scrw )
			else
				HoriPosSlide:SetMax( scrw-HatsChat.Settings.WindowSizeX:GetInt() )
				HoriPosSlide:SetMin( 0 )
			end
			HoriPosSlide:SetValue( math.Clamp(val or HoriPosSlide:GetValue(), HoriPosSlide:GetMin(), HoriPosSlide:GetMax()) )
		end
	end
	
	HoriPosSlide = set:NumSlider( "Horizontal Position", HatsChat.Settings.WindowPosX:GetName(), 0, scrw, 0)
	if HoriPosSlide.Label then
		HoriPosSlide.Label:SetWrap(true)
	end
	HoriPosSlide.OnValueChanged = function( s,data )
		HatsChat.Settings.SettingsCustomised:SetBool( 1 )
		HatsChat:DoWindowPos( {xpos = data} )
	end
	HoriPosSlide:SetTooltip( "Chatbox Position" )
	
	WindHighSlide = set:NumSlider( "Window Height", HatsChat.Settings.WindowSizeY:GetName(), 0, scrh, 0)
	if WindHighSlide.Label then
		WindHighSlide.Label:SetWrap(true)
	end
	WindHighSlide.OnValueChanged = function( s,data )
		HatsChat.Settings.SettingsCustomised:SetBool( 1 )
		HatsChat:DoWindowPos( {high = data} )
		if IsValid(VertPosSlide) then
			if HatsChat.Settings.WindowAlignY:GetBool() then
				VertPosSlide:SetMin( s:GetValue() )
				VertPosSlide:SetMax( scrh )
				if VertPosSlide:GetValue()<VertPosSlide:GetMin() then
					VertPosSlide:SetValue( VertPosSlide:GetMin() )
				elseif VertPosSlide:GetValue()>VertPosSlide:GetMax() then
					VertPosSlide:SetValue( VertPosSlide:GetMax() )
				end
			else
				VertPosSlide:SetMax( scrh-s:GetValue() )
				VertPosSlide:SetMin( 0 )
				if VertPosSlide:GetValue()<VertPosSlide:GetMin() then
					VertPosSlide:SetValue( VertPosSlide:GetMin() )
				elseif VertPosSlide:GetValue()>VertPosSlide:GetMax() then
					VertPosSlide:SetValue( VertPosSlide:GetMax() )
				end
			end
		end
	end
	WindHighSlide:SetTooltip( "Chatbox Height" )
	
	WindWideSlide = set:NumSlider( "Window Width", HatsChat.Settings.WindowSizeX:GetName(), 0, scrw, 0)
	if WindWideSlide.Label then
		WindWideSlide.Label:SetWrap(true)
	end
	WindWideSlide.OnValueChanged = function( s,data )
		HatsChat.Settings.SettingsCustomised:SetBool( 1 )
		
		HatsChat:DoWindowPos( {wide = data} )
		if IsValid(HoriPosSlide) then
			if HatsChat.Settings.WindowAlignX:GetBool() then
				HoriPosSlide:SetMin( s:GetValue() )
				HoriPosSlide:SetMax( scrw )
				if HoriPosSlide:GetValue()<HoriPosSlide:GetMin() then
					HoriPosSlide:SetValue( HoriPosSlide:GetMin() )
				elseif HoriPosSlide:GetValue()>HoriPosSlide:GetMax() then
					HoriPosSlide:SetValue( HoriPosSlide:GetMax() )
				end
			else
				HoriPosSlide:SetMax( scrw-s:GetValue() )
				HoriPosSlide:SetMin( 0 )
				if HoriPosSlide:GetValue()<HoriPosSlide:GetMin() then
					HoriPosSlide:SetValue( HoriPosSlide:GetMin() )
				elseif HoriPosSlide:GetValue()>HoriPosSlide:GetMax() then
					HoriPosSlide:SetValue( HoriPosSlide:GetMax() )
				end
			end
		end
	end
	WindWideSlide:SetTooltip( "Chatbox Width" )
	
	--Themes
	--______
	local set = vgui.Create("DForm", SettingsFrame)
	set:SetName( "Chatbox Theme" )
	set.Paint = PaintForm
	
	pnl = vgui.Create( "DComboBox", set )
	pnl:Dock( TOP )
	local choice = HatsChat.Settings.ChatTheme:GetString()
	for i=1,#self.ThemeList do
		local nm = self.ThemeList[i]
		pnl:AddChoice( nm, nm, (choice==nm) )
	end
	pnl.OnSelect = function( s,index,val,data )
		HatsChat.Settings.SettingsCustomised:SetBool( 1 )
		RunConsoleCommand( HatsChat.Settings.ChatTheme:GetName(), data )
		HatsChat:SelectTheme( data )
	end
	set:AddItem( pnl )
	
	--Received Messages Settings
	--__________________________
	local set = vgui.Create("DForm", SettingsFrame)
	set:SetName( "Chat Text Settings" )
	set.Paint = PaintForm
	
	pnl = vgui.Create( "DComboBox", set )
	pnl:Dock( TOP )
	local choice = HatsChat.Settings.ChatTextFont:GetString()
	for k,v in pairs( self.FontData ) do
		pnl:AddChoice( k, k, (choice==k) )
	end
	pnl.OnSelect = function( s,index,val,data )
		HatsChat.Settings.SettingsCustomised:SetBool( 1 )
		RunConsoleCommand( HatsChat.Settings.ChatTextFont:GetName(), data )
		HatsChat:RefreshLines( {font=data} )
	end
	set:AddItem( pnl )
	
	pnl = set:NumSlider( "Font Size", HatsChat.Settings.ChatTextSize:GetName(), 16, 128, 0)
	if pnl.Label then
		pnl.Label:SetWrap(true)
	end
	pnl.OnValueChanged = function( s,data )
		HatsChat.Settings.SettingsCustomised:SetBool( 1 )
		
		timer.Create( "HatsChat_UpdateFontSize", 0.2, 1, function()
			RunConsoleCommand( HatsChat.Settings.ChatTextSize:GetName(), data )
			
			local ovr = {size=data}
			for k,v in pairs( HatsChat.FontData ) do HatsChat.FormatFont( k, v, ovr ) end
			
			HatsChat:RefreshLines()
		end)
	end
	pnl:SetTooltip( "Font size" )
	
	pnl = set:NumSlider( "Persistence time", HatsChat.Settings.ChatFadeTime:GetName(), 1, 120, 0)
	if pnl.Label then pnl.Label:SetWrap(true) end
	
	pnl = set:NumSlider( "Fade time", HatsChat.Settings.ChatFade2:GetName(), 1, 120, 2)
	if pnl.Label then pnl.Label:SetWrap(true) end
	
	--Misc
	--____
	local set = vgui.Create("DForm", SettingsFrame)
	set:SetName( "Misc Settings" )
	set.Paint = PaintForm
	
	pnl = set:NumSlider( "Fade Time", HatsChat.Settings.WindowFadeTime:GetName(), 0, 5, 2)
	if pnl.Label then pnl.Label:SetWrap(true) end
	
	local inScreenshots = set:CheckBox( "Show chatbox in Screenshots", HatsChat.Settings.ShowInScreenshots:GetName() )
	inScreenshots.OnChange = function( s,data )
		HatsChat.Settings.SettingsCustomised:SetBool( 1 )
	end
end
function HatsChat:OpenOptions()
	if not IsValid( self.Window ) then return end
	if IsValid( self.OptionsWindow ) then self.OptionsWindow:Remove() end
	
	self:Show()
	
	self.Window.TextEntry:SetEnabled( false )
	
	self.OptionsWindow = vgui.Create( "DFrame" )
	local ow = self.OptionsWindow
	ow:SetSize( 400, 500 )
	ow:SetPos( ScrW()/2-200, ScrH()/2-250 )
	ow:SetDeleteOnClose( true )
	ow:SetTitle( "HatsChat2 Settings" )
	ow.OnClose = function(s)
		self.Window.TextEntry:SetEnabled( true )
		self:RefreshLines()
		self:Hide()
		s:Remove()
	end
	ow.Think = function(s) --OnFocusChanged only refreshes focus once
		if not s:HasFocus() then
			if not IsValid(s.Popup) then
				s:MakePopup()
			end
		end
	end
	ow:MakePopup()
	ow.Paint = PaintMain
	
	local ButtonsFrame = vgui.Create( "DPanel", ow )
	ButtonsFrame:SetSize( 500, 25 )
	ButtonsFrame:Dock( BOTTOM )
	ButtonsFrame.Paint = PaintFrame
	ButtonsFrame:DockMargin( 0,5,0,0 )
	ButtonsFrame:DockPadding( 3,3,3,3 )
	
	local ResetButton = vgui.Create( "DButton", ButtonsFrame )
	ResetButton:Dock( FILL )
	ResetButton:SetText( "Reset to Default" )
	ResetButton.DoClick = function( s )
		ow:Close()
		self:ResetSettings()
	end
	ResetButton.Paint=PaintButton ResetButton.UpdateColours=ButtonTxt
	
	local SettingsFrame = DScrollList( ow )
	
	self:PopulateOptions( SettingsFrame )
	
	if HatsChat.HasPermission(LocalPlayer(), "HatsChatAdmin_Config", LocalPlayer():IsSuperAdmin()) then
		ResetButton:Dock( RIGHT )
		ResetButton:SetWide( 133 )
		
		local SetButton = vgui.Create( "DButton", ButtonsFrame )
		SetButton:SetWide( 133 )
		SetButton:Dock( LEFT )
		SetButton:SetText( "Set as server default" )
		SetButton.DoClick = function( s )
			if SettingsFrame.ConfigIDPnl:GetValue():lower()=="standard" then
				Derma_Message( "You must change \"Server Config ID\" to change default values.", "Error!", "OK" )
				
				return
			end
			local tbl = {
				XAlign = HatsChat.Settings.WindowAlignX:GetInt(), YAlign = HatsChat.Settings.WindowAlignY:GetInt(),
				PosX = HatsChat.Settings.WindowPosX:GetInt(), PosY = HatsChat.Settings.WindowPosY:GetInt(),
				Wide = HatsChat.Settings.WindowSizeX:GetInt(), Tall = HatsChat.Settings.WindowSizeY:GetInt(),
				TextFont = HatsChat.Settings.ChatTextFont:GetString(), TextSize = HatsChat.Settings.ChatTextSize:GetInt(), TextFade = HatsChat.Settings.ChatFadeTime:GetInt(),
				Theme = HatsChat.Settings.ChatTheme:GetString(), FadeTime = HatsChat.Settings.WindowFadeTime:GetInt(),
			}
			net.Start( "HatsChat_SetDefaults" )
				net.WriteString( SettingsFrame.ConfigIDPnl:GetValue() )
				net.WriteTable( tbl )
			net.SendToServer()
		end
		SetButton.Paint=PaintButton SetButton.UpdateColours=ButtonTxt
		
		local AdvButton = vgui.Create( "DButton", ButtonsFrame )
		AdvButton:Dock( FILL )
		AdvButton:SetText( "Open Server settings" )
		AdvButton.DoClick = function( s )
			ow:Close()
			self:OpenServerSettings()
		end
		AdvButton.Paint=PaintButton AdvButton.UpdateColours=ButtonTxt
	end
end
concommand.Add( "hatschat_settings", function() HatsChat:OpenOptions() end )


hook.Add( "TTTSettingsTabs", "HatsChat OptionsMenu TTTSettings", function( dtabs )
	local dsettings, frame = DScrollList( dtabs )
	frame:DockMargin( 2,2,2,1 )
	
	HatsChat:PopulateOptions( dsettings )
	
	dtabs:AddSheet("HatsChat2 Settings", frame, "icon16/wrench.png", false, false, "Client Chatbox settings")
end)

local Calendar = {
	{"January",31}, {"February",29}, {"March",31}, {"April",30}, {"May",31}, {"June",30}, {"July",31}, {"August",31}, {"September",30}, {"October",31}, {"November",30}, {"December",31},
}
local matRefresh = Material("icon16/arrow_refresh.png")
local function PopulateFliterSettings( SettingsFrame )
	if not IsValid( SettingsFrame ) then return end
	SettingsFrame:Clear()
	
	local filters = vgui.Create( "DForm", SettingsFrame )
	filters:SetName( "Chat Filter" )
	filters.Paint = PaintForm
	
	
	local pnl = vgui.Create( "DPanel", filters ) pnl.Paint = PaintFrame pnl:DockPadding( 3,3,3,3 )
	local LoadBox = vgui.Create( "DComboBox", pnl )
	HatsChat.ChatFilter.settingsCategory = LoadBox
	LoadBox:Dock( FILL )
	local sorted = {}
	for k,v in pairs( HatsChat.ChatFilter.CategoryData ) do
		if v==false then continue end
		table.insert( sorted, k )
	end
	table.sort( sorted )
	for _,v in ipairs( sorted ) do LoadBox:AddChoice( v ) end
	LoadBox:SetValue( "  ** Select Category **  " )
	filters:AddItem( pnl )
	
	local refresh = vgui.Create( "DButton", pnl )
	refresh:Dock( RIGHT ) refresh:SetSize(20,20)
	refresh:SetText( "" )
	refresh.Paint = function(s,w,h)
		PaintButton(s,w,h)
		surface.SetMaterial( matRefresh )
		surface.SetDrawColor( WindowCol.Image )
		if s.Depressed or s.m_bSelected then surface.DrawTexturedRect( 3,2, 16,16 ) else surface.DrawTexturedRect( 2,1, 16,16 ) end
	end
	refresh.DoClick = function(s)
		LoadBox:Refresh()
	end
	
	local CatButtonFrame = vgui.Create( "DPanel", filters )
	CatButtonFrame.Paint = PaintFrame
	CatButtonFrame:DockPadding( 3,3,3,3 )
	CatButtonFrame:DockMargin( 0,0,0,5 )
	filters:AddItem( CatButtonFrame )
	
	local btnNew = vgui.Create( "DButton", CatButtonFrame )
	btnNew:SetWide( 220 )
	btnNew:Dock( LEFT )
	btnNew.Paint = PaintButton btnNew.UpdateColours = ButtonTxt
	btnNew:SetText( "Category Editor" )
	
	local btnDelete = vgui.Create( "DButton", CatButtonFrame )
	btnDelete:SetWide( 220 )
	btnDelete:Dock( RIGHT )
	btnDelete.Paint = PaintButton btnDelete.UpdateColours = ButtonTxt
	btnDelete:SetText( "Delete category" )
	btnDelete.DoClick = function( s )
		if LoadBox:GetValue()=="  ** Select Category **  " or LoadBox:GetValue()=="  ** New Category **  " then return end
		
		net.Start( "HatsChat_SetValues" )
			net.WriteUInt( HATSCHAT_NET_FILTER_CATEGORIES, 3 )
			net.WriteString( LoadBox:GetValue() )
		net.SendToServer()
	end
	
	-- New Category --
	------------------
	local pnlCategoryEditor = vgui.Create( "DPanel", filters )
	pnlCategoryEditor.Paint = PaintFrame
	pnlCategoryEditor:Dock( TOP )
	pnlCategoryEditor:SetTall( 190 )
	pnlCategoryEditor:DockPadding( 5,5,5,5 )
	pnlCategoryEditor.Hidden = true
	filters:AddItem( pnlCategoryEditor )
	
	-- Name
	local pnl,newCategoryName = LabeledTextEntry( pnlCategoryEditor, "Category Name", "NewCategory" )
	pnl:Dock( TOP )
	
	-- Priority
	local pnl = vgui.Create( "DPanel", pnlCategoryEditor )
	pnl:SetTall( 20 ) pnl:Dock( TOP )
	pnl.Paint = function() end
	local lbl = vgui.Create( "DLabel", pnl )
	lbl:SetDark( true ) lbl:SetText( "Priority" )
	lbl:SizeToContents() lbl:Dock( LEFT ) lbl:DockMargin( 0,0,10,0 )
	local newCategoryPriority = vgui.Create( "DNumberWang", pnl )
	newCategoryPriority:Dock( LEFT )
	newCategoryPriority:SetMinMax( 0, 100 )
	newCategoryPriority:SetValue( 5 )
	
	-- Force Active
	local pnl = vgui.Create( "DPanel", pnlCategoryEditor )
	pnl:SetTall( 20 ) pnl:Dock( TOP )
	pnl.Paint = function() end
	local chkForceActive = vgui.Create( "DCheckBoxLabel", pnl )
	chkForceActive:SetText( "Force Active" ) chkForceActive:SetDark( true )
	chkForceActive:SetChecked( false )
	chkForceActive:SizeToContents()
	
	-- Pattern Filter
	local pnl = vgui.Create( "DPanel", pnlCategoryEditor )
	pnl:SetTall( 20 ) pnl:Dock( TOP )
	pnl.Paint = function() end
	local chkPatternFilter = vgui.Create( "DCheckBoxLabel", pnl )
	chkPatternFilter:SetText( "Pattern Filters (ADVANCED)" ) chkPatternFilter:SetDark( true )
	chkPatternFilter:SetChecked( false )
	chkPatternFilter:SizeToContents()
	
	-- Dates Checkbox
	local pnl = vgui.Create( "DPanel", pnlCategoryEditor )
	pnl:SetTall( 20 ) pnl:Dock( TOP )
	pnl.Paint = function() end
	local chkRestrictDates = vgui.Create( "DCheckBoxLabel", pnl )
	chkRestrictDates:SetText( "Restrict Dates" ) chkRestrictDates:SetDark( true )
	chkRestrictDates:SetChecked( false )
	chkRestrictDates:SizeToContents()
	
	-- Dates Selection
	local pnlDates = vgui.Create( "DPanel", pnlCategoryEditor )
	pnlDates.Paint = PaintFrame
	pnlDates:DockPadding( 5,5,5,0 )
	pnlDates:Dock( TOP )
	pnlDates:SetTall( chkRestrictDates:GetChecked() and 50 or 0 )
	
	local pnl = vgui.Create( "DPanel", pnlDates )
	pnl:SetTall( 20 ) pnl:Dock( TOP )
	pnl.Paint = function() end
	local lbl = vgui.Create( "DLabel", pnl )
	lbl:SetDark( true ) lbl:SetText( "Start date" )
	lbl:SizeToContents() lbl:Dock( LEFT ) lbl:DockMargin( 0,0,10,0 )
	local dateStartMonth = vgui.Create( "DComboBox", pnl )
	dateStartMonth:Dock( LEFT ) dateStartMonth:SetWide( 120 )
	for i=1,#Calendar do dateStartMonth:AddChoice( Calendar[i][1], i, i==1 ) end
	dateStartMonth.OpenMenu = dateOpenMenu
	local dateStartDay = vgui.Create( "DComboBox", pnl )
	dateStartDay:Dock( LEFT ) dateStartDay:SetWide( 80 )
	dateStartMonth.OnSelect = function( s,index,val,data )
		dateStartDay:Clear()
		for i=1,Calendar[index][2] do dateStartDay:AddChoice( i, i, i==1 ) end
	end
	dateStartMonth:ChooseOptionID( 1 )
	
	local pnl = vgui.Create( "DPanel", pnlDates )
	pnl:SetTall( 20 ) pnl:Dock( TOP )
	pnl.Paint = function() end
	local lbl = vgui.Create( "DLabel", pnl )
	lbl:SetDark( true ) lbl:SetText( "End date" )
	lbl:SizeToContents() lbl:Dock( LEFT ) lbl:DockMargin( 0,0,10,0 )
	local dateEndMonth = vgui.Create( "DComboBox", pnl )
	dateEndMonth:Dock( LEFT ) dateEndMonth:SetWide( 120 )
	for i=1,#Calendar do dateEndMonth:AddChoice( Calendar[i][1], i, i==1 ) end
	dateEndMonth.OpenMenu = dateOpenMenu
	local dateEndDay = vgui.Create( "DComboBox", pnl )
	dateEndDay:Dock( LEFT ) dateEndDay:SetWide( 80 )
	dateEndMonth.OnSelect = function( s,index,val,data )
		dateEndDay:Clear()
		for i=1,Calendar[index][2] do dateEndDay:AddChoice( i, i, i==1 ) end
	end
	dateEndMonth:ChooseOptionID( 1 )
	
	chkRestrictDates.OnChange = function(s)
		pnlDates:InvalidateLayout()
		-- pnlCategoryEditor:InvalidateLayout()
	end
	
	-- Buttons
	local NewCatButtonFrame = vgui.Create( "DPanel", pnlCategoryEditor )
	NewCatButtonFrame.Paint = PaintFrame
	NewCatButtonFrame:DockPadding( 3,3,3,3 )
	NewCatButtonFrame:DockMargin( 0,5,0,0 )
	NewCatButtonFrame:Dock( TOP )
	
	local btnCreateCategory = vgui.Create( "DButton", NewCatButtonFrame )
	btnCreateCategory:SetWide( 220 )
	btnCreateCategory:Dock( LEFT )
	btnCreateCategory.Paint = PaintButton btnCreateCategory.UpdateColours = ButtonTxt
	btnCreateCategory:SetText( "Create/Update" )
	btnCreateCategory.DoClick = function( s )
		local tbl = {
			Priority = newCategoryPriority:GetValue(),
			Force = chkForceActive:GetChecked(),
			Pattern = chkPatternFilter:GetChecked(),
			RestrictedDates = chkRestrictDates:GetChecked(),
		}
		if tbl.RestrictedDates then
			tbl.DateRange = {
				Start = { dateStartMonth:GetSelectedID(),dateStartDay:GetSelectedID() },
				End = { dateEndMonth:GetSelectedID(),dateEndDay:GetSelectedID() },
			}
		end
		net.Start( "HatsChat_SetValues" )
			net.WriteUInt( HATSCHAT_NET_FILTER_CATEGORIES, 3 )
			net.WriteString( newCategoryName:GetValue() )
			net.WriteTable(tbl)
		net.SendToServer()
	end
	
	local btnCancelCreate = vgui.Create( "DButton", NewCatButtonFrame )
	btnCancelCreate:SetWide( 220 )
	btnCancelCreate:Dock( RIGHT )
	btnCancelCreate.Paint = PaintButton btnCancelCreate.UpdateColours = ButtonTxt
	btnCancelCreate:SetText( "Cancel" )
	------------------
	
	-- Filter words --
	------------------
	local pnlWordEditor = vgui.Create( "DPanel", filters )
	pnlWordEditor.Paint = PaintFrame
	pnlWordEditor:Dock( TOP )
	pnlWordEditor:SetTall( 170 )
	pnlWordEditor:DockPadding( 5,0,5,5 )
	filters:AddItem( pnlWordEditor )
	
	local pnl,selectedCategory = LabeledTextEntry( pnlWordEditor, "Selected Category", "" )
	pnl:Dock( TOP ) pnl:DockMargin(0,5,0,0)
	selectedCategory:SetEnabled( false )
	selectedCategory:SetDisabled( true )
	selectedCategory:AllowInput( false )
	
	local pnl = vgui.Create( "DPanel", pnlWordEditor ) pnl.Paint = PaintFrame
	pnl:DockPadding( 3,3,3,3 ) pnl:DockMargin( 0,5,0,0 ) pnl:Dock( TOP )
	local WordBox = vgui.Create( "DComboBox", pnl )
	HatsChat.ChatFilter.settingsWords = WordBox
	WordBox:Dock( FILL )
	WordBox:SetValue( "  ** Select Word **  " )
	
	local pnl,triggerName,lblTrigerName = LabeledTextEntry( pnlWordEditor, "Trigger word", "fuck" )
	pnl:Dock( TOP ) pnl:DockMargin( 0,5,0,0 )
	local pnl,triggerReplace = LabeledTextEntry( pnlWordEditor, "Replace with", "fudge" )
	pnl:Dock( TOP ) pnl:DockMargin( 0,5,0,0 )
	
	local pnlTest = vgui.Create( "DPanel", pnlWordEditor )
	pnlTest.Paint = PaintFrame
	pnlTest:DockPadding( 5,0,5,5 )
	pnlTest:Dock( TOP )
	pnlTest:SetTall( 0 )
	
	local pnl,testString = LabeledTextEntry( pnlTest, "Test string", "Lorem ipsum dolor sit amet." )
	pnl:Dock( TOP ) pnl:DockMargin( 0,5,0,0 )
	
	local testPreview = vgui.Create( "DTextEntry", pnlTest )
	testPreview:Dock( FILL )
	testPreview:SetEditable( false )
	testPreview:SetMultiline( true )
	testPreview:SetValue( "" )
	
	local btnTest = vgui.Create( "DButton", pnl )
	btnTest:Dock( RIGHT )
	btnTest:SetWide( 70 )
	btnTest.Paint = PaintButton btnTest.UpdateColours = ButtonTxt
	btnTest:SetText( "Test" )
	btnTest.DoClick = function()
		testPreview:SetValue( string.gsub( (testString:GetValue() or ""), (triggerName:GetValue() or ""), (triggerReplace:GetValue() or "") ) )
	end
	
	-- Buttons
	local EditWordButtonFrame = vgui.Create( "DPanel", pnlWordEditor )
	EditWordButtonFrame.Paint = PaintFrame
	EditWordButtonFrame:DockPadding( 3,3,3,3 )
	EditWordButtonFrame:DockMargin( 0,5,0,0 )
	EditWordButtonFrame:Dock( TOP )
	
	local btnMakeWord = vgui.Create( "DButton", EditWordButtonFrame )
	btnMakeWord:SetWide( 220 )
	btnMakeWord:Dock( LEFT )
	btnMakeWord.Paint = PaintButton btnMakeWord.UpdateColours = ButtonTxt
	btnMakeWord:SetText( "Create/Update word" )
	btnMakeWord.Think = function( s )
		s:SetEnabled( HatsChat.ChatFilter.CategoryData[selectedCategory:GetValue()] )
	end
	btnMakeWord.DoClick = function( s )
		if not HatsChat.ChatFilter.CategoryData[selectedCategory:GetValue()] then return end
		
		net.Start( "HatsChat_SetFilter" )
			net.WriteString( selectedCategory:GetValue() )
			net.WriteString( triggerName:GetValue() )
			net.WriteString( triggerReplace:GetValue() )
		net.SendToServer()
	end
	
	local btnDeleteWord = vgui.Create( "DButton", EditWordButtonFrame )
	btnDeleteWord:SetWide( 220 )
	btnDeleteWord:Dock( RIGHT )
	btnDeleteWord.Paint = PaintButton btnDeleteWord.UpdateColours = ButtonTxt
	btnDeleteWord:SetText( "Delete word" )
	btnDeleteWord.Think = function( s )
		s:SetEnabled( HatsChat.ChatFilter.CategoryData[selectedCategory:GetValue()] )
	end
	btnDeleteWord.DoClick = function( s )
		if not HatsChat.ChatFilter.CategoryData[selectedCategory:GetValue()] then return end
		
		net.Start( "HatsChat_SetFilter" )
			net.WriteString( selectedCategory:GetValue() )
			net.WriteString( triggerName:GetValue() )
		net.SendToServer()
	end
	
	-- Layout --
	------------
	pnlCategoryEditor.PerformLayout = function( s ) s:SetTall( (s.Hidden and 0) or (140+pnlDates:GetTall()) ) end
	pnlCategoryEditor:InvalidateLayout()
	
	pnlWordEditor.PerformLayout = function( s ) s:SetTall( (pnlCategoryEditor.Hidden and (140+pnlTest:GetTall())) or 0 ) end
	pnlWordEditor:InvalidateLayout()
	
	pnlDates.PerformLayout = function(s) s:SetTall( chkRestrictDates:GetChecked() and 50 or 0 ) pnlCategoryEditor:InvalidateLayout() end
	
	btnNew.DoClick = function( s )
		pnlCategoryEditor.Hidden = false
		pnlCategoryEditor:InvalidateLayout()
		pnlWordEditor:InvalidateLayout()
	end
	btnCancelCreate.DoClick = function( s )
		pnlCategoryEditor.Hidden = true
		pnlCategoryEditor:InvalidateLayout()
		pnlWordEditor:InvalidateLayout()
	end
	
	-- Refresh --
	-------------
	LoadBox.Refresh = function(s)
		s:Clear()
		local sorted = {}
		for k,v in pairs( HatsChat.ChatFilter.CategoryData ) do
			if v==false then continue end
			table.insert( sorted, k )
		end
		table.sort( sorted )
		for _,v in ipairs( sorted ) do s:AddChoice( v ) end
		-- s:SetValue( "  ** Select Category **  " )
		if HatsChat.ChatFilter.CategoryData[ newCategoryName:GetValue() or "" ] then
			LoadBox:SetValue( newCategoryName:GetValue() or "" )
			LoadBox:OnSelect( nil, ( newCategoryName:GetValue() or "" ) )
		elseif newCategoryName:GetValue()=="" then
			LoadBox:SetValue( "  ** Select Category **  " )
			selectedCategory:SetValue("")
		else
			LoadBox:SetValue( "  ** New Category **  " )
			selectedCategory:SetValue("")
		end
	end
	
	WordBox.Load = function( s, cat )
		s:Clear()
		if not (cat and HatsChat.ChatFilter.Categories[cat]) then
			if triggerName:GetValue()=="" then
				WordBox:SetValue( "  ** Select Word **  " )
			else
				WordBox:SetValue( "  ** New Word **  " )
			end
			return
		end
		
		local sorted = {}
		for k,v in pairs( HatsChat.ChatFilter.Categories[cat] ) do
			if v==false then continue end
			table.insert( sorted, k )
		end
		table.sort( sorted )
		for _,v in ipairs( sorted ) do s:AddChoice( v ) end
		
		-- if not HatsChat.ChatFilter.Categories[ selectedCategory:GetValue() ] then HatsChat.ChatFilter.Categories[ selectedCategory:GetValue() ] = {} end
		if HatsChat.ChatFilter.Categories[ selectedCategory:GetValue() ] and HatsChat.ChatFilter.Categories[ selectedCategory:GetValue() ][ triggerName:GetValue() or "" ] then
			WordBox:SetValue( triggerName:GetValue() or "" )
		elseif triggerName:GetValue()=="" then
			WordBox:SetValue( "  ** Select Word **  " )
		else
			WordBox:SetValue( "  ** New Word **  " )
		end
	end
	WordBox.Refresh = function(s)
		s:Load( selectedCategory:GetValue() )
	end
	
	-- Populate settings --
	-----------------------
	LoadBox.OnSelect = function( s, ind, val )
		local cf = HatsChat.ChatFilter.CategoryData[ val ]
		if not cf then LoadBox:SetValue( "  ** Select Category **  " ) return end
		
		selectedCategory:SetValue( val )
		newCategoryName:SetValue( val )
		WordBox:Load( val )
		
		newCategoryPriority:SetValue( cf.Priority )
		chkForceActive:SetChecked( cf.Force )
		chkPatternFilter:SetChecked( cf.Pattern )
		chkRestrictDates:SetChecked( cf.RestrictedDates )
		
		if cf.DateRange and cf.DateRange.Start and cf.DateRange.End then
			dateStartMonth:ChooseOptionID( cf.DateRange.Start[1] )
			dateStartDay:ChooseOptionID( cf.DateRange.Start[2] )
			dateEndMonth:ChooseOptionID( cf.DateRange.End[1] )
			dateEndDay:ChooseOptionID( cf.DateRange.End[2] )
		else
			dateStartMonth:ChooseOptionID( 1 )
			dateStartDay:ChooseOptionID( 1 )
			dateEndMonth:ChooseOptionID( 1 )
			dateEndDay:ChooseOptionID( 1 )
		end
		
		pnlDates:InvalidateLayout()
		
		if cf.Pattern then
			lblTrigerName:SetText( "Trigger pattern" )
			lblTrigerName:SizeToContents()
			
			pnlTest:SetTall(60)
			
			-- testString:OnTextChanged()
		else
			lblTrigerName:SetText( "Trigger word" )
			lblTrigerName:SizeToContents()
			
			pnlTest:SetTall(0)
		end
	end
	newCategoryName.OnTextChanged = function( s )
		if HatsChat.ChatFilter.CategoryData[ s:GetValue() or "" ] then
			LoadBox:SetValue( s:GetValue() or "" )
			LoadBox:OnSelect( nil, ( s:GetValue() or "" ) )
		else
			LoadBox:SetValue( "  ** New Category **  " )
			selectedCategory:SetValue("")
		end
	end
	
	WordBox.OnSelect = function( s, ind, val )
		local wd = HatsChat.ChatFilter.Categories[ selectedCategory:GetValue() ] and HatsChat.ChatFilter.Categories[ selectedCategory:GetValue() ][ val ]
		if not wd then WordBox:SetValue( "  ** Select Word **  " ) return end
		
		triggerName:SetValue( val )
		triggerReplace:SetValue( wd )
		
		-- testString:OnTextChanged()
	end
	triggerName.OnTextChanged = function( s )
		-- if not HatsChat.ChatFilter.Categories[ selectedCategory:GetValue() ] then HatsChat.ChatFilter.Categories[ selectedCategory:GetValue() ] = {} end
		if HatsChat.ChatFilter.Categories[ selectedCategory:GetValue() ] and HatsChat.ChatFilter.Categories[ selectedCategory:GetValue() ][ s:GetValue() or "" ] then
			WordBox:SetValue( s:GetValue() or "" )
		else
			WordBox:SetValue( "  ** New Word **  " )
		end
		
		-- testString:OnTextChanged()
	end
	-- testString.OnTextChanged = function( s )
		-- testPreview:SetValue( string.gsub( (s:GetValue() or ""), (triggerName:GetValue() or ""), (triggerReplace:GetValue() or "") ) )
	-- end
end
local function PopulateEmoteSettings( SettingsFrame )
	if not IsValid( SettingsFrame ) then return end
	SettingsFrame:Clear()
	
	-- Emotes stuff --
	local add = vgui.Create( "DForm", SettingsFrame )
	add:SetName( "Emoticon Settings" )
	add.Paint = PaintForm
	
	local pnl = vgui.Create( "DPanel", add ) pnl.Paint = PaintFrame pnl:DockPadding( 3,3,3,3 )
	local LoadBox = vgui.Create( "DComboBox", pnl )
	LoadBox:Dock( FILL )
	local sorted = {}
	for k,v in pairs( HatsChat.Emote ) do
		if v==false then continue end
		table.insert( sorted, k )
	end
	table.sort( sorted )
	for _,v in ipairs( sorted ) do LoadBox:AddChoice( v ) end
	LoadBox:SetValue( "  ** Select Emote **  " )
	add:AddItem( pnl )
	
	local pnl,FilePath = LabeledTextEntry( add, "File Path", "icon16/tux.png" ) add:AddItem( pnl )
	local pnl,EmoteLabel = LabeledTextEntry( add, "Emoticon Label", ":tux:" ) add:AddItem( pnl )
	
	local EmoteWide = add:NumberWang( "Emoticon Width", nil, 8, 64, 0 ) EmoteWide:SetValue( 16 )
	local EmoteTall = add:NumberWang( "Emoticon Height", nil, 8, 64, 0 ) EmoteTall:SetValue( 16 )
	
	local pnl = vgui.Create( "DPanel", add )
	pnl:SetTall( 20 ) pnl.Paint = function() end
	local lbl = vgui.Create( "DLabel", pnl )
	lbl:SetDark( true ) lbl:SetText( "Permissions" ) lbl:SizeToContents() lbl:Dock( LEFT ) lbl:DockMargin( 0,0,10,0 )
	local Permission = vgui.Create( "DComboBox", pnl )
	Permission:Dock( FILL )
	Permission:AddChoice( "Everyone", HATSCHAT_PERM_ALL, true )
	Permission:AddChoice( "Donor Only", HATSCHAT_PERM_DONOR )
	Permission:AddChoice( "Admin Only", HATSCHAT_PERM_ADMIN )
	Permission:ChooseOptionID( 1 )
	Permission.OnSelect = function( s, ind, val, data )
		Permission.Sel = data
	end
	add:AddItem( pnl )
	
	local pnl = vgui.Create( "DPanel", add )
	pnl.Paint = function() end pnl:SetTall( 20 )
	local lbl = vgui.Create( "DLabel", pnl )
	lbl:SetDark( true ) lbl:SetText( "Preview" ) lbl:Dock( LEFT ) lbl:SetWide( 100 )
	local img = vgui.Create( "DImage", pnl )
	img:SetSize( EmoteWide:GetValue(), EmoteTall:GetValue() ) img:SetPos( 110, 0 )
	img:SetImage( FilePath:GetValue() )
	img.RefreshImg = function( s )
		s:SetSize( EmoteWide:GetValue(), EmoteTall:GetValue() )
		s:SetImage( FilePath:GetValue() )
	end
	
	add:AddItem( pnl )
	
	FilePath.OnTextChanged = function( s )
		local val = s:GetValue()
		if val and val~="" then
			img:SetImage( val )
		end
	end
	EmoteLabel.OnTextChanged = function( s )
		if HatsChat.Emote[ s:GetValue() or "" ] then
			LoadBox:SetValue( s:GetValue() or "" )
		else
			LoadBox:SetValue( "  ** New Emote **  " )
		end
	end
	EmoteWide.OnValueChange = function( s )
		img:SetWide( s:GetValue() )
	end
	EmoteTall.OnValueChange = function( s )
		img:SetTall( s:GetValue() )
		pnl:SetTall( math.max( 20, s:GetValue() ) )
	end
	
	LoadBox.OnSelect = function( s, ind, val )
		local em = HatsChat.Emote[ val ]
		if not em then LoadBox:SetValue( "  ** Select Emote **  " ) return end
		
		EmoteLabel:SetValue( val )
		FilePath:SetValue( em.icon )
		EmoteWide:SetValue( em.size and em.size[1] or 16 )
		EmoteTall:SetValue( em.size and em.size[2] or 16 )
		Permission:ChooseOptionID( (em.restricted==HatsChat.AdminOnly and 3) or (em.restricted==HatsChat.DonatorOnly and 2) or 1 )
		
		img:RefreshImg()
	end
	
	local ButtonFrame = vgui.Create( "DPanel", add )
	ButtonFrame.Paint = PaintFrame
	ButtonFrame:DockPadding( 3,3,3,3 )
	ButtonFrame:DockMargin( 0,0,0,5 )
	add:AddItem( ButtonFrame )
	
	local AddButton = vgui.Create( "DButton", ButtonFrame )
	AddButton:SetWide( 160 )
	AddButton:Dock( LEFT )
	AddButton.Paint = PaintButton AddButton.UpdateColours = ButtonTxt
	AddButton:SetText( "Add/Update Emote" )
	AddButton.DoClick = function( s )
		local tbl = {}
		tbl.icon = FilePath:GetValue()
		tbl.restricted = Permission.Sel or HATSCHAT_PERM_ALL
		if EmoteWide:GetValue()~=16 and EmoteTall:GetValue()~=16 then
			tbl.size = {EmoteWide:GetValue(),EmoteTall:GetValue()}
		end
		net.Start( "HatsChat_SetValues" )
			net.WriteUInt( HATSCHAT_NET_EMOTE, 3 )
			net.WriteString( EmoteLabel:GetValue() )
			net.WriteTable( tbl )
		net.SendToServer()
	end
	
	local ResetButton = vgui.Create( "DButton", ButtonFrame )
	ResetButton:SetWide( 160 )
	ResetButton:Dock( RIGHT )
	ResetButton.Paint = PaintButton ResetButton.UpdateColours = ButtonTxt
	ResetButton:SetText( "Remove Emote" )
	ResetButton.DoClick = function( s )
		net.Start( "HatsChat_SetValues" )
			net.WriteUInt( HATSCHAT_NET_EMOTE, 3 )
			net.WriteString( EmoteLabel:GetValue() )
		net.SendToServer()
	end
	
	local RefreshButton = vgui.Create( "DButton", ButtonFrame )
	RefreshButton:SetWide( 160 )
	RefreshButton:Dock( FILL )
	RefreshButton.Paint = PaintButton RefreshButton.UpdateColours = ButtonTxt
	RefreshButton:SetText( "Update Preview" )
	RefreshButton.DoClick = function( s ) img:RefreshImg() end
	
	--Chat Colours--
	local mod = vgui.Create( "DForm", SettingsFrame )
	mod:SetName( "Chat Colours" )
	mod.Paint = PaintForm
	
	local pnl = vgui.Create( "DPanel", mod ) pnl.Paint = PaintFrame pnl:DockPadding( 3,3,3,3 )
	local LoadBox = vgui.Create( "DComboBox", pnl )
	LoadBox:Dock( FILL )
	local sorted = {}
	for k,v in pairs( HatsChat.ChatCol ) do
		if v==false then continue end
		table.insert( sorted, k )
	end
	table.sort( sorted )
	for _,v in ipairs( sorted ) do LoadBox:AddChoice( v ) end
	LoadBox:SetValue( "  ** Select Color **  " )
	mod:AddItem( pnl )
	
	local pnl,ColorLabel = LabeledTextEntry( mod, "Color Label", "[red]" ) mod:AddItem( pnl )
	
	local pnl = vgui.Create( "DPanel", mod ) pnl.Paint = function() end
	local lbl = vgui.Create( "DLabel", pnl )
	lbl:SetDark( true ) lbl:SetText( "Colour" ) lbl:Dock( LEFT ) lbl:SetWide( 100 )
	local Colour = vgui.Create( "DColorMixer", pnl )
	Colour:Dock( FILL ) Colour:SetColor( Color(255,0,0) )
	Colour:SetPalette( false ) Colour:SetAlphaBar( false ) Colour:SetWangs( true )
	pnl:SetTall( 80 )
	mod:AddItem( pnl )
	
	local ShouldGlow = mod:CheckBox( "Glow?" )
	ShouldGlow:SetValue( false )
	
	local pnl = vgui.Create( "DPanel", mod ) pnl.Paint = function() end
	local lbl = vgui.Create( "DLabel", pnl )
	lbl:SetDark( true ) lbl:SetText( "Glow Colour" ) lbl:Dock( LEFT ) lbl:SetWide( 100 )
	local GlowCol = vgui.Create( "DColorMixer", pnl )
	GlowCol:Dock( FILL ) GlowCol:SetColor( Color(255,255,255) )
	GlowCol:SetPalette( false ) GlowCol:SetAlphaBar( false ) GlowCol:SetWangs( true )
	pnl:SetTall( 0 )
	mod:AddItem( pnl )
	
	ShouldGlow.OnChange = function( s, IsEnabled )
		pnl:SetTall( IsEnabled and 80 or 0 )
	end
	ColorLabel.OnTextChanged = function( s )
		if HatsChat.ChatCol[ s:GetValue() or "" ] then
			LoadBox:SetValue( s:GetValue() or "" )
		else
			LoadBox:SetValue( "  ** New Color **  " )
		end
	end
	
	local pnl = vgui.Create( "DPanel", mod )
	pnl:SetTall( 20 ) pnl.Paint = function() end
	local lbl = vgui.Create( "DLabel", pnl )
	lbl:SetDark( true ) lbl:SetText( "Permissions" ) lbl:SizeToContents() lbl:Dock( LEFT ) lbl:DockMargin( 0,0,10,0 )
	local Permission = vgui.Create( "DComboBox", pnl )
	Permission:Dock( FILL )
	Permission:AddChoice( "Everyone", HATSCHAT_PERM_ALL, true )
	Permission:AddChoice( "Donor Only", HATSCHAT_PERM_DONOR )
	Permission:AddChoice( "Admin Only", HATSCHAT_PERM_ADMIN )
	Permission:ChooseOptionID( 1 )
	Permission.OnSelect = function( s, ind, val, data )
		Permission.Sel = data
	end
	mod:AddItem( pnl )
	
	local pnl = vgui.Create( "DPanel", mod )
	pnl.Paint = function() end pnl:SetTall( 20 )
	local lbl = vgui.Create( "DLabel", pnl )
	lbl:SetDark( true ) lbl:SetText( "Preview" ) lbl:Dock( LEFT ) lbl:DockMargin( 0,0,10,0 )
	local prev = vgui.Create( "DPanel", pnl )
	prev:Dock( FILL )
	prev.Paint = function( s,w,h )
		surface.SetDrawColor( Color(255,255,255, 100) )
		surface.DrawRect( 0,0, w,h )
		
		local mult = (math.sin( CurTime()*2 )+1)/2
		surface.SetFont( "HatsChatPrompt" )
		surface.SetTextColor( Color(0,0,0) )
		surface.SetTextPos( 3,3 )
		surface.DrawText( "Lorem ipsum dolar sit amet." )
		
		if ShouldGlow:GetChecked() then
			local col = Colour:GetColor()
			local tar = GlowCol:GetColor()
			surface.SetTextColor( Color( col.r+(tar.r-col.r)*mult, col.g+(tar.g-col.g)*mult, col.b+(tar.b-col.b)*mult ) )
		else
			surface.SetTextColor( Colour:GetColor() )
		end
		surface.SetTextPos( 2,2 )
		surface.DrawText( "Lorem ipsum dolar sit amet." )
	end
	mod:AddItem( pnl )
	
	LoadBox.OnSelect = function( s, ind, val )
		local col = HatsChat.ChatCol[ val ]
		if not col then LoadBox:SetValue( "  ** Select Color **  " ) return end
		col = table.Copy( col )
		
		ColorLabel:SetValue( val )
		Colour:SetColor( col )
		ShouldGlow:SetValue( col.Glow )
		GlowCol:SetColor( col.GlowTarget or Color(255,255,255) )
		Permission:ChooseOptionID( (col.restriction==HatsChat.AdminOnly and 3) or (col.restriction==HatsChat.DonatorOnly and 2) or 1 )
	end
	
	local ButtonFrame = vgui.Create( "DPanel", mod )
	ButtonFrame.Paint = PaintFrame
	ButtonFrame:DockPadding( 3,3,3,3 )
	ButtonFrame:DockMargin( 0,0,0,5 )
	mod:AddItem( ButtonFrame )
	
	local AddButton = vgui.Create( "DButton", ButtonFrame )
	AddButton:SetWide( 220 )
	AddButton:Dock( LEFT )
	AddButton.Paint = PaintButton AddButton.UpdateColours = ButtonTxt
	AddButton:SetText( "Add/Update Colour" )
	AddButton.DoClick = function( s )
		local col = Colour:GetColor()
		if ShouldGlow:GetChecked() then
			col.Glow = true
			local target = GlowCol:GetColor()
			if target.r~=255 or target.g~=255 or target.b~=255 then
				target.a = 255
				col.GlowTarget = target
			end
		end
		col.a = 255
		col.restriction = Permission.Sel or HATSCHAT_PERM_ALL
		-- net.Start( "HatsChat_SetChatCol" )
		net.Start( "HatsChat_SetValues" )
			net.WriteUInt( HATSCHAT_NET_CHATCOL, 3 )
			net.WriteString( ColorLabel:GetValue() )
			net.WriteTable( col )
		net.SendToServer()
	end
	
	local ResetButton = vgui.Create( "DButton", ButtonFrame )
	ResetButton:SetWide( 220 )
	ResetButton:Dock( RIGHT )
	ResetButton.Paint = PaintButton ResetButton.UpdateColours = ButtonTxt
	ResetButton:SetText( "Remove Colour" )
	ResetButton.DoClick = function( s )
		-- net.Start( "HatsChat_SetChatCol" )
		net.Start( "HatsChat_SetValues" )
			net.WriteUInt( HATSCHAT_NET_CHATCOL, 3 )
			net.WriteString( ColorLabel:GetValue() )
		net.SendToServer()
	end
end
local function PopulateLineIconSettings( SettingsFrame )
	if not IsValid( SettingsFrame ) then return end
	SettingsFrame:Clear()
	
	--LineIcons--
	local icons = vgui.Create( "DForm", SettingsFrame )
	icons:SetName( "LineIcon Settings" )
	icons.Paint = PaintForm
	
	local pnl = vgui.Create( "DPanel", icons ) pnl.Paint = PaintFrame pnl:DockPadding( 3,3,3,3 )
	local LoadBox = vgui.Create( "DComboBox", pnl )
	LoadBox:Dock( FILL )
	local sorted = {}
	for k,v in pairs( HatsChat.LineIcon ) do
		if v==false then continue end
		table.insert( sorted, k )
	end
	table.sort( sorted )
	for _,v in ipairs( sorted ) do LoadBox:AddChoice( v ) end
	LoadBox:SetValue( "  ** Select LineIcon **  " )
	icons:AddItem( pnl )
	
	local pnl,LineIconLabel = LabeledTextEntry( icons, "LineIcon Rank/SteamID", "superadmin" ) icons:AddItem( pnl )
	local pnl,LineIconPath = LabeledTextEntry( icons, "LineIcon Path", "materials/icon16/shield_add.png" ) icons:AddItem( pnl )
	
	local ShouldUseAvatar = icons:CheckBox( "Use Steam avatar" )
	
	local pnl = vgui.Create( "DPanel", icons )
	pnl.Paint = function() end pnl:SetTall( 20 )
	local lbl = vgui.Create( "DLabel", pnl )
	lbl:SetDark( true ) lbl:SetText( "Preview" ) lbl:Dock( LEFT ) lbl:SetWide( 100 )
	local img = vgui.Create( "DImage", pnl )
	img:SetSize( 16, 16 ) img:SetPos( 110, 0 ) img:SetImage( LineIconPath:GetValue() )
	local avatar = vgui.Create( "AvatarImage", pnl )
	avatar:SetSize( 0, 0 ) avatar:SetPos( 110, 0 ) avatar:SetPlayer( LocalPlayer() )
	img.RefreshImg = function( s )
		if ShouldUseAvatar:GetChecked() then
			s:SetSize(0,0)
			avatar:SetSize(16,16)
		else
			avatar:SetSize(0,0)
			s:SetSize(16,16)
			local val = LineIconPath:GetValue()
			if val and val~="" then
				s:SetImage( val )
			end
		end
	end
	icons:AddItem( pnl )
	
	ShouldUseAvatar.OnChange = function( s, IsEnabled )
		LineIconPath:SetValue( IsEnabled and "AVATAR" or "materials/icon16/shield_add.png" )
		img:RefreshImg()
	end
	LineIconPath.OnTextChanged = function( s )
		ShouldUseAvatar:SetChecked( s:GetValue():lower()=="avatar" )
		img:RefreshImg()
	end
	LineIconLabel.OnTextChanged = function( s )
		local val, curs = s:GetValue(), s:GetCaretPos()
		s:SetText( (string.match( val:upper(), "STEAM_0:[0-1]:[0-9]*") and val:upper()) or
			(val:sub(1,9):lower()=="internal_" and val:sub(1,1):upper()..val:sub(2,8):lower()..val:sub(9,-1)) or
			val )
		s:SetValue( s:GetText() )
		s:SetCaretPos( curs )
		if HatsChat.LineIcon[ s:GetText() or "" ] then
			LoadBox:SetValue( s:GetText() or "" )
		else
			LoadBox:SetValue( "  ** New LineIcon **  " )
		end
	end
	
	LoadBox.OnSelect = function( s, ind, val )
		local col = HatsChat.LineIcon[ val ]
		if not col then LoadBox:SetValue( "  ** Select LineIcon **  " ) return end
		
		LineIconLabel:SetValue( val )
		LineIconPath:SetValue( col )
		LineIconPath:OnTextChanged()
	end
	
	local ButtonFrame = vgui.Create( "DPanel", icons )
	ButtonFrame.Paint = PaintFrame
	ButtonFrame:DockPadding( 3,3,3,3 )
	ButtonFrame:DockMargin( 0,0,0,5 )
	icons:AddItem( ButtonFrame )
	
	local AddButton = vgui.Create( "DButton", ButtonFrame )
	AddButton:SetWide( 220 )
	AddButton:Dock( LEFT )
	AddButton.Paint = PaintButton AddButton.UpdateColours = ButtonTxt
	AddButton:SetText( "Add/Update LineIcon" )
	AddButton.DoClick = function( s )
		net.Start( "HatsChat_SetValues" )
			net.WriteUInt( HATSCHAT_NET_LINEICON, 3 )
			net.WriteString( LineIconLabel:GetValue() )
			net.WriteTable( {SingleValue=true, val=LineIconPath:GetValue()} )
		net.SendToServer()
	end
	
	local ResetButton = vgui.Create( "DButton", ButtonFrame )
	ResetButton:SetWide( 220 )
	ResetButton:Dock( RIGHT )
	ResetButton.Paint = PaintButton ResetButton.UpdateColours = ButtonTxt
	ResetButton:SetText( "Remove LineIcon" )
	ResetButton.DoClick = function( s )
		net.Start( "HatsChat_SetValues" )
			net.WriteUInt( HATSCHAT_NET_LINEICON, 3 )
			net.WriteString( LineIconLabel:GetValue() )
		net.SendToServer()
	end
	
	--Chat tags--
	local tag = vgui.Create( "DForm", SettingsFrame )
	tag:SetName( "Chat Tag Settings" )
	tag.Paint = PaintForm
	
	local pnl = vgui.Create( "DPanel", tag ) pnl.Paint = PaintFrame pnl:DockPadding( 3,3,3,3 )
	local LoadBox = vgui.Create( "DComboBox", pnl )
	LoadBox:Dock( FILL )
	local sorted = {}
	for k,v in pairs( HatsChat.ChatTags.Tags ) do
		if v==false then continue end
		table.insert( sorted, k )
	end
	table.sort( sorted )
	for _,v in ipairs( sorted ) do LoadBox:AddChoice( v ) end
	LoadBox:SetValue( "  ** Select Chat Tag **  " )
	tag:AddItem( pnl )
	
	local pnl,ChatTagLabel = LabeledTextEntry( tag, "Chat Tag Rank/SteamID", "superadmin" ) tag:AddItem( pnl )
	local pnl,ChatTagTag = LabeledTextEntry( tag, "Chat Tag", "[S-Admin]" ) tag:AddItem( pnl )
	
	local UseChatCol = tag:CheckBox( "Use Chat Colour?" )
	
	--Standard Colouring stuff--
	local ColoursPanel = vgui.Create( "DPanel", tag ) ColoursPanel.Paint = function() end
	local SubPnl1 = vgui.Create( "DPanel", ColoursPanel ) SubPnl1.Paint = function() end
		local lbl = vgui.Create( "DLabel", SubPnl1 )
		lbl:SetDark( true ) lbl:SetText( "Colour" ) lbl:Dock( LEFT ) lbl:SetWide( 100 )
		local Colour = vgui.Create( "DColorMixer", SubPnl1 )
		Colour:Dock( FILL ) Colour:SetColor( Color(255,0,0) )
		Colour:SetPalette( false ) Colour:SetAlphaBar( false ) Colour:SetWangs( true )
	SubPnl1:SetTall( 80 ) SubPnl1:Dock( TOP )
	local SubPnl2 = vgui.Create( "DPanel", ColoursPanel ) SubPnl2.Paint = function() end
		local ShouldGlow = vgui.Create( "DCheckBoxLabel", SubPnl2 )
		ShouldGlow:SetText( "Glow?" ) ShouldGlow:SetDark( true ) ShouldGlow:Dock( LEFT )
	SubPnl2:SetTall( 20 ) SubPnl2:Dock( TOP )
	local SubPnl3 = vgui.Create( "DPanel", ColoursPanel ) SubPnl3.Paint = function() end
		local lbl = vgui.Create( "DLabel", SubPnl3 )
		lbl:SetDark( true ) lbl:SetText( "Glow Colour" ) lbl:Dock( LEFT ) lbl:SetWide( 100 )
		local GlowCol = vgui.Create( "DColorMixer", SubPnl3 )
		GlowCol:Dock( FILL ) GlowCol:SetColor( Color(255,255,255) )
		GlowCol:SetPalette( false ) GlowCol:SetAlphaBar( false ) GlowCol:SetWangs( true )
	SubPnl3:SetTall( 0 ) SubPnl3:Dock( TOP )
	ColoursPanel.PerformLayout = function( s ) s:SetTall( UseChatCol:GetChecked() and 0 or SubPnl1:GetTall()+SubPnl2:GetTall()+SubPnl3:GetTall()+6 ) end
	ColoursPanel.Paint=PaintFrame ColoursPanel:DockPadding(3,3,3,3) 
	ColoursPanel:InvalidateLayout()
	
	ShouldGlow.OnChange = function( s, IsEnabled )
		SubPnl3:SetTall( IsEnabled and 80 or 0 )
		ColoursPanel:InvalidateLayout()
	end
	tag:AddItem( ColoursPanel )
	--                        --
	
	--Chat colour stuff--
	local ChatColPnl,ChatColStr = LabeledTextEntry( tag, "Chat Colour", "[rainbow]" ) tag:AddItem( ChatColPnl )
	ChatColPnl.Paint = PaintFrame
	ChatColPnl.PerformLayout = function( s ) s:SetTall( UseChatCol:GetChecked() and 23 or 0 ) end
	ChatColPnl:DockPadding(3,3,3,3) ChatColPnl:InvalidateLayout()
	--                 --
	
	UseChatCol.OnChange = function( s, IsEnabled )
		ColoursPanel:InvalidateLayout()
		ChatColPnl:InvalidateLayout()
	end
	
	local pnl = vgui.Create( "DPanel", tag )
	pnl.Paint = function() end pnl:SetTall( 20 )
	local lbl = vgui.Create( "DLabel", pnl )
	lbl:SetDark( true ) lbl:SetText( "Preview" ) lbl:Dock( LEFT ) lbl:DockMargin( 0,0,10,0 )
	local prev = vgui.Create( "DPanel", pnl )
	prev:Dock( FILL )
	prev.DefCol = Color(150,150,200,255)
	prev.Paint = function( s,w,h )
		local str = ChatTagTag:GetValue()
		surface.SetDrawColor( Color(255,255,255, 100) )
		surface.DrawRect( 0,0, w,h )
		
		local mult = (math.sin( CurTime()*2 )+1)/2
		surface.SetFont( "HatsChatPrompt" )
		surface.SetTextColor( Color(0,0,0) )
		surface.SetTextPos( 3,3 )
		surface.DrawText( str )
		
		if UseChatCol:GetChecked() then
			local col = HatsChat.ChatCol[ ChatColStr:GetValue() ] or s.DefCol
			col.a = 255
			surface.SetTextColor( col )
		elseif ShouldGlow:GetChecked() then
			local col = Colour:GetColor()
			local tar = GlowCol:GetColor()
			surface.SetTextColor( Color( col.r+(tar.r-col.r)*mult, col.g+(tar.g-col.g)*mult, col.b+(tar.b-col.b)*mult ) )
		else
			surface.SetTextColor( Colour:GetColor() )
		end
		surface.SetTextPos( 2,2 )
		surface.DrawText( str )
	end
	tag:AddItem( pnl )
	
	ChatTagLabel.OnTextChanged = function( s )
		local val, curs = s:GetValue(), s:GetCaretPos()
		s:SetText( string.match( val:upper(), "STEAM_0:[0-1]:[0-9]*") and val:upper() or val )
		s:SetValue( s:GetText() )
		s:SetCaretPos( curs )
		if HatsChat.ChatTags.Tags[ s:GetText() or "" ] then
			LoadBox:SetValue( s:GetText() or "" )
		else
			LoadBox:SetValue( "  ** New LineIcon **  " )
		end
	end
	
	LoadBox.OnSelect = function( s, ind, val )
		local ctag = HatsChat.ChatTags.Tags[ val ]
		if not ctag then LoadBox:SetValue( "  ** Select Chat Tag **  " ) return end
		
		ChatTagLabel:SetValue( val )
		ChatTagTag:SetValue( ctag[2] )
		if ctag[1][1]=="chatcol" then
			UseChatCol:SetValue( true )
			ChatColStr:SetValue( ctag[1][2] )
		else
			UseChatCol:SetValue( false )
			local col = table.Copy( ctag[1] )
			GlowCol:SetColor( col.GlowTarget or Color(255,255,255) ) col.GlowTarget=nil
			ShouldGlow:SetValue( col.Glow ) col.Glow=nil
			Colour:SetColor( col )
		end
	end
	
	local ButtonFrame = vgui.Create( "DPanel", tag )
	ButtonFrame.Paint = PaintFrame
	ButtonFrame:DockPadding( 3,3,3,3 )
	ButtonFrame:DockMargin( 0,0,0,5 )
	tag:AddItem( ButtonFrame )
	
	local AddButton = vgui.Create( "DButton", ButtonFrame )
	AddButton:SetWide( 220 )
	AddButton:Dock( LEFT )
	AddButton.Paint = PaintButton AddButton.UpdateColours = ButtonTxt
	AddButton:SetText( "Add/Update Chat Tag" )
	AddButton.DoClick = function( s )
		local tbl = {}
		if UseChatCol:GetChecked() then
			table.insert( tbl, {"chatcol", ChatColStr:GetValue() } )
		elseif ShouldGlow:GetChecked() then
			local col = Colour:GetColor()
			local tar = GlowCol:GetColor()
			col.Glow = true
			col.a=255 tar.a=255
			if tar.r~=255 or tar.g~=255 or tar.b~=255 then
				col.GlowTarget = tar
			end
			table.insert( tbl, col )
		else
			table.insert( tbl, Colour:GetColor() )
		end
		table.insert( tbl, ChatTagTag:GetValue() )
		net.Start( "HatsChat_SetValues" )
			net.WriteUInt( HATSCHAT_NET_CHATTAG, 3 )
			net.WriteString( ChatTagLabel:GetValue() )
			net.WriteTable( tbl )
		net.SendToServer()
	end
	
	local ResetButton = vgui.Create( "DButton", ButtonFrame )
	ResetButton:SetWide( 220 )
	ResetButton:Dock( RIGHT )
	ResetButton.Paint = PaintButton ResetButton.UpdateColours = ButtonTxt
	ResetButton:SetText( "Remove Chat Tag" )
	ResetButton.DoClick = function( s )
		net.Start( "HatsChat_SetValues" )
			net.WriteUInt( HATSCHAT_NET_CHATTAG, 3 )
			net.WriteString( ChatTagLabel:GetValue() )
		net.SendToServer()
	end
end

function HatsChat:OpenServerSettings()
	if IsValid( self.OptionsWindow ) then self.OptionsWindow:Remove() end
	if not HatsChat.HasPermission(LocalPlayer(), "HatsChatAdmin_Config", LocalPlayer():IsSuperAdmin()) then return end
	
	self.OptionsWindow = vgui.Create( "DFrame" )
	local ow = self.OptionsWindow
	ow:SetSize( 500, math.min(700, ScrH()) )
	ow:SetPos( (ScrW()/2)-250, (ScrH()/2)-(ow:GetTall()/2) )
	ow:SetTitle( "HatsChat2 Advanced Server Settings" )
	ow:MakePopup()
	ow.Paint = PaintMain
	
	local SettingsFrame
	
	local ButtonFrame = vgui.Create( "DPanel", ow )
	ButtonFrame:Dock( TOP )
	ButtonFrame.Paint = PaintFrame
	ButtonFrame:DockPadding( 3,3,3,3 )
	ButtonFrame:DockMargin( 0,0,0,5 )
	
	local EmoteButton = vgui.Create( "DButton", ButtonFrame )
	local FliterButton = vgui.Create( "DButton", ButtonFrame )
	local IconButton = vgui.Create( "DButton", ButtonFrame )
	
	EmoteButton:SetWide( 160 )
	-- EmoteButton:SetWide( 240 )
	EmoteButton:Dock( LEFT )
	EmoteButton.Paint = PaintButton EmoteButton.UpdateColours = ButtonTxt
	EmoteButton:SetText( "User's Chat" )
	EmoteButton.DoClick = function( s )
		PopulateEmoteSettings( SettingsFrame )
		s:SetSelected( true )
		IconButton:SetSelected( false )
		FliterButton:SetSelected( false )
	end
	
	IconButton:SetWide( 160 )
	-- IconButton:SetWide( 240 )
	IconButton:Dock( FILL )
	IconButton.Paint = PaintButton IconButton.UpdateColours = ButtonTxt
	IconButton:SetText( "Rank Settings" )
	IconButton.DoClick = function( s )
		PopulateLineIconSettings( SettingsFrame )
		s:SetSelected( true )
		EmoteButton:SetSelected( false )
		FliterButton:SetSelected( false )
	end
	
	FliterButton:SetWide( 160 )
	FliterButton:Dock( RIGHT )
	FliterButton.Paint = PaintButton FliterButton.UpdateColours = ButtonTxt
	FliterButton:SetText( "Filter Settings" )
	FliterButton.DoClick = function( s )
		PopulateFliterSettings( SettingsFrame )
		s:SetSelected( true )
		EmoteButton:SetSelected( false )
		IconButton:SetSelected( false )
	end
	
	SettingsFrame = DScrollList( ow )
	EmoteButton:DoClick()
end
concommand.Add( "hatschat_advsettings", function() HatsChat:OpenServerSettings() end )

--[[
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
--]]