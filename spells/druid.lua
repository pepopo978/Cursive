function getRipDuration()
	return 8 + GetComboPoints() * 2
end

local L = AceLibrary("AceLocale-2.2"):new("Cursive")
function getDruidSpells()
	return {
		[339] = { name = L["entangling roots"], rank = 1, duration = 12 },
		[1062] = { name = L["entangling roots"], rank = 2, duration = 15 },
		[5195] = { name = L["entangling roots"], rank = 3, duration = 18 },
		[5196] = { name = L["entangling roots"], rank = 4, duration = 21 },
		[9852] = { name = L["entangling roots"], rank = 5, duration = 24 },
		[9853] = { name = L["entangling roots"], rank = 6, duration = 27 },

		[700] = { name = L["sleep"], rank = 1, duration = 20 },
		[1090] = { name = L["sleep"], rank = 2, duration = 30 },
		[2937] = { name = L["sleep"], rank = 3, duration = 40 },

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

		[2637] = { name = L["hibernate"], rank = 1, duration = 20 },
		[18657] = { name = L["hibernate"], rank = 2, duration = 30 },
		[18658] = { name = L["hibernate"], rank = 3, duration = 40 },

		[5570] = { name = L["insect swarm"], rank = 1, duration = 18, variableDuration = true },
		[24974] = { name = L["insect swarm"], rank = 2, duration = 18, variableDuration = true },
		[24975] = { name = L["insect swarm"], rank = 3, duration = 18, variableDuration = true },
		[24976] = { name = L["insect swarm"], rank = 4, duration = 18, variableDuration = true },
		[24977] = { name = L["insect swarm"], rank = 5, duration = 18, variableDuration = true },

		[8921] = { name = L["moonfire"], rank = 1, duration = 9, variableDuration = true },
		[8924] = { name = L["moonfire"], rank = 2, duration = 18, variableDuration = true },
		[8925] = { name = L["moonfire"], rank = 3, duration = 18, variableDuration = true },
		[8926] = { name = L["moonfire"], rank = 4, duration = 18, variableDuration = true },
		[8927] = { name = L["moonfire"], rank = 5, duration = 18, variableDuration = true },
		[8928] = { name = L["moonfire"], rank = 6, duration = 18, variableDuration = true },
		[8929] = { name = L["moonfire"], rank = 7, duration = 18, variableDuration = true },
		[9833] = { name = L["moonfire"], rank = 8, duration = 18, variableDuration = true },
		[9834] = { name = L["moonfire"], rank = 9, duration = 18, variableDuration = true },
		[9835] = { name = L["moonfire"], rank = 10, duration = 18, variableDuration = true },

		[1822] = { name = L["rake"], rank = 1, duration = 9, variableDuration = true },
		[1823] = { name = L["rake"], rank = 2, duration = 9, variableDuration = true },
		[1824] = { name = L["rake"], rank = 3, duration = 9, variableDuration = true },
		[9904] = { name = L["rake"], rank = 4, duration = 9, variableDuration = true },

		[1079] = { name = L["rip"], rank = 1, duration = 8, calculateDuration = getRipDuration },
		[9492] = { name = L["rip"], rank = 2, duration = 8, calculateDuration = getRipDuration },
		[9493] = { name = L["rip"], rank = 3, duration = 8, calculateDuration = getRipDuration },
		[9752] = { name = L["rip"], rank = 4, duration = 8, calculateDuration = getRipDuration },
		[9894] = { name = L["rip"], rank = 5, duration = 8, calculateDuration = getRipDuration },
		[9896] = { name = L["rip"], rank = 6, duration = 8, calculateDuration = getRipDuration },

		[2908] = { name = L["soothe animal"], rank = 1, duration = 15 },
		[8955] = { name = L["soothe animal"], rank = 2, duration = 15 },
		[9901] = { name = L["soothe animal"], rank = 3, duration = 15 },

		[5211] = { name = L["bash"], rank = 1, duration = 2 },
		[6798] = { name = L["bash"], rank = 2, duration = 3 },
		[8983] = { name = L["bash"], rank = 3, duration = 4 },

		[99] = { name = L["demoralizing roar"], rank = 1, duration = 30 },
		[1735] = { name = L["demoralizing roar"], rank = 2, duration = 30 },
		[9490] = { name = L["demoralizing roar"], rank = 3, duration = 30 },
		[9747] = { name = L["demoralizing roar"], rank = 4, duration = 30 },
		[9898] = { name = L["demoralizing roar"], rank = 5, duration = 30 },

		[5209] = { name = L["challenging roar"], rank = 1, duration = 6 },

		[9005] = { name = L["pounce bleed"], rank = 1, duration = 18 },
		[9823] = { name = L["pounce bleed"], rank = 2, duration = 18 },
		[9827] = { name = L["pounce bleed"], rank = 3, duration = 18 },
	}
end
