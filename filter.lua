if not Cursive.superwow then
	return
end

local filter = {}

filter.attackable = function(unit)
	return UnitCanAttack("player", unit) and true or false
end

filter.infight = function(unit)
	return UnitAffectingCombat(unit) and true or false
end

filter.hascurse = function(unit)
	return Cursive.curses:HasAnyCurse(unit) and true or false
end

filter.alive = function(unit)
	return not UnitIsDead(unit) and true or false
end

filter.range = function(unit)
	if IsSpellInRange then
		-- 16707 is hex which has 45 yd range
		return IsSpellInRange(16707, unit) == 1 and true or false
	else
		return CheckInteractDistance(unit, 4) and true or false
	end
end

filter.icon = function(unit)
	return GetRaidTargetIndex(unit) and true or false
end

filter.normal = function(unit)
	local elite = UnitClassification(unit)
	return elite == "normal" and true or false
end

filter.elite = function(unit)
	local elite = UnitClassification(unit)
	return (elite == "elite" or elite == "rareelite") and true or false
end

filter.hostile = function(unit)
	return UnitIsEnemy("player", unit) and true or false
end

filter.range = function(unit)
	return CheckInteractDistance(unit, 4) and true or false
end

Cursive.filter = filter

function Cursive:ShouldDisplayGuid(guid)
	-- never display units that don't exist
	if not UnitExists(guid) then
		return false
	end

	-- never display dead units
	if not Cursive.filter.alive(guid) then
		return false
	end

	local _, targetGuid = UnitExists("target")

	-- always show target if attackable
	if (targetGuid == guid) and filter.attackable(guid) then
		return true
	end

	-- always show raid marks if attackable and not in combat or this guid is affecting combat
	if filter.icon(guid) and filter.attackable(guid) and (not UnitAffectingCombat("player") or UnitAffectingCombat(guid)) then
		return true
	end

	-- apply filters
	local shouldDisplay = true -- default to true

	if Cursive.db.profile.filterincombat then
		shouldDisplay = shouldDisplay and filter.infight(guid)
	end

	if Cursive.db.profile.filterhascurse then
		shouldDisplay = shouldDisplay and filter.hascurse(guid)
	end

	if Cursive.db.profile.filterhostile then
		shouldDisplay = shouldDisplay and filter.hostile(guid)
	end

	if Cursive.db.profile.filterattackable then
		shouldDisplay = shouldDisplay and filter.attackable(guid)
	end

	if Cursive.db.profile.filterrange then
		shouldDisplay = shouldDisplay and filter.range(guid)
	end

	if Cursive.db.profile.filterraidmark then
		shouldDisplay = shouldDisplay and filter.icon(guid)
	end

	return shouldDisplay
end
