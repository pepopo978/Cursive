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
		},
		sunderarmor = {
			[7386] = { name = L["sunder armor"], rank = 1, duration = 30 },
			[7405] = { name = L["sunder armor"], rank = 2, duration = 30 },
			[8380] = { name = L["sunder armor"], rank = 3, duration = 30 },
			[11596] = { name = L["sunder armor"], rank = 4, duration = 30 },
			[11597] = { name = L["sunder armor"], rank = 5, duration = 30 },
			[25225] = { name = L["sunder armor"], rank = 6, duration = 30 },
		},
		exposearmor = {
			[8647] = { name = L["expose armor"], rank = 1, duration = 30 },
			[8649] = { name = L["expose armor"], rank = 2, duration = 30 },
			[8650] = { name = L["expose armor"], rank = 3, duration = 30 },
			[11197] = { name = L["expose armor"], rank = 4, duration = 30 },
			[11198] = { name = L["expose armor"], rank = 5, duration = 30 },
		},
	curseofrecklessness = {
		[704] = { name = L["curse of recklessness"], rank = 1, duration = 120 },
		[7658] = { name = L["curse of recklessness"], rank = 2, duration = 120 },
		[7659] = { name = L["curse of recklessness"], rank = 3, duration = 120 },
		[11717] = { name = L["curse of recklessness"], rank = 4, duration = 120 },
	}
}
end
