local L = AceLibrary("AceLocale-2.2"):new("Cursive")
function getHunterSpells()
	return {
		[3043] = { name = L["scorpid sting"], rank = 1, duration = 20, travelTime = true },
		[14275] = { name = L["scorpid sting"], rank = 2, duration = 20, travelTime = true },
		[14276] = { name = L["scorpid sting"], rank = 3, duration = 20, travelTime = true },
		[14277] = { name = L["scorpid sting"], rank = 4, duration = 20, travelTime = true },

		[1978] = { name = L["serpent sting"], rank = 1, duration = 15, travelTime = true },
		[13549] = { name = L["serpent sting"], rank = 2, duration = 15, travelTime = true },
		[13550] = { name = L["serpent sting"], rank = 3, duration = 15, travelTime = true },
		[13551] = { name = L["serpent sting"], rank = 4, duration = 15, travelTime = true },
		[13552] = { name = L["serpent sting"], rank = 5, duration = 15, travelTime = true },
		[13553] = { name = L["serpent sting"], rank = 6, duration = 15, travelTime = true },
		[13554] = { name = L["serpent sting"], rank = 7, duration = 15, travelTime = true },
		[13555] = { name = L["serpent sting"], rank = 8, duration = 15, travelTime = true },
		[25295] = { name = L["serpent sting"], rank = 9, duration = 15, travelTime = true },

		[3034] = { name = L["viper sting"], rank = 1, duration = 8, travelTime = true },
		[14279] = { name = L["viper sting"], rank = 2, duration = 8, travelTime = true },
		[14280] = { name = L["viper sting"], rank = 3, duration = 8, travelTime = true },

		[2974] = { name = L["wing clip"], rank = 1, duration = 10 },
		[14267] = { name = L["wing clip"], rank = 2, duration = 10 },
		[14268] = { name = L["wing clip"], rank = 3, duration = 10 },

		[5116] = { name = L["concussive shot"], rank = 1, duration = 4, travelTime = true },

		[19386] = { name = L["wyvern sting"], rank = 1, duration = 12, travelTime = true },
		[24132] = { name = L["wyvern sting"], rank = 2, duration = 12, travelTime = true },
		[24133] = { name = L["wyvern sting"], rank = 3, duration = 12, travelTime = true },

		[19306] = { name = L["counterattack"], rank = 1, duration = 5 },
		[20909] = { name = L["counterattack"], rank = 2, duration = 5 },
		[20910] = { name = L["counterattack"], rank = 3, duration = 5 },

		[1130] = { name = L["hunter's mark"], rank = 1, duration = 120 },
		[14323] = { name = L["hunter's mark"], rank = 2, duration = 120 },
		[14324] = { name = L["hunter's mark"], rank = 3, duration = 120 },
		[14325] = { name = L["hunter's mark"], rank = 4, duration = 120 },
	}
end
