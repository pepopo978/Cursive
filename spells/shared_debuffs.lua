local L = AceLibrary("AceLocale-2.2"):new("Cursive")
function getSharedDebuffs()
	return {
		faeriefire = {
			[770] = { name = L["faerie fire"], rank = 1, duration = 40 },
			[778] = { name = L["faerie fire"], rank = 2, duration = 40 },
			[9749] = { name = L["faerie fire"], rank = 3, duration = 40 },
			[9907] = { name = L["faerie fire"], rank = 4, duration = 40 },

			[16855] = { name = L["faerie fire"], rank = 1, duration = 40 }, -- use faerie fire instead of (bear) version so they block each other
			[17387] = { name = L["faerie fire"], rank = 2, duration = 40 },
			[17388] = { name = L["faerie fire"], rank = 3, duration = 40 },
			[17389] = { name = L["faerie fire"], rank = 4, duration = 40 },

			[16857] = { name = L["faerie fire"], rank = 1, duration = 40 }, -- use faerie fire instead of (feral) version so they block each other
			[17390] = { name = L["faerie fire"], rank = 2, duration = 40 },
			[17391] = { name = L["faerie fire"], rank = 3, duration = 40 },
			[17392] = { name = L["faerie fire"], rank = 4, duration = 40 },
		}
	}
end
