-- Credit `ALL THE THINGS` to Crieve/Dylan
-- This Addon will NOT save or write or anything to ATT, it only reads what's given.
local vCP_AppTitle = "|CFFFFFF00"..strsub(GetAddOnMetadata("QuickCPATT", "Title"),2).."|r v"..GetAddOnMetadata("QuickCPATT", "Version")
local vCP_AppNotes = GetAddOnMetadata("QuickCPATT", "Notes")
------------------------------------------------------------------------
-- User Modification If Needed
------------------------------------------------------------------------
local v_ShowHide = false			-- Show (true)/Hide (false) All Times
local v_PrecDec = 2				-- Decimal Precision Default is 2
local v_NbrOfLines = 18			-- ATT loves to change their Data/Rows
--local v_NbrOfXPac = 11		-- Number of Expansions (Including All)
------------------------------------------------------------------------
-- Global Localizations
------------------------------------------------------------------------
local _TData = {}
local ATTMainList = {
	"Dungeons & Raids",
	"Outdoor Zones",
	"World Drop",
	"Group Finder",
	"Achievements", -- Now a Dynamic Listing (Marked in Orange)
	"Expansion Features",
	"Holiday",
	"World Event",
	"Promotion",
	"Pet Battles",
	"PvP",
	"Crafted Item",
	"Professions",
	"Secrets",
	"Character",
	"In-Game Shop",
	"Trading Post",
	"Black Market Auction House",
	-- "Factions", -- Removed From ATT 12/13/2023
}
local ATTDRList = {
	"All Expansion",
	"Classic",
	"Burning Crusade",
	"Wrath of the Lich King",
	"Cataclysm",
	"Mists of Pandaria",
	"Warlords of Draenor",
	"Legion",
	"Battle for Azeroth",
	"Shadowlands",
	"Dragonflight",
}
local ATT_Keyword = {
	"Memory of Scholomance",
	"Tier 3 Sets",
	"Looking For Raid",
	"Looking For Raid / Normal / Heroic",
	"Looking For Raid / Normal / Heroic / Mythic",
	"Normal",
	"Heroic",
	"Mythic",
	"Normal / Heroic",
	"Normal / Heroic / Mythic",
	"Heroic / Mythic",
	"10 Player",
	"10 Player (Heroic)",
	"25 Player",
	"25 Player (Heroic)",
}
------------------------------------------------------------------------
-- Check Toggles and Select Function
------------------------------------------------------------------------
function vCP_ToggleSwitch(arg1,arg2)
	if arg1 == 0 then -- Redo List if XPac is Selected?
		for i = 1, #ATTDRList do
			if _G["vCP_DRList"..i]:GetChecked() then
				if i == 1 then vCP_ATTAllXPac() else vCP_ATTSpecXPac(i-1) end
				break
			end
		end
	end
	if arg1 == 1 then -- Percent/Remaining
		for i = 1, 2 do _G["vCP_Number"..i]:SetChecked(false) end
		_G["vCP_Number"..arg2]:SetChecked(true)
	end
	if arg1 == 2 then -- Main/Sub or Main/Sub/Diff
		for i = 1, 2 do _G["vCP_DRSubList"..i]:SetChecked(false) end
		_G["vCP_DRSubList"..arg2]:SetChecked(true)
	end
	if arg1 == 3 then
		-- Expansion Selections
		for i = 1, #ATTDRList do _G["vCP_DRList"..i]:SetChecked(false) end
		_G["vCP_DRList"..arg2]:SetChecked(true)
		if vCP_DRList1:GetChecked() then
			vCP_ATTAllXPac()
		else
			for i = 1, #ATTDRList do
				if _G["vCP_DRList"..i]:GetChecked() then
					vCP_ATTSpecXPac(i-1)
					break
				end
			end
		end
	end
end
------------------------------------------------------------------------
-- Pulling Data from ATT
------------------------------------------------------------------------
-- Pull Specific ATT: Main List or Expansion Dungeon/Raid List
------------------------------------------------------------------------
	function vCP_ATTList(arg)
		for i = 1, #ATTDRList do _G["vCP_DRList"..i]:SetChecked(false) end
		
		vCP_ResultArea:SetText("")
		wipe(_TData)
		local _AData = { AllTheThings.GetDataCache() }
		local _SData = ""
		
		if arg == 1 then _SData = _AData[1]["g"] end
		if arg == 2 then _SData = _AData[1]["g"][1]["g"] end
		
		for a = 1, #_SData do
			if ( a > tonumber(v_NbrOfLines) and arg == 1 ) then break end
			
			if ( _SData[a]["progress"] == 0 or _SData[a]["total"] == 0 ) then
				tinsert(_TData,
					( a > 1 and "\n" or "" )..
					( vCP_LblHdr:GetChecked() and ( arg == 1 and ATTMainList[a] or ATTDRList[a] ).."\t" or "" )..
					( "N/A" )..
					( a > #_SData and "\n" or "" )
				)
			end
			if ( _SData[a]["progress"] ~= 0 or _SData[a]["total"] ~= 0 ) then
				tinsert(_TData,
					( a > 1 and "\n" or "" )..
					(
						vCP_LblHdr:GetChecked() and
						_SData[a]["text"]:gsub("%[([^]]*)%]","%1",1):gsub("|cff"..("%w"):rep(6),""):gsub("|r","").."\t" or
						""
					)..
					(
						( vCP_Number1:GetChecked() ) and
						( string.format("%."..tonumber(v_PrecDec).."f",(_SData[a]["progress"]/_SData[a]["total"])*100) ) or
						( (_SData[a]["total"]-_SData[a]["progress"]) )
					)..
					( a > #_SData and "\n" or "" )
				)
			end
		end
		vCP_ResultArea:SetText(table.concat(_TData,""))
	end
------------------------------------------------------------------------
-- Pull ATT: Main List AND Expansion Dungeon/Raid List
------------------------------------------------------------------------
	function vCP_ATTMDRList()
		for i = 1, #ATTDRList do _G["vCP_DRList"..i]:SetChecked(false) end
		
		vCP_ResultArea:SetText("")
		wipe(_TData)
		local _AData = { AllTheThings.GetDataCache() }
		local _SData = _AData[1]["g"]

		tinsert(_TData,_AData[1]["total"]-_AData[1]["progress"].."\n")
		for a = 1, #_SData do
			if ( a > tonumber(v_NbrOfLines) ) then break end
			if ( _SData[a]["progress"] == 0 or _SData[a]["total"] == 0 ) then
				tinsert(_TData,
					( a > 1 and "\n" or "" )..
					( vCP_LblHdr:GetChecked() and ATTMainList[a].."\t" or "" )..
					( "N/A" )..
					( a > #_SData and "\n" or "" )
				)
			end
			if ( _SData[a]["progress"] ~= 0 or _SData[a]["total"] ~= 0 ) then
				tinsert(_TData,
					( a > 1 and "\n" or "" )..
					(
						vCP_LblHdr:GetChecked() and
						_SData[a]["text"]:gsub("%[([^]]*)%]","%1",1):gsub("|cff"..("%w"):rep(6),""):gsub("|r","").."\t" or
						""
					)..
					(
						( vCP_Number1:GetChecked() ) and
						( string.format("%."..tonumber(v_PrecDec).."f",(_SData[a]["progress"]/_SData[a]["total"])*100) ) or
						( (_SData[a]["total"]-_SData[a]["progress"]) )
					)..
					( a > #_SData and "\n" or "" )
				)
			end
		end
		tinsert(_TData,"\n\n")
		_SData = _AData[1]["g"][1]["g"]
		for a = 1, #_SData do
			if ( a > tonumber(v_NbrOfLines) ) then break end
			if ( _SData[a]["progress"] == 0 or _SData[a]["total"] == 0 ) then
				tinsert(_TData,
					( a > 1 and "\n" or "" )..
					( vCP_LblHdr:GetChecked() and ATTDRList[a].."\t" or "" )..
					( "N/A" )..
					( a > #_SData and "\n" or "" )
				)
			end
			if ( _SData[a]["progress"] ~= 0 or _SData[a]["total"] ~= 0 ) then
				tinsert(_TData,
					( a > 1 and "\n" or "" )..
					(
						vCP_LblHdr:GetChecked() and
						_SData[a]["text"]:gsub("%[([^]]*)%]","%1",1):gsub("|cff"..("%w"):rep(6),""):gsub("|r","").."\t" or
						""
					)..
					(
						( vCP_Number1:GetChecked() ) and
						( string.format("%."..tonumber(v_PrecDec).."f",(_SData[a]["progress"]/_SData[a]["total"])*100) ) or
						( (_SData[a]["total"]-_SData[a]["progress"]) )
					)..
					( a > #_SData and "\n" or "" )
				)
			end
		end
		vCP_ResultArea:SetText(table.concat(_TData,""))
	end
------------------------------------------------------------------------
-- Pull Specific Dungeon & Raid
------------------------------------------------------------------------
function vCP_ATTSpecXPac(arg)
	vCP_ResultArea:SetText("")
	wipe(_TData)
	local _MDR_H, _SDR_H, _DDR_H, Progress, Total, ATTKW = "", "", "", 0, 0, false
	local _AData = { AllTheThings.GetDataCache() }
	local _MData = _AData[1]["g"][1]["g"][arg]

	-- Expansion Header
	_MDR_H = _MData["text"]:gsub("%[([^]]*)%]","%1",1):gsub("|cff"..("%w"):rep(6),""):gsub("|r","")
	tinsert(_TData,
		( vCP_LblHdr:GetChecked() and "|cff03A9F4".._MDR_H.."|r\t" or "" )..
		( vCP_Number1:GetChecked() and
			( string.format("%."..tonumber(v_PrecDec).."f",(_MData["progress"]/_MData["total"])*100) ) or
			( (_MData["total"]-_MData["progress"]) )
		)..
		( arg == 1 and "" or "\n" )
	)
	
	local _SData = _MData["g"]
	for b = 1, #_SData do
		if ( _SData[b]["progress"] ~= 0 or _SData[b]["total"] ~= 0 ) then
			_SDR_H = _SData[b]["text"]:gsub("%[([^]]*)%]","%1",1):gsub("|cff"..("%w"):rep(6),""):gsub("|r","")

			--Exceptions
			if ( _MDR_H == "Legion" and _SDR_H == "Common Dungeon Drop" ) then --Do Nothing
			else
				tinsert(_TData,
					( b > 1 and "\n" or "" )..
					( vCP_LblHdr:GetChecked() and ("|cff"..( _SData[b]["isRaid"] and "FF5722" or "FFEB3B" ).._SDR_H.."|r\t") or "" )..
					( vCP_Number1:GetChecked() and
						( string.format("%."..tonumber(v_PrecDec).."f",(_SData[b]["progress"]/_SData[b]["total"])*100) ) or
						( (_SData[b]["total"]-_SData[b]["progress"]) )
					)..
					( b > #_SData and "\n" or "" )
				)
			end
			
			if ( vCP_DRSubList2:GetChecked() ) then
				local _DData = _AData[1]["g"][1]["g"][arg]["g"][b]["g"]
				Progress, Total = 0, 0
				for c = 1, #_DData do
					if ( _DData[c]["progress"] ~= 0 or _DData[c]["total"] ~= 0 ) then
						if _DData[c]["text"] == nil then
							vCP_ResultArea:SetText("Please Wait!\n\nAllTheThings is generating information...")
							C_Timer.After(.5, function() vCP_ATTSpecXPac(arg) end)
							return false
						end
							_DDR_H = _DData[c]["text"]:gsub("%[([^]]*)%]","%1",1):gsub("|cff"..("%w"):rep(6),""):gsub("|r","")
							for k = 1, #ATT_Keyword do
								if ATT_Keyword[k] == _DDR_H then
									ATTKW = true
									kc = k
									break
								end
							end
							_DDR_H = _DDR_H:gsub("Looking For Raid ","LFR ")
							--Exceptions
							if ( _MDR_H == "Legion" and _SDR_H == "The Emerald Nightmare" and _DDR_H == "LFR / Normal / Heroic / Mythic" ) then ATTKW = false end
							if ( _MDR_H == "Legion" and _SDR_H == "The Nighthold" and _DDR_H == "LFR / Normal / Heroic / Mythic" ) then ATTKW = false end
							if ( _MDR_H == "Legion" and _SDR_H == "Antorus, the Burning Throne" and _DDR_H == "LFR / Normal / Heroic / Mythic" ) then ATTKW = false end
							if ( _MDR_H == "Legion" and _SDR_H == "Neltharion's Lair" and _DDR_H == "Mythic+" ) then ATTKW = false end
							if ( _MDR_H == "Battle for Azeroth" and _SDR_H == "Ny'alotha, the Waking City" and _DDR_H == "LFR / Normal / Heroic / Mythic" ) then ATTKW = false end
							if ( _MDR_H == "Battle for Azeroth" and _SDR_H == "The Underrot" and _DDR_H == "Mythic+" ) then ATTKW = false end

						if ( ATTKW ) then
							tinsert(_TData,
								( c > 0 and "\n" or "" )..
								( vCP_LblHdr:GetChecked() and ( "|cffCFD8DC".._DDR_H.."|r\t" ) or "" )..
								( vCP_Number1:GetChecked() and
									( string.format("%."..tonumber(v_PrecDec).."f",(_DData[c]["progress"]/_DData[c]["total"])*100) ) or
									( (_DData[c]["total"]-_DData[c]["progress"]) )
								)
							)
						end
					end
					ATTKW = false
				end
			end
		end
	end
	vCP_ResultArea:SetText(table.concat(_TData,""))
end
------------------------------------------------------------------------
-- All Expansion
------------------------------------------------------------------------
function vCP_ATTAllXPac()
	vCP_ResultArea:SetText("")
	wipe(_TData)
	local _MDR_H, _SDR_H, _DDR_H, Progress, Total, ATTKW = "", "", "", 0, 0, false
	local _AData = { AllTheThings.GetDataCache() }
	local _MData = _AData[1]["g"][1]["g"]

	tinsert(_TData,_AData[1]["g"][1]["total"]-_AData[1]["g"][1]["progress"].."\n")
	
	-- Expansion Header
	for a = 1, #_MData do
		local _HData = _MData[a]
		_MDR_H = _HData["text"]:gsub("%[([^]]*)%]","%1",1):gsub("|cff"..("%w"):rep(6),""):gsub("|r","")
		tinsert(_TData,
			( vCP_LblHdr:GetChecked() and "|cff03A9F4".._MDR_H.."|r\t" or "" )..
			( vCP_Number1:GetChecked() and
				( string.format("%."..tonumber(v_PrecDec).."f",(_HData["progress"]/_HData["total"])*100) ) or
				( (_HData["total"]-_HData["progress"]) )
			)..
			( "\n" )
			--( a == 1 and "" or "\n" )
		)
		-- Achievements, World Boss, Raid, Dungeon Header
		local _SData = _MData[a]["g"]
		for b = 1, #_SData do
			if ( _SData[b]["progress"] ~= 0 or _SData[b]["total"] ~= 0 ) then
				_SDR_H = _SData[b]["text"]:gsub("%[([^]]*)%]","%1",1):gsub("|cff"..("%w"):rep(6),""):gsub("|r","")
				
				--Exceptions
				if ( _MDR_H == "Legion" and _SDR_H == "Common Dungeon Drop" ) then --Do Nothing
				else
					tinsert(_TData,
						( b > 1 and "\n" or "" )..
						( vCP_LblHdr:GetChecked() and ("|cff"..( _SData[b]["isRaid"] and "FF5722" or "FFEB3B" ).._SDR_H.."|r\t") or "" )..
						( vCP_Number1:GetChecked() and
							( string.format("%."..tonumber(v_PrecDec).."f",(_SData[b]["progress"]/_SData[b]["total"])*100) ) or
							( (_SData[b]["total"]-_SData[b]["progress"]) )
						)..
						( b > #_SData and "\n" or "" )
					)
				end
				-- Sub-Header of Normal, Heroic, Mythic, LFR, etc
				if ( vCP_DRSubList2:GetChecked() ) then
					local _DData = _MData[a]["g"][b]["g"]
					for c = 1, #_DData do
						if ( _DData[c]["progress"] ~= 0 or _DData[c]["total"] ~= 0 ) then
							if _DData[c]["text"] == nil then
								vCP_ResultArea:SetText("Please Wait!\n\nAllTheThings is generating information...")
								C_Timer.After(.5, function() vCP_ATTAllXPac() end)
								return false
							end
							_DDR_H = _DData[c]["text"]:gsub("%[([^]]*)%]","%1",1):gsub("|cff"..("%w"):rep(6),""):gsub("|r","")
							for k = 1, #ATT_Keyword do
								if ATT_Keyword[k] == _DDR_H then
									ATTKW = true
									kc = k
									break
								end
							end
							_DDR_H = _DDR_H:gsub("Looking For Raid ","LFR ")
							--Exceptions
							if ( _MDR_H == "Legion" and _SDR_H == "The Emerald Nightmare" and _DDR_H == "LFR / Normal / Heroic / Mythic" ) then ATTKW = false end
							if ( _MDR_H == "Legion" and _SDR_H == "The Nighthold" and _DDR_H == "LFR / Normal / Heroic / Mythic" ) then ATTKW = false end
							if ( _MDR_H == "Legion" and _SDR_H == "Antorus, the Burning Throne" and _DDR_H == "LFR / Normal / Heroic / Mythic" ) then ATTKW = false end
							if ( _MDR_H == "Legion" and _SDR_H == "Neltharion's Lair" and _DDR_H == "Mythic+" ) then ATTKW = false end
							if ( _MDR_H == "Battle for Azeroth" and _SDR_H == "Ny'alotha, the Waking City" and _DDR_H == "LFR / Normal / Heroic / Mythic" ) then ATTKW = false end
							if ( _MDR_H == "Battle for Azeroth" and _SDR_H == "The Underrot" and _DDR_H == "Mythic+" ) then ATTKW = false end
							
							if ( ATTKW ) then
								tinsert(_TData,
									( c > 0 and "\n" or "" )..
									( vCP_LblHdr:GetChecked() and ( "|cffCFD8DC".._DDR_H.."|r\t" ) or "" )..
									( vCP_Number1:GetChecked() and
										( string.format("%."..tonumber(v_PrecDec).."f",(_DData[c]["progress"]/_DData[c]["total"])*100) ) or
										( (_DData[c]["total"]-_DData[c]["progress"]) )
									)
								)
							end -- if ATTKW
							--if _MainDR_H == "Legion" then print(c,_MainDR_H,_SubDR_H,_DDR_H) end
						end -- _DData not 0
						ATTKW = false
					end -- for c _DData
				end -- vCP_DRSubList2 Checked
			end -- _SData Not 0
		end -- for B _SData
		tinsert(_TData,( a == #_MData and "" or "\n" ))
	end
	vCP_ResultArea:SetText(table.concat(_TData,""))
end
------------------------------------------------------------------------
-- Game ToolTip Simplified
------------------------------------------------------------------------
function vCP_ToolTipsOnly(vArg)
	GameTooltip:ClearLines()
	GameTooltip:Hide()
	if vArg == 0 then return end
	
	if vCP_Main:GetCenter() > (UIParent:GetWidth() / 2) then
		GameTooltip:SetOwner(vArg, "ANCHOR_LEFT")
	else
		GameTooltip:SetOwner(vArg, "ANCHOR_RIGHT")
	end
	
	if vArg == vCP_MiniMap then vArg = vCP_AppTitle.."\n\n"..vCP_AppNotes end
	GameTooltip:AddLine(vArg,1,1,1,1)
	GameTooltip:Show()
end
------------------------------------------------------------------------
-- Mini Map Button
------------------------------------------------------------------------
	local vCP_MiniMap = CreateFrame("Button", "vCP_MiniMap", Minimap)
		vCP_MiniMap:SetSize(40, 40)
		vCP_MiniMap:SetNormalTexture("Interface\\Store\\category-icon-services")
		vCP_MiniMap:ClearAllPoints()
		vCP_MiniMap:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", -25, 5)
		vCP_MiniMap:SetMovable(false)
		vCP_MiniMap:SetScript("OnClick", function()
			if vCP_Main:IsVisible() then vCP_Main:Hide() else vCP_Main:Show() end
		end)
		vCP_MiniMap:SetScript("OnEnter", function() vCP_ToolTipsOnly(vCP_MiniMap) end)
		vCP_MiniMap:SetScript("OnLeave", function() vCP_ToolTipsOnly(0) end)
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
	local vCP_Main = CreateFrame("Frame", "vCP_Main", UIParent, BackdropTemplateMixin and "BackdropTemplate")
		vCP_Main:SetBackdrop(BDropA)
		vCP_Main:SetSize(358, 353)
		vCP_Main:ClearAllPoints()
		vCP_Main:SetPoint("CENTER", UIParent)
		vCP_Main:EnableMouse(true)
		vCP_Main:SetMovable(true)
		vCP_Main:RegisterForDrag("LeftButton")
		vCP_Main:SetScript("OnDragStart", function() vCP_Main:StartMoving() end)
		vCP_Main:SetScript("OnDragStop", function() vCP_Main:StopMovingOrSizing() end)
		vCP_Main:SetClampedToScreen(true)
		if not v_ShowHide then vCP_Main:Hide() end
	--Title
	local vCP_Title = vCP_Main:CreateFontString(nil, "ARTWORK", "GameFontNormalLeftYellow")
		vCP_Title:SetPoint("TOP", vCP_Main, 0, -8)
		vCP_Title:SetText("Quick Copy from ATT`s D&R Data")
	-- Close Button
	local vCP_CloseButton = CreateFrame("Button", "vCP_CloseButton", vCP_Main, "UIPanelCloseButton")
		vCP_CloseButton:SetSize(22, 22)
		vCP_CloseButton:SetPoint("TOPRIGHT", vCP_Main, -3, -3)
		vCP_CloseButton:SetScript("OnClick", function() vCP_Main:Hide() end)
	
	--Seperator
	local vCP_Line1 = vCP_Main:CreateTexture("vCP_Line1")
		vCP_Line1:SetSize(vCP_Main:GetWidth()-16, 2)
		vCP_Line1:SetTexture("Interface\\BUTTONS\\WHITE8X8")
		vCP_Line1:SetColorTexture(.8, .8, .8, .2)
		vCP_Line1:SetPoint("TOPLEFT",vCP_Main, 8, -25)

	-- Include Header/Label/Title
	local vCP_LblHdr = CreateFrame("CheckButton", "vCP_LblHdr", vCP_Main, "InterfaceOptionsCheckButtonTemplate")
		vCP_LblHdr:SetPoint("TOPLEFT", vCP_Main, 5, -27)
		vCP_LblHdr:SetChecked(false)
		vCP_LblHdr:SetScript("OnClick", function() vCP_ToggleSwitch(0) end)
			vCP_Hdr = vCP_LblHdr:CreateFontString(nil, "ARTWORK", "GameFontWhiteSmall")
			vCP_Hdr:SetPoint("LEFT", vCP_LblHdr, 25, 0)
			vCP_Hdr:SetText("Display Label?")
	-- Use Percent?
	local vCP_Number1 = CreateFrame("CheckButton", "vCP_Number1", vCP_Main, "InterfaceOptionsCheckButtonTemplate")
		vCP_Number1:SetPoint("TOPLEFT", vCP_Main, 120, -27)
		vCP_Number1:SetChecked(true)
		vCP_Number1:SetScript("OnClick", function() vCP_ToggleSwitch(1,1) end)
			vCP_Hdr = vCP_Number1:CreateFontString(nil, "ARTWORK", "GameFontWhiteSmall")
			vCP_Hdr:SetPoint("LEFT", vCP_Number1, 25, 0)
			vCP_Hdr:SetJustifyH("LEFT")
			vCP_Hdr:SetText("Percent %")
	-- Use Remaining?
	local vCP_Number2 = CreateFrame("CheckButton", "vCP_Number2", vCP_Main, "InterfaceOptionsCheckButtonTemplate")
		vCP_Number2:SetPoint("TOPLEFT", vCP_Main, 235, -27)
		vCP_Number2:SetChecked(false)
		vCP_Number2:SetScript("OnClick", function() vCP_ToggleSwitch(1,2) end)
			vCP_Hdr = vCP_Number2:CreateFontString(nil, "ARTWORK", "GameFontWhiteSmall")
			vCP_Hdr:SetPoint("LEFT", vCP_Number2, 25, 0)
			vCP_Hdr:SetJustifyH("LEFT")
			vCP_Hdr:SetText("Remain ##")

	-- ATT Main List % Only
	local vCP_MainList = CreateFrame("Button", "vCP_MainList", vCP_Main, "UIPanelButtonTemplate")
		vCP_MainList:SetSize(110,20)
		vCP_MainList:SetPoint("TOPLEFT", vCP_Main, 15, -50)
		vCP_MainList:SetText("Main List %")
		vCP_MainList:SetScript("OnClick", function() vCP_ATTList(1) end)
	-- D&R Main List Only
	local vCP_DRMainList = CreateFrame("Button", "vCP_DRMainList", vCP_Main, "UIPanelButtonTemplate")
		vCP_DRMainList:SetSize(110,20)
		vCP_DRMainList:SetPoint("TOPLEFT", vCP_Main, 125, -50)
		vCP_DRMainList:SetText("D&R List %")
		vCP_DRMainList:SetScript("OnClick", function() vCP_ATTList(2) end)
	-- ATT Main & D&R Main List Only
	local vCP_BothMainList = CreateFrame("Button", "vCP_BothMainList", vCP_Main, "UIPanelButtonTemplate")
		vCP_BothMainList:SetSize(110,20)
		vCP_BothMainList:SetPoint("TOPLEFT", vCP_Main, 235, -50)
		vCP_BothMainList:SetText("Both List %")
		vCP_BothMainList:SetScript("OnClick", function() vCP_ATTMDRList() end)
		
	-- Seperator
	local vCP_Line2 = vCP_Main:CreateTexture("vCP_Line2")
		vCP_Line2:SetSize(138, 2)
		vCP_Line2:SetTexture("Interface\\BUTTONS\\WHITE8X8")
		vCP_Line2:SetColorTexture(.8, .8, .8, .2)
		vCP_Line2:SetPoint("TOPLEFT",vCP_Main, 8, -73)
		
	-- Pick To Display
	local vCP_PDis = vCP_Main:CreateFontString(nil, "ARTWORK", "GameFontWhiteSmall")
		vCP_PDis:SetPoint("TOPLEFT", vCP_Main, 10, -80)
		vCP_PDis:SetText("|cffFFFF00Pick Data To Display|r")
	-- D&R Main & Sub List
	local vCP_DRSubList1 = CreateFrame("CheckButton", "vCP_DRSubList1", vCP_Main, "InterfaceOptionsCheckButtonTemplate")
		vCP_DRSubList1:SetPoint("TOPLEFT", vCP_Main, 5, -90)
		vCP_DRSubList1:SetChecked(false)
		vCP_DRSubList1:SetScript("OnClick", function() vCP_ToggleSwitch(2,1) end)
			vCP_Hdr = vCP_DRSubList1:CreateFontString(nil, "ARTWORK", "GameFontWhiteSmall")
			vCP_Hdr:SetPoint("LEFT", vCP_DRSubList1, 25, 0)
			vCP_Hdr:SetJustifyH("LEFT")
			vCP_Hdr:SetText("Main & Sub")
	-- D&R Main, Sub & Difficulty List
	local vCP_DRSubList2 = CreateFrame("CheckButton", "vCP_DRSubList2", vCP_Main, "InterfaceOptionsCheckButtonTemplate")
		vCP_DRSubList2:SetPoint("TOPLEFT", vCP_Main, 5, -108)
		vCP_DRSubList2:SetChecked(true)
		vCP_DRSubList2:SetScript("OnClick", function() vCP_ToggleSwitch(2,2) end)
			vCP_Hdr = vCP_DRSubList2:CreateFontString(nil, "ARTWORK", "GameFontWhiteSmall")
			vCP_Hdr:SetPoint("LEFT", vCP_DRSubList2, 25, 0)
			vCP_Hdr:SetJustifyH("LEFT")
			vCP_Hdr:SetText("Main, Sub & Diff")

	-- Pick An Expansion
	local vCP_PExp = vCP_Main:CreateFontString(nil, "ARTWORK", "GameFontWhiteSmall")
		vCP_PExp:SetPoint("TOPLEFT", vCP_Main, 10, -135)
		vCP_PExp:SetText("|cffFFFF00Pick An Expansion|r")
	-- Create A List using `Array`
		DRHeight = -145
		for i = 1, #ATTDRList do
			local vCP_DRList = CreateFrame("CheckButton", "vCP_DRList"..i, vCP_Main, "InterfaceOptionsCheckButtonTemplate")
				vCP_DRList:SetPoint("TOPLEFT", vCP_Main, 5, DRHeight)
				vCP_DRList:SetChecked(false)
				vCP_DRList:SetScript("OnClick", function() vCP_ToggleSwitch(3,i) end)
					vCP_Hdr = vCP_DRList:CreateFontString(nil, "ARTWORK", "GameFontWhiteSmall")
					vCP_Hdr:SetPoint("LEFT", vCP_DRList, 25, 0)
					vCP_Hdr:SetJustifyH("LEFT")
					vCP_Hdr:SetText(ATTDRList[i])
			DRHeight = DRHeight - 18
		end
	
	--Result Box
	local vCP_Result = CreateFrame("Frame", "vCP_Result", vCP_Main, BackdropTemplateMixin and "BackdropTemplate")
		vCP_Result:SetBackdrop(BDropB)
		vCP_Result:SetSize(vCP_Main:GetWidth()-150, vCP_Main:GetHeight()-76)
		--vCP_Result:ClearAllPoints()
		vCP_Result:SetPoint("TOPRIGHT", vCP_Main, -3, -72)
		local vCP_ResultScroll = CreateFrame("ScrollFrame", "vCP_ResultScroll", vCP_Result, "UIPanelScrollFrameTemplate")
			vCP_ResultScroll:SetPoint("TOPLEFT", vCP_Result, 7, -7)
			vCP_ResultScroll:SetWidth(vCP_Result:GetWidth()-33)
			vCP_ResultScroll:SetHeight(vCP_Result:GetHeight()-10)
				vCP_ResultArea = CreateFrame("EditBox", "vCP_ResultArea", vCP_ResultScroll)
				vCP_ResultArea:SetWidth(vCP_ResultScroll:GetWidth())
				vCP_ResultArea:SetFontObject(GameFontNormalSmall)
				vCP_ResultArea:SetAutoFocus(false)
				vCP_ResultArea:SetMultiLine(true)
				vCP_ResultArea:EnableMouse(true)
				vCP_ResultArea:SetScript("OnEditFocusGained", function() vCP_ResultArea:HighlightText() end)
			--vCP_ResultArea:SetText("ABCDEFGHIJLKMNOPQRSTUVWXYZ_ABCDEFGHIJLKMNOPQRSTUVWXYZ_ABCDEFGHIJLKMNOPQRSTUVWXYZ")
			vCP_ResultScroll:SetScrollChild(vCP_ResultArea)
------------------------------------------------------------------------
-- Fire Up Events
------------------------------------------------------------------------
	local vCP_OnUpdate = CreateFrame("Frame")
		vCP_OnUpdate:RegisterEvent("ADDON_LOADED")
		vCP_OnUpdate:SetScript("OnEvent", function(self, event, ...)
		if event == "ADDON_LOADED" then
			vCP_OnUpdate:RegisterEvent("PLAYER_LOGIN")
			vCP_OnUpdate:UnregisterEvent("ADDON_LOADED")
		end
		if event == "PLAYER_LOGIN" then
			SLASH_vQuickCP1 = '/vqcp'
			
			SlashCmdList["vQuickCP"] = function(arg)
				if IsAddOnLoaded("AllTheThings") then
					if vCP_Main:IsVisible() then vCP_Main:Hide() else vCP_Main:Show() end
					if not _G["AllTheThings-Window-Prime"]:IsVisible() then print("You need to open AllTheThings Main Window to run this addon properly, you can close when you're done getting data on QuickCPATT from ATT") end
				else
					DEFAULT_CHAT_FRAME:AddMessage("Error: Cannot Run This without `All The Things`")
				end
			end
			vCP_OnUpdate:UnregisterEvent("PLAYER_LOGIN")
		end
	end)