local L = AceLibrary("AceLocale-2.2"):new("Cursive")
function getWarlockSpells()
	return {
		[172] = { name = L["Corruption"], rank = 1, duration = 12, rapid_deterioration = true },
		[6222] = { name = L["Corruption"], rank = 2, duration = 15, rapid_deterioration = true },
		[6223] = { name = L["Corruption"], rank = 3, duration = 18, rapid_deterioration = true },
		[7648] = { name = L["Corruption"], rank = 4, duration = 18, rapid_deterioration = true },
		[11671] = { name = L["Corruption"], rank = 5, duration = 18, rapid_deterioration = true },
		[11672] = { name = L["Corruption"], rank = 6, duration = 18, rapid_deterioration = true },
		[25311] = { name = L["Corruption"], rank = 7, duration = 18, rapid_deterioration = true },

		[980] = { name = L["Curse of Agony"], rank = 1, duration = 24, rapid_deterioration = true },
		[1014] = { name = L["Curse of Agony"], rank = 2, duration = 24, rapid_deterioration = true },
		[6217] = { name = L["Curse of Agony"], rank = 3, duration = 24, rapid_deterioration = true },
		[11711] = { name = L["Curse of Agony"], rank = 4, duration = 24, rapid_deterioration = true },
		[11712] = { name = L["Curse of Agony"], rank = 5, duration = 24, rapid_deterioration = true },
		[11713] = { name = L["Curse of Agony"], rank = 6, duration = 24, rapid_deterioration = true },

		[603] = { name = L["Curse of Doom"], rank = 1, duration = 60 },

		[704] = { name = L["Curse of Recklessness"], rank = 1, duration = 120 },
		[7658] = { name = L["Curse of Recklessness"], rank = 2, duration = 120 },
		[7659] = { name = L["Curse of Recklessness"], rank = 3, duration = 120 },
		[11717] = { name = L["Curse of Recklessness"], rank = 4, duration = 120 },

		[17862] = { name = L["Curse of Shadow"], rank = 1, duration = 300 },
		[17937] = { name = L["Curse of Shadow"], rank = 2, duration = 300 },

		[1490] = { name = L["Curse of the Elements"], rank = 1, duration = 300 },
		[11721] = { name = L["Curse of the Elements"], rank = 2, duration = 300 },
		[11722] = { name = L["Curse of the Elements"], rank = 3, duration = 300 },

		[1714] = { name = L["Curse of Tongues"], rank = 1, duration = 30 },
		[11719] = { name = L["Curse of Tongues"], rank = 2, duration = 30 },

		[702] = { name = L["Curse of Weakness"], rank = 1, duration = 120 },
		[1108] = { name = L["Curse of Weakness"], rank = 2, duration = 120 },
		[6205] = { name = L["Curse of Weakness"], rank = 3, duration = 120 },
		[7646] = { name = L["Curse of Weakness"], rank = 4, duration = 120 },
		[11707] = { name = L["Curse of Weakness"], rank = 5, duration = 120 },
		[11708] = { name = L["Curse of Weakness"], rank = 6, duration = 120 },

		[18223] = { name = L["Curse of Exhaustion"], rank = 1, duration = 12 },

		[348] = { name = L["Immolate"], rank = 1, duration = 15 },
		[707] = { name = L["Immolate"], rank = 2, duration = 15 },
		[1094] = { name = L["Immolate"], rank = 3, duration = 15 },
		[2941] = { name = L["Immolate"], rank = 4, duration = 15 },
		[11665] = { name = L["Immolate"], rank = 5, duration = 15 },
		[11667] = { name = L["Immolate"], rank = 6, duration = 15 },
		[11668] = { name = L["Immolate"], rank = 7, duration = 15 },
		[25309] = { name = L["Immolate"], rank = 8, duration = 15 },

		[6789] = { name = L["Death Coil"], rank = 1, duration = 3 },
		[17925] = { name = L["Death Coil"], rank = 2, duration = 3 },
		[17926] = { name = L["Death Coil"], rank = 3, duration = 3 },

		[710] = { name = L["Banish"], rank = 1, duration = 20 },
		[18647] = { name = L["Banish"], rank = 2, duration = 30 },

		[18265] = { name = L["Siphon Life"], rank = 1, duration = 30, rapid_deterioration = true },
		[18879] = { name = L["Siphon Life"], rank = 2, duration = 30, rapid_deterioration = true },
		[18880] = { name = L["Siphon Life"], rank = 3, duration = 30, rapid_deterioration = true },
		[18881] = { name = L["Siphon Life"], rank = 4, duration = 30, rapid_deterioration = true },

		[5782] = { name = L["Fear"], rank = 1, duration = 10 },
		[6213] = { name = L["Fear"], rank = 2, duration = 15 },
		[6215] = { name = L["Fear"], rank = 3, duration = 20 },
	}
end
