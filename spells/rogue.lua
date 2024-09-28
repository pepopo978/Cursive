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
	}
end
