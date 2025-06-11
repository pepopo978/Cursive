local L = AceLibrary("AceLocale-2.2"):new("Cursive")
function getRogueSpells()
	return {
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

		[8647] = { name = L["expose armor"], rank = 1, duration = 30 }, -- this is a shared debuff but almost always only done by 1 rogue
		[8649] = { name = L["expose armor"], rank = 2, duration = 30 },
		[8650] = { name = L["expose armor"], rank = 3, duration = 30 },
		[11197] = { name = L["expose armor"], rank = 4, duration = 30 },
		[11198] = { name = L["expose armor"], rank = 5, duration = 30 },

		[703] = { name = L["garrote"], rank = 1, duration = 18 },
		[8631] = { name = L["garrote"], rank = 2, duration = 18 },
		[8632] = { name = L["garrote"], rank = 3, duration = 18 },
		[8633] = { name = L["garrote"], rank = 4, duration = 18 },
		[11289] = { name = L["garrote"], rank = 5, duration = 18 },
		[11290] = { name = L["garrote"], rank = 6, duration = 18 },

		[2818] = { name = L["deadly poison"], rank = 1, duration = 12 },
		[2819] = { name = L["deadly poison II"], rank = 2, duration = 12 },
		[11353] = { name = L["deadly poison III"], rank = 3, duration = 12 },
		[11354] = { name = L["deadly poison IV"], rank = 4, duration = 12 },
		[25349] = { name = L["deadly poison V"], rank = 5, duration = 12 },

		[16511] = { name = L["hemorrhage"], rank = 1, duration = 15 },
	}
end
