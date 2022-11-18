-- Credit `ALL THE THINGS` to Crieve/Dylan
-- This Addon will NOT save or write or anything to ATT, it only reads what's given.
local vQuickCP_AppTitle = "|CFFFFFF00"..strsub(GetAddOnMetadata("QuickCP", "Title"),2).."|r v"..GetAddOnMetadata("QuickCP", "Version")
local vQuickCP_AppNotes = GetAddOnMetadata("QuickCP", "Notes")
------------------------------------------------------------------------
-- User Modification If Needed
------------------------------------------------------------------------
local vQuickCP_ShowHide = false		-- Show (true)/Hide (false) All Times
local vQuickCP_DecDef = 2			-- Decimal Precision Default is 2
local vQuickCP_NbrOfATT = 18		-- ATT loves to change their Data/Rows
------------------------------------------------------------------------
-- Global Localizations
------------------------------------------------------------------------
local vQuickCP_Table = {}
local ATT_Keyword = { "Looking For Raid", "Normal", "Heroic", "Mythic", "10 Player", "25 Player", "10 Player (Heroic)", "25 Player (Heroic)", }
------------------------------------------------------------------------
-- Check Toggles and Select Function
------------------------------------------------------------------------
function vQuickCP_ToggleSwitch(arg1,arg2)
	if arg1 == 1 then -- Percent/Remaining
		for i = 1, 2 do _G["vQuickCP_Number"..i]:SetChecked(false) end
		_G["vQuickCP_Number"..arg2]:SetChecked(true)
	end

	if arg1 == 2 then -- Main/Sub or Main/Sub/Diff
		for i = 1, 2 do _G["vQuickCP_DRSubList"..i]:SetChecked(false) end
		_G["vQuickCP_DRSubList"..arg2]:SetChecked(true)
	end

	if arg1 == 3 then -- Expansion Selections
		for i = 1, 10 do _G["vQuickCP_DRList"..i]:SetChecked(false) end
		_G["vQuickCP_DRList"..arg2]:SetChecked(true)
	end
	
	if ( vQuickCP_DRList1:GetChecked() ) then
		vQuickCP_ATTDRAllExpansion()
	else
		for i = 1, 10 do
			if _G["vQuickCP_DRList"..i]:GetChecked() then
				vQuickCP_ATTDRSpecific(i-1)
				break
			end
		end
	end
end
------------------------------------------------------------------------
-- Pulling Data from ATT
------------------------------------------------------------------------
-- Pull Specific ATT: Main List or Expansion Dungeon/Raid List
------------------------------------------------------------------------
	function vQuickCP_ATTList(arg)
		for i = 1, 10 do _G["vQuickCP_DRList"..i]:SetChecked(false) end
		
		vQuickCP_ResultArea:SetText("")
		wipe(vQuickCP_Table)
		local vQuickCP_AData = { AllTheThings.GetDataCache() }
		local vQuickCP_SData = ""
		if arg == 1 then vQuickCP_SData = vQuickCP_AData[1]["g"] end
		if arg == 2 then vQuickCP_SData = vQuickCP_AData[1]["g"][1]["g"] end
		
		for a = 1, #vQuickCP_SData do
			if ( a > tonumber(vQuickCP_NbrOfATT) and arg == 1 ) then break end
			if ( vQuickCP_SData[a]["progress"] ~= 0 or vQuickCP_SData[a]["total"] ~= 0 ) then
				tinsert(vQuickCP_Table,
					( a > 1 and "\n" or "" )..
					(
						vQuickCP_LabelHeader:GetChecked() and
						vQuickCP_SData[a]["text"]:gsub("%[([^]]*)%]","%1",1):gsub("|cff"..("%w"):rep(6),""):gsub("|r","").."\t" or
						""
					)..
					(
						( vQuickCP_Number1:GetChecked() ) and
						( string.format("%."..tonumber(vQuickCP_DecDef).."f",(vQuickCP_SData[a]["progress"]/vQuickCP_SData[a]["total"])*100) ) or
						( (vQuickCP_SData[a]["total"]-vQuickCP_SData[a]["progress"]) )
					)..
					( a > #vQuickCP_SData and "\n" or "" )
				)
			end
		end
		vQuickCP_ResultArea:SetText(table.concat(vQuickCP_Table,""))
	end
------------------------------------------------------------------------
-- Pull Specific Dungeon & Raid
------------------------------------------------------------------------
	function vQuickCP_ATTDRSpecific(arg)
		vQuickCP_ResultArea:SetText("")
		wipe(vQuickCP_Table)
		local DRHdr, SubHdr, DiffHdr = "", "", ""
		local Progress, Total = 0, 0
		local ATTKW = false
		local vQuickCP_AData = { AllTheThings.GetDataCache() }
		local vQuickCP_HData = vQuickCP_AData[1]["g"][1]["g"][arg]
		local vQuickCP_SData = vQuickCP_AData[1]["g"][1]["g"][arg]["g"]

		DRHdr = vQuickCP_HData["text"]:gsub("%[([^]]*)%]","%1",1):gsub("|cff"..("%w"):rep(6),""):gsub("|r","")
		tinsert(vQuickCP_Table,
			( vQuickCP_LabelHeader:GetChecked() and "|cffFFA500"..DRHdr.."|r\t" or "" )..
			( vQuickCP_Number1:GetChecked() and
				( string.format("%."..tonumber(vQuickCP_DecDef).."f",(vQuickCP_HData["progress"]/vQuickCP_HData["total"])*100) ) or
				( (vQuickCP_HData["total"]-vQuickCP_HData["progress"]) )
			)..
			( arg == 1 and "" or "\n" )
		)
		for b = 1, #vQuickCP_SData do
			if ( vQuickCP_SData[b]["progress"] ~= 0 or vQuickCP_SData[b]["total"] ~= 0 ) then
				SubHdr = vQuickCP_SData[b]["text"]:gsub("%[([^]]*)%]","%1",1):gsub("|cff"..("%w"):rep(6),""):gsub("|r","")

				--Skip Legions/Common Dungeon Drop
				--if ( DRHdr == "Legion" and SubHdr == "Common Dungeon Drop" ) then break end

				-- print("=",b,SubHdr,DRHdr)
				if ( DRHdr == "Cataclysm" and ( b == 1 and SubHdr ~= "World Bosses" ) ) then
					--print("Yes, Match!")
					tinsert(vQuickCP_Table,
						( b > 1 and "\n" or "" )..
						( vQuickCP_LabelHeader:GetChecked() and "|cff4169e1World Bosses|r\t" or "" )..
						( vQuickCP_Number1:GetChecked() and "--" or "" )..
						( b > #vQuickCP_SData and "\n" or "" )
					)
				end
				tinsert(vQuickCP_Table,
					( b > 1 and "\n" or "" )..
					( vQuickCP_LabelHeader:GetChecked() and "|cff4169e1"..SubHdr.."|r\t" or "" )..
					( vQuickCP_Number1:GetChecked() and
						( string.format("%."..tonumber(vQuickCP_DecDef).."f",(vQuickCP_SData[b]["progress"]/vQuickCP_SData[b]["total"])*100) ) or
						( (vQuickCP_SData[b]["total"]-vQuickCP_SData[b]["progress"]) )
					)..
					( b > #vQuickCP_SData and "\n" or "" )
				)
				if ( vQuickCP_DRSubList2:GetChecked() ) then
					local vQuickCP_DData = vQuickCP_AData[1]["g"][1]["g"][arg]["g"][b]["g"]
					Progress, Total = 0, 0
					for c = 1, #vQuickCP_DData do
						if ( vQuickCP_DData[c]["progress"] ~= 0 or vQuickCP_DData[c]["total"] ~= 0 ) then
							if vQuickCP_DData[c]["text"] == nil then
								vQuickCP_ResultArea:SetText("Please Wait!\n\nAllTheThings isn't responding on requested information...")
								C_Timer.After(2, function() vQuickCP_ATTDRSpecific(arg) end)
								return false
							end
							DiffHdr = vQuickCP_DData[c]["text"]:gsub("%[([^]]*)%]","%1",1):gsub("|cff"..("%w"):rep(6),""):gsub("|r","")
							-- print(#vQuickCP_DData,SubHdr,DiffHdr)
							for _, v in ipairs(ATT_Keyword) do
								if v == DiffHdr then
									ATTKW = true
									break
								end
							end
							if ( ATTKW ) then
								tinsert(vQuickCP_Table,
									( c > 0 and "\n" or "" )..
									( vQuickCP_LabelHeader:GetChecked() and DiffHdr.."\t" or "" )..
									( vQuickCP_Number1:GetChecked() and
										( string.format("%."..tonumber(vQuickCP_DecDef).."f",(vQuickCP_DData[c]["progress"]/vQuickCP_DData[c]["total"])*100) ) or
										( (vQuickCP_DData[c]["total"]-vQuickCP_DData[c]["progress"]) )
									)
								)
							end
						end
						ATTKW = false
					end
				end
			end
		end
		vQuickCP_ResultArea:SetText(table.concat(vQuickCP_Table,""))
	end
------------------------------------------------------------------------
-- All Expansion
------------------------------------------------------------------------
	function vQuickCP_ATTDRAllExpansion()
		vQuickCP_ResultArea:SetText("")
		wipe(vQuickCP_Table)
		local DRHdr, SubHdr, DiffHdr = "", "", ""
		local Progress, Total = 0, 0
		local ATTKW = false
		local vQuickCP_AData = { AllTheThings.GetDataCache() }
		local vQuickCP_MData = vQuickCP_AData[1]["g"][1]["g"]

		tinsert(vQuickCP_Table,"\n")
		
		for a = 1, #vQuickCP_MData do
			local vQuickCP_HData = vQuickCP_AData[1]["g"][1]["g"][a]
			local vQuickCP_SData = vQuickCP_AData[1]["g"][1]["g"][a]["g"]
			
			DRHdr = vQuickCP_HData["text"]:gsub("%[([^]]*)%]","%1",1):gsub("|cff"..("%w"):rep(6),""):gsub("|r","")
			tinsert(vQuickCP_Table,
				( vQuickCP_LabelHeader:GetChecked() and "|cffFFA500"..DRHdr.."|r\t" or "" )..
				( vQuickCP_Number1:GetChecked() and
					( string.format("%."..tonumber(vQuickCP_DecDef).."f",(vQuickCP_HData["progress"]/vQuickCP_HData["total"])*100) ) or
					( (vQuickCP_HData["total"]-vQuickCP_HData["progress"]) )
				)..
				( a == 1 and "" or "\n" )
			)
			for b = 1, #vQuickCP_SData do
				if ( vQuickCP_SData[b]["progress"] ~= 0 or vQuickCP_SData[b]["total"] ~= 0 ) then
					SubHdr = vQuickCP_SData[b]["text"]:gsub("%[([^]]*)%]","%1",1):gsub("|cff"..("%w"):rep(6),""):gsub("|r","")
					
					--Skip Legions/Common Dungeon Drop
					--if ( DRHdr == "Legion" and SubHdr == "Common Dungeon Drop" ) then break end

					-- print("=",b,SubHdr,DRHdr)
					if ( DRHdr == "Cataclysm" and ( b == 1 and SubHdr ~= "World Bosses" ) ) then
						--print("Yes, Match!")
						tinsert(vQuickCP_Table,
							( b > 1 and "\n" or "" )..
							( vQuickCP_LabelHeader:GetChecked() and "|cff4169e1World Bosses|r\t" or "" )..
							( vQuickCP_Number1:GetChecked() and "--" or "" )..
							( b > #vQuickCP_SData and "\n" or "" )
						)
					end
					tinsert(vQuickCP_Table,
						( b > 1 and "\n" or "" )..
						( vQuickCP_LabelHeader:GetChecked() and "|cff4169e1"..SubHdr.."|r\t" or "" )..
						( vQuickCP_Number1:GetChecked() and
							( string.format("%."..tonumber(vQuickCP_DecDef).."f",(vQuickCP_SData[b]["progress"]/vQuickCP_SData[b]["total"])*100) ) or
							( (vQuickCP_SData[b]["total"]-vQuickCP_SData[b]["progress"]) )
						)..
						( b > #vQuickCP_SData and "\n" or "" )
					)
					if ( vQuickCP_DRSubList2:GetChecked() ) then
						local vQuickCP_DData = vQuickCP_AData[1]["g"][1]["g"][a]["g"][b]["g"]
						Progress, Total = 0, 0
						for c = 1, #vQuickCP_DData do
							if ( vQuickCP_DData[c]["progress"] ~= 0 or vQuickCP_DData[c]["total"] ~= 0 ) then
								if vQuickCP_DData[c]["text"] == nil then
									vQuickCP_ResultArea:SetText("Please Wait!\n\nAllTheThings isn't responding on requested information...")
									C_Timer.After(2, function() vQuickCP_ATTDRAllExpansion() end)
									return false
								end
								DiffHdr = vQuickCP_DData[c]["text"]:gsub("%[([^]]*)%]","%1",1):gsub("|cff"..("%w"):rep(6),""):gsub("|r","")
								-- print(#vQuickCP_DData,SubHdr,DiffHdr)
								for _, v in ipairs(ATT_Keyword) do
									if v == DiffHdr then
										ATTKW = true
										break
									end
								end
								if ( ATTKW ) then
									tinsert(vQuickCP_Table,
										( c > 0 and "\n" or "" )..
										( vQuickCP_LabelHeader:GetChecked() and DiffHdr.."\t" or "" )..
										( vQuickCP_Number1:GetChecked() and
											( string.format("%."..tonumber(vQuickCP_DecDef).."f",(vQuickCP_DData[c]["progress"]/vQuickCP_DData[c]["total"])*100) ) or
											( (vQuickCP_DData[c]["total"]-vQuickCP_DData[c]["progress"]) )
										)
									)
								end
							end
							ATTKW = false
						end
					end
				end
			end
			tinsert(vQuickCP_Table,( a == #vQuickCP_MData and "" or "\n" ))
		end
		vQuickCP_ResultArea:SetText(table.concat(vQuickCP_Table,""))
	end
------------------------------------------------------------------------
-- Game ToolTip Simplified
------------------------------------------------------------------------
function vQuickCP_ToolTipsOnly(vArg)
	GameTooltip:ClearLines()
	GameTooltip:Hide()
	if vArg == 0 then return end
	
	if vQuickCP_Main:GetCenter() > (UIParent:GetWidth() / 2) then
		GameTooltip:SetOwner(vArg, "ANCHOR_LEFT")
	else
		GameTooltip:SetOwner(vArg, "ANCHOR_RIGHT")
	end
	
	if vArg == vQuickCP_MiniMap then vArg = vQuickCP_AppTitle.."\n\n"..vQuickCP_AppNotes end
	GameTooltip:AddLine(vArg,1,1,1,1)
	GameTooltip:Show()
end
------------------------------------------------------------------------
-- Mini Map Button
------------------------------------------------------------------------
	local vQuickCP_MiniMap = CreateFrame("Button", "vQuickCP_MiniMap", Minimap)
		vQuickCP_MiniMap:SetSize(40, 40)
		vQuickCP_MiniMap:SetNormalTexture("Interface\\Store\\category-icon-services")
		vQuickCP_MiniMap:ClearAllPoints()
		vQuickCP_MiniMap:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", -25, 5)
		vQuickCP_MiniMap:SetMovable(false)
		vQuickCP_MiniMap:SetScript("OnClick", function()
			if vQuickCP_Main:IsVisible() then vQuickCP_Main:Hide() else vQuickCP_Main:Show() end
		end)
		vQuickCP_MiniMap:SetScript("OnEnter", function() vQuickCP_ToolTipsOnly(vQuickCP_MiniMap) end)
		vQuickCP_MiniMap:SetScript("OnLeave", function() vQuickCP_ToolTipsOnly(0) end)
------------------------------------------------------------------------
-- Framing
------------------------------------------------------------------------
	local BDropA = {
		edgeFile = "Interface\\ToolTips\\UI-Tooltip-Border",
		bgFile = "Interface\\BlackMarket\\BlackMarketBackground-Tile",
		tileEdge = true,
		tileSize = 10,
		edgeSize = 14,
		insets = { left = 3, right = 3, top = 3, bottom = 3 }
	}
	local BDropB = {
		edgeFile = "Interface\\ToolTips\\UI-Tooltip-Border",
		tileEdge = true,
		tileSize = 10,
		edgeSize = 14,
		insets = { left = 3, right = 3, top = 3, bottom = 3 }
	}
------------------------------------------------------------------------
-- Rest of the Frames
------------------------------------------------------------------------
	-- Main Frame
	local vQuickCP_Main = CreateFrame("Frame", "vQuickCP_Main", UIParent, BackdropTemplateMixin and "BackdropTemplate")
		vQuickCP_Main:SetBackdrop(BDropA)
		vQuickCP_Main:SetSize(358, 335)
		vQuickCP_Main:ClearAllPoints()
		vQuickCP_Main:SetPoint("CENTER", UIParent)
		vQuickCP_Main:EnableMouse(true)
		vQuickCP_Main:SetMovable(true)
		vQuickCP_Main:RegisterForDrag("LeftButton")
		vQuickCP_Main:SetScript("OnDragStart", function() vQuickCP_Main:StartMoving() end)
		vQuickCP_Main:SetScript("OnDragStop", function() vQuickCP_Main:StopMovingOrSizing() end)
		vQuickCP_Main:SetClampedToScreen(true)
		if not vQuickCP_ShowHide then vQuickCP_Main:Hide() end
	--Title
	local vQuickCP_Title = vQuickCP_Main:CreateFontString(nil, "ARTWORK", "GameFontNormalLeftYellow")
		vQuickCP_Title:SetPoint("TOP", vQuickCP_Main, 0, -8)
		vQuickCP_Title:SetText("Quick Copy from ATT`s D&R Data")
	-- Close Button
	local vQuickCP_CloseButton = CreateFrame("Button", "vQuickCP_CloseButton", vQuickCP_Main, "UIPanelCloseButton")
		vQuickCP_CloseButton:SetSize(22, 22)
		vQuickCP_CloseButton:SetPoint("TOPRIGHT", vQuickCP_Main, -3, -3)
		vQuickCP_CloseButton:SetScript("OnClick", function() vQuickCP_Main:Hide() end)
	
	--Seperator
	local vQuickCP_Line1 = vQuickCP_Main:CreateTexture("vQuickCP_Line1")
		vQuickCP_Line1:SetSize(vQuickCP_Main:GetWidth()-16, 2)
		vQuickCP_Line1:SetTexture("Interface\\BUTTONS\\WHITE8X8")
		vQuickCP_Line1:SetColorTexture(.8, .8, .8, .2)
		vQuickCP_Line1:SetPoint("TOPLEFT",vQuickCP_Main, 8, -25)

	-- Include Header/Label/Title
	local vQuickCP_LabelHeader = CreateFrame("CheckButton", "vQuickCP_LabelHeader", vQuickCP_Main, "InterfaceOptionsCheckButtonTemplate")
		vQuickCP_LabelHeader:SetPoint("TOPLEFT", vQuickCP_Main, 5, -27)
		vQuickCP_LabelHeader:SetChecked(false)
		vQuickCP_LabelHeader:SetScript("OnClick", function() vQuickCP_ToggleSwitch(0,0) end)
			vQuickCP_Hdr = vQuickCP_LabelHeader:CreateFontString(nil, "ARTWORK", "GameFontWhiteSmall")
			vQuickCP_Hdr:SetPoint("LEFT", vQuickCP_LabelHeader, 25, 0)
			vQuickCP_Hdr:SetText("Display Label?")
	-- Use Percent?
	local vQuickCP_Number1 = CreateFrame("CheckButton", "vQuickCP_Number1", vQuickCP_Main, "InterfaceOptionsCheckButtonTemplate")
		vQuickCP_Number1:SetPoint("TOPLEFT", vQuickCP_Main, 120, -27)
		vQuickCP_Number1:SetChecked(true)
		vQuickCP_Number1:SetScript("OnClick", function() vQuickCP_ToggleSwitch(1,1) end)
			vQuickCP_Hdr = vQuickCP_Number1:CreateFontString(nil, "ARTWORK", "GameFontWhiteSmall")
			vQuickCP_Hdr:SetPoint("LEFT", vQuickCP_Number1, 25, 0)
			vQuickCP_Hdr:SetJustifyH("LEFT")
			vQuickCP_Hdr:SetText("Percent %")
	-- Use Remaining?
	local vQuickCP_Number2 = CreateFrame("CheckButton", "vQuickCP_Number2", vQuickCP_Main, "InterfaceOptionsCheckButtonTemplate")
		vQuickCP_Number2:SetPoint("TOPLEFT", vQuickCP_Main, 235, -27)
		vQuickCP_Number2:SetChecked(false)
		vQuickCP_Number2:SetScript("OnClick", function() vQuickCP_ToggleSwitch(1,2) end)
			vQuickCP_Hdr = vQuickCP_Number2:CreateFontString(nil, "ARTWORK", "GameFontWhiteSmall")
			vQuickCP_Hdr:SetPoint("LEFT", vQuickCP_Number2, 25, 0)
			vQuickCP_Hdr:SetJustifyH("LEFT")
			vQuickCP_Hdr:SetText("Remain ##")

	-- ATT Main List % Only
	local vQuickCP_MainList = CreateFrame("Button", "vQuickCP_MainList", vQuickCP_Main, "UIPanelButtonTemplate")
		vQuickCP_MainList:SetSize(150,20)
		vQuickCP_MainList:SetPoint("TOPLEFT", vQuickCP_Main, 20, -50)
		vQuickCP_MainList:SetText("ATT Main List %")
		vQuickCP_MainList:SetScript("OnClick", function() vQuickCP_ATTList(1) end)
	-- D&R Main List Only
	local vQuickCP_DRMainList = CreateFrame("Button", "vQuickCP_DRMainList", vQuickCP_Main, "UIPanelButtonTemplate")
		vQuickCP_DRMainList:SetSize(150,20)
		vQuickCP_DRMainList:SetPoint("TOPLEFT", vQuickCP_Main, 185, -50)
		vQuickCP_DRMainList:SetText("ATT D&R Main List %")
		vQuickCP_DRMainList:SetScript("OnClick", function() vQuickCP_ATTList(2) end)
		
	-- Seperator
	local vQuickCP_Line2 = vQuickCP_Main:CreateTexture("vQuickCP_Line2")
		vQuickCP_Line2:SetSize(138, 2)
		vQuickCP_Line2:SetTexture("Interface\\BUTTONS\\WHITE8X8")
		vQuickCP_Line2:SetColorTexture(.8, .8, .8, .2)
		vQuickCP_Line2:SetPoint("TOPLEFT",vQuickCP_Main, 8, -73)
		
	-- Pick To Display
	local vQuickCP_PDis = vQuickCP_Main:CreateFontString(nil, "ARTWORK", "GameFontWhiteSmall")
		vQuickCP_PDis:SetPoint("TOPLEFT", vQuickCP_Main, 10, -80)
		vQuickCP_PDis:SetText("|cffFFFF00Pick To Display|r")
	-- D&R Main & Sub List
	local vQuickCP_DRSubList1 = CreateFrame("CheckButton", "vQuickCP_DRSubList1", vQuickCP_Main, "InterfaceOptionsCheckButtonTemplate")
		vQuickCP_DRSubList1:SetPoint("TOPLEFT", vQuickCP_Main, 5, -90)
		vQuickCP_DRSubList1:SetChecked(false)
		vQuickCP_DRSubList1:SetScript("OnClick", function() vQuickCP_ToggleSwitch(2,1) end)
			vQuickCP_Hdr = vQuickCP_DRSubList1:CreateFontString(nil, "ARTWORK", "GameFontWhiteSmall")
			vQuickCP_Hdr:SetPoint("LEFT", vQuickCP_DRSubList1, 25, 0)
			vQuickCP_Hdr:SetJustifyH("LEFT")
			vQuickCP_Hdr:SetText("Main & Sub")
	-- D&R Main, Sub & Difficulty List
	local vQuickCP_DRSubList2 = CreateFrame("CheckButton", "vQuickCP_DRSubList2", vQuickCP_Main, "InterfaceOptionsCheckButtonTemplate")
		vQuickCP_DRSubList2:SetPoint("TOPLEFT", vQuickCP_Main, 5, -108)
		vQuickCP_DRSubList2:SetChecked(true)
		vQuickCP_DRSubList2:SetScript("OnClick", function() vQuickCP_ToggleSwitch(2,2) end)
			vQuickCP_Hdr = vQuickCP_DRSubList2:CreateFontString(nil, "ARTWORK", "GameFontWhiteSmall")
			vQuickCP_Hdr:SetPoint("LEFT", vQuickCP_DRSubList2, 25, 0)
			vQuickCP_Hdr:SetJustifyH("LEFT")
			vQuickCP_Hdr:SetText("Main, Sub & Diff")

	-- Pick An Expansion
	local vQuickCP_PExp = vQuickCP_Main:CreateFontString(nil, "ARTWORK", "GameFontWhiteSmall")
		vQuickCP_PExp:SetPoint("TOPLEFT", vQuickCP_Main, 10, -135)
		vQuickCP_PExp:SetText("|cffFFFF00Pick An Expansion|r")
	-- Create A List using `Array`
	local DRExp = { "|cffFFA500All Expansions|r", "Classic", "Burning Crusade", "Wrath of Lich King", "Cataclysm", "Mists of Pandaria", "Warlords of Draenor", "Legion", "Battle for Azeroth", "Shadowlands", }
		DRHeight = -145
		for i = 1, #DRExp do
			local vQuickCP_DRList = CreateFrame("CheckButton", "vQuickCP_DRList"..i, vQuickCP_Main, "InterfaceOptionsCheckButtonTemplate")
				vQuickCP_DRList:SetPoint("TOPLEFT", vQuickCP_Main, 5, DRHeight)
				vQuickCP_DRList:SetChecked(false)
				vQuickCP_DRList:SetScript("OnClick", function() vQuickCP_ToggleSwitch(3,i) end)
					vQuickCP_Hdr = vQuickCP_DRList:CreateFontString(nil, "ARTWORK", "GameFontWhiteSmall")
					vQuickCP_Hdr:SetPoint("LEFT", vQuickCP_DRList, 25, 0)
					vQuickCP_Hdr:SetJustifyH("LEFT")
					vQuickCP_Hdr:SetText(DRExp[i])
			DRHeight = DRHeight - 18
		end
	
	--Result Box
	local vQuickCP_Result = CreateFrame("Frame", "vQuickCP_Result", vQuickCP_Main, BackdropTemplateMixin and "BackdropTemplate")
		vQuickCP_Result:SetBackdrop(BDropB)
		vQuickCP_Result:SetSize(vQuickCP_Main:GetWidth()-139, vQuickCP_Main:GetHeight()-74)
		vQuickCP_Result:ClearAllPoints()
		vQuickCP_Result:SetPoint("TOPRIGHT", vQuickCP_Main, -2, -72)
		local vQuickCP_ResultScroll = CreateFrame("ScrollFrame", "vQuickCP_ResultScroll", vQuickCP_Result, "UIPanelScrollFrameTemplate")
			vQuickCP_ResultScroll:SetPoint("TOPLEFT", vQuickCP_Result, 7, -7)
			vQuickCP_ResultScroll:SetWidth(vQuickCP_Result:GetWidth()-35)
			vQuickCP_ResultScroll:SetHeight(vQuickCP_Result:GetHeight()-12)
				vQuickCP_ResultArea = CreateFrame("EditBox", "vQuickCP_ResultArea", vQuickCP_ResultScroll)
				vQuickCP_ResultArea:SetWidth(vQuickCP_ResultScroll:GetWidth())
				--vQuickCP_ResultArea:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE,MONOCHROME")
				vQuickCP_ResultArea:SetFontObject(GameFontNormalSmall)
				vQuickCP_ResultArea:SetAutoFocus(false)
				vQuickCP_ResultArea:SetMultiLine(true)
				vQuickCP_ResultArea:EnableMouse(true)
				vQuickCP_ResultArea:SetScript("OnEditFocusGained", function() vQuickCP_ResultArea:HighlightText() end)
			vQuickCP_ResultScroll:SetScrollChild(vQuickCP_ResultArea)
------------------------------------------------------------------------
-- Fire Up Events
------------------------------------------------------------------------
	local vQuickCP_OnUpdate = CreateFrame("Frame")
		vQuickCP_OnUpdate:RegisterEvent("ADDON_LOADED")
		vQuickCP_OnUpdate:SetScript("OnEvent", function(self, event, ...)
		if event == "ADDON_LOADED" then
			vQuickCP_OnUpdate:RegisterEvent("PLAYER_LOGIN")
			vQuickCP_OnUpdate:UnregisterEvent("ADDON_LOADED")
		end
		if event == "PLAYER_LOGIN" then
			SLASH_vQuickCP1 = '/vqcp'
			
			SlashCmdList["vQuickCP"] = function(arg)
				if IsAddOnLoaded("AllTheThings") then
					if vQuickCP_Main:IsVisible() then vQuickCP_Main:Hide() else vQuickCP_Main:Show() end
				else
					DEFAULT_CHAT_FRAME:AddMessage("Error: Cannot Run This without `All The Things`")
				end
			end
			vQuickCP_OnUpdate:UnregisterEvent("PLAYER_LOGIN")
		end
	end)