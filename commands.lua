local curseCommands = "|cffffcc00Cursive:|cffffaaaa Commands:"

local commands = {
	["curse"] = "/cursive curse <spellName:str>|<guid?:str>|<noFailureWarning:int[0,1]: Casts spell if not already on target/guid",
	["multicurse"] = "/cursive multicurse <spellName:str>|<priority?:str>|<noFailureWarning:int[0,1]: Picks target based on priority and casts spell if not already on target.  Priority options: HIGHEST_HP, RAID_MARK.",
}

local curseNoTarget = "|cffffcc00Cursive:|cffffaaaa Couldn't find a target to curse."

local function handleSlashCommands(msg, editbox)
	if not msg or msg == "" then
		DEFAULT_CHAT_FRAME:AddMessage(curseCommands)
		for command, description in pairs(commands) do
			DEFAULT_CHAT_FRAME:AddMessage(description)
		end
		return
	end
	-- get first word in string
	local _, _, command, args = string.find(msg, "(%w+) (.*)")
	if command == "curse" then
		local spellName, targetedGuid, noFailureWarning = Cursive.utils.strsplit("|", args)
		Cursive:Curse(spellName, targetedGuid, noFailureWarning)
	elseif command == "multicurse" then
		local spellName, priority, noFailureWarning = Cursive.utils.strsplit("|", args)
		Cursive:Multicurse(spellName, priority, noFailureWarning)
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

local function pickHighestHpTarget(selectedPriority, spellNameNoRank, skipCheckRange)
	-- Curse the target with the highest HP
	local highestHP = 0
	local targetedGuid = nil

	for guid, time in pairs(Cursive.core.guids) do
		-- apply filters
		local shouldDisplay = Cursive:ShouldDisplayGuid(guid)
		-- check if target exists/displayed/infight
		if UnitExists(guid) and shouldDisplay and Cursive.filter.infight(guid) then
			if not skipCheckRange and CheckInteractDistance(guid, 4) then
				-- check if the target has the curse
				if not Cursive.curses:HasCurse(spellNameNoRank, guid) and not isMobCrowdControlled(guid) then
					local health = UnitHealth(guid)
					if health > highestHP then
						highestHP = health
						targetedGuid = guid
					end
				end
			end
		end
	end

	-- run again if no target found ignoring range
	if not targetedGuid and not skipCheckRange then
		targetedGuid = pickHighestHpTarget(selectedPriority, spellNameNoRank, true)
	end

	return targetedGuid
end

local function pickRaidMarkTarget(selectedPriority, spellNameNoRank, skipCheckRange)
	-- Curse the target with the highest raid mark
	local highestMark = 0
	local targetedGuid = nil

	for guid, time in pairs(Cursive.core.guids) do
		-- apply filters
		local shouldDisplay = Cursive:ShouldDisplayGuid(guid)
		-- check if target exists/displayed/infight
		if UnitExists(guid) and shouldDisplay and Cursive.filter.infight(guid) then
			if not skipCheckRange and CheckInteractDistance(guid, 4) then
				-- check if the target has the curse
				if not Cursive.curses:HasCurse(spellNameNoRank, guid) and not isMobCrowdControlled(guid) then
					local raidMark = GetRaidTargetIndex(guid)
					if not raidMark or raidMark == 0 then
						if highestMark == 0 then
							targetedGuid = guid
						end
					else
						if raidMark > highestMark then
							highestMark = raidMark
							targetedGuid = guid
						end
					end
				end
			end
		end
	end

	-- run again if no target found ignoring range
	if not targetedGuid and not skipCheckRange then
		targetedGuid = pickRaidMarkTarget(selectedPriority, spellNameNoRank, true)
	end

	return targetedGuid
end

function Cursive:Curse(spellName, targetedGuid, noFailureWarning)
	if not spellName or not targetedGuid then
		DEFAULT_CHAT_FRAME:AddMessage(commands["curse"])
		return
	end

	if targetedGuid and string.sub(targetedGuid, 1, 2) ~= "0x" then
		_, targetedGuid = UnitExists(targetedGuid)

		if not targetedGuid then
			if not (noFailureWarning and noFailureWarning == "1") then
				DEFAULT_CHAT_FRAME:AddMessage(curseNoTarget)
			end
			return
		end
	end

	-- remove (Rank x) from spellName if it exists
	local spellNameNoRank = string.gsub(spellName, "%(.+%)", "")

	if targetedGuid and not Cursive.curses:HasCurse(spellNameNoRank, targetedGuid) and not isMobCrowdControlled(targetedGuid) then
		CastSpellByName(spellName, targetedGuid)
	elseif not (noFailureWarning and noFailureWarning == "1") then
		DEFAULT_CHAT_FRAME:AddMessage(curseNoTarget)
	end
end

function Cursive:Multicurse(spellName, priority, noFailureWarning)
	if not spellName then
		DEFAULT_CHAT_FRAME:AddMessage(commands["multicurse"])
		return
	end

	local selectedPriority = priority or "HIGHEST_HP"

	-- remove (Rank x) from spellName if it exists
	local spellNameNoRank = string.gsub(spellName, "%(.+%)", "")

	if not targetedGuid then
		if selectedPriority == "HIGHEST_HP" then
			targetedGuid = pickHighestHpTarget(selectedPriority, spellNameNoRank)
		elseif selectedPriority == "RAID_MARK" then
			targetedGuid = pickRaidMarkTarget(selectedPriority, spellNameNoRank)
		else
			DEFAULT_CHAT_FRAME:AddMessage(multiCurseUsage)
			return
		end
	end

	if targetedGuid then
		CastSpellByName(spellName, targetedGuid)
	elseif not (noFailureWarning and noFailureWarning == "1") then
		DEFAULT_CHAT_FRAME:AddMessage(curseNoTarget)
	end
end

SLASH_CURSIVE1 = "/cursive" --creating the slash command
SlashCmdList["CURSIVE"] = handleSlashCommands --associating the function with the slash command
