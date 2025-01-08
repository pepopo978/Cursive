local L = AceLibrary("AceLocale-2.2"):new("Cursive")
function getMageSpells()
	return {
		[118] = { name = L["polymorph"], rank = 1, duration = 20 },
		[12824] = { name = L["polymorph"], rank = 2, duration = 30 },
		[12825] = { name = L["polymorph"], rank = 3, duration = 40 },
		[12826] = { name = L["polymorph"], rank = 4, duration = 50 },

		[28270] = { name = L["polymorph: cow"], rank = 1, duration = 50 },
		[28271] = { name = L["polymorph: turtle"], rank =1, duration = 50 },
		[28272] = { name = L["polymorph: pig"], rank = 1, duration = 50 },
	}
end
