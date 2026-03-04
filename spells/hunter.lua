local L = AceLibrary("AceLocale-2.2"):new("Cursive")
function getHunterSpells()
	return {
    [3043] = { name = L["scorpid sting"], rank = 1, duration = 21 }, -- 1 sec added to estimate travel time.  Can't use travelTime due to the spell having no direct damage component
    [14275] = { name = L["scorpid sting"], rank = 2, duration = 21 },
    [14276] = { name = L["scorpid sting"], rank = 3, duration = 21 },
    [14277] = { name = L["scorpid sting"], rank = 4, duration = 21 },

    [1978] = { name = L["serpent sting"], rank = 1, duration = 16 }, -- 1 sec added to estimate travel time.  Can't use travelTime due to the spell having no direct damage component
    [13549] = { name = L["serpent sting"], rank = 2, duration = 16 },
    [13550] = { name = L["serpent sting"], rank = 3, duration = 16 },
    [13551] = { name = L["serpent sting"], rank = 4, duration = 16 },
    [13552] = { name = L["serpent sting"], rank = 5, duration = 16 },
    [13553] = { name = L["serpent sting"], rank = 6, duration = 16 },
    [13554] = { name = L["serpent sting"], rank = 7, duration = 16 },
    [13555] = { name = L["serpent sting"], rank = 8, duration = 16 },
    [25295] = { name = L["serpent sting"], rank = 9, duration = 16 },

    [3034] = { name = L["viper sting"], rank = 1, duration = 9 }, -- 1 sec added to estimate travel time.  Can't use travelTime due to the spell having no direct damage component
    [14279] = { name = L["viper sting"], rank = 2, duration = 9 },
    [14280] = { name = L["viper sting"], rank = 3, duration = 9 },

    [19386] = { name = L["wyvern sting"], rank = 1, duration = 13 }, -- 1 sec added to estimate travel time.  Can't use travelTime due to the spell having no direct damage component
    [24132] = { name = L["wyvern sting"], rank = 2, duration = 13 },
    [24133] = { name = L["wyvern sting"], rank = 3, duration = 13 },

		[2974] = { name = L["wing clip"], rank = 1, duration = 10 },
		[14267] = { name = L["wing clip"], rank = 2, duration = 10 },
		[14268] = { name = L["wing clip"], rank = 3, duration = 10 },

    [5116] = { name = L["concussive shot"], rank = 1, duration = 5 }, -- 1 sec added to estimate travel time.  Can't use travelTime due to the spell having no direct damage component

		[19306] = { name = L["counterattack"], rank = 1, duration = 5 },
		[20909] = { name = L["counterattack"], rank = 2, duration = 5 },
		[20910] = { name = L["counterattack"], rank = 3, duration = 5 },

		[1130] = { name = L["hunter's mark"], rank = 1, duration = 120 },
		[14323] = { name = L["hunter's mark"], rank = 2, duration = 120 },
		[14324] = { name = L["hunter's mark"], rank = 3, duration = 120 },
		[14325] = { name = L["hunter's mark"], rank = 4, duration = 120 },
	}
end
