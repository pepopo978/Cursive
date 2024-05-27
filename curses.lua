if not Cursive.superwow then
	return
end

local curses = {
	trackedCurseIds = {},
	trackedCurseNamesToTextures = {},
	guids = {},
	resistSoundGuids = {},
	expiringSoundGuids = {},
	requestedExpiringSoundGuids = {} -- guid added on spellcast, moved to expiringSoundGuids once rendered by ui
}

-- combat events for curses
local afflict_test = "^(.+) is afflicted by (.+) %((%d+)%)" -- for stacks 2-5 will be "Fire Vulnerability (2)".
local gains_test = "^(.+) gains (.+) %((%d+)%)" -- for stacks 2-5 will be "Fire Vulnerability (2)".
local fades_test = "(.+) fades from (.+)."
local resist_test = "Your (.+) was resisted by (.+)"

local lastGuid = nil

function curses:LoadCurses()
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

	for id, data in pairs(curses.trackedCurseIds) do
		-- get the texture
		local name, rank, texture = SpellInfo(id)
		-- update trackedCurseNamesToTextures
		curses.trackedCurseNamesToTextures[data.name] = texture
		-- update trackedCurseIds
		curses.trackedCurseIds[id].texture = texture
	end
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
					-- check if sound should be played
					if curses:ShouldPlayResistSound(lastGuid) then
						PlaySoundFile("Interface\\AddOns\\Cursive\\Sounds\\resist.mp3")
					end
				end
			end
		end
) -- resists

function curses:TimeRemaining(curseData)
	return math.ceil(curseData.duration - (GetTime() - curseData.start))
end

function curses:EnableResistSound(guid)
	curses.resistSoundGuids[guid] = true
end

function curses:EnableExpiringSound(spellName, guid)
	if curses.requestedExpiringSoundGuids[guid] and curses.requestedExpiringSoundGuids[guid][spellName] then
		curses.requestedExpiringSoundGuids[guid][spellName] = nil
	end

	if not curses.expiringSoundGuids[guid] then
		curses.expiringSoundGuids[guid] = {}
	end
	curses.expiringSoundGuids[guid][spellName] = true
end

function curses:RequestExpiringSound(spellName, guid)
	if not curses.requestedExpiringSoundGuids[guid] then
		curses.requestedExpiringSoundGuids[guid] = {}
	end
	curses.requestedExpiringSoundGuids[guid][spellName] = true
end

function curses:HasRequestedExpiringSound(spellName, guid)
	return curses.requestedExpiringSoundGuids[guid] and curses.requestedExpiringSoundGuids[guid][spellName]
end

function curses:ShouldPlayExpiringSound(spellName, guid)
	if curses.expiringSoundGuids[guid] and curses.expiringSoundGuids[guid][spellName] then
		curses.expiringSoundGuids[guid][spellName] = nil -- remove entry to avoid playing sound multiple times
		return true
	end

	return false
end

function curses:ShouldPlayResistSound(guid)
	if curses.resistSoundGuids[guid] then
		curses.resistSoundGuids[guid] = nil -- remove entry to avoid playing sound multiple times
		return true
	end

	return false
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
	curses.resistSoundGuids[guid] = nil
	curses.expiringSoundGuids[guid] = nil
	curses.requestedExpiringSoundGuids[guid] = nil
end

Cursive.curses = curses
