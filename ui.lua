if not Cursive.superwow then
	return
end

local L = AceLibrary("AceLocale-2.2"):new("Cursive")

local utils = Cursive.utils
local filter = Cursive.filter

local ui = CreateFrame("Frame", "CursiveUI", UIParent)

ui.border = {
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 8,
	insets = { left = 2, right = 2, top = 2, bottom = 2 }
}

ui.background = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	tile = true, tileSize = 16, edgeSize = 8,
	insets = { left = 0, right = 0, top = 0, bottom = 0 }
}

ui.rootBarFrame = nil
ui.targetIndicatorSize = 8
ui.padding = 2

ui.row = 1
ui.col = 1
ui.maxBarsDisplayed = false
ui.numDisplayed = 0

local function GetBarFirstSectionWidth()
	local config = Cursive.db.profile

	local size = 1
	if config.showraidicons then
		size = size + config.raidiconsize
	end
	if config.showtargetindicator then
		size = size + ui.targetIndicatorSize
	end
	if size > 0 then
		size = size + ui.padding
	end

	return size
end

local function GetBarSecondSectionWidth()
	local config = Cursive.db.profile

	if config.showhealthbar == false and config.showunitname == false then
		return 1
	end

	return config.healthwidth + ui.padding
end

local function GetBarThirdSectionWidth()
	local config = Cursive.db.profile

	return config.maxcurses * (config.curseiconsize + ui.padding)
end

local function GetBarWidth()
	return GetBarFirstSectionWidth() +
			GetBarSecondSectionWidth() +
			GetBarThirdSectionWidth()
end

local function UpdateRootBarFrame()
	local config = Cursive.db.profile

	if config.showbackdrop then
		ui.rootBarFrame:SetBackdrop(ui.background)
	else
		ui.rootBarFrame:SetBackdrop(nil)
	end

	ui.rootBarFrame:EnableMouse(not config.clickthrough)

	ui.rootBarFrame.pos = config.anchor .. config.x .. config.y .. config.scale
	ui.rootBarFrame:ClearAllPoints()
	ui.rootBarFrame:SetPoint(config.anchor, config.x, config.y)

	ui.rootBarFrame:SetScale(config.scale)

	ui.rootBarFrame.caption:SetFont(STANDARD_TEXT_FONT, Cursive.db.profile.textsize, "THINOUTLINE")
	ui.rootBarFrame.caption:SetText(Cursive.db.profile.caption)
	if Cursive.db.profile.showtitle then
		ui.rootBarFrame.caption:Show()
	else
		ui.rootBarFrame.caption:Hide()
	end

	ui.rootBarFrame:SetWidth(config.maxcol * GetBarWidth())
	ui.rootBarFrame:SetHeight(config.maxrow * config.height)
end

local function CreateRoot()
	local frame = CreateFrame("Frame", Cursive.db.profile.caption, UIParent)
	ui.rootBarFrame = frame

	frame.id = Cursive.db.profile.caption

	frame:RegisterForDrag("LeftButton")
	frame:SetMovable(true)

	frame:SetScript("OnDragStart", function()
		this.lock = true
		this:StartMoving()
	end)

	frame:SetScript("OnDragStop", function()
		-- convert to best anchor depending on position
		local new_anchor = utils.GetBestAnchor(this)
		local anchor, x, y = utils.ConvertFrameAnchor(this, new_anchor)
		this:ClearAllPoints()
		this:SetPoint(anchor, UIParent, anchor, x, y)

		-- save new position
		anchor, _, _, x, y = this:GetPoint()
		Cursive.db.profile.anchor, Cursive.db.profile.x, Cursive.db.profile.y = anchor, x, y

		-- stop drag
		this:StopMovingOrSizing()
		this.lock = false

		this:ClearAllPoints()
		this:SetPoint(anchor, x, y)
	end)

	-- create title text
	frame.caption = frame:CreateFontString(nil, "HIGH", "GameFontWhite")
	frame.caption:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -2)
	frame.caption:SetTextColor(1, 1, 1, 1)

	UpdateRootBarFrame()

	frame:Show()

	return frame
end

ui.unitFrames = {} -- holds all unitFrames for all columns/rows

Cursive.UpdateFramesFromConfig = function()
	for col, rows in pairs(ui.unitFrames) do
		for row, unitFrame in pairs(rows) do
			if unitFrame and unitFrame:IsShown() then
				unitFrame:Hide()
			end
		end
	end

	if ui.rootBarFrame then
		UpdateRootBarFrame()
	end
end

ui.BarEnter = function()
	if this.parent.healthBar then
		this.parent.healthBar.border:SetBackdropBorderColor(1, 1, 1, 1)
	end
	this.parent.hover = true

	GameTooltip_SetDefaultAnchor(GameTooltip, this)
	GameTooltip:SetUnit(this.parent.guid)
	GameTooltip:Show()
end

ui.BarLeave = function()
	this.parent.hover = false
	GameTooltip:Hide()
end

ui.BarUpdate = function()
	if not this.guid or this.guid == 0 then
		this:Hide()
		return
	end

	if (this.tick or 1) > GetTime() then
		return
	else
		this.tick = GetTime() + 0.05
	end

	-- update statusbar values if it exists
	if this.healthBar then
		this.healthBar:SetMinMaxValues(0, UnitHealthMax(this.guid))
		this.healthBar:SetValue(UnitHealth(this.guid))

		-- update health bar color
		local hex, r, g, b, a = utils.GetUnitColor(this.guid)
		this.healthBar:SetStatusBarColor(r, g, b, a)

		-- update health bar border
		if this.healthBar.border then
			if this.hover then
				this.healthBar.border:SetBackdropBorderColor(1, 1, 1, 1)
			elseif UnitAffectingCombat(this.guid) then
				this.healthBar.border:SetBackdropBorderColor(.8, .2, .2, 1)
			else
				this.healthBar.border:SetBackdropBorderColor(.2, .2, .2, 1)
			end
		end
	end

	-- update caption text
	local name = UnitName(this.guid)
	if name and this.nameText then
		this.nameText:SetText(name)
	end

	if this.hpText then
		local hp = UnitHealth(this.guid)
		if GetLocale() == "zhCN" then
			if hp then
				if hp >= 10000 then
					hp = math.floor(hp / 1000) / 10 .. "万"
					-- elseif hp >= 1000 then
					-- 	hp = math.floor(hp / 100) / 10 .. "k"
				end
			end
		else
			-- convert hp to k if > 1000
			if hp then
				if hp >= 1000000 then
					hp = math.floor(hp / 100000) / 10 .. "m"
				elseif hp >= 1000 then
					hp = math.floor(hp / 100) / 10 .. "k"
				end
			end
		end

		if hp then
			this.hpText:SetText(hp)
		end
	end

	-- show raid icon if existing
	if this.icon then
		if GetRaidTargetIndex(this.guid) and Cursive.filter.alive(this.guid) then
			SetRaidTargetIconTexture(this.icon, GetRaidTargetIndex(this.guid))
			this.icon:Show()
		else
			this.icon:Hide()
		end
	end

	-- update target indicator
	if this.target_left then
		if UnitIsUnit("target", this.guid) then
			this.target_left:Show()
		else
			this.target_left:Hide()
		end
	end
end

ui.BarClick = function()
	TargetUnit(this.parent.guid)
end

local function CreateBarFirstSection(unitFrame, guid)
	local config = Cursive.db.profile
	local firstSection = CreateFrame("Frame", "Cursive1stSection", unitFrame)
	firstSection:SetPoint("LEFT", unitFrame, "LEFT", 0, 0)
	firstSection:SetWidth(GetBarFirstSectionWidth())
	firstSection:SetHeight(config.height)
	firstSection:EnableMouse(false)
	unitFrame.firstSection = firstSection

	-- create target indicator
	if config.showtargetindicator then
		local targetLeft = firstSection:CreateTexture(nil, "OVERLAY")
		targetLeft:SetWidth(ui.targetIndicatorSize)
		targetLeft:SetHeight(8)
		targetLeft:SetPoint("LEFT", unitFrame, "LEFT", 0, 0)
		targetLeft:SetTexture("Interface\\AddOns\\Cursive\\img\\target-left")
		targetLeft:Hide()
		unitFrame.target_left = targetLeft
	end

	-- create raid icon textures
	if config.showraidicons then
		local icon = firstSection:CreateTexture(nil, "OVERLAY")
		icon:SetWidth(config.raidiconsize)
		icon:SetHeight(config.raidiconsize)
		icon:SetPoint("RIGHT", firstSection, "RIGHT", 0, 0)
		icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
		icon:Hide()
		unitFrame.icon = icon
	end
end

local function CreateBarSecondSection(unitFrame, guid)
	local config = Cursive.db.profile
	local secondSection = CreateFrame("Button", "Cursive2ndSection", unitFrame)
	secondSection:SetPoint("LEFT", unitFrame.firstSection, "RIGHT", 0, 0)
	secondSection:SetWidth(GetBarSecondSectionWidth())
	secondSection:SetHeight(config.height)
	unitFrame.secondSection = secondSection
	secondSection.parent = unitFrame

	secondSection:SetScript("OnClick", ui.BarClick)
	secondSection:SetScript("OnEnter", ui.BarEnter)
	secondSection:SetScript("OnLeave", ui.BarLeave)

	-- create health bar
	if config.showhealthbar then
		local healthBar = CreateFrame("StatusBar", "CursiveHealthBar", secondSection)
		healthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
		healthBar:SetStatusBarColor(1, .8, .2, 1)
		healthBar:SetMinMaxValues(0, 100)
		healthBar:SetValue(20)
		healthBar:SetPoint("LEFT", secondSection, "LEFT", ui.padding, 0)
		healthBar:SetWidth(config.healthwidth)
		healthBar:SetHeight(config.height)
		unitFrame.healthBar = healthBar

		if config.showunithp then
			local hp = healthBar:CreateFontString(nil, "HIGH", "GameFontWhite")
			hp:SetPoint("TOPRIGHT", healthBar, "TOPRIGHT", -2, -2)
			hp:SetWidth(30)
			hp:SetHeight(config.height - 4)
			hp:SetFont(STANDARD_TEXT_FONT, config.textsize, "THINOUTLINE")
			hp:SetJustifyH("RIGHT")
			unitFrame.hpText = hp
		end

		if config.showunitname then
			local name = healthBar:CreateFontString(nil, "HIGH", "GameFontWhite")
			name:SetPoint("TOPLEFT", healthBar, "TOPLEFT", 2, -2)
			if config.showhp then
				name:SetPoint("BOTTOMRIGHT", hp, "BOTTOMLEFT", 2, 0)
			else
				name:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", -2, 0)
			end
			name:SetFont(STANDARD_TEXT_FONT, config.textsize, "THINOUTLINE")
			name:SetJustifyH("LEFT")
			unitFrame.nameText = name
		end

		-- create health bar backdrops
		if pfUI and pfUI.uf then
			pfUI.api.CreateBackdrop(healthBar)
			healthBar.border = healthBar.backdrop
		else
			healthBar:SetBackdrop(ui.background)
			healthBar:SetBackdropColor(0, 0, 0, 1)

			local border = CreateFrame("Frame", "CursiveBorder", healthBar.bar)
			border:SetBackdrop(ui.border)
			border:SetBackdropColor(.2, .2, .2, 1)
			border:SetPoint("TOPLEFT", healthBar.bar, "TOPLEFT", -2, 2)
			border:SetPoint("BOTTOMRIGHT", healthBar.bar, "BOTTOMRIGHT", 2, -2)
			healthBar.border = border
		end
	else
		if config.showunitname then
			local name = secondSection:CreateFontString(nil, "HIGH", "GameFontWhite")
			name:SetPoint("TOPLEFT", secondSection, "TOPLEFT", 2, -2)
			name:SetPoint("BOTTOMRIGHT", secondSection, "BOTTOMRIGHT", 2, 0)
			name:SetFont(STANDARD_TEXT_FONT, config.textsize, "THINOUTLINE")
			name:SetWidth(config.healthwidth)
			name:SetHeight(config.height - 4)
			name:SetJustifyH("LEFT")
			unitFrame.nameText = name
		end
	end
end

local function CreateBarThirdSection(unitFrame, guid)
	local config = Cursive.db.profile

	local thirdSection = CreateFrame("Frame", "Cursive3rdSection", unitFrame)
	thirdSection:SetPoint("LEFT", unitFrame.secondSection, "RIGHT", 0, 0)
	thirdSection:SetWidth(GetBarThirdSectionWidth())
	thirdSection:SetHeight(config.height)
	thirdSection:EnableMouse(false)
	unitFrame.thirdSection = thirdSection

	-- display up to maxcurses curses
	for i = 1, config.maxcurses do
		local curse = thirdSection:CreateTexture(nil, "OVERLAY")
		curse:SetWidth(config.curseiconsize)
		curse:SetHeight(config.curseiconsize)
		curse:SetPoint("LEFT", thirdSection, "LEFT", i * ui.padding + ((i - 1) * config.curseiconsize), 0)

		curse.timer = thirdSection:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		curse.timer:SetFontObject(GameFontHighlight)
		curse.timer:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
		curse.timer:SetTextColor(1, 1, 1)
		curse.timer:SetAllPoints(curse)

		curse.timer:Hide()
		curse:Hide()
		unitFrame["curse" .. i] = curse
	end
end

local function CreateBar(row, col, guid)
	local unitFrame = CreateFrame("Frame", "CursiveUnitFrame", ui.rootBarFrame)
	unitFrame.guid = guid

	unitFrame:SetScript("OnUpdate", ui.BarUpdate)

	local config = Cursive.db.profile
	local width = GetBarWidth()
	unitFrame:SetWidth(width)
	unitFrame:SetHeight(config.height)

	CreateBarFirstSection(unitFrame, guid)
	CreateBarSecondSection(unitFrame, guid)
	CreateBarThirdSection(unitFrame, guid)

	ui.unitFrames[col][row] = unitFrame
	return unitFrame
end

local function GetBarCords(row, col)
	local config = Cursive.db.profile
	local x = (col - 1) * GetBarWidth()
	local y = row * (config.height + config.spacing) -- don't subtract 1 to account for header
	return x, y
end

local function hasAnySpellId(guid, spellIds)
	for i = 1, 16 do
		local texture, stacks, spellSchool, spellId = UnitDebuff(guid, i);
		if not spellId then
			break
		end
		if spellIds[spellId] then
			return spellId
		end
	end

	for i = 1, 32 do
		local texture, stacks, spellId = UnitBuff(guid, i);
		if not spellId then
			break
		end
		if spellIds[spellId] then
			return spellId
		end
	end

	return nil
end

local function GetSortedCurses(guidCurses)
	-- Collect keys
	local curseNames = {}
	for key in pairs(guidCurses) do
		table.insert(curseNames, key)
	end

	if Cursive.db.profile.curseordering == L["Order applied"] then
		table.sort(curseNames, function(a, b)
			return guidCurses[a].start < guidCurses[b].start
		end)
	elseif Cursive.db.profile.curseordering == L["Expiring soonest -> latest"] then
		table.sort(curseNames, function(a, b)
			return Cursive.curses:TimeRemaining(guidCurses[a]) < Cursive.curses:TimeRemaining(guidCurses[b])
		end)
	elseif Cursive.db.profile.curseordering == L["Expiring latest -> soonest"] then
		table.sort(curseNames, function(a, b)
			return Cursive.curses:TimeRemaining(guidCurses[a]) > Cursive.curses:TimeRemaining(guidCurses[b])
		end)
	end

	local i = 0
	return function()
		i = i + 1
		local key = curseNames[i]
		if key then
			return key, guidCurses[key]
		end
	end
end

local function DisplayGuid(guid)
	if not ui.unitFrames[ui.col] then
		ui.unitFrames[ui.col] = {}
	end

	local unitFrame
	if ui.unitFrames[ui.col][ui.row] then
		unitFrame = ui.unitFrames[ui.col][ui.row]
		unitFrame.guid = guid
	else
		unitFrame = CreateBar(ui.row, ui.col, guid)
		ui.unitFrames[ui.col][ui.row] = unitFrame
	end

	local x, y = GetBarCords(ui.row, ui.col)

	-- update position if required
	if not unitFrame.pos or unitFrame.pos ~= x .. -y then
		unitFrame:ClearAllPoints()
		unitFrame:SetPoint("TOPLEFT", ui.rootBarFrame, "TOPLEFT", x, -y)
		unitFrame.pos = x .. -y
	end

	-- check for shared debuffs
	for sharedDebuffKey, guids in pairs(Cursive.curses.sharedDebuffGuids) do
		if guids[guid] then
			local sharedDebuffSpellIds = Cursive.curses.sharedDebuffs[sharedDebuffKey]
			local spellId = hasAnySpellId(guid, sharedDebuffSpellIds)
			if spellId ~= nil then
				-- add curse to curses
				Cursive.curses:ApplySharedCurse(sharedDebuffKey, spellId, guid, GetTime())
				-- remove guid
				Cursive.curses.sharedDebuffGuids[sharedDebuffKey][guid] = nil
			end
		end
	end

	-- update curses
	local curseNumber = 1

	-- make sure old curses are hidden
	for i = 1, Cursive.db.profile.maxcurses do
		local curse = unitFrame["curse" .. i]
		curse:Hide()
		curse.timer:Hide()
	end

	local guidCurses = Cursive.curses.guids[guid]
	if guidCurses then
		for curseName, curseData in GetSortedCurses(guidCurses) do
			if curseNumber > Cursive.db.profile.maxcurses then
				break
			end

			local remaining = Cursive.curses:TimeRemaining(curseData)
			local curse = unitFrame["curse" .. curseNumber]
			if remaining >= 0 then
				curse:SetTexture(Cursive.curses.trackedCurseIds[curseData.spellID].texture)

				if curseData["currentPlayer"] == false then
					curse:SetDesaturated(true); -- desaturate if not applied by current player
				else
					curse:SetDesaturated(false); -- saturate if applied by current player
				end

				-- curse:SetTexCoord(.078, .92, .079, .937) rounded icons
				curse.timer:SetText(remaining)
				curse.timer:Show()
				curse:Show()

				if remaining < 1 then
					if Cursive.curses:ShouldPlayExpiringSound(curseName, guid) then
						PlaySoundFile("Interface\\AddOns\\Cursive\\sounds\\expiring.mp3")
					end
				elseif Cursive.curses:HasRequestedExpiringSound(curseName, guid) then
					Cursive.curses:EnableExpiringSound(curseName, guid)
				end
			end
			curseNumber = curseNumber + 1
		end
	end

	unitFrame:Show()
	ui.numDisplayed = ui.numDisplayed + 1

	local config = Cursive.db.profile

	-- update row/col
	ui.row = ui.row + 1
	if ui.row > config.maxrow then
		ui.row = 1
		ui.col = ui.col + 1
		if ui.col > config.maxcol then
			ui.maxBarsDisplayed = true
		end
	end
end

local function CheckForCleanup(guid, time)
	local active = UnitExists(guid) and Cursive.filter.alive(guid)
	if active then
		local old = GetTime() - time >= 900 -- >= 15 minutes old
		if old and not UnitIsVisible(guid) then
			active = false
		end
	end

	if not active then
		-- remove from core
		Cursive.core.remove(guid)
		-- remove from curses
		Cursive.curses:RemoveGuid(guid)

		-- remove from sharedDebuffGuids
		for sharedDebuffKey, guids in pairs(Cursive.curses.sharedDebuffGuids) do
			if guids[guid] then
				Cursive.curses.sharedDebuffGuids[sharedDebuffKey][guid] = nil
			end
		end
	end
end


local shouldDisplayGuids = {};
local displayedGuids = {};

ui:SetAllPoints()
ui:SetScript("OnUpdate", function()
	local config = Cursive.db.profile

	if not config.enabled then
		return
	end

	if (this.tick or 1) > GetTime() then
		return
	else
		this.tick = GetTime() + 0.1
	end

	if not ui.rootBarFrame then
		ui.rootBarFrame = CreateRoot()
	end

	-- skip if locked (due to moving)
	if ui.rootBarFrame.lock then
		return
	end

	-- reset display data
	ui.row = 1
	ui.col = 1
	ui.maxBarsDisplayed = false
	ui.numDisplayed = 0

	-- clear shouldDisplayGuids
	for guid, _ in pairs(shouldDisplayGuids) do
		shouldDisplayGuids[guid] = nil
	end

	-- clear displayedGuids
	for guid, _ in pairs(displayedGuids) do
		displayedGuids[guid] = nil
	end

	-- run through all guids and fill with bars
	local title_size = 12 + config.spacing

	local topMaxHp = 0
	local secondMaxHp = 0
	local thirdMaxHp = 0

	local topMaxGuid = 0
	local secondMaxGuid = 0
	local thirdMaxGuid = 0

	local numDisplayable = 0

	local averageMaxHp = 0

	local _, currentTargetGuid = UnitExists("target")

	-- first consider raid marks
	for i = 8, 1, -1 do
		local _, guid = UnitExists("mark" .. i)
		if guid then
			if Cursive:ShouldDisplayGuid(guid) then
				numDisplayable = numDisplayable + 1

				-- display guid
				displayedGuids[guid] = true
				DisplayGuid(guid)
				if ui.maxBarsDisplayed then
					break
				end
			end
			-- don't try to display this guid again
			shouldDisplayGuids[guid] = false
		end
	end

	for guid, time in pairs(Cursive.core.guids) do
		-- calculate shouldDisplay
		local shouldDisplay = false
		if shouldDisplayGuids[guid] == nil then
			shouldDisplay = Cursive:ShouldDisplayGuid(guid)
			shouldDisplayGuids[guid] = shouldDisplay

			if shouldDisplay then
				numDisplayable = numDisplayable + 1
			end
		else
			shouldDisplay = shouldDisplayGuids[guid]
		end

		-- calculate top 3 max hps
		if shouldDisplay then
			local maxHp = UnitHealthMax(guid)
			if maxHp > topMaxHp then
				thirdMaxHp = secondMaxHp
				thirdMaxGuid = secondMaxGuid
				secondMaxHp = topMaxHp
				secondMaxGuid = topMaxGuid
				topMaxHp = maxHp
				topMaxGuid = guid
			elseif maxHp > secondMaxHp then
				thirdMaxHp = secondMaxHp
				thirdMaxGuid = secondMaxGuid
				secondMaxHp = maxHp
				secondMaxGuid = guid
			elseif maxHp > thirdMaxHp then
				thirdMaxHp = maxHp
				thirdMaxGuid = guid
			end
		else
			CheckForCleanup(guid, time)
		end
	end

	-- top max hp
	if not ui.maxBarsDisplayed and numDisplayable > ui.numDisplayed and not displayedGuids[topMaxGuid] then
		displayedGuids[topMaxGuid] = true
		DisplayGuid(topMaxGuid)
	end

	-- second max hp
	if not ui.maxBarsDisplayed and numDisplayable > ui.numDisplayed and not displayedGuids[secondMaxGuid] then
		displayedGuids[secondMaxGuid] = true
		DisplayGuid(secondMaxGuid)
	end

	-- third max hp
	if not ui.maxBarsDisplayed and numDisplayable > ui.numDisplayed and not displayedGuids[thirdMaxGuid] then
		displayedGuids[thirdMaxGuid] = true

		DisplayGuid(thirdMaxGuid)
	end

	-- fill in remaining slots
	for guid, time in pairs(Cursive.core.guids) do
		if ui.maxBarsDisplayed or numDisplayable <= ui.numDisplayed then
			break
		end

		if not displayedGuids[guid] and shouldDisplayGuids[guid] == true then
			displayedGuids[guid] = true
			DisplayGuid(guid)
		end
	end

	-- if current target not yet displayed, show it at maxrow/maxcol
	if currentTargetGuid and
			shouldDisplayGuids[currentTargetGuid] and
			not displayedGuids[currentTargetGuid] and
			Cursive.db.profile.alwaysshowcurrenttarget then
		-- replace the last displayed guid with the current target
		displayedGuids[currentTargetGuid] = true
		ui.col = config.maxcol
		ui.row = config.maxrow
		DisplayGuid(currentTargetGuid)
	end

	-- hide any remaining unit frames
	for col, rows in pairs(ui.unitFrames) do
		for row, unitFrame in pairs(rows) do
			if unitFrame:IsShown() then
				if not displayedGuids[unitFrame.guid] then
					unitFrame:Hide()
				else
					displayedGuids[unitFrame.guid] = nil -- avoid displaying duplicate rows
				end
			end
		end
	end

end)

Cursive.ui = ui
