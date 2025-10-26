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
	previousComboPoints = 0,
	comboPoints = 0,
	lastFerociousBiteTime = 0,
	lastFerociousBiteTargetGuid = 0,
	lastMoltenBlastTargetGuid = 0,

	sharedDebuffs = {
		faeriefire = {},
	},
	sharedDebuffGuids = {
		faeriefire = {}, -- used for scanning for shared debuffs like faerie fire
	}, -- used for scanning for shared debuffs like faerie fire

	-- Whitelist of mobs that can bleed (for rake tracking at client debuff cap)
	mobsThatBleed = {
		["0xF13000F1F3276A33"] = true, -- Keeper Gnarlmoon
		["0xF13000F1FA276A32"] = true, -- Ley-Watcher Incantagos
		["0xF13000EA3F276C05"] = true, -- King
		["0xF13000EA31279058"] = true, -- Queen
		["0xF13000EA43276C06"] = true, -- Bishop
		["0xF13000EA44279044"] = true, -- Pawn
		["0xF13000EA42276C07"] = true, -- Rook
		["0xF13000EA4D05DA44"] = true, -- Sanv Tas'dal
		["0xF13000EA57276C04"] = true, -- Kruul
		["0xF130016C95276DAF"] = true, -- Mephistroth

		["0xF130003E5401591A"] = true, --Anub'Rekhan
		["0xF130003E510159B0"] = true, --Grand Widow Faerlina
		["0xF130003E500159A3"] = true, --Maexxna
		["0xF130003EBD01598C"] = true, --Razuvious
		["0xF130003EBC01599F"] = true, --Gothik
		["0xF130003EBF015AB2"] = true, --Zeliek
		["0xF130003EBE015AB3"] = true, --Mograine
		["0xF130003EC1015AB1"] = true, --Blaumeux
		["0xF130003EC0015AB0"] = true, --Thane
		["0xF130003E52015824"] = true, --Noth
		["0xF130003E4001588D"] = true, --Heigan
		["0xF130003E8B0158A2"] = true, --Loatheb
		["0xF130003E9C0158EA"] = true, --Patchwerk
		["0xF130003E3B0158EF"] = true, --Grobbulus
		["0xF130003E3C0158F0"] = true, --Gluth
		["0xF130003E380159A0"] = true, --Thaddius
		["0xF130003E75015AB4"] = true, --Sapphiron
		["0xF130003E76015AED"] = true, --Kel'Thuzad
	},
}

-- combat events for curses
local fades_test = L["(.+) fades from (.+)"]
local resist_test = L["Your (.+) was resisted by (.+)"]
local missed_test = L["Your (.+) missed (.+)"]
local parry_test = L["Your (.+) is parried by (.+)"]
local immune_test = L["Your (.+) fail.+\. (.+) is immune"]
local block_test = L["Your (.+) was blocked by (.+)"]
local dodge_test = L["Your (.+) was dodged by (.+)"]

local molten_blast_test = L["Your Molten Blast(.+)for .+ Fire damage"]

local lastGuid = nil

-- I think depending on ping the combo point used event can fire either before or after your ability cast
function curses:GetComboPointsUsed()
	if curses.comboPoints == 0 then
		return curses.previousComboPoints
	else
		return curses.comboPoints
	end
end


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

	if curses.isDruid or curses.isRogue then
		Cursive:RegisterEvent("PLAYER_COMBO_POINTS", function()
			local currentComboPoints = GetComboPoints()
			if curses.isDruid and currentComboPoints >= curses.comboPoints then
				-- combo points did not decrease, check if Ferocious Bite was used is the last .5 sec
				if GetTime() - curses.lastFerociousBiteTime < 0.5 and
						curses.lastFerociousBiteTargetGuid and
						curses.lastFerociousBiteTargetGuid ~= 0 then

					-- check if Rip active
					local rip = L["rip"]
					if curses:HasCurse(rip, curses.lastFerociousBiteTargetGuid, 0) then
						curses.guids[curses.lastFerociousBiteTargetGuid][rip]["start"] = GetTime() -- reset start time to current time
					end

					-- check if Rake active
					local rake = L["rake"]
					if curses:HasCurse(rake, curses.lastFerociousBiteTargetGuid, 0) then
						curses.guids[curses.lastFerociousBiteTargetGuid][rake]["start"] = GetTime() -- reset start time to current time
					end
				end
			end
			curses.previousComboPoints = curses.comboPoints
			curses.comboPoints = currentComboPoints
		end)
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
	elseif curses.trackedCurseIds[curseSpellID].calculateDuration then
		return curses.trackedCurseIds[curseSpellID].calculateDuration()
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

function curses:GetLowercaseSpellName(spellName)
	spellName = string.lower(spellName)

	-- handle faerie fire special case
	if curses.isDruid and string.find(spellName, L["faerie fire"]) then
		return L["faerie fire"]
	end

	return spellName
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

		if curses.isDruid then
			-- track ferocious bite cast time and target
			if spellID == 22557 or
					spellID == 22568 or
					spellID == 22827 or
					spellID == 22828 or
					spellID == 22829 or
					spellID == 31018 then
				curses.lastFerociousBiteTime = GetTime()
				curses.lastFerociousBiteTargetGuid = targetGuid
			end
		end

		if curses.isShaman then
			if spellID >= 36916 and spellID <= 36921 then
				curses.lastMoltenBlastTargetGuid = targetGuid
			end
		end

		-- delay to check for resists/failures
		local delay = 0.2

		local _, _, nping = GetNetStats()
		-- ignore extreme pings
		if nping and nping > 0 and nping < 500 then
			delay = 0.05 + (nping / 1000.0) -- convert to seconds
		end

		if curses.trackedCurseIds[spellID] then
			lastGuid = targetGuid
			local duration = curses:GetCurseDuration(spellID) - delay
			Cursive:ScheduleEvent("addCurse" .. targetGuid .. curses.trackedCurseIds[spellID].name, curses.ApplyCurse, delay, self, spellID, targetGuid, GetTime(), duration)
		elseif curses.conflagrateSpellIds[spellID] then
			Cursive:ScheduleEvent("updateCurse" .. targetGuid .. L["conflagrate"], curses.UpdateCurse, delay, self, spellID, targetGuid, GetTime())
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

			local spellName, failedTarget
			for _, test in pairs(spell_failed_tests) do
				local _, _, foundSpell, foundTarget = string.find(message, test)
				if foundSpell and foundTarget then
					spellName = foundSpell
					failedTarget = foundTarget
					break
				end
			end

			if spellName and failedTarget then
				spellName = curses:GetLowercaseSpellName(spellName)

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
				return
			end

			if curses.isShaman and string.find(message, molten_blast_test) then
				local flame_shock = L["flame shock"]
				if curses:HasCurse(flame_shock, curses.lastMoltenBlastTargetGuid, 0) then
					curses.guids[curses.lastMoltenBlastTargetGuid][flame_shock]["start"] = GetTime() -- reset start time to current time
				end
			end
		end
) -- resists

Cursive:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", function(message)
	-- check if spell that faded is relevant
	local _, _, spellName, target = string.find(message, fades_test)
	if spellName and target then
		spellName = curses:GetLowercaseSpellName(spellName)
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

function curses:EnableExpiringSound(lowercaseSpellNameNoRank, guid)
	if curses.requestedExpiringSoundGuids[guid] and curses.requestedExpiringSoundGuids[guid][lowercaseSpellNameNoRank] then
		curses.requestedExpiringSoundGuids[guid][lowercaseSpellNameNoRank] = nil
	end

	if not curses.expiringSoundGuids[guid] then
		curses.expiringSoundGuids[guid] = {}
	end
	curses.expiringSoundGuids[guid][lowercaseSpellNameNoRank] = true
end

function curses:RequestExpiringSound(lowercaseSpellNameNoRank, guid)
	if not curses.requestedExpiringSoundGuids[guid] then
		curses.requestedExpiringSoundGuids[guid] = {}
	end
	curses.requestedExpiringSoundGuids[guid][lowercaseSpellNameNoRank] = true
end

function curses:HasRequestedExpiringSound(lowercaseSpellNameNoRank, guid)
	return curses.requestedExpiringSoundGuids[guid] and curses.requestedExpiringSoundGuids[guid][lowercaseSpellNameNoRank]
end

function curses:ShouldPlayExpiringSound(lowercaseSpellNameNoRank, guid)
	if curses.expiringSoundGuids[guid] and curses.expiringSoundGuids[guid][lowercaseSpellNameNoRank] then
		curses.expiringSoundGuids[guid][lowercaseSpellNameNoRank] = nil -- remove entry to avoid playing sound multiple times
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

function curses:GetCurseData(spellName, guid)
	-- convert to lowercase and remove rank
	local lowercaseSpellNameNoRank = Cursive.utils.GetLowercaseSpellNameNoRank(spellName)

	if curses.guids[guid] and curses.guids[guid][lowercaseSpellNameNoRank] then
		return curses.guids[guid][lowercaseSpellNameNoRank]
	end

	return nil
end

function curses:HasCurse(lowercaseSpellNameNoRank, targetGuid, minRemaining)
	if not minRemaining then
		minRemaining = 0 -- default to 0
	end

	-- handle faerie fire special case
	if curses.isDruid and string.find(lowercaseSpellNameNoRank, L["faerie fire"]) then
		-- remove (feral) or (bear) from spell name
		lowercaseSpellNameNoRank = L["faerie fire"]
	end

	if curses.guids[targetGuid] and curses.guids[targetGuid][lowercaseSpellNameNoRank] then
		local remaining = Cursive.curses:TimeRemaining(curses.guids[targetGuid][lowercaseSpellNameNoRank])
		if remaining >= minRemaining then
			return true
		end
	end

	-- check pending cast
	if curses.pendingCast and
			curses.pendingCast.targetGuid == targetGuid and
			curses.pendingCast.spellID and
			curses.trackedCurseIds[curses.pendingCast.spellID] and
			curses.trackedCurseIds[curses.pendingCast.spellID].name == lowercaseSpellNameNoRank then
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
function curses:ApplyCurse(spellID, targetGuid, startTime, duration)
	-- clear pending cast
	curses.pendingCast = {}

	local name = curses.trackedCurseIds[spellID].name
	local rank = curses.trackedCurseIds[spellID].rank

	if curses.isDruid and name == L["rake"] then
		-- check if mob is in bleed whitelist first
		-- these bosses are most likely to hit 48 client debuff cap
		if not curses.mobsThatBleed[targetGuid] then
			if not curses:ScanGuidForCurse(targetGuid, spellID) then
				-- rake not found on target, do not apply
				return
			end
		end
	end

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
