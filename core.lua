if not Cursive.superwow then
	return
end

-- add (1) for first stack of buffs/debuffs
-- other addons already do this, avoid having to parse both formats
AURAADDEDOTHERHELPFUL = "%s gains %s (1)."
AURAADDEDOTHERHARMFUL = "%s is afflicted by %s (1)."
AURAADDEDSELFHARMFUL = "You are afflicted by %s (1)."
AURAADDEDSELFHELPFUL = "You gain %s (1)."

Cursive.core = CreateFrame("Frame", "Cursive", UIParent)

Cursive.core.tooltipScan = CreateFrame("GameTooltip", "CursiveTooltipScan", UIParent, "GameTooltipTemplate")

Cursive.core.guids = {}

Cursive.core.add = function(unit)
	local _, guid = UnitExists(unit)

	if guid and not UnitIsDead(unit) then
		Cursive.core.guids[guid] = GetTime()
	end
end

Cursive.core.addGuid = function(guid)
	-- check if first two characters are 0x
	if string.sub(guid, 1, 2) ~= "0x" then
		return
	end
	if UnitExists(guid) and not UnitIsDead(guid) then
		Cursive.core.guids[guid] = GetTime()
	end
end

Cursive.core.remove = function(guid)
	Cursive.core.guids[guid] = nil
end

Cursive.core.enable = function()
	-- unitstr
	Cursive.core:RegisterEvent("PLAYER_TARGET_CHANGED")
	-- arg1
	Cursive.core:RegisterEvent("UNIT_COMBAT") -- this can get called with player/target/raid1 etc
	Cursive.core:RegisterEvent("UNIT_MODEL_CHANGED")
end

Cursive.core.disable = function()
	Cursive.core:UnregisterAllEvents()
	Cursive.core.guids = {}
end

Cursive.core:SetScript("OnEvent", function()
	if event == "PLAYER_TARGET_CHANGED" then
		this.add("target")
	else
		-- arg1 is guid
		this.addGuid(arg1)
	end
end)
