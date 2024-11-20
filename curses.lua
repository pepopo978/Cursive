if not Cursive.superwow then
	return
end
local L = AceLibrary("AceLocale-2.2"):new("Cursive")

local _, playerClassName = UnitClass("player")

local curses = {
	trackedCurseIds = {},
	trackedCurseNamesToTextures = {},
	trackedCurseNameRanksToSpellSlots = {},
	conflagrateSpellIds = {
		[17962] = true,
		[18930] = true,
		[18931] = true,
		[18932] = true,
	},
	guids = {},
	resistSoundGuids = {},
	expiringSoundGuids = {},
	requestedExpiringSoundGuids = {} -- guid added on spellcast, moved to expiringSoundGuids once rendered by ui
}

-- combat events for curses
local afflict_test = "^(.+) is afflicted by (.+) %((%d+)%)" -- for stacks 2-5 will be "Fire Vulnerability (2)".
local gains_test = "^(.+) gains (.+) %((%d+)%)" -- for stacks 2-5 will be "Fire Vulnerability (2)".
local fades_test = L["(.+) fades from (.+)"]
local resist_test = L["Your (.+) was resisted by (.+)"]

local lastGuid = nil

function curses:LoadCurses()
	-- reset dicts
	curses.trackedCurseIds = {}
	curses.trackedCurseNamesToTextures = {}
	curses.trackedCurseNameRanksToSpellSlots = {}

	-- curses to track
	if playerClassName == "WARLOCK" then
		curses.trackedCurseIds = getWarlockSpells()
	elseif playerClassName == "PRIEST" then
		curses.trackedCurseIds = getPriestSpells()
	elseif playerClassName == "MAGE" then
		curses.trackedCurseIds = getMageSpells()
	elseif playerClassName == "DRUID" then
		curses.trackedCurseIds = getDruidSpells()
	elseif playerClassName == "HUNTER" then
		curses.trackedCurseIds = getHunterSpells()
	elseif playerClassName == "ROGUE" then
		curses.trackedCurseIds = getRogueSpells()
	end

	-- go through spell slots and
	local i = 1
	while true do
		local spellname, spellrank = GetSpellName(i, BOOKTYPE_SPELL)
		if not spellname then
			break
		end

		if spellrank == "" then
			spellrank = "Rank 1"
		end

		curses.trackedCurseNameRanksToSpellSlots[spellname .. spellrank] = i
		i = i + 1
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

function curses:ScanTooltipForDuration(curseSpellID)
	-- scan spellbook for duration in case they have haste talent
	local nameRank = curses.trackedCurseIds[curseSpellID].name .. "Rank " .. curses.trackedCurseIds[curseSpellID].rank
	local spellSlot = curses.trackedCurseNameRanksToSpellSlots[nameRank]

	if spellSlot then
		Cursive.core.tooltipScan:SetOwner(Cursive.core.tooltipScan, "ANCHOR_NONE")
		Cursive.core.tooltipScan:ClearLines()
		Cursive.core.tooltipScan:SetSpell(spellSlot, BOOKTYPE_SPELL)
		local numLines = Cursive.core.tooltipScan:NumLines()
		if numLines and numLines > 0 then
			-- get the last line
			local text = getglobal("CursiveTooltipScan" .. "TextLeft" .. numLines):GetText()
			if text then
				local _, _, duration = string.find(text, L["curse_duration_format"])
				if duration then
					return tonumber(duration)
				end
			end
		end
	end

	return curses.trackedCurseIds[curseSpellID].duration
end

function curses:GetCurseDuration(curseSpellID)
	if curses.trackedCurseIds[curseSpellID].variable_duration then
		return curses:ScanTooltipForDuration(curseSpellID)
	end

	return curses.trackedCurseIds[curseSpellID].duration
end

function curses:ScanGuidForCurse(guid, curseSpellID)
	for i = 1, 16 do
		local _, _, _, spellID = UnitDebuff(guid, i)
		if spellID then
			if spellID == curseSpellID then
				return true
			end
		else
			break
		end
	end
	for i = 1, 32 do
		local _, _, spellID = UnitBuff(guid, i)
		if spellID then
			if spellID == curseSpellID then
				return true
			end
		else
			break
		end
	end

	return nil
end

Cursive:RegisterEvent("LEARNED_SPELL_IN_TAB", function()
	-- reload curses in case spell slots changed
	curses:LoadCurses()
end)

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
		elseif curses.conflagrateSpellIds[spellID] then
			-- check if target has immolate
			if curses:HasCurse(L["Immolate"], targetGuid) then
				-- reduce duration by 3 sec
				curses.guids[targetGuid][L["Immolate"]].duration = curses.guids[targetGuid][L["Immolate"]].duration - 3
			end
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
				elseif spell == L["Conflagrate"] and lastGuid then
					if curses:HasCurse(L["Immolate"], lastGuid) then
						-- increase duration by 3 sec to undo the deduction due to resist
						curses.guids[lastGuid][L["Immolate"]].duration = curses.guids[lastGuid][L["Immolate"]].duration + 3
					end
				end
			end
		end
) -- resists

Cursive:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", function(message)
	-- check if spell that faded is relevant
	local _, _, spell, target = string.find(message, fades_test)
	if spell and target then
		if curses.trackedCurseNamesToTextures[spell] then
			-- loop through targets with active curses
			for guid, data in pairs(curses.guids) do
				for curseName, curseData in pairs(data) do
					if curseName == spell then
						-- see if target still has that curse
						if not curses:ScanGuidForCurse(guid, curseData.spellID) then
							-- remove curse
							curses:RemoveCurse(guid, curseName)
						end
					end
				end
			end
		end
	end
end
)

function curses:TimeRemaining(curseData)
	return math.ceil(curseData.duration - (GetTime() - curseData.start))
end

function curses:EnableResistSound(guid)
	curses.resistSoundGuids[guid] = true
end

function curses:EnableExpiringSound(spellNameNoRank, guid)
	if curses.requestedExpiringSoundGuids[guid] and curses.requestedExpiringSoundGuids[guid][spellNameNoRank] then
		curses.requestedExpiringSoundGuids[guid][spellNameNoRank] = nil
	end

	if not curses.expiringSoundGuids[guid] then
		curses.expiringSoundGuids[guid] = {}
	end
	curses.expiringSoundGuids[guid][spellNameNoRank] = true
end

function curses:RequestExpiringSound(spellNameNoRank, guid)
	if not curses.requestedExpiringSoundGuids[guid] then
		curses.requestedExpiringSoundGuids[guid] = {}
	end
	curses.requestedExpiringSoundGuids[guid][spellNameNoRank] = true
end

function curses:HasRequestedExpiringSound(spellNameNoRank, guid)
	return curses.requestedExpiringSoundGuids[guid] and curses.requestedExpiringSoundGuids[guid][spellNameNoRank]
end

function curses:ShouldPlayExpiringSound(spellNameNoRank, guid)
	if curses.expiringSoundGuids[guid] and curses.expiringSoundGuids[guid][spellNameNoRank] then
		curses.expiringSoundGuids[guid][spellNameNoRank] = nil -- remove entry to avoid playing sound multiple times
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

function curses:HasAnyCurse(guid)
	if curses.guids[guid] and next(curses.guids[guid]) then
		return true
	end
	return nil
end

function curses:HasCurse(spellName, targetGuid, minRemaining)
	if not minRemaining then
		minRemaining = 0 -- default to 0
	end

	if curses.guids[targetGuid] and curses.guids[targetGuid][spellName] then
		local remaining = Cursive.curses:TimeRemaining(curses.guids[targetGuid][spellName])
		if remaining > minRemaining then
			return true
		end
	end
	return nil
end

function curses:ApplyCurse(spellID, targetGuid, startTime)
	local name = curses.trackedCurseIds[spellID].name
	local rank = curses.trackedCurseIds[spellID].rank
	local duration = curses:GetCurseDuration(spellID)

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

function curses:RemoveCurse(guid, curseName)
	if curses.guids[guid] and curses.guids[guid][curseName] then
		curses.guids[guid][curseName] = nil
	end
	if curses.expiringSoundGuids[guid] and curses.expiringSoundGuids[guid][curseName] then
		curses.expiringSoundGuids[guid][curseName] = nil
	end
end

function curses:RemoveGuid(guid)
	curses.guids[guid] = nil
	curses.resistSoundGuids[guid] = nil
	curses.expiringSoundGuids[guid] = nil
	curses.requestedExpiringSoundGuids[guid] = nil
end

Cursive.curses = curses
