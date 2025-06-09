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
	refreshtime = L["Time threshold at which to allow refreshing a curse.  Default is 0 seconds."],
	priotarget = L["Always prioritize current target when choosing target for multicurse.  Does not affect 'curse' command."],
	ignoretarget = L["Ignore the current target when choosing target for multicurse.  Does not affect 'curse' command."],
	playeronly = L["Only choose players and ignore npcs when choosing target for multicurse.  Does not affect 'curse' command."],
	name = L["Filter targets by name. Can be a partial match.  If no match is found, the command will do nothing."],
	ignorespellid = L["Ignore targets with the specified spell id already on them. Useful for ignoring targets that already have a shared debuff."],
	ignorespelltexture = L["Ignore targets with the specified spell texture already on them. Useful for ignoring targets that already have a shared debuff."],
}

local commands = {
	["curse"] = L["/cursive curse <spellName:str>|<guid?:str>|<options?:List<str>>: Casts spell if not already on target/guid"],
	["multicurse"] = L["/cursive multicurse <spellName:str>|<priority?:str>|<options?:List<str>>: Picks target based on priority and casts spell if not already on target"],
	["target"] = L["/cursive target <spellName:str>|<priority?:str>|<options?:List<str>>: Targets unit based on priority if spell in range and not already on target"],
}

local PRIORITY_HIGHEST_HP = "HIGHEST_HP"
local PRIORITY_LOWEST_HP = "LOWEST_HP"
local PRIORITY_RAID_MARK = "RAID_MARK"
local PRIORITY_RAID_MARK_SQUARE = "RAID_MARK_SQUARE"
local PRIORITY_INVERSE_RAID_MARK = "INVERSE_RAID_MARK"
local PRIORITY_HIGHEST_HP_RAID_MARK = "HIGHEST_HP_RAID_MARK"
local PRIORITY_HIGHEST_HP_RAID_MARK_SQUARE = "HIGHEST_HP_RAID_MARK_SQUARE"
local PRIORITY_HIGHEST_HP_INVERSE_RAID_MARK = "HIGHEST_HP_INVERSE_RAID_MARK"

local priorities = {
	[PRIORITY_HIGHEST_HP] = L["Target with the highest HP."],
	[PRIORITY_LOWEST_HP] = L["Target with the lowest HP."],
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
			elseif option == "name" then
				local _, _, name = string.find(optionsStr, "name=([%w%s]+)")
				if name then
					options["name"] = name
				end
			elseif option == "ignorespellid" then
				local _, _, spellId = string.find(optionsStr, "ignorespellid=(%d+)")
				if spellId then
					options["ignorespellid"] = tonumber(spellId)
				end
			elseif option == "ignorespelltexture" then
				local _, _, texture = string.find(optionsStr, "ignorespelltexture=([%w_]+)")
				if texture then
					options["ignorespelltexture"] = texture
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
			DEFAULT_CHAT_FRAME:AddMessage("|CFFFFFF00" .. priority .. "|R: " .. description)
		end

		DEFAULT_CHAT_FRAME:AddMessage(curseOptions)
		for option, description in pairs(commandOptions) do
			DEFAULT_CHAT_FRAME:AddMessage("|CFFFFFF00" .. option .. "|R: " .. description)
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
	elseif command == "target" then
		local spellName, priority, optionsStr = Cursive.utils.strsplit("|", args)
		local options = parseOptions(optionsStr)
		Cursive:Target(spellName, priority, options)
	end
end

local crowdControlledSpellIds = {
	[700] = { name = L["sleep"], rank = 1, duration = 20 },
	[1090] = { name = L["sleep"], rank = 2, duration = 30 },
	[2937] = { name = L["sleep"], rank = 3, duration = 40 },

	[339] = { name = L["entangling roots"], rank = 1, duration = 12 },
	[1062] = { name = L["entangling roots"], rank = 2, duration = 15 },
	[5195] = { name = L["entangling roots"], rank = 3, duration = 18 },
	[5196] = { name = L["entangling roots"], rank = 4, duration = 21 },
	[9852] = { name = L["entangling roots"], rank = 5, duration = 24 },
	[9853] = { name = L["entangling roots"], rank = 6, duration = 27 },

	[2637] = { name = L["hibernate"], rank = 1, duration = 20 },
	[18657] = { name = L["hibernate"], rank = 2, duration = 30 },
	[18658] = { name = L["hibernate"], rank = 3, duration = 40 },

	[1425] = { name = L["shackle undead"], rank = 1, duration = 30 },
	[9486] = { name = L["shackle undead"], rank = 2, duration = 40 },
	[10956] = { name = L["shackle undead"], rank = 3, duration = 50 },

	-- polymorph
	[118] = { name = L["polymorph"], rank = L["Rank 1"], duration = 20 },
	[12824] = { name = L["polymorph"], rank = L["Rank 2"], duration = 30 },
	[12825] = { name = L["polymorph"], rank = L["Rank 3"], duration = 40 },
	[12826] = { name = L["polymorph"], rank = L["Rank 4"], duration = 50 },

	[28270] = { name = L["polymorph: cow"], rank = L["Rank 1"], duration = 50 },
	[28271] = { name = L["polymorph: turtle"], rank = L["Rank 1"], duration = 50 },
	[28272] = { name = L["polymorph: pig"], rank = L["Rank 1"], duration = 50 },

	[2878] = { name = L["turn undead"], rank = 1, duration = 10 },
	[5627] = { name = L["turn undead"], rank = 2, duration = 15 },
	[10326] = { name = L["turn undead"], rank = 3, duration = 20 },

	[2094] = { name = L["blind"], rank = 1, duration = 10 },
	[21060] = { name = L["blind"], rank = 1, duration = 10 },

	[6770] = { name = L["sap"], rank = 1, duration = 25 },
	[2070] = { name = L["sap"], rank = 2, duration = 35 },
	[11297] = { name = L["sap"], rank = 3, duration = 45 },

	[1776] = { name = L["gouge"], rank = 1, duration = 4 },
	[1777] = { name = L["gouge"], rank = 2, duration = 4 },
	[8629] = { name = L["gouge"], rank = 3, duration = 4 },
	[11285] = { name = L["gouge"], rank = 4, duration = 4 },
	[11286] = { name = L["gouge"], rank = 5, duration = 4 },

	[3355] = { name = L["freezing trap"], rank = 1, duration = 10 },
	[14308] = { name = L["freezing trap"], rank = 2, duration = 15 },
	[14309] = { name = L["freezing trap"], rank = 3, duration = 20 },

	[710] = { name = L["banish"], rank = 1, duration = 30 },
	[18647] = { name = L["banish"], rank = 2, duration = 30 },

	-- mind control effects
	[28410] = { name = "Chains of Kel'Thuzad" }, -- we aren't casting these, name doesn't matter
	[7621] = { name = "Arugal's Curse" },
	[24261] = { name = "Brain Wash" },
	[12888] = { name = "Cause Insanity" },
	[24327] = { name = "Cause Insanity" },
	[26079] = { name = "Cause Insanity" },
	[24327] = { name = "Cause Insanity" },
	[23174] = { name = "Chromatic Mutation" },
	[25806] = { name = "Creature of Nightmare" },
	[23298] = { name = "Demonic Doom" },
	[7645] = { name = "Dominate Mind" },
	[14515] = { name = "Dominate Mind" },
	[15859] = { name = "Dominate Mind" },
	[20604] = { name = "Dominate Mind" },
	[20740] = { name = "Dominate Mind" },
	[17405] = { name = "Domination" },
	[3442] = { name = "Enslave" },
	[13181] = { name = "Gnomish Mind Control Cap" },
	[26740] = { name = "Gnomish Mind Control Cap" },
	[12483] = { name = "Hex of Jammal'an" },
	[25772] = { name = "Mental Domination" },
	[7967] = { name = "Naralex's Nightmare" },
	[19469] = { name = "Poison Mind" },
	[17244] = { name = "Possess" },
	[22667] = { name = "Shadow Command" },
	[20668] = { name = "Sleepwalk" },
	[785] = { name = "True Fulfillment" },
	[26195] = { name = "Whisperings of C'Thun" },
	[26197] = { name = "Whisperings of C'Thun" },
	[26198] = { name = "Whisperings of C'Thun" },
	[26258] = { name = "Whisperings of C'Thun" },
	[26259] = { name = "Whisperings of C'Thun" },
	[24178] = { name = "Will of Hakkar" },

	-- immunity effects
	[642] = { name = "Divine Shield" },
	[1020] = { name = "Divine Shield" },
	[13874] = { name = "Divine Shield" },
	[5573] = { name = "Divine Protection" },
	[13007] = { name = "Divine Protection" },
	[6356] = { name = "Spell Immunity" },
	[6724] = { name = "Light of Elune" },
	[7121] = { name = "Anti-Magic Shield" },
	[19645] = { name = "Anti-Magic Shield" },
	[24021] = { name = "Anti-Magic Shield" },
	[8361] = { name = "Purity" },
	[8611] = { name = "Phase Shift" },
	[45713] = { name = "Phase Shift" },
	[9438] = { name = "Arcane Bubble" },
	[11958] = { name = "Ice Block" },
	[12843] = { name = "Mordresh's Shield" },
	[21892] = { name = "Arcane Protection" },
	[51096] = { name = "Worgen Dimension" },
	[51228] = { name = "Invulnerability" },
	[52010] = { name = "Pending Detonation" },
	[53225] = { name = "Ward of Vorgendor" },
	[57644] = { name = "Veil of Vorgendor" },
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

local function hasSpellId(guid, ignoreSpellId)
	for i = 1, 16 do
		local texture, stacks, spellSchool, spellId = UnitDebuff(guid, i);
		if not spellId then
			break
		end
		if spellId == ignoreSpellId then
			return true
		end
	end

	for i = 1, 32 do
		local texture, stacks, spellId = UnitBuff(guid, i);
		if not spellId then
			break
		end
		if spellId == ignoreSpellId then
			return true
		end
	end

	return false
end

local function hasSpellTexture(guid, ignoreTexture)
	for i = 1, 16 do
		local texture = UnitDebuff(guid, i);
		if not texture then
			break
		end
		if string.find(texture, ignoreTexture) then
			return true
		end
	end

	for i = 1, 32 do
		local texture = UnitBuff(guid, i);
		if not texture then
			break
		end
		if string.find(texture, ignoreTexture) then
			return true
		end
	end

	return false
end

local function passedOptionFilters(guid, options)
	if options["name"] then
		local name = UnitName(guid)
		if not string.find(name, options["name"]) then
			return false
		end
	end
	if options["ignorespellid"] then
		if hasSpellId(guid, options["ignorespellid"]) then
			return false
		end
	end
	if options["ignorespelltexture"] then
		if hasSpellTexture(guid, options["ignorespelltexture"]) then
			return false
		end
	end
	if options["playeronly"] and not UnitIsPlayer(guid) then
		return false
	end
	return true
end

local function pickTarget(selectedPriority, spellNameNoRank, checkRange, options)
	-- Curse the target that best matches the selected priority
	local highestPrimaryValue = -10
	local highestSecondaryValue = -10
	local targetedGuid = nil

	if selectedPriority == PRIORITY_LOWEST_HP then
		highestPrimaryValue = 999999999999 -- should be bigger than any mob hp
	end

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
			if not options["ignoretarget"] or guid ~= currentTargetGuid then
				-- check if in combat already or player is actively targeting the mob
				if ignoreInFight or Cursive.filter.infight(guid) or guid == currentTargetGuid then
					if passedOptionFilters(guid, options) then
						local passedRangeCheck = false
						if IsSpellInRange then
							-- use IsSpellInRange from nampower if available
							local result = IsSpellInRange(spellNameNoRank, guid)
							if result == -1 then
								passedRangeCheck = checkRange == false or CheckInteractDistance(guid, 4) -- fallback to old range check
							else
								-- 0 or 1
								passedRangeCheck = result == 1
							end
						else
							-- prioritize targets within 28 yards first to improve chances of being in range
							passedRangeCheck = checkRange == false or CheckInteractDistance(guid, 4)
						end
						if passedRangeCheck then
							-- check if the target has the curse
							if not Cursive.curses:HasCurse(spellNameNoRank, guid, refreshTime) and not isMobCrowdControlled(guid) then
								local mobHp = UnitHealth(guid)
								if not minHp or mobHp >= minHp then
									local primaryValue = -1
									local secondaryValue = -1
									if options["priotarget"] and guid == currentTargetGuid then
										seenRaidMark = true
										primaryValue = 999999999999 -- should be bigger than any mob hp
									elseif selectedPriority == PRIORITY_HIGHEST_HP then
										primaryValue = UnitHealth(guid) or 0
									elseif selectedPriority == PRIORITY_LOWEST_HP then
										primaryValue = UnitHealth(guid) or 999999999999
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

									if selectedPriority == PRIORITY_LOWEST_HP then
										if primaryValue < highestPrimaryValue then
											highestPrimaryValue = primaryValue
											targetedGuid = guid
										end
									elseif primaryValue > highestPrimaryValue then
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
		end
	end

	-- run again if no target found ignoring range (only if IsSpellInRange is not available)
	if not targetedGuid and checkRange == true and not IsSpellInRange then
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
		return false
	end

	if targetedGuid and string.sub(targetedGuid, 1, 2) ~= "0x" then
		_, targetedGuid = UnitExists(targetedGuid)

		if not targetedGuid then
			if options["warnings"] then
				DEFAULT_CHAT_FRAME:AddMessage(curseNoTarget)
			end
			return false
		end
	end

	if targetedGuid then
		-- check for options
		if not passedOptionFilters(targetedGuid, options) then
			if options["warnings"] then
				DEFAULT_CHAT_FRAME:AddMessage(curseNoTarget)
			end
			return false
		end
	end

	-- remove (Rank x) from spellName if it exists
	local spellNameNoRank = Cursive.utils.GetSpellNameNoRank(spellName)

	if targetedGuid and not Cursive.curses:HasCurse(spellNameNoRank, targetedGuid, options["refreshtime"]) and not isMobCrowdControlled(targetedGuid) then
		castSpellWithOptions(string.lower(spellName), spellNameNoRank, targetedGuid, options)
		return true
	elseif options["warnings"] then
		DEFAULT_CHAT_FRAME:AddMessage(curseNoTarget)
	end

	return false
end

local function getSpellTarget(spellName, priority, options)
	if not spellName then
		DEFAULT_CHAT_FRAME:AddMessage(commands["multicurse"])
		return
	end

	if priority and not priorities[priority] then
		DEFAULT_CHAT_FRAME:AddMessage(priorityChoices)
		for choice, description in pairs(priorities) do
			DEFAULT_CHAT_FRAME:AddMessage("|CFFFFFF00" .. choice .. "|R: " .. description)
		end
		return
	end

	local selectedPriority = priority or PRIORITY_HIGHEST_HP

	-- remove (Rank x) from spellName if it exists
	local spellNameNoRank = Cursive.utils.GetSpellNameNoRank(spellName)

	return pickTarget(selectedPriority, spellNameNoRank, true, options)
end

function Cursive:Multicurse(spellName, priority, options)
	local targetedGuid = getSpellTarget(spellName, priority, options)
	if targetedGuid then
		local spellNameNoRank = Cursive.utils.GetSpellNameNoRank(spellName)
		castSpellWithOptions(string.lower(spellName), spellNameNoRank, targetedGuid, options)
		return true
	elseif options["warnings"] then
		DEFAULT_CHAT_FRAME:AddMessage(curseNoTarget)
	end
	return false
end

function Cursive:Target(spellName, priority, options)
	local targetedGuid = getSpellTarget(spellName, priority, options)
	if targetedGuid then
		TargetUnit(targetedGuid)
		return true
	end
	return false
end

SLASH_CURSIVE1 = "/cursive" --creating the slash command
SlashCmdList["CURSIVE"] = handleSlashCommands --associating the function with the slash command
