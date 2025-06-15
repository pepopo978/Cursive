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
	darkHarvestSpellIds = {
		[52550] = true,
		[52551] = true,
		[52552] = true,
	},
	darkHarvestData = {},
	guids = {},
	isChanneling = false,
	pendingCast = {},
	resistSoundGuids = {},
	expiringSoundGuids = {},
	requestedExpiringSoundGuids = {}, -- guid added on spellcast, moved to expiringSoundGuids once rendered by ui

	sharedDebuffs = {
		faeriefire = {},
	},
	sharedDebuffGuids = {
		faeriefire = {}, -- used for scanning for shared debuffs like faerie fire
	}, -- used for scanning for shared debuffs like faerie fire
}

-- combat events for curses
local fades_test = L["(.+) fades from (.+)"]
local resist_test = L["Your (.+) was resisted by (.+)"]
local missed_test = L["Your (.+) missed (.+)"]
local parry_test = L["Your (.+) is parried by (.+)"]
local immune_test = L["Your (.+) fail.+\. (.+) is immune"]
local block_test = L["Your (.+) was blocked by (.+)"]
local dodge_test = L["Your (.+) was dodged by (.+)"]

local lastGuid = nil

function curses:LoadCurses()
	-- reset dicts
	curses.trackedCurseIds = {}
	curses.trackedCurseNamesToTextures = {}
	curses.trackedCurseNameRanksToSpellSlots = {}

	curses.isWarlock = playerClassName == "WARLOCK"
	curses.isPriest = playerClassName == "PRIEST"
	curses.isMage = playerClassName == "MAGE"
	curses.isDruid = playerClassName == "DRUID"
	curses.isHunter = playerClassName == "HUNTER"
	curses.isRogue = playerClassName == "ROGUE"
	curses.isShaman = playerClassName == "SHAMAN"
	curses.isWarrior = playerClassName == "WARRIOR"


	-- curses to track
	if curses.isWarlock then
		curses.trackedCurseIds = getWarlockSpells()
	elseif curses.isPriest then
		curses.trackedCurseIds = getPriestSpells()
	elseif curses.isMage then
		curses.trackedCurseIds = getMageSpells()
	elseif curses.isDruid then
		curses.trackedCurseIds = getDruidSpells()
	elseif curses.isHunter then
		curses.trackedCurseIds = getHunterSpells()
	elseif curses.isRogue then
		curses.trackedCurseIds = getRogueSpells()
	elseif curses.isShaman then
		curses.trackedCurseIds = getShamanSpells()
	elseif curses.isWarrior then
		curses.trackedCurseIds = getWarriorSpells()
	end

	-- load shared debuffs
	curses.sharedDebuffs = getSharedDebuffs()

	-- go through spell slots and
	local i = 1
	while true do
		local spellname, spellrank = GetSpellName(i, BOOKTYPE_SPELL)
		if not spellname then
			break
		end

		if spellrank == "" then
			spellrank = L["Rank 1"]
		end

		curses.trackedCurseNameRanksToSpellSlots[string.lower(spellname) .. spellrank] = i
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
	local nameRank = curses.trackedCurseIds[curseSpellID].name .. L["Rank"] .. " " .. curses.trackedCurseIds[curseSpellID].rank
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
	if curses.trackedCurseIds[curseSpellID].variableDuration then
		return curses:ScanTooltipForDuration(curseSpellID)
	end

	return curses.trackedCurseIds[curseSpellID].duration
end

function curses:ScanGuidForCurse(guid, curseSpellID)
	for i = 1, 64 do
		local _, _, _, spellID = UnitDebuff(guid, i)
		if spellID then
			if spellID == curseSpellID then
				return true
			end
		else
			break
		end
	end
	for i = 1, 64 do
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

local function StopChanneling()
	curses.isChanneling = false
end

Cursive:RegisterEvent("SPELLCAST_CHANNEL_START", function()
	curses.isChanneling = true
end);
Cursive:RegisterEvent("SPELLCAST_CHANNEL_STOP", StopChanneling);
Cursive:RegisterEvent("SPELLCAST_INTERRUPTED", StopChanneling);
Cursive:RegisterEvent("SPELLCAST_FAILED", StopChanneling);

Cursive:RegisterEvent("UNIT_CASTEVENT", function(casterGuid, targetGuid, event, spellID, castDuration)
	-- immolate will fire both start and cast
	if event == "CAST" then
		local _, guid = UnitExists("player")
		if casterGuid ~= guid then
			-- check for faeriefire
			if Cursive.db.profile.shareddebuffs.faeriefire and curses.sharedDebuffs.faeriefire[spellID] then
				curses.sharedDebuffGuids.faeriefire[targetGuid] = GetTime()
			end

			return
		end

		-- store pending cast
		curses.pendingCast = {
			spellID = spellID,
			targetGuid = targetGuid,
			castDuration = castDuration
		}

		if curses.trackedCurseIds[spellID] then
			lastGuid = targetGuid
			Cursive:ScheduleEvent("addCurse" .. targetGuid .. curses.trackedCurseIds[spellID].name, curses.ApplyCurse, 0.2, self, spellID, targetGuid, GetTime())
		elseif curses.conflagrateSpellIds[spellID] then
			Cursive:ScheduleEvent("updateCurse" .. targetGuid .. L["conflagrate"], curses.UpdateCurse, 0.2, self, spellID, targetGuid, GetTime())
		end
	elseif event == "START" then
		if curses.trackedCurseIds[spellID] then
			local _, guid = UnitExists("player")
			if casterGuid ~= guid then
				return
			end

			-- store pending cast
			curses.pendingCast = {
				spellID = spellID,
				targetGuid = targetGuid,
				castDuration = castDuration
			}
		end
	elseif event == "FAIL" then
		if curses.trackedCurseIds[spellID] then
			local _, guid = UnitExists("player")
			if casterGuid ~= guid then
				return
			end
			-- clear pending cast
			curses.pendingCast = {}
		end
	elseif event == "CHANNEL" then
		-- dark harvest
		if curses.darkHarvestSpellIds[spellID] then
			local _, guid = UnitExists("player")
			if casterGuid ~= guid then
				return
			end

			curses.darkHarvestData = {
				spellID = spellID,
				targetGuid = targetGuid,
				castDuration = curses:ScanTooltipForDuration(spellID),
				start = GetTime()
			}
		end
	end
end)

Cursive:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE",
		function(message)
			local spell_failed_tests = {
				resist_test,
				immune_test
			}
			-- only some classes have melee spells that need to check for dodge, parry, miss, block
			if playerClassName == "DRUID" or playerClassName == "HUNTER" or playerClassName == "ROGUE" then
				spell_failed_tests = {
					resist_test,
					immune_test,
					missed_test,
					parry_test,
					block_test,
					dodge_test
				}
			end

			local spellName, target
			for _, test in pairs(spell_failed_tests) do
				local _, _, foundSpell, foundTarget = string.find(message, test)
				if foundSpell and foundTarget then
					spellName = foundSpell
					target = foundTarget
					break
				end
			end

			if spellName and target then
				spellName = string.lower(spellName)

				-- clear pending cast
				curses.pendingCast = {}

				if curses.trackedCurseNamesToTextures[spellName] and lastGuid then
					Cursive:CancelScheduledEvent("addCurse" .. lastGuid .. spellName)
					-- check if sound should be played
					if curses:ShouldPlayResistSound(lastGuid) then
						PlaySoundFile("Interface\\AddOns\\Cursive\\Sounds\\resist.mp3")
					end
				elseif spellName == L["conflagrate"] and lastGuid then
					Cursive:CancelScheduledEvent("updateCurse" .. lastGuid .. spellName)
				end
			end
		end
) -- resists

Cursive:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", function(message)
	-- check if spell that faded is relevant
	local _, _, spellName, target = string.find(message, fades_test)
	if spellName and target then
		spellName = string.lower(spellName)
		if curses.trackedCurseNamesToTextures[spellName] then
			-- loop through targets with active curses
			for guid, data in pairs(curses.guids) do
				for curseName, curseData in pairs(data) do
					if curseName == spellName then
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

function curses:GetLastTickTime(curseData)
	local ticks = curses.trackedCurseIds[curseData.spellID].numTicks
	if not ticks then
		return GetTime()
	end

	local tickTime = curseData.duration / ticks
	local currentTime = GetTime() + tickTime * .2 -- dh won't apply to previous tick if within 20% of tick time

	return math.floor((currentTime - curseData.start) / tickTime) * tickTime + curseData.start
end

function curses:TrackDarkHarvest(curseData)
	if curses.darkHarvestData["targetGuid"] and curses.darkHarvestData["targetGuid"] == curseData["targetGuid"] then
		local dhActive = false
		-- check if still channeling
		if curses.isChanneling then
			local dhTimeRemaining = curses.darkHarvestData.castDuration - (GetTime() - curses.darkHarvestData.start)
			-- check if dh still active based on cast duration
			if dhTimeRemaining > 0 then
				dhActive = true
				-- dh is active
				if not curseData["dhStartTime"] then
					curseData["dhStartTime"] = curses:GetLastTickTime(curseData) -- dh will reduce full tick duration
				end
			end
		end
		if curseData["dhStartTime"] and dhActive == false and not curseData["dhEndTime"] then
			-- if dh no longer active, store end time if not already stored
			curseData["dhEndTime"] = GetTime()
		end
	end
end

function curses:GetDarkHarvestReduction(curseData)
	if curseData["dhStartTime"] then
		local endTime = curseData["dhEndTime"] or GetTime()
		local dhActiveTime = endTime - curseData["dhStartTime"]
		if dhActiveTime > 0 then
			return dhActiveTime * .3 -- 30% reduction
		end
	end
	return 0
end

function curses:TimeRemaining(curseData)
	local dhReduction = 0

	if curses.trackedCurseIds[curseData.spellID].darkHarvest then
		curses:TrackDarkHarvest(curseData)

		dhReduction = curses:GetDarkHarvestReduction(curseData)
	end

	local remaining = curseData.duration - (GetTime() - curseData.start) - dhReduction
	if Cursive.db.profile.curseshowdecimals and remaining < 10 then
		-- round to 1 decimal point
		remaining = math.floor(remaining * 10) / 10
	else
		remaining = math.ceil(remaining)
	end

	return remaining
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

	-- handle faerie fire special case
	if curses.isDruid and string.find(spellName, L["faerie fire"]) then
		-- remove (feral) or (bear) from spell name
		spellName = L["faerie fire"]
	end

	if curses.guids[targetGuid] and curses.guids[targetGuid][spellName] then
		local remaining = Cursive.curses:TimeRemaining(curses.guids[targetGuid][spellName])
		if remaining > minRemaining then
			return true
		end
	end

	-- check pending cast
	if curses.pendingCast and
			curses.pendingCast.targetGuid == targetGuid and
			curses.pendingCast.spellID and
			curses.trackedCurseIds[curses.pendingCast.spellID] and
			curses.trackedCurseIds[curses.pendingCast.spellID].name == spellName then
		return true
	end

	return nil
end

-- Apply shared curse from another player
function curses:ApplySharedCurse(sharedDebuffKey, spellID, targetGuid, startTime)
	local name = curses.sharedDebuffs[sharedDebuffKey][spellID].name
	local rank = curses.sharedDebuffs[sharedDebuffKey][spellID].rank
	local duration = curses.sharedDebuffs[sharedDebuffKey][spellID].duration

	if not curses.guids[targetGuid] then
		curses.guids[targetGuid] = {}
	end

	curses.guids[targetGuid][name] = {
		rank = rank,
		duration = duration,
		start = startTime,
		spellID = spellID,
		targetGuid = targetGuid,
		currentPlayer = false,
	}
end

-- Apply curse from player
function curses:ApplyCurse(spellID, targetGuid, startTime)
	-- clear pending cast
	curses.pendingCast = {}

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
		targetGuid = targetGuid,
		currentPlayer = true,
	}
end

function curses:UpdateCurse(spellID, targetGuid, startTime)
	-- clear pending cast
	curses.pendingCast = {}

	if curses.conflagrateSpellIds[spellID] then
		-- check if target has immolate
		if curses:HasCurse(L["immolate"], targetGuid) then
			-- reduce duration by 3 sec
			curses.guids[targetGuid][L["immolate"]].duration = curses.guids[targetGuid][L["immolate"]].duration - 3
		end
	end
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
