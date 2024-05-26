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

ui.frames = {}

ui.CreateRoot = function(parent, caption)
	local frame = CreateFrame("Frame", "Cursive" .. caption, parent)
	frame.id = caption

	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetMovable(true)

	frame:SetScript("OnDragStart", function()
		this.lock = true
		this:StartMoving()
	end)

	frame:SetScript("OnDragStop", function()
		-- load current window config
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
	end)

	-- assign/initialize elements
	frame.CreateBar = ui.CreateBar
	frame.frames = {}

	-- create title text
	frame.caption = frame:CreateFontString(nil, "HIGH", "GameFontWhite")
	frame.caption:SetFont(STANDARD_TEXT_FONT, 9, "THINOUTLINE")
	frame.caption:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -2)
	frame.caption:SetTextColor(1, 1, 1, 1)
	frame.caption:SetText(caption)

	return frame
end

ui.BarEnter = function()
	this.border:SetBackdropBorderColor(1, 1, 1, 1)
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
	-- update statusbar values
	this.bar:SetMinMaxValues(0, UnitHealthMax(this.guid))
	this.bar:SetValue(UnitHealth(this.guid))

	-- update health bar color
	local hex, r, g, b, a = utils.GetUnitColor(this.guid)
	this.bar:SetStatusBarColor(r, g, b, a)

	-- update caption text
	local name = UnitName(this.guid)
	local hp = UnitHealth(this.guid)
	-- convert hp to k if > 1000
	if hp and hp  > 1000 then
		-- round to 1 decimal
		hp = math.floor(hp / 100) / 10 .. "k"
	end

	if name then
		if hp then
			this.text:SetText(name .. " " .. tostring(hp))
		else
			this.text:SetText(name)
		end
	end

	-- update health bar border
	if this.hover then
		this.border:SetBackdropBorderColor(1, 1, 1, 1)
	elseif UnitAffectingCombat(this.guid) then
		this.border:SetBackdropBorderColor(.8, .2, .2, 1)
	else
		this.border:SetBackdropBorderColor(.2, .2, .2, 1)
	end

	-- show raid icon if existing
	if GetRaidTargetIndex(this.guid) then
		SetRaidTargetIconTexture(this.icon, GetRaidTargetIndex(this.guid))
		this.icon:Show()
	else
		this.icon:Hide()
	end

	-- update target indicator
	if UnitIsUnit("target", this.guid) then
		this.target_left:Show()
	else
		this.target_left:Hide()
	end
end

ui.BarClick = function()
	TargetUnit(this.guid)
end

ui.CreateBar = function(parent, guid)
	local frame = CreateFrame("Button", nil, parent)
	frame.guid = guid

	frame:SetScript("OnClick", ui.BarClick)
	frame:SetScript("OnEnter", ui.BarEnter)
	frame:SetScript("OnLeave", ui.BarLeave)
	frame:SetScript("OnUpdate", ui.BarUpdate)

	-- create health bar
	local bar = CreateFrame("StatusBar", nil, frame)
	bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	bar:SetStatusBarColor(1, .8, .2, 1)
	bar:SetMinMaxValues(0, 100)
	bar:SetValue(20)
	bar:SetAllPoints()
	frame.bar = bar

	-- create caption text
	local text = frame.bar:CreateFontString(nil, "HIGH", "GameFontWhite")
	text:SetPoint("TOPLEFT", bar, "TOPLEFT", 2, -2)
	text:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -2, 2)
	text:SetFont(STANDARD_TEXT_FONT, 9, "THINOUTLINE")
	text:SetJustifyH("LEFT")
	frame.text = text

	-- create raid icon textures
	local icon = bar:CreateTexture(nil, "OVERLAY")
	icon:SetWidth(16)
	icon:SetHeight(16)
	icon:SetPoint("RIGHT", frame, "RIGHT", -2, 0)
	icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
	icon:Hide()
	frame.icon = icon

	-- display up to 3 curses
	for i = 1, 3 do
		local curse = bar:CreateTexture(nil, "OVERLAY")
		curse:SetWidth(20)
		curse:SetHeight(20)
		curse:SetPoint("LEFT", frame, "RIGHT", 4 + ((i - 1) * 20), 0)

		curse.timer = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		curse.timer:SetFontObject(GameFontHighlight)
		curse.timer:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
		curse.timer:SetTextColor(1, 1, 1)
		curse.timer:SetAllPoints(curse)

		curse.timer:Hide()
		curse:Hide()
		frame["curse" .. i] = curse
	end

	-- create target indicator
	local target_left = bar:CreateTexture(nil, "OVERLAY")
	target_left:SetWidth(8)
	target_left:SetHeight(8)
	target_left:SetPoint("LEFT", frame, "LEFT", -4, 0)
	target_left:SetTexture("Interface\\AddOns\\Cursive\\img\\target-left")
	target_left:Hide()
	frame.target_left = target_left

	-- create frame backdrops
	if pfUI and pfUI.uf then
		pfUI.api.CreateBackdrop(frame)
		frame.border = frame.backdrop
	else
		frame:SetBackdrop(ui.background)
		frame:SetBackdropColor(0, 0, 0, 1)

		local border = CreateFrame("Frame", nil, frame.bar)
		border:SetBackdrop(ui.border)
		border:SetBackdropColor(.2, .2, .2, 1)
		border:SetPoint("TOPLEFT", frame.bar, "TOPLEFT", -2, 2)
		border:SetPoint("BOTTOMRIGHT", frame.bar, "BOTTOMRIGHT", 2, -2)
		frame.border = border
	end

	return frame
end

ui:SetAllPoints()
ui:SetScript("OnUpdate", function()
	if not Cursive.db.profile.enabled then
		return
	end

	if (this.tick or 1) > GetTime() then
		return
	else
		this.tick = GetTime() + .2
	end

	local caption = Cursive.db.profile.caption
	local config = Cursive.db.profile

	-- create ui frames based on config values
	-- create root frame if not existing
	ui.frames[caption] = ui.frames[caption] or ui:CreateRoot(caption)
	local root = ui.frames[caption]

	-- skip if locked (due to moving)
	if root.lock then
		return
	end

	-- update position based on config
	if not root.pos or root.pos ~= config.anchor .. config.x .. config.y .. config.scale then
		root.pos = config.anchor .. config.x .. config.y .. config.scale
		root:ClearAllPoints()
		root:SetPoint(config.anchor, config.x, config.y)
		root:SetScale(config.scale)
	end

	-- run through all guids and fill with bars
	local title_size = 12 + config.spacing
	local width, height = config.width, config.height + title_size
	local x, y, count = 0, 0, 0

	for guid, time in pairs(Cursive.core.guids) do
		-- apply filters
		local shouldDisplay = Cursive:ShouldDisplayGuid(guid)

		local exists = UnitExists(guid)

		-- display element if filters allow it
		if exists and shouldDisplay then
			count = count + 1

			if count > config.maxrow then
				count, x = 1, x + config.width + config.spacing
				width = math.max(x + config.width, width)
			end

			y = (count - 1) * (config.height + config.spacing) + title_size
			height = math.max(y + config.height + config.spacing, height)

			root.frames[guid] = root.frames[guid] or root:CreateBar(guid)

			-- update position if required
			if not root.frames[guid].pos or root.frames[guid].pos ~= x .. -y then
				root.frames[guid]:ClearAllPoints()
				root.frames[guid]:SetPoint("TOPLEFT", root, "TOPLEFT", x, -y)
				root.frames[guid].pos = x .. -y
			end

			-- update sizes if required
			if not root.frames[guid].sizes or root.frames[guid].sizes ~= config.width .. config.height then
				root.frames[guid]:SetWidth(config.width)
				root.frames[guid]:SetHeight(config.height)
				root.frames[guid].sizes = config.width .. config.height
			end

			-- update curses
			local curseNumber = 1

			local guidCurses = Cursive.curses.guids[guid]
			if guidCurses then
				for curseName, curseData in pairs(guidCurses) do
					if curseNumber > 3 then
						break
					end

					local remaining = Cursive.curses:TimeRemaining(curseData)
					local curse = root.frames[guid]["curse" .. curseNumber]
					if remaining >= 0 then
						curse:SetTexture(Cursive.curses.trackedCurseIds[curseData.spellID].texture)
						curse.timer:SetText(remaining)
						curse.timer:Show()
						curse:Show()
					else
						curse.timer:Hide()
						curse:Hide()
					end
					curseNumber = curseNumber + 1
				end
			end

			root.frames[guid]:Show()
		else
			if root.frames[guid] then
				root.frames[guid]:Hide()
				root.frames[guid] = nil
			end
			if not exists then
				-- remove from core
				Cursive.core.remove(guid)
				-- remove from curses
				Cursive.curses:RemoveGuid(guid)
			end
		end
	end

	-- update window size
	root:SetWidth(width)
	root:SetHeight(height)
end)

Cursive.ui = ui
