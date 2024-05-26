local curses = {
	trackedCurseIds = {},
	trackedCurseNamesToTextures = {},
	guids = {},
}
Cursive.curses = curses

-- combat events for curses
local afflict_test = "^(.+) is afflicted by (.+) %((%d+)%)" -- for stacks 2-5 will be "Fire Vulnerability (2)".
local gains_test = "^(.+) gains (.+) %((%d+)%)" -- for stacks 2-5 will be "Fire Vulnerability (2)".
local fades_test = "(.+) fades from (.+)."
local resist_test = "Your (.+) was resisted by (.+)"

local lastGuid = nil

-- curses to track
local _, className = UnitClass("player")
if className == "WARLOCK" then
	curses.trackedCurseIds = getWarlockSpells()
elseif className == "PRIEST" then
	curses.trackedCurseIds = getPriestSpells()
elseif className == "MAGE" then
	curses.trackedCurseIds = getMageSpells()
elseif className == "DRUID" then
	curses.trackedCurseIds = getDruidSpells()
elseif className == "HUNTER" then
	curses.trackedCurseIds = getHunterSpells()
elseif className == "ROGUE" then
	curses.trackedCurseIds = getRogueSpells()
end

curses.trackedCurseNamesToTextures = {}
for id, data in pairs(curses.trackedCurseIds) do
	-- get the texture
	local name, rank, texture = SpellInfo(id)
	-- update trackedCurseNamesToTextures
	curses.trackedCurseNamesToTextures[data.name] = texture
	-- update trackedCurseIds
	curses.trackedCurseIds[id].texture = texture
end

Cursive:RegisterEvent("UNIT_CASTEVENT", function(casterGuid, targetGuid, event, spellID, castDuration)
	-- immolate will fire both start and cast
	if event == "CAST" then
		local _, guid = UnitExists("player")
		if casterGuid ~= guid then
			return
		end

		if curses.trackedCurseIds[spellID] then
			lastGuid = targetGuid
			Cursive:ScheduleEvent("addCurse" .. targetGuid .. curses.trackedCurseIds[spellID].name, curses.ApplyCurse, 0.2, self, spellID, targetGuid, GetTime())
		end
	end
end)

Cursive:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE",
		function(message)
			-- check for resist
			local _, _, spell, target = string.find(message, resist_test)
			if spell and target then
				if curses.trackedCurseNamesToTextures[spell] and lastGuid then
					Cursive:CancelScheduledEvent("addCurse" .. lastGuid .. spell)
				end
			end
		end
) -- resists

function curses:TimeRemaining(curseData)
	return math.ceil(curseData.duration - (GetTime() - curseData.start))
end

function curses:HasCurse(spellName, targetGuid)
	if curses.guids[targetGuid] and curses.guids[targetGuid][spellName] then
		local remaining = Cursive.curses:TimeRemaining(curses.guids[targetGuid][spellName])
		return remaining > 0
	end
	return false
end

function curses:ApplyCurse(spellID, targetGuid, startTime)
	local name = curses.trackedCurseIds[spellID].name
	local rank = curses.trackedCurseIds[spellID].rank
	local duration = curses.trackedCurseIds[spellID].duration

	if not curses.guids[targetGuid] then
		curses.guids[targetGuid] = {}
	end

	curses.guids[targetGuid][name] = {
		rank = rank,
		duration = duration,
		start = startTime,
		spellID = spellID,
	}
end

function curses:RemoveGuid(guid)
	curses.guids[guid] = nil
end
