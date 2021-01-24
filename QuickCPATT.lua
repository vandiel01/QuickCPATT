-- Credit `ALL THE THINGS` to Crieve/Dylan
-- This Addon will NOT save or write or anything to ATT, it only reads what's given.
------------------------------------------------------------------------
-- Checkbox Toggles
------------------------------------------------------------------------
	function vQCP_Toggle(arg)
		if arg ~= nil then
			for i = 1, 2 do
				_G["vQCP_Opt"..i]:SetChecked(false)
			end
			_G["vQCP_Opt"..arg]:SetChecked(true)
		end
		
		if _G["AllTheThingsSettings"]["General"]["DebugMode"] then
			vQCP_RPArea:SetText("|cFFFFFF00Not Recommended with\nATT DEBUG Mode|r")
		else
			for j = 1, 9 do
				if _G["vQCP_DRHdr"..j]:GetChecked() then DRListTog(j) break end
			end
		end
	end
	
	function DRListTog(arg)
		for i = 1, 9 do
			_G["vQCP_DRHdr"..i]:SetChecked(false)
		end
		_G["vQCP_DRHdr"..arg]:SetChecked(true)
			
		if _G["AllTheThingsSettings"]["General"]["DebugMode"] then
			vQCP_RPArea:SetText("|cFFFFFF00Not Recommended with\nATT DEBUG Mode|r")
		else
			local vQCP_MaData = { AllTheThings.GetDataCache() }
			local vQCP_DRData = vQCP_MaData[1]["g"][1]["g"][arg]["g"]
			local vTTable = {}
			wipe(vTTable)
			for i = 1, #vQCP_DRData do
				if vQCP_DRData[i]["total"] ~= 0 then
					tinsert(vTTable,(vQCP_WHdr:GetChecked() and vQCP_DRData[i]["text"]:gsub("|cffff8000",""):gsub("|r","").." - " or "")..string.format("%.2f",(vQCP_DRData[i]["progress"]/vQCP_DRData[i]["total"])*100)..(vQCP_Opt1:GetChecked() and "\n" or "\t"))
				end
			end
			vQCP_RPArea:SetText(table.concat(vTTable,""))
		end
	end
------------------------------------------------------------------------
-- Nothing here, right?
------------------------------------------------------------------------
function DoNothing(f,t)
	print("Did I Forget Something Here on "..f.." ?", t)
	--I mean, it's obvious isn't it?
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

	local vQCP_Main = CreateFrame("Frame", "vQCP_Main", UIParent, BackdropTemplateMixin and "BackdropTemplate")
		vQCP_Main:SetBackdrop(BDropA)
		vQCP_Main:SetSize(325, 260)
		vQCP_Main:ClearAllPoints()
		vQCP_Main:SetPoint("CENTER", UIParent)
		vQCP_Main:EnableMouse(true)
		vQCP_Main:SetMovable(true)
		vQCP_Main:RegisterForDrag("LeftButton")
		vQCP_Main:SetScript("OnDragStart", function() vQCP_Main:StartMoving() end)
		vQCP_Main:SetScript("OnDragStop", function() vQCP_Main:StopMovingOrSizing() end)
		vQCP_Main:SetClampedToScreen(true)
		vQCP_Main:Hide()

	local vQCP_Title = CreateFrame("Frame", "vQCP_Title", vQCP_Main, BackdropTemplateMixin and "BackdropTemplate")
		vQCP_Title:SetBackdrop(BDropA)
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

	DRList = { "Classic", "Burning Crusade", "Wrath of Lich King", "Cataclysm", "Mists of Pandaria", "Warlords of Draenor", "Legion", "Battle for Azeroth", "Shadowlands" }
	DRHeight = -90
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

	local vQCP_RightPane = CreateFrame("Frame", "vQCP_RightPane", vQCP_Main, BackdropTemplateMixin and "BackdropTemplate")
		vQCP_RightPane:SetBackdrop(BDropA)
		vQCP_RightPane:SetSize(vQCP_Main:GetWidth()-140, vQCP_Main:GetHeight()-56)
		vQCP_RightPane:ClearAllPoints()
		vQCP_RightPane:SetPoint("TOPRIGHT", vQCP_Main, -2, -53)
		
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
			vQCP_RPScr:SetScrollChild(vQCP_RPArea)
------------------------------------------------------------------------
-- Fire Up Events
------------------------------------------------------------------------
	local vQCP_OnUpdate = CreateFrame("Frame")
	vQCP_OnUpdate:RegisterEvent("ADDON_LOADED")
	vQCP_OnUpdate:SetScript("OnEvent", function(self, event, ...)
		if event == "ADDON_LOADED" then
			vQCP_OnUpdate:RegisterEvent("PLAYER_LOGIN")
		end
		if event == "PLAYER_LOGIN" then
			SLASH_QuickCPATT1 = '/qcp'
			SLASH_QuickCPATT2 = '/quickcp'
			SlashCmdList["QuickCPATT"] = function(arg)
				if IsAddOnLoaded("AllTheThings") then
					if vQCP_Main:IsVisible() then vQCP_Main:Hide() else vQCP_Main:Show() end
					_G["vQCP_Opt2"]:SetChecked(true)
				else
					DEFAULT_CHAT_FRAME:AddMessage("Error: Cannot Run This without `All The Things`")
				end
			end
			vQCP_OnUpdate:UnregisterEvent("ADDON_LOADED")
			vQCP_OnUpdate:UnregisterEvent("PLAYER_LOGIN")
		end
	end)