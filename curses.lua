if not Cursive.nampower then
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
  travelTimeSpellIds = {},
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
  bleedImmuneMobs = { -- populated with mob names that fail VerifyMeleeBleedApplied to allow skipping future bleed checks
  }
}

-- combat events for curses
local fades_test = L["(.+) fades from (.+)"]

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

  -- build travelTimeSpellIds from spell data
  -- travelTime spells must have a damage component otherwise it won't work
  curses.travelTimeSpellIds = {}
  for id, data in pairs(curses.trackedCurseIds) do
    if data.travelTime then
      curses.travelTimeSpellIds[id] = true
    end
  end

  -- register travel time spell tracking
  if next(curses.travelTimeSpellIds) and not Cursive:IsEventRegistered("SPELL_DAMAGE_EVENT_SELF") then
    Cursive:RegisterEvent("SPELL_DAMAGE_EVENT_SELF", function(targetGuid, casterGuid, spellID, amount, mitigationStr, hitInfo, spellSchool, effectAuraStr)
      if curses.travelTimeSpellIds[spellID] and curses.trackedCurseIds[spellID] then
        lastGuid = targetGuid
        local duration = curses:GetCurseDuration(spellID)
        curses:ApplyCurse(spellID, targetGuid, GetTime(), duration)
      end
    end)
  end

	-- load shared debuffs
	curses.sharedDebuffs = getSharedDebuffs()

  -- register faerie fire tracking from other players
  if Cursive.db.profile.shareddebuffs.faeriefire then
    if not Cursive:IsEventRegistered("SPELL_GO_OTHER") then
      Cursive:RegisterEvent("SPELL_GO_OTHER", function(itemId, spellID, casterGuid, targetGuid, castFlags, numTargetsHit, numTargetsMissed)
        if curses.sharedDebuffs.faeriefire[spellID] then
          curses.sharedDebuffGuids.faeriefire[targetGuid] = GetTime()
        end
      end)
    end
  end

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
    local texture = GetSpellIconTexture(GetSpellRecField(id, "spellIconID"))
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

local function VerifyMeleeBleedApplied(targetGuid, spellID)
	local curseData = curses.trackedCurseIds[spellID]
	if not curseData or not curseData.meleeBleed then
		return
	end

	if not curses.guids[targetGuid] or not curses.guids[targetGuid][curseData.name] then
		return
	end

  if not UnitExists(targetGuid) then
    return
  end

  local hasFullBuffsAndDebuffs = true
	local auras = GetUnitField(targetGuid, "aura") or {}
	for i, auraSpellID in pairs(auras) do
		if auraSpellID == spellID then
			return
    elseif auraSpellID <= 0 then
      hasFullBuffsAndDebuffs = false
		end
	end

  local isPounceBleed = false
  if spellID == 9005 or
      spellID == 9823 or
      spellID == 9827 then
    isPounceBleed = true
  end

  -- pounce bleed can fail due to stun immunity as well
  -- skip marking the mob as bleed immune for it
  if not hasFullBuffsAndDebuffs and not isPounceBleed then
    local mobName = UnitName(targetGuid)
    if mobName then
      curses.bleedImmuneMobs[mobName] = true
    end
  end

	curses:RemoveCurse(targetGuid, curseData.name)
end

Cursive:RegisterEvent("SPELLCAST_CHANNEL_START", function()
	curses.isChanneling = true
end);

Cursive:RegisterEvent("SPELLCAST_CHANNEL_STOP", StopChanneling);
Cursive:RegisterEvent("SPELLCAST_INTERRUPTED", StopChanneling);

-- player spell completions
Cursive:RegisterEvent("SPELL_GO_SELF", function(itemId, spellID, casterGuid, targetGuid, castFlags, numTargetsHit, numTargetsMissed)
  if curses.travelTimeSpellIds[spellID] and numTargetsMissed == 0 then
			curses.pendingCast = {
				spellID = spellID,
				targetGuid = targetGuid,
			}
  end

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
      if numTargetsHit > 0 then
        local flame_shock = L["flame shock"]
        if curses:HasCurse(flame_shock, targetGuid, 0) then
          curses.guids[targetGuid][flame_shock]["start"] = GetTime()
        end
      end
    end
  end

  if numTargetsHit > 0 then
    if curses.trackedCurseIds[spellID] and not curses.travelTimeSpellIds[spellID] then
			lastGuid = targetGuid
      local curseData = curses.trackedCurseIds[spellID]
      if curseData.meleeBleed then
        if numTargetsMissed > 0 then
          -- I think this will always mean the bleed missed and we can skip the extra bleed immunity logic
          return
        end
        local mobName = UnitName(targetGuid)
        local isBleedImmuneMob = mobName and mobName ~= "" and curses.bleedImmuneMobs[mobName]
        if not isBleedImmuneMob then
          local duration = curses:GetCurseDuration(spellID)
          curses:ApplyCurse(spellID, targetGuid, GetTime(), duration)
          if not curses.mobsThatBleed[targetGuid] then
            Cursive:ScheduleEvent(VerifyMeleeBleedApplied, 1, targetGuid, spellID)
          end
        end
      else
        local duration = curses:GetCurseDuration(spellID)
        curses:ApplyCurse(spellID, targetGuid, GetTime(), duration)
      end
		elseif curses.conflagrateSpellIds[spellID] then
      curses:UpdateCurse(spellID, targetGuid, GetTime())
		end
  end
end)

-- player spell start (cast time spells)
Cursive:RegisterEvent("SPELL_START_SELF", function(itemId, spellID, casterGuid, targetGuid, castFlags, castTime)
  if curses.trackedCurseIds[spellID] then
    curses.pendingCast = {
      spellID = spellID,
      targetGuid = targetGuid,
    }
  end
end)

-- player spell failure
Cursive:RegisterEvent("SPELL_FAILED_SELF", function(spellID, spellResult, failedByServer)
  if curses.trackedCurseIds[spellID] then
    curses.pendingCast = {}
  end
end)

-- player channel start (dark harvest)
Cursive:RegisterEvent("SPELL_CHANNEL_START", function(spellID, targetGuid, durationMs)
  if curses.darkHarvestSpellIds[spellID] then
    curses.darkHarvestData = {
      spellID = spellID,
      targetGuid = targetGuid,
      castDuration = durationMs / 1000,
      start = GetTime()
    }
	end
end)

Cursive:RegisterEvent("SPELL_MISS_SELF", function(casterGuid, targetGuid, spellID, missInfo)
  curses.pendingCast = {}

  if curses.trackedCurseIds[spellID] and lastGuid then
    if curses:ShouldPlayResistSound(lastGuid) then
      PlaySoundFile("Interface\\AddOns\\Cursive\\Sounds\\resist.mp3")
    end
  end
end)

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
	local currentTime = GetTime()

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

	if curses.trackedCurseIds[curseData.spellID] and curses.trackedCurseIds[curseData.spellID].darkHarvest then
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

function curses:HasCurse(lowercaseSpellNameNoRank, targetGuid, minRemaining, malediction)
	if not minRemaining then
		minRemaining = 0 -- default to 0
	end

	if malediction == nil then
		malediction = 1 -- default to enabled
	end

	-- handle faerie fire special case
	if curses.isDruid and string.find(lowercaseSpellNameNoRank, L["faerie fire"]) then
		-- remove (feral) or (bear) from spell name
		lowercaseSpellNameNoRank = L["faerie fire"]
	end

	-- handle malediction for warlocks
	if curses.isWarlock and malediction ~= 0 and (
			lowercaseSpellNameNoRank == L["curse of recklessness"] or
			lowercaseSpellNameNoRank == L["curse of the elements"] or
			lowercaseSpellNameNoRank == L["curse of shadow"]) then
		local _, _, _, _, hasMalediction = GetTalentInfo(1, 17)
		if hasMalediction > 0 then
			lowercaseSpellNameNoRank = L["curse of agony"]
		end
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

  local curseData = curses.trackedCurseIds[spellID]
  local name = curseData.name
  local rank = curseData.rank

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
