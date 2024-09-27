local L = AceLibrary("AceLocale-2.2"):new("Cursive")
local curseCommands = L["|cffffcc00Cursive:|cffffaaaa Commands:"]
local priorityChoices = L["|cffffcc00Priority choices:"]
local curseOptions = L["|cffffcc00Options (separate with ,):"]

local commandOptions = {
	warnings = L["Display text warnings when a curse fails to cast."],
	resistsound = L["Play a sound when a curse is resisted."],
	expiringsound = L["Play a sound when a curse is about to expire."],
	allowooc = L["Allow out of combat targets to be multicursed.  Would only consider using this solo to avoid potentially griefing raids/dungeons by pulling unintended mobs."],
	minhp = L["Minimum HP for a target to be considered.  Example usage minhp=10000. "],
	refreshtime = L["Time threshold at which to allow refreshing a curse.  Default is 0 seconds."]
}

local commands = {
	["curse"] = L["/cursive curse <spellName:str>|<guid?:str>|<options?:List<str>>: Casts spell if not already on target/guid"],
	["multicurse"] = L["/cursive multicurse <spellName:str>|<priority?:str>|<options?:List<str>>: Picks target based on priority and casts spell if not already on target"],
}

local PRIORITY_HIGHEST_HP = "HIGHEST_HP"
local PRIORITY_RAID_MARK = "RAID_MARK"
local PRIORITY_RAID_MARK_SQUARE = "RAID_MARK_SQUARE"
local PRIORITY_INVERSE_RAID_MARK = "INVERSE_RAID_MARK"
local PRIORITY_HIGHEST_HP_RAID_MARK = "HIGHEST_HP_RAID_MARK"
local PRIORITY_HIGHEST_HP_RAID_MARK_SQUARE = "HIGHEST_HP_RAID_MARK_SQUARE"
local PRIORITY_HIGHEST_HP_INVERSE_RAID_MARK = "HIGHEST_HP_INVERSE_RAID_MARK"

local priorities = {
	[PRIORITY_HIGHEST_HP] = L["Target with the highest HP."],
	[PRIORITY_RAID_MARK] = L["Target with the highest raid mark."],
	[PRIORITY_RAID_MARK_SQUARE] = L["Target with the highest raid mark with Cross set to -1 and Skull set to -2 (Square highest prio at 6)."],
	[PRIORITY_INVERSE_RAID_MARK] = L["Target with the lowest raid mark."],
	[PRIORITY_HIGHEST_HP_RAID_MARK] = L["Target with the highest HP and raid mark."],
	[PRIORITY_HIGHEST_HP_RAID_MARK_SQUARE] = L["Same as HIGHEST_HP_RAID_MARK but with RAID_MARK_SQUARE mark prio."],
	[PRIORITY_HIGHEST_HP_INVERSE_RAID_MARK] = L["Same as HIGHEST_HP_RAID_MARK but with INVERSE_RAID_MARK mark prio."]
}

local curseNoTarget = L["|cffffcc00Cursive:|cffffaaaa Couldn't find a target to curse."]

local function parseOptions(optionsStr)
	local options = {  }

	if optionsStr then
		for option, _ in pairs(commandOptions) do
			-- special case for minhp as it takes a param
			if option == "minhp" then
				local _, _, minHp = string.find(optionsStr, "minhp=(%d+)")
				if minHp then
					options["minhp"] = tonumber(minHp)
				end
			elseif option == "refreshtime" then
				local _, _, refreshTime = string.find(optionsStr, "refreshtime=(%d+)")
				if refreshTime then
					options["refreshtime"] = tonumber(refreshTime)
				end
			elseif string.find(optionsStr, option) then
				options[option] = true
			end
		end
	end

	return options
end

local function handleSlashCommands(msg, editbox)
	if not msg or msg == "" then
		DEFAULT_CHAT_FRAME:AddMessage(curseCommands)
		for command, description in pairs(commands) do
			DEFAULT_CHAT_FRAME:AddMessage(description)
		end
		DEFAULT_CHAT_FRAME:AddMessage(priorityChoices)
		for priority, description in pairs(priorities) do
			DEFAULT_CHAT_FRAME:AddMessage("|CFFFFFF00"..priority .. "|R: " .. description)
		end

		DEFAULT_CHAT_FRAME:AddMessage(curseOptions)
		for option, description in pairs(commandOptions) do
			DEFAULT_CHAT_FRAME:AddMessage("|CFFFFFF00"..option .. "|R: " .. description)
		end
		return
	end
	-- get first word in string
	local _, _, command, args = string.find(msg, "(%w+) (.*)")
	if command == "curse" then
		local spellName, targetedGuid, optionsStr = Cursive.utils.strsplit("|", args)
		local options = parseOptions(optionsStr)
		Cursive:Curse(spellName, targetedGuid, options)
	elseif command == "multicurse" then
		local spellName, priority, optionsStr = Cursive.utils.strsplit("|", args)
		local options = parseOptions(optionsStr)
		Cursive:Multicurse(spellName, priority, options)
	end
end

local crowdControlledSpellIds = {
	[700] = { name = L["Sleep"], rank = 1, duration = 20 },
	[1090] = { name = L["Sleep"], rank = 2, duration = 30 },
	[2937] = { name = L["Sleep"], rank = 3, duration = 40 },

	[339] = { name = L["Entangling Roots"], rank = 1, duration = 12 },
	[1062] = { name = L["Entangling Roots"], rank = 2, duration = 15 },
	[5195] = { name = L["Entangling Roots"], rank = 3, duration = 18 },
	[5196] = { name = L["Entangling Roots"], rank = 4, duration = 21 },
	[9852] = { name = L["Entangling Roots"], rank = 5, duration = 24 },
	[9853] = { name = L["Entangling Roots"], rank = 6, duration = 27 },

	[2637] = { name = L["Hibernate"], rank = 1, duration = 20 },
	[18657] = { name = L["Hibernate"], rank = 2, duration = 30 },
	[18658] = { name = L["Hibernate"], rank = 3, duration = 40 },

	[1425] = { name = L["Shackle Undead"], rank = 1, duration = 30 },
	[9486] = { name = L["Shackle Undead"], rank = 2, duration = 40 },
	[10956] = { name = L["Shackle Undead"], rank = 3, duration = 50 },

	-- polymorph
	[118] = { name = L["Polymorph"], rank = L["Rank 1"], duration = 20 },
	[12824] = { name = L["Polymorph"], rank = L["Rank 2"], duration = 30 },
	[12825] = { name = L["Polymorph"], rank = L["Rank 3"], duration = 40 },
	[12826] = { name = L["Polymorph"], rank = L["Rank 4"], duration = 50 },

	[28270] = { name = L["Polymorph: Cow"], rank = L["Rank 1"], duration = 50 },
	[28271] = { name = L["Polymorph: Turtle"], rank = L["Rank 1"], duration = 50 },
	[28272] = { name = L["Polymorph: Pig"], rank = L["Rank 1"], duration = 50 },

	[2878] = { name = L["Turn Undead"], rank = 1, duration = 10 },
	[5627] = { name = L["Turn Undead"], rank = 2, duration = 15 },
	[10326] = { name = L["Turn Undead"], rank = 3, duration = 20 },

	[2094] = { name = L["Blind"], rank = 1, duration = 10 },
	[21060] = { name = L["Blind"], rank = 1, duration = 10 },

	[6770] = { name = L["Sap"], rank = 1, duration = 25 },
	[2070] = { name = L["Sap"], rank = 2, duration = 35 },
	[11297] = { name = L["Sap"], rank = 3, duration = 45 },

	[1776] = { name = L["Gouge"], rank = 1, duration = 4 },
	[1777] = { name = L["Gouge"], rank = 2, duration = 4 },
	[8629] = { name = L["Gouge"], rank = 3, duration = 4 },
	[11285] = { name = L["Gouge"], rank = 4, duration = 4 },
	[11286] = { name = L["Gouge"], rank = 5, duration = 4 },

	[3355] = { name = L["Freezing Trap"], rank = 1, duration = 10 },
	[14308] = { name = L["Freezing Trap"], rank = 2, duration = 15 },
	[14309] = { name = L["Freezing Trap"], rank = 3, duration = 20 },

	[710] = { name = L["Banish"], rank = 1, duration = 30 },
	[18647] = { name = L["Banish"], rank = 2, duration = 30 },
}

local function isMobCrowdControlled(guid)
	-- check if mob is CC'ed

	-- check debuffs
	for i = 1, 16 do
		local _, _, _, spellId = UnitDebuff(guid, i)
		if spellId then
			if crowdControlledSpellIds[spellId] then
				return true
			end
		else
			break
		end
	end

	-- check buffs
	for i = 1, 32 do
		local _, _, spellId = UnitBuff(guid, i)
		if spellId then
			if crowdControlledSpellIds[spellId] then
				return true
			end
		else
			break
		end
	end

	return false
end

local function GetSquarePrioRaidTargetIndex(guid)
	local index = GetRaidTargetIndex(guid)
	if index == 7 then
		return 0 -- cross becomes 0
	elseif index == 8 then
		return -1 -- skull becomes -1
	elseif index == 0 then
		return -2 -- nomark becomes -2
	end
	return index or -2
end

local function pickTarget(selectedPriority, spellNameNoRank, checkRange, options)
	-- Curse the target that best matches the selected priority
	local highestPrimaryValue = -10
	local highestSecondaryValue = -10
	local targetedGuid = nil

	local minHp = options["minhp"]
	local ignoreInFight = options["allowooc"]
	local refreshTime = options["refreshtime"]

	local _, currentTargetGuid = UnitExists("target")

	local seenRaidMark = nil -- if we have seen a raid mark

	for guid, time in pairs(Cursive.core.guids) do
		-- apply filters
		local shouldDisplay = Cursive:ShouldDisplayGuid(guid)
		-- check if target displayed
		if shouldDisplay then
			-- check if in combat already or player is actively targeting the mob
			if ignoreInFight or Cursive.filter.infight(guid) or guid == currentTargetGuid then
				-- prioritize targets within 28 yards first to improve chances of being in range
				if checkRange == false or CheckInteractDistance(guid, 4) then
					-- check if the target has the curse
					if not Cursive.curses:HasCurse(spellNameNoRank, guid, refreshTime) and not isMobCrowdControlled(guid) then
						local mobHp = UnitHealth(guid)
						if not minHp or mobHp >= minHp then
							local primaryValue = -1
							local secondaryValue = -1
							if selectedPriority == PRIORITY_HIGHEST_HP then
								primaryValue = UnitHealth(guid) or 0
							elseif selectedPriority == PRIORITY_RAID_MARK then
								primaryValue = GetRaidTargetIndex(guid) or 0
							elseif selectedPriority == PRIORITY_RAID_MARK_SQUARE then
								primaryValue = GetSquarePrioRaidTargetIndex(guid)
							elseif selectedPriority == PRIORITY_INVERSE_RAID_MARK then
								primaryValue = -1 * (GetRaidTargetIndex(guid) or 9)
							elseif selectedPriority == PRIORITY_HIGHEST_HP_RAID_MARK then
								secondaryValue = GetRaidTargetIndex(guid) or 0
								if secondaryValue > 0 and not seenRaidMark then
									highestPrimaryValue = -10 -- reset highestPriorityValue if this is the first raid mark we've seen
									seenRaidMark = true
								end
								primaryValue = UnitHealth(guid) or 0
							elseif selectedPriority == PRIORITY_HIGHEST_HP_RAID_MARK_SQUARE then
								secondaryValue = GetSquarePrioRaidTargetIndex(guid)
								if secondaryValue > -2 and not seenRaidMark then
									highestPrimaryValue = -10 -- reset highestPriorityValue if this is the first raid mark we've seen
									seenRaidMark = true
								end
								primaryValue = UnitHealth(guid) or 0
							elseif selectedPriority == PRIORITY_HIGHEST_HP_INVERSE_RAID_MARK then
								secondaryValue = -1 * (GetRaidTargetIndex(guid) or 9)
								if secondaryValue > -9 and not seenRaidMark then
									highestPrimaryValue = -10 -- reset highestPriorityValue if this is the first raid mark we've seen
									seenRaidMark = true
								end
								primaryValue = UnitHealth(guid) or 0
							end

							if primaryValue > highestPrimaryValue then
								highestPrimaryValue = primaryValue
								highestSecondaryValue = secondaryValue
								targetedGuid = guid
							elseif primaryValue == highestPrimaryValue and secondaryValue > highestSecondaryValue then
								highestSecondaryValue = secondaryValue
								targetedGuid = guid
							end
						end
					end
				end
			end
		end
	end

	-- run again if no target found ignoring range
	if not targetedGuid and checkRange == true then
		targetedGuid = pickTarget(selectedPriority, spellNameNoRank, false, options)
	end

	return targetedGuid
end

local function castSpellWithOptions(spellName, spellNameNoRank, targetedGuid, options)
	if options["resistsound"] then
		Cursive.curses:EnableResistSound(targetedGuid)
	end
	if options["expiringsound"] then
		Cursive.curses:RequestExpiringSound(spellNameNoRank, targetedGuid)
	end
	CastSpellByName(spellName, targetedGuid)
end

function Cursive:Curse(spellName, targetedGuid, options)
	if not spellName or not targetedGuid then
		DEFAULT_CHAT_FRAME:AddMessage(commands["curse"])
		return
	end

	if targetedGuid and string.sub(targetedGuid, 1, 2) ~= "0x" then
		_, targetedGuid = UnitExists(targetedGuid)

		if not targetedGuid then
			if options["warnings"] then
				DEFAULT_CHAT_FRAME:AddMessage(curseNoTarget)
			end
			return
		end
	end

	-- remove (Rank x) from spellName if it exists
	local spellNameNoRank = string.gsub(spellName, "%(.+%)", "")

	if targetedGuid and not Cursive.curses:HasCurse(spellNameNoRank, targetedGuid, options["refreshtime"]) and not isMobCrowdControlled(targetedGuid) then
		castSpellWithOptions(spellName, spellNameNoRank, targetedGuid, options)
	elseif options["warnings"] then
		DEFAULT_CHAT_FRAME:AddMessage(curseNoTarget)
	end
end

function Cursive:Multicurse(spellName, priority, options)
	if not spellName then
		DEFAULT_CHAT_FRAME:AddMessage(commands["multicurse"])
		return
	end

	if priority and not priorities[priority] then
		DEFAULT_CHAT_FRAME:AddMessage(priorityChoices)
		for choice, description in pairs(priorities) do
			DEFAULT_CHAT_FRAME:AddMessage("|CFFFFFF00"..choice .. "|R: " .. description)
		end
		return
	end

	local selectedPriority = priority or PRIORITY_HIGHEST_HP

	-- remove (Rank x) from spellName if it exists
	local spellNameNoRank = string.gsub(spellName, "%(.+%)", "")

	local targetedGuid = pickTarget(selectedPriority, spellNameNoRank, true, options)

	if targetedGuid then
		castSpellWithOptions(spellName, spellNameNoRank, targetedGuid, options)
	elseif options["warnings"] then
		DEFAULT_CHAT_FRAME:AddMessage(curseNoTarget)
	end
end

SLASH_CURSIVE1 = "/cursive" --creating the slash command
SlashCmdList["CURSIVE"] = handleSlashCommands --associating the function with the slash command
