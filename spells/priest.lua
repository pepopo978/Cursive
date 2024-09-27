local L = AceLibrary("AceLocale-2.2"):new("Cursive")
function getPriestSpells()
	return {
		[1425] = { name = L["Shackle Undead"], rank = 1, duration = 30 },
		[9486] = { name = L["Shackle Undead"], rank = 2, duration = 40 },
		[10956] = { name = L["Shackle Undead"], rank = 3, duration = 50 },

		[453] = { name = L["Mind Soothe"], rank = 1, duration = 15 },
		[8192] = { name = L["Mind Soothe"], rank = 2, duration = 15 },
		[10953] = { name = L["Mind Soothe"], rank = 3, duration = 15 },

		[605] = { name = L["Mind Control"], rank = 1, duration = 60 },
		[10911] = { name = L["Mind Control"], rank = 2, duration = 30 },
		[10912] = { name = L["Mind Control"], rank = 3, duration = 30 },

		[2944] = { name = L["Devouring Plague"], rank = 1, duration = 24 },
		[19276] = { name = L["Devouring Plague"], rank = 2, duration = 24 },
		[19277] = { name = L["Devouring Plague"], rank = 3, duration = 24 },
		[19278] = { name = L["Devouring Plague"], rank = 4, duration = 24 },
		[19279] = { name = L["Devouring Plague"], rank = 5, duration = 24 },
		[19280] = { name = L["Devouring Plague"], rank = 6, duration = 24 },

		[9035] = { name = L["Hex of Weakness"], rank = 1, duration = 120 },
		[19281] = { name = L["Hex of Weakness"], rank = 2, duration = 120 },
		[19282] = { name = L["Hex of Weakness"], rank = 3, duration = 120 },
		[19283] = { name = L["Hex of Weakness"], rank = 4, duration = 120 },
		[19284] = { name = L["Hex of Weakness"], rank = 5, duration = 120 },
		[19285] = { name = L["Hex of Weakness"], rank = 6, duration = 120 },

		[589] = { name = L["Shadow Word: Pain"], rank = 1, duration = 24 },  -- assume they have talent
		[594] = { name = L["Shadow Word: Pain"], rank = 2, duration = 24 },
		[970] = { name = L["Shadow Word: Pain"], rank = 3, duration = 24 },
		[992] = { name = L["Shadow Word: Pain"], rank = 4, duration = 24 },
		[2767] = { name = L["Shadow Word: Pain"], rank = 5, duration = 24 },
		[10892] = { name = L["Shadow Word: Pain"], rank = 6, duration = 24 },
		[10893] = { name = L["Shadow Word: Pain"], rank = 7, duration = 24 },
		[10894] = { name = L["Shadow Word: Pain"], rank = 8, duration = 24 },

		[15286] = { name = L["Vampiric Embrace"], rank = 1, duration = 60 },

		[14914] = { name = L["Holy Fire"], rank = 1, duration = 10 },
		[15262] = { name = L["Holy Fire"], rank = 2, duration = 10 },
		[15263] = { name = L["Holy Fire"], rank = 3, duration = 10 },
		[15264] = { name = L["Holy Fire"], rank = 4, duration = 10 },
		[15265] = { name = L["Holy Fire"], rank = 5, duration = 10 },
		[15266] = { name = L["Holy Fire"], rank = 6, duration = 10 },
		[15267] = { name = L["Holy Fire"], rank = 7, duration = 10 },
		[15261] = { name = L["Holy Fire"], rank = 8, duration = 10 },
	}
end
