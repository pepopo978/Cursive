local L = AceLibrary("AceLocale-2.2"):new("Cursive")
function getShamanSpells()
	return {
		[8050] = { name = L["flame shock"], rank = 1, duration = 12, variable_duration = true },
		[8052] = { name = L["flame shock"], rank = 2, duration = 12, variable_duration = true },
		[8053] = { name = L["flame shock"], rank = 3, duration = 12, variable_duration = true },
		[10447] = { name = L["flame shock"], rank = 4, duration = 12, variable_duration = true },
		[10448] = { name = L["flame shock"], rank = 5, duration = 12, variable_duration = true },
		[29228] = { name = L["flame shock"], rank = 6, duration = 12, variable_duration = true },
	}
end
