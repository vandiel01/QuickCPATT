-- Credit `ALL THE THINGS` to Crieve/Dylan
-- This Addon will NOT save or write or anything to ATT, it only reads what's given.
------------------------------------------------------------------------
-- User Modification If Needed
------------------------------------------------------------------------
--local ShowHide = true				-- Show (True)/Hide (False) All Times
local ShowHide = false				-- Show (True)/Hide (False) All Times
local DecimalDefault = 2			-- Decimal Precision Default is 2
local AllXpacATTPercent = true		-- All Xpac w ATT % (true) else False for Normal Operations

------------------------------------------------------------------------
-- Global Localizations
------------------------------------------------------------------------
local vTTable = {}
------------------------------------------------------------------------
-- Horz/Vert Toggles
------------------------------------------------------------------------
	function vQCP_Toggle(arg)
		Status = xpcall(CheckATT(), err)
		if arg ~= nil then
			for i = 1, 2 do _G["vQCP_Opt"..i]:SetChecked(false) end
			_G["vQCP_Opt"..arg]:SetChecked(true)
		end
		
		for j = 1, 9 do
			if _G["vQCP_DRHdr"..j]:GetChecked() then DRListTog(j) break end
		end
	end
------------------------------------------------------------------------
-- Single Expansion
------------------------------------------------------------------------
	function DRListTog(arg)
		Status = xpcall(CheckATT(), err)
		for i = 1, 2 do _G["vQCP_AllHdr"..i]:SetChecked(false) end	
		for i = 1, 9 do _G["vQCP_DRHdr"..i]:SetChecked(false) end
		_G["vQCP_DRHdr"..arg]:SetChecked(true)
			
		local vQCP_MaData = { AllTheThings.GetDataCache() }
		local vQCP_DRData = vQCP_MaData[1]["g"][1]["g"][arg]["g"]
		
		wipe(vTTable)
		for i = 1, #vQCP_DRData do
			if (vQCP_DRData[i]["total"] ~= 0 or vQCP_DRData[i]["progress"] ~= 0) and vQCP_DRData[i]["text"] ~= "Currencies" then
				tinsert(vTTable,
					(vQCP_WHdr:GetChecked() and vQCP_DRData[i]["text"]:gsub("|cffff8000",""):gsub("|r","").." - " or "")..
					string.format("%."..vQCP_HdrDec:GetNumber().."f",(vQCP_DRData[i]["progress"]/vQCP_DRData[i]["total"])*100)..
					(vQCP_Opt1:GetChecked() and "\n" or "\t")
				)
			end
		end
		vQCP_RPArea:SetText(table.concat(vTTable,""))
	end
------------------------------------------------------------------------
-- All Expansion
------------------------------------------------------------------------	
	function AllListTog(arg)
		Status = xpcall(CheckATT(), err)
		for i = 1, 9 do _G["vQCP_DRHdr"..i]:SetChecked(false) end
		for i = 1, 2 do _G["vQCP_AllHdr"..i]:SetChecked(false) end	
		_G["vQCP_AllHdr"..arg]:SetChecked(true)
		
		vQCP_MainData = { AllTheThings.GetDataCache() }
		vQCP_TotalDR = vQCP_MainData[1]["g"][1]["g"]
		wipe(vTTable)

		for j = 1, #vQCP_TotalDR do
			vQCP_DRData = vQCP_MainData[1]["g"][1]["g"][j]["g"]
			
			if arg == 2 then
				tinsert(vTTable,
					(vQCP_WHdr:GetChecked() and vQCP_TotalDR[j]["text"]:gsub("|cffff8000",""):gsub("|r","").." - " or "")..
					string.format("%."..vQCP_HdrDec:GetNumber().."f",(vQCP_TotalDR[j]["progress"]/vQCP_TotalDR[j]["total"])*100)..
					(vQCP_Opt1:GetChecked() and "\n" or "\t")
				)
			end
			
			for i = 1, #vQCP_DRData do
				if (vQCP_DRData[i]["total"] ~= 0 or vQCP_DRData[i]["progress"] ~= 0) and vQCP_DRData[i]["text"] ~= "Currencies" then
					tinsert(vTTable,
						(vQCP_WHdr:GetChecked() and vQCP_DRData[i]["text"]:gsub("|cffff8000",""):gsub("|r","").." - " or "")..
						string.format("%."..vQCP_HdrDec:GetNumber().."f",(vQCP_DRData[i]["progress"]/vQCP_DRData[i]["total"])*100)..
						(vQCP_Opt1:GetChecked() and "\n" or "\t")
					)	
				end
			end
		end
		vQCP_RPArea:SetText("\n"..table.concat(vTTable,""))
	end
------------------------------------------------------------------------
-- Main % List Only
------------------------------------------------------------------------	
	function ATTMainList()
		Status = xpcall(CheckATT(), err)
		
		vQCP_MainData = { AllTheThings.GetDataCache() }
		vQCP_TotalDR = vQCP_MainData[1]["g"]
		wipe(vTTable)

		for j = 1, #vQCP_TotalDR do
			if j < 21 then
				tinsert(vTTable,
					(vQCP_WHdr:GetChecked() and vQCP_TotalDR[j]["text"]:gsub("|cffff8000",""):gsub("|r","").." - " or "")..
					((vQCP_TotalDR[j]["progress"] == 0 and vQCP_TotalDR[j]["total"] == 0) and string.format("%."..vQCP_HdrDec:GetNumber().."f","0") or string.format("%."..vQCP_HdrDec:GetNumber().."f",(vQCP_TotalDR[j]["progress"]/vQCP_TotalDR[j]["total"])*100))..
					(vQCP_Opt1:GetChecked() and "\n" or "\t")
				)
			end
		end
		vQCP_RPArea:SetText(table.concat(vTTable,""))
	end
------------------------------------------------------------------------
-- Check Mode on ATT
------------------------------------------------------------------------
	function CheckATT()
		v = ""
		if _G["AllTheThingsSettings"]["General"]["AccountMode"] then v = "Account" end
		if _G["AllTheThingsSettings"]["General"]["Completionist"] then v = v.." Completionist" else v = v.." Unique" end
		if _G["AllTheThingsSettings"]["General"]["DebugMode"] then v = "DEBUG" end
		
		vQCP_WarnHeader.T:SetText("Heads up! You're on\n -- |cFFFFFF00 "..v.." |r --\nmode!")
	end
------------------------------------------------------------------------
-- Framing
------------------------------------------------------------------------
	local BDropA = {
		edgeFile = "Interface\\ToolTips\\UI-Tooltip-Border",
		bgFile = "Interface\\BlackMarket\\BlackMarketBackground-Tile",
		tileEdge = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	}
	local BDropB = {
		edgeFile = "Interface\\ToolTips\\UI-Tooltip-Border",
		bgFile = "Interface\\BankFrame\\Bank-Background",
		tileEdge = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	}
------------------------------------------------------------------------
-- Mini Map Button
------------------------------------------------------------------------
	local vQCP_MiniMap = CreateFrame("Button", "vQCP_MiniMap", Minimap)
		vQCP_MiniMap:SetFrameLevel(8)
		vQCP_MiniMap:SetSize(40, 40)
		vQCP_MiniMap:SetNormalTexture("Interface\\Store\\category-icon-services")
		vQCP_MiniMap:ClearAllPoints()
		vQCP_MiniMap:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 0, -20)
		vQCP_MiniMap:SetMovable(false)
		vQCP_MiniMap:RegisterForDrag("LeftButton")
		vQCP_MiniMap:SetScript("OnClick", function()
			if vQCP_Main:IsVisible() then vQCP_Main:Hide() else vQCP_Main:Show() end
			_G["vQCP_Opt1"]:SetChecked(true)
		end)
------------------------------------------------------
-- Rest of the Frames
------------------------------------------------------------------------
	local vQCP_Main = CreateFrame("Frame", "vQCP_Main", UIParent, BackdropTemplateMixin and "BackdropTemplate")
		vQCP_Main:SetBackdrop(BDropA)
		vQCP_Main:SetSize(300, 380)
		vQCP_Main:ClearAllPoints()
		vQCP_Main:SetPoint("CENTER", UIParent)
		vQCP_Main:EnableMouse(true)
		vQCP_Main:SetMovable(true)
		vQCP_Main:RegisterForDrag("LeftButton")
		vQCP_Main:SetScript("OnDragStart", function() vQCP_Main:StartMoving() end)
		vQCP_Main:SetScript("OnDragStop", function() vQCP_Main:StopMovingOrSizing() end)
		vQCP_Main:SetClampedToScreen(true)
		if not ShowHide then vQCP_Main:Hide() end

	local vQCP_Title = CreateFrame("Frame", "vQCP_Title", vQCP_Main, BackdropTemplateMixin and "BackdropTemplate")
		vQCP_Title:SetBackdrop(BDropB)
		vQCP_Title:SetSize(vQCP_Main:GetWidth()-4,24)
		vQCP_Title:ClearAllPoints()
		vQCP_Title:SetPoint("TOP", vQCP_Main, 0, -2)
			vQCP_Title.Text = vQCP_Title:CreateFontString("T")
			vQCP_Title.Text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
			vQCP_Title.Text:SetPoint("CENTER", vQCP_Title)
			vQCP_Title.Text:SetText("Pull D&R ATT Data for Quick Copy")
			local vQCP_TitleX = CreateFrame("Button", "vQCP_TitleX", vQCP_Title, "UIPanelCloseButton")
				vQCP_TitleX:SetSize(26,26)
				vQCP_TitleX:SetPoint("RIGHT", vQCP_Title, 0, 0)
				vQCP_TitleX:SetScript("OnClick", function() vQCP_Main:Hide() end)

	local vQCP_WHdr = CreateFrame("CheckButton", "vQCP_WHdr", vQCP_Main, "ChatConfigCheckButtonTemplate")
		vQCP_WHdr:SetPoint("TOPLEFT", vQCP_Main, 5, -25)
		vQCP_WHdr:SetChecked(false)
		vQCP_WHdr:SetScript("OnClick", function() vQCP_Toggle() end)
			vQCP_WHdr.Text = vQCP_WHdr:CreateFontString("T")
			vQCP_WHdr.Text:SetFont("Fonts\\FRIZQT__.TTF", 10)
			vQCP_WHdr.Text:SetPoint("LEFT", vQCP_WHdr, 25, 0)
			vQCP_WHdr.Text:SetText("Check To Include D&R Header [Default: Off]")
		
	local vQCP_HdrDec = CreateFrame("EditBox", "vQCP_HdrDec", vQCP_Main, "InputBoxTemplate")
		vQCP_HdrDec:SetSize(24,20)
		vQCP_HdrDec:SetPoint("TOPLEFT", vQCP_Main, 150, -61)
		vQCP_HdrDec:SetFont("Fonts\\FRIZQT__.TTF", 10)
		vQCP_HdrDec:SetMaxLetters(10)
		vQCP_HdrDec:SetAutoFocus(false)
		vQCP_HdrDec:SetMultiLine(false)
		vQCP_HdrDec:SetNumeric(true)
		vQCP_HdrDec:SetNumber(DecimalDefault)
		vQCP_HdrDec:SetScript("OnEditFocusLost", function() if vQCP_HdrDec:GetText() == "" then vQCP_HdrDec:SetText(DecimalDefault) end end)
			vQCP_HdrDec.Text = vQCP_HdrDec:CreateFontString("T")
			vQCP_HdrDec.Text:SetFont("Fonts\\FRIZQT__.TTF", 10)
			vQCP_HdrDec.Text:SetPoint("LEFT", vQCP_HdrDec, 30, 0)
			vQCP_HdrDec.Text:SetText("Decimal Precision")

	OptList = { "Vertical", "Horizontal" }
	DRHeight = -43
	for i = 1, #OptList do
		local vQCP_Opt = CreateFrame("CheckButton", "vQCP_Opt"..i, vQCP_Main, "ChatConfigCheckButtonTemplate")
			vQCP_Opt:SetPoint("TOPLEFT", vQCP_Main, 5, DRHeight)
			vQCP_Opt:SetChecked(false)
			vQCP_Opt:SetScript("OnClick", function() vQCP_Toggle(i) end)
				vQCP_Opt.Text = vQCP_Opt:CreateFontString("T")
				vQCP_Opt.Text:SetFont("Fonts\\FRIZQT__.TTF", 10)
				vQCP_Opt.Text:SetPoint("LEFT", _G["vQCP_Opt"..i], 25, 0)
				vQCP_Opt.Text:SetText(OptList[i])
		DRHeight = DRHeight - 18
	end
	
		vQCP_Header = vQCP_Main:CreateFontString("T")
		vQCP_Header:SetFont("Fonts\\FRIZQT__.TTF", 10)
		vQCP_Header:SetPoint("TOPLEFT", vQCP_Main, 10, -95)
		vQCP_Header:SetText("|CFFFFFF00Individual Expansion|r")
			
	DRList = { "Classic", "Burning Crusade", "Wrath of Lich King", "Cataclysm", "Mists of Pandaria", "Warlords of Draenor", "Legion", "Battle for Azeroth", "Shadowlands" }
	DRHeight = -105
	for i = 1, #DRList do
		local vQCP_DRHdr = CreateFrame("CheckButton", "vQCP_DRHdr"..i, vQCP_Main, "ChatConfigCheckButtonTemplate")
			vQCP_DRHdr:SetPoint("TOPLEFT", vQCP_Main, 5, DRHeight)
			vQCP_DRHdr:SetChecked(false)
			vQCP_DRHdr:SetScript("OnClick", function() DRListTog(i) end)
				vQCP_DRHdr.Text = vQCP_DRHdr:CreateFontString("T")
				vQCP_DRHdr.Text:SetFont("Fonts\\FRIZQT__.TTF", 10)
				vQCP_DRHdr.Text:SetPoint("LEFT", _G["vQCP_DRHdr"..i], 25, 0)
				vQCP_DRHdr.Text:SetText(DRList[i])
		DRHeight = DRHeight - 18
	end

		vQCP_Header = vQCP_Main:CreateFontString("T")
		vQCP_Header:SetFont("Fonts\\FRIZQT__.TTF", 10)
		vQCP_Header:SetPoint("TOPLEFT", vQCP_Main, 10, -280)
		vQCP_Header:SetText("|cFFFFFF00All Raw Xpac Data|r")

	AllList = { "All Exp - No Hdr %", "All Exp - ATT Hdr %" }
	DRHeight = -290
	for i = 1, #AllList do
		local vQCP_AllHdr = CreateFrame("CheckButton", "vQCP_AllHdr"..i, vQCP_Main, "ChatConfigCheckButtonTemplate")
			vQCP_AllHdr:SetPoint("TOPLEFT", vQCP_Main, 5, DRHeight)
			vQCP_AllHdr:SetChecked(false)
			vQCP_AllHdr:SetScript("OnClick", function() AllListTog(i) end)
				vQCP_AllHdr.Text = vQCP_AllHdr:CreateFontString("T")
				vQCP_AllHdr.Text:SetFont("Fonts\\FRIZQT__.TTF", 10)
				vQCP_AllHdr.Text:SetPoint("LEFT", _G["vQCP_AllHdr"..i], 25, 0)
				vQCP_AllHdr.Text:SetText(AllList[i])
		DRHeight = DRHeight - 18
	end
	
		vQCP_Header = vQCP_Main:CreateFontString("T")
		vQCP_Header:SetFont("Fonts\\FRIZQT__.TTF", 10)
		vQCP_Header:SetPoint("TOPLEFT", vQCP_Main, 10, -340)
		vQCP_Header:SetText("|cFFFFFF00Main ATT List % Only|r")
		
		local vQCP_MainList = CreateFrame("Button", "vQCP_MainList", vQCP_Main, "UIPanelButtonTemplate")
			vQCP_MainList:SetSize(120,20)
			vQCP_MainList:SetPoint("TOPLEFT", vQCP_Main, 5, -353)
			vQCP_MainList:SetText("ATT List % Only")
			vQCP_MainList:SetScript("OnClick", function() ATTMainList() end)

	--RIGHT SIDE
	local vQCP_RightPane = CreateFrame("Frame", "vQCP_RightPane", vQCP_Main, BackdropTemplateMixin and "BackdropTemplate")
		vQCP_RightPane:SetBackdrop(BDropA)
		vQCP_RightPane:SetSize(vQCP_Main:GetWidth()-145, vQCP_Main:GetHeight()-136)
		vQCP_RightPane:ClearAllPoints()
		vQCP_RightPane:SetPoint("TOPRIGHT", vQCP_Main, -2, -133)
		local vQCP_RPScr = CreateFrame("ScrollFrame", "vQCP_RPScr", vQCP_RightPane, "UIPanelScrollFrameTemplate")
			vQCP_RPScr:SetPoint("TOPLEFT", vQCP_RightPane, 7, -7)
			vQCP_RPScr:SetWidth(vQCP_RightPane:GetWidth()-35)
			vQCP_RPScr:SetHeight(vQCP_RightPane:GetHeight()-12)
				vQCP_RPArea = CreateFrame("EditBox", "vQCP_RPArea", vQCP_RPScr)
				vQCP_RPArea:SetWidth(vQCP_RPScr:GetWidth())
				vQCP_RPArea:SetFont("Fonts\\FRIZQT__.TTF", 10)
				vQCP_RPArea:SetAutoFocus(false)
				vQCP_RPArea:SetMultiLine(true)
				vQCP_RPArea:EnableMouse(true)
				vQCP_RPArea:SetScript("OnEditFocusGained", function() vQCP_RPArea:HighlightText() end)
			vQCP_RPScr:SetScrollChild(vQCP_RPArea)

	local vQCP_WarnHeader = CreateFrame("Frame", "vQCP_WarnHeader", vQCP_Main, BackdropTemplateMixin and "BackdropTemplate")
		vQCP_WarnHeader:SetBackdrop(BDropB)
		vQCP_WarnHeader:SetSize(vQCP_Main:GetWidth()-145, 55)
		vQCP_WarnHeader:ClearAllPoints()
		vQCP_WarnHeader:SetPoint("TOPRIGHT", vQCP_Main, -2, -80)
			vQCP_WarnHeader.T = vQCP_WarnHeader:CreateFontString("T")
			vQCP_WarnHeader.T:SetFont("Fonts\\FRIZQT__.TTF", 12)
			vQCP_WarnHeader.T:SetPoint("CENTER", vQCP_WarnHeader, "CENTER", 0, 0)
			vQCP_WarnHeader.T:SetText()

------------------------------------------------------------------------
-- Fire Up Events
------------------------------------------------------------------------
	local vQCP_OnUpdate = CreateFrame("Frame")
	vQCP_OnUpdate:RegisterEvent("ADDON_LOADED")
	vQCP_OnUpdate:SetScript("OnEvent", function(self, event, ...)
		if event == "ADDON_LOADED" then
			vQCP_OnUpdate:RegisterEvent("PLAYER_LOGIN")
			vQCP_OnUpdate:UnregisterEvent("ADDON_LOADED")
		end
		if event == "PLAYER_LOGIN" then
			SLASH_QuickCPATT1 = '/qcp'
			SLASH_QuickCPATT2 = '/quickcp'
			
			SlashCmdList["QuickCPATT"] = function(arg)
				if IsAddOnLoaded("AllTheThings") then
					if vQCP_Main:IsVisible() then vQCP_Main:Hide() else vQCP_Main:Show() end
					_G["vQCP_Opt1"]:SetChecked(true)
					
				else
					DEFAULT_CHAT_FRAME:AddMessage("Error: Cannot Run This without `All The Things`")
				end
			end

			if ShowHide then _G["vQCP_Opt1"]:SetChecked(true) end
			if AllXpacATTPercent then _G["vQCP_AllHdr2"]:SetChecked(true) end

			vQCP_OnUpdate:UnregisterEvent("PLAYER_LOGIN")
		end
	end)
	Status = xpcall(CheckATT(), err)
	