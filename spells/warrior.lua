local L = AceLibrary("AceLocale-2.2"):new("Cursive")
function getWarriorSpells()
	return {
		[772] = { name = L["rend"], rank = 1, duration = 9, meleeBleed=true },
		[6546] = { name = L["rend"], rank = 2, duration = 12, meleeBleed=true },
		[6547] = { name = L["rend"], rank = 3, duration = 15, meleeBleed=true },
		[6548] = { name = L["rend"], rank = 4, duration = 18, meleeBleed=true },
		[11572] = { name = L["rend"], rank = 5, duration = 21, meleeBleed=true },
		[11573] = { name = L["rend"], rank = 6, duration = 21, meleeBleed=true },
		[11574] = { name = L["rend"], rank = 7, duration = 21, meleeBleed=true },
	}
end
