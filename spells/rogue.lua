local L = AceLibrary("AceLocale-2.2"):new("Cursive")
function getRogueSpells()
	return {
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

		[8647] = { name = L["Expose Armor"], rank = 1, duration = 30 }, -- this is a shared debuff but almost always only done by 1 rogue
		[8649] = { name = L["Expose Armor"], rank = 2, duration = 30 },
		[8650] = { name = L["Expose Armor"], rank = 3, duration = 30 },
		[11197] = { name = L["Expose Armor"], rank = 4, duration = 30 },
		[11198] = { name = L["Expose Armor"], rank = 5, duration = 30 },

		[703] = { name = L["Garrote"], rank = 1, duration = 18 },
		[8631] = { name = L["Garrote"], rank = 2, duration = 18 },
		[8632] = { name = L["Garrote"], rank = 3, duration = 18 },
		[8633] = { name = L["Garrote"], rank = 4, duration = 18 },
		[11289] = { name = L["Garrote"], rank = 5, duration = 18 },
		[11290] = { name = L["Garrote"], rank = 6, duration = 18 },

		[2818] = { name = L["Deadly Poison"], rank = 1, duration = 12 },
		[2819] = { name = L["Deadly Poison II"], rank = 2, duration = 12 },
		[11353] = { name = L["Deadly Poison III"], rank = 3, duration = 12 },
		[11354] = { name = L["Deadly Poison IV"], rank = 4, duration = 12 },
		[25349] = { name = L["Deadly Poison V"], rank = 5, duration = 12 },
	}
end
