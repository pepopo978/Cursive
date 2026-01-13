local L = AceLibrary("AceLocale-2.2"):new("Cursive")
function getPriestSpells()
	return {
		[9484] = { name = L["shackle undead"], rank = 1, duration = 30 },
		[9485] = { name = L["shackle undead"], rank = 2, duration = 40 },
		[10955] = { name = L["shackle undead"], rank = 3, duration = 50 },

		[453] = { name = L["mind soothe"], rank = 1, duration = 15 },
		[8192] = { name = L["mind soothe"], rank = 2, duration = 15 },
		[10953] = { name = L["mind soothe"], rank = 3, duration = 15 },

		[605] = { name = L["mind control"], rank = 1, duration = 60 },
		[10911] = { name = L["mind control"], rank = 2, duration = 30 },
		[10912] = { name = L["mind control"], rank = 3, duration = 30 },

		[2944] = { name = L["devouring plague"], rank = 1, duration = 24 },
		[19276] = { name = L["devouring plague"], rank = 2, duration = 24 },
		[19277] = { name = L["devouring plague"], rank = 3, duration = 24 },
		[19278] = { name = L["devouring plague"], rank = 4, duration = 24 },
		[19279] = { name = L["devouring plague"], rank = 5, duration = 24 },
		[19280] = { name = L["devouring plague"], rank = 6, duration = 24 },

		[9035] = { name = L["hex of weakness"], rank = 1, duration = 120 },
		[19281] = { name = L["hex of weakness"], rank = 2, duration = 120 },
		[19282] = { name = L["hex of weakness"], rank = 3, duration = 120 },
		[19283] = { name = L["hex of weakness"], rank = 4, duration = 120 },
		[19284] = { name = L["hex of weakness"], rank = 5, duration = 120 },
		[19285] = { name = L["hex of weakness"], rank = 6, duration = 120 },

		[589] = { name = L["shadow word: pain"], rank = 1, duration = 24, variableDuration = true }, -- assume they have talent
		[594] = { name = L["shadow word: pain"], rank = 2, duration = 24, variableDuration = true },
		[970] = { name = L["shadow word: pain"], rank = 3, duration = 24, variableDuration = true },
		[992] = { name = L["shadow word: pain"], rank = 4, duration = 24, variableDuration = true },
		[2767] = { name = L["shadow word: pain"], rank = 5, duration = 24, variableDuration = true },
		[10892] = { name = L["shadow word: pain"], rank = 6, duration = 24, variableDuration = true },
		[10893] = { name = L["shadow word: pain"], rank = 7, duration = 24, variableDuration = true },
		[10894] = { name = L["shadow word: pain"], rank = 8, duration = 24, variableDuration = true },

		[15286] = { name = L["vampiric embrace"], rank = 1, duration = 60 },

		[14914] = { name = L["holy fire"], rank = 1, duration = 10 },
		[15262] = { name = L["holy fire"], rank = 2, duration = 10 },
		[15263] = { name = L["holy fire"], rank = 3, duration = 10 },
		[15264] = { name = L["holy fire"], rank = 4, duration = 10 },
		[15265] = { name = L["holy fire"], rank = 5, duration = 10 },
		[15266] = { name = L["holy fire"], rank = 6, duration = 10 },
		[15267] = { name = L["holy fire"], rank = 7, duration = 10 },
		[15261] = { name = L["holy fire"], rank = 8, duration = 10 },
	}
end
