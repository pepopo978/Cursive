local curseCommands = "|cffffcc00Cursive:|cffffaaaa Commands:"
local curseOptions = "Options (separate with ,):"

local commandOptions = {
	["warnings"] = "Display text warnings when a curse fails to cast.",
	["resistsound"] = "Play a sound when a curse is resisted.",
	["expiringsound"] = "Play a sound when a curse is about to expire.",
}

local commands = {
	["curse"] = "/cursive curse <spellName:str>|<guid?:str>|<options?:List<str>>: Casts spell if not already on target/guid",
	["multicurse"] = "/cursive multicurse <spellName:str>|<priority?:str>|<options?:List<str>>: Picks target based on priority and casts spell if not already on target.  Priority options: HIGHEST_HP, RAID_MARK.",
}

local curseNoTarget = "|cffffcc00Cursive:|cffffaaaa Couldn't find a target to curse."

local function parseOptions(optionsStr)
	local options = {  }

	if optionsStr then
		for option, _ in pairs(commandOptions) do
			if string.find(optionsStr, option) then
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
		DEFAULT_CHAT_FRAME:AddMessage(curseOptions)
		for option, description in pairs(commandOptions) do
			DEFAULT_CHAT_FRAME:AddMessage(option .. ": " .. description)
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
	[700] = { name = "Sleep", rank = 1, duration = 20 },
	[1090] = { name = "Sleep", rank = 2, duration = 30 },
	[2937] = { name = "Sleep", rank = 3, duration = 40 },

	[339] = { name = "Entangling Roots", rank = 1, duration = 12 },
	[1062] = { name = "Entangling Roots", rank = 2, duration = 15 },
	[5195] = { name = "Entangling Roots", rank = 3, duration = 18 },
	[5196] = { name = "Entangling Roots", rank = 4, duration = 21 },
	[9852] = { name = "Entangling Roots", rank = 5, duration = 24 },
	[9853] = { name = "Entangling Roots", rank = 6, duration = 27 },

	[1425] = { name = "Shackle Undead", rank = 1, duration = 30 },
	[9486] = { name = "Shackle Undead", rank = 2, duration = 40 },
	[10956] = { name = "Shackle Undead", rank = 3, duration = 50 },

	-- polymorph
	[118] = { name = "Polymorph", rank = "Rank 1", duration = 20 },
	[12824] = { name = "Polymorph", rank = "Rank 2", duration = 30 },
	[12825] = { name = "Polymorph", rank = "Rank 3", duration = 40 },
	[12826] = { name = "Polymorph", rank = "Rank 4", duration = 50 },

	[28270] = { name = "Polymorph: Cow", rank = "Rank 1", duration = 50 },
	[28271] = { name = "Polymorph: Turtle", rank = "Rank 1", duration = 50 },
	[28272] = { name = "Polymorph: Pig", rank = "Rank 1", duration = 50 },

	[2878] = { name = "Turn Undead", rank = 1, duration = 10 },
	[5627] = { name = "Turn Undead", rank = 2, duration = 15 },
	[10326] = { name = "Turn Undead", rank = 3, duration = 20 },

	[2094] = { name = "Blind", rank = 1, duration = 10 },
	[21060] = { name = "Blind", rank = 1, duration = 10 },

	[6770] = { name = "Sap", rank = 1, duration = 25 },
	[2070] = { name = "Sap", rank = 2, duration = 35 },
	[11297] = { name = "Sap", rank = 3, duration = 45 },

	[1776] = { name = "Gouge", rank = 1, duration = 4 },
	[1777] = { name = "Gouge", rank = 2, duration = 4 },
	[8629] = { name = "Gouge", rank = 3, duration = 4 },
	[11285] = { name = "Gouge", rank = 4, duration = 4 },
	[11286] = { name = "Gouge", rank = 5, duration = 4 },

	[3355] = { name = "Freezing Trap", rank = 1, duration = 10 },
	[14308] = { name = "Freezing Trap", rank = 2, duration = 15 },
	[14309] = { name = "Freezing Trap", rank = 3, duration = 20 },
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

local function pickTarget(selectedPriority, spellNameNoRank, checkRange)
	-- Curse the target that best matches the selected priority
	local highestPriorityValue = -1
	local targetedGuid = nil

	local _, currentTargetGuid = UnitExists("target")

	for guid, time in pairs(Cursive.core.guids) do
		-- apply filters
		local shouldDisplay = Cursive:ShouldDisplayGuid(guid)
		-- check if target displayed
		if shouldDisplay then
			-- check if in combat already or player is actively targeting the mob
			if Cursive.filter.infight(guid) or guid == currentTargetGuid then
				if checkRange == false or CheckInteractDistance(guid, 4) then
					-- check if the target has the curse
					if not Cursive.curses:HasCurse(spellNameNoRank, guid) and not isMobCrowdControlled(guid) then
						local value
						if selectedPriority == "HIGHEST_HP" then
							value = UnitHealth(guid)
						elseif selectedPriority == "RAID_MARK" then
							value = GetRaidTargetIndex(guid) or 0
						end

						if value > highestPriorityValue then
							highestPriorityValue = value
							targetedGuid = guid
						end
					end
				end
			end
		end
	end

	-- run again if no target found ignoring range
	if not targetedGuid and checkRange == true then
		targetedGuid = pickTarget(selectedPriority, spellNameNoRank, false)
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

	if targetedGuid and not Cursive.curses:HasCurse(spellNameNoRank, targetedGuid) and not isMobCrowdControlled(targetedGuid) then
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

	if priority and (priority ~= "HIGHEST_HP" and priority ~= "RAID_MARK") then
		DEFAULT_CHAT_FRAME:AddMessage(commands["multicurse"])
		return
	end

	local selectedPriority = priority or "HIGHEST_HP"

	-- remove (Rank x) from spellName if it exists
	local spellNameNoRank = string.gsub(spellName, "%(.+%)", "")

	local targetedGuid = pickTarget(selectedPriority, spellNameNoRank, true)

	if targetedGuid then
		castSpellWithOptions(spellName, spellNameNoRank, targetedGuid, options)
	elseif options["warnings"] then
		DEFAULT_CHAT_FRAME:AddMessage(curseNoTarget)
	end
end

SLASH_CURSIVE1 = "/cursive" --creating the slash command
SlashCmdList["CURSIVE"] = handleSlashCommands --associating the function with the slash command
