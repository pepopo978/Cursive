local L = AceLibrary("AceLocale-2.2"):new("Cursive")
function getMageSpells()
	return {
		[118] = { name = L["Polymorph"], rank = L["Rank 1"], duration = 20 },
		[12824] = { name = L["Polymorph"], rank = L["Rank 2"], duration = 30 },
		[12825] = { name = L["Polymorph"], rank = L["Rank 3"], duration = 40 },
		[12826] = { name = L["Polymorph"], rank = L["Rank 4"], duration = 50 },

		[28270] = { name = L["Polymorph: Cow"], rank = L["Rank 1"], duration = 50 },
		[28271] = { name = L["Polymorph: Turtle"], rank = L["Rank 1"], duration = 50 },
		[28272] = { name = L["Polymorph: Pig"], rank = L["Rank 1"], duration = 50 },
	}
end
