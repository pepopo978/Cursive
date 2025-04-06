This fork allows to track an extra limited list of debuffs on Cursive frames from a whitelist defined in curses.lua, like follows:

	`whitelistedDebuffIDs = {
		[710] = { name = L["banish"], rank = 1, duration = 20 },
		[18647] = { name = L["banish"], rank = 2, duration = 30 },
		[6770] = { name = L["sap"], rank = 1, duration = 25 },
		[2070] = { name = L["sap"], rank = 2, duration = 35 },
		[11297] = { name = L["sap"], rank = 3, duration = 45 },
		[1425] = { name = L["shackle undead"], rank = 1, duration = 30 },
		[9486] = { name = L["shackle undead"], rank = 2, duration = 40 },
		[10956] = { name = L["shackle undead"], rank = 3, duration = 50 },
		[118] = { name = L["polymorph"], rank = 1, duration = 20 },
		[12824] = { name = L["polymorph"], rank = 2, duration = 30 },
		[12825] = { name = L["polymorph"], rank = 3, duration = 40 },
		[12826] = { name = L["polymorph"], rank = 4, duration = 50 },
		[28270] = { name = L["polymorph: cow"], rank = 1, duration = 50 },
		[28271] = { name = L["polymorph: turtle"], rank =1, duration = 50 },
		[28272] = { name = L["polymorph: pig"], rank = 1, duration = 50 },
		[700] = { name = L["sleep"], rank = 1, duration = 20 },
		[1090] = { name = L["sleep"], rank = 2, duration = 30 },
		[2937] = { name = L["sleep"], rank = 3, duration = 40 },
		[2637] = { name = L["hibernate"], rank = 1, duration = 20 },
		[18657] = { name = L["hibernate"], rank = 2, duration = 30 },
		[18658] = { name = L["hibernate"], rank = 3, duration = 40 },
	},`
	
The debuffs from the whitelist can now also be tracked if they are owned by other players.

Limited testing has been done at the moment.