if not Cursive.superwow then
	return
end

local utils = Cursive.utils
local filter = Cursive.filter

local ui = CreateFrame("Frame", nil, UIParent)

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

ui.unitFrames = {} -- holds all unitFrames for all guids

Cursive.UpdateFramesFromConfig = function()
	for guid, frame in pairs(ui.unitFrames) do
		frame:Hide()
		ui.unitFrames[guid] = nil
	end

	if ui.rootBarFrame then
		UpdateRootBarFrame()
	end
end

ui.BarEnter = function()
	if this.healthBar then
		this.healthBar.border:SetBackdropBorderColor(1, 1, 1, 1)
	end
	this.hover = true

	GameTooltip_SetDefaultAnchor(GameTooltip, this)
	GameTooltip:SetUnit(this.guid)
	GameTooltip:Show()
end

ui.BarLeave = function()
	this.hover = false
	GameTooltip:Hide()
end

ui.BarUpdate = function()
	if not this.guid then
		return
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
	TargetUnit(this.guid)
end

local function CreateBarFirstSection(unitFrame, guid)
	local config = Cursive.db.profile
	local firstSection = CreateFrame("Frame", nil, unitFrame)
	firstSection:SetPoint("LEFT", unitFrame, "LEFT", 0, 0)
	firstSection:SetWidth(GetBarFirstSectionWidth())
	firstSection:SetHeight(config.height)
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
	local secondSection = CreateFrame("Frame", nil, unitFrame)
	secondSection:SetPoint("LEFT", unitFrame.firstSection, "RIGHT", 0, 0)
	secondSection:SetWidth(GetBarSecondSectionWidth())
	secondSection:SetHeight(config.height)
	unitFrame.secondSection = secondSection

	-- create health bar
	if config.showhealthbar then
		local healthBar = CreateFrame("StatusBar", nil, secondSection)
		healthBar:SetStatusBarTexture("Interface\\AddOns\\Cursive\\img\\bar")
		healthBar:SetStatusBarColor(1, .8, .2, 1)
		healthBar:SetMinMaxValues(0, 100)
		healthBar:SetValue(20)
		healthBar:SetPoint("LEFT", secondSection, "LEFT", ui.padding, 0)
		healthBar:SetWidth(config.healthwidth)
		healthBar:SetHeight(config.height)
		unitFrame.healthBar = healthBar

		local hp = healthBar:CreateFontString(nil, "HIGH", "GameFontWhite")
		hp:SetPoint("TOPRIGHT", healthBar, "TOPRIGHT", -2, -2)
		hp:SetWidth(30)
		hp:SetHeight(config.height - 4)
		hp:SetFont(STANDARD_TEXT_FONT, config.textsize, "THINOUTLINE")
		hp:SetJustifyH("RIGHT")
		unitFrame.hpText = hp

		if config.showunitname then
			local name = healthBar:CreateFontString(nil, "HIGH", "GameFontWhite")
			name:SetPoint("TOPLEFT", healthBar, "TOPLEFT", 2, -2)
			name:SetPoint("BOTTOMRIGHT", hp, "BOTTOMLEFT", 2, 0)
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

			local border = CreateFrame("Frame", nil, healthBar.bar)
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

	local thirdSection = CreateFrame("Frame", nil, unitFrame)
	thirdSection:SetPoint("LEFT", unitFrame.secondSection, "RIGHT", 0, 0)
	thirdSection:SetWidth(GetBarThirdSectionWidth())
	thirdSection:SetHeight(config.height)
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

local function CreateBar(guid)
	local unitFrame = CreateFrame("Button", nil, ui.rootBarFrame)
	unitFrame.guid = guid

	unitFrame:SetScript("OnClick", ui.BarClick)
	unitFrame:SetScript("OnEnter", ui.BarEnter)
	unitFrame:SetScript("OnLeave", ui.BarLeave)
	unitFrame:SetScript("OnUpdate", ui.BarUpdate)

	local config = Cursive.db.profile
	local width = GetBarWidth()
	unitFrame:SetWidth(width)
	unitFrame:SetHeight(config.height)

	CreateBarFirstSection(unitFrame, guid)
	CreateBarSecondSection(unitFrame, guid)
	CreateBarThirdSection(unitFrame, guid)

	ui.unitFrames[guid] = unitFrame
	return unitFrame
end

local function GetBarCords(row, col)
	local config = Cursive.db.profile
	local x = (col - 1) * GetBarWidth()
	local y = row * (config.height + config.spacing) -- don't subtract 1 to account for header
	return x, y
end

local function DisplayGuid(guid, row, col)
	local unitFrame = ui.unitFrames[guid] or CreateBar(guid)

	local x, y = GetBarCords(row, col)

	-- update position if required
	if not unitFrame.pos or unitFrame.pos ~= x .. -y then
		unitFrame:ClearAllPoints()
		unitFrame:SetPoint("TOPLEFT", ui.rootBarFrame, "TOPLEFT", x, -y)
		unitFrame.pos = x .. -y
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
		for curseName, curseData in pairs(guidCurses) do
			if curseNumber > Cursive.db.profile.maxcurses then
				break
			end

			local remaining = Cursive.curses:TimeRemaining(curseData)
			local curse = unitFrame["curse" .. curseNumber]
			if remaining >= 0 then
				curse:SetTexture(Cursive.curses.trackedCurseIds[curseData.spellID].texture)
				curse:SetTexCoord(.078, .92, .079, .937)
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
end

local function HideGuid(guid, time)
	if ui.unitFrames[guid] then
		ui.unitFrames[guid]:Hide()
		ui.unitFrames[guid] = nil
	end

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
	end
end

ui:SetAllPoints()
ui:SetScript("OnUpdate", function()
	local config = Cursive.db.profile

	if not config.enabled then
		return
	end

	if (this.tick or 1) > GetTime() then
		return
	else
		this.tick = GetTime() + .2
	end

	if not ui.rootBarFrame then
		ui.rootBarFrame = CreateRoot()
	end

	-- skip if locked (due to moving)
	if ui.rootBarFrame.lock then
		return
	end

	-- run through all guids and fill with bars
	local title_size = 12 + config.spacing

	local row = 1
	local col = 1
	local maxBarsDisplayed = false

	for i = 1, 2 do
		for guid, time in pairs(Cursive.core.guids) do
			-- apply filters
			local shouldDisplay = Cursive:ShouldDisplayGuid(guid)

			local hasIcon = filter.icon(guid)

			if (i == 1 and hasIcon) or (i == 2 and not hasIcon) then
				-- display element if filters allow it
				if shouldDisplay and not maxBarsDisplayed then
					-- display guid
					DisplayGuid(guid, row, col)

					-- update row/col
					row = row + 1
					if row > config.maxrow then
						row = 1
						col = col + 1
						if col > config.maxcol then
							maxBarsDisplayed = true
						end
					end
				else
					HideGuid(guid, time)
				end
			end
		end
	end
end)

Cursive.ui = ui
