local L = AceLibrary("AceLocale-2.2"):new("Cursive")
function getDruidSpells()
	return {
		[339] = { name = L["Entangling Roots"], rank = 1, duration = 12 },
		[1062] = { name = L["Entangling Roots"], rank = 2, duration = 15 },
		[5195] = { name = L["Entangling Roots"], rank = 3, duration = 18 },
		[5196] = { name = L["Entangling Roots"], rank = 4, duration = 21 },
		[9852] = { name = L["Entangling Roots"], rank = 5, duration = 24 },
		[9853] = { name = L["Entangling Roots"], rank = 6, duration = 27 },

		[700] = { name = L["Sleep"], rank = 1, duration = 20 },
		[1090] = { name = L["Sleep"], rank = 2, duration = 30 },
		[2937] = { name = L["Sleep"], rank = 3, duration = 40 },

		[770] = { name = L["Faerie Fire"], rank = 1, duration = 40 },
		[778] = { name = L["Faerie Fire"], rank = 2, duration = 40 },
		[9749] = { name = L["Faerie Fire"], rank = 3, duration = 40 },
		[9907] = { name = L["Faerie Fire"], rank = 4, duration = 40 },

		[16855] = { name = L["Faerie Fire (Bear)"], rank = 1, duration = 40 },
		[17387] = { name = L["Faerie Fire (Bear)"], rank = 2, duration = 40 },
		[17388] = { name = L["Faerie Fire (Bear)"], rank = 3, duration = 40 },
		[17389] = { name = L["Faerie Fire (Bear)"], rank = 4, duration = 40 },

		[16857] = { name = L["Faerie Fire (Feral)"], rank = 1, duration = 40 },
		[17390] = { name = L["Faerie Fire (Feral)"], rank = 2, duration = 40 },
		[17391] = { name = L["Faerie Fire (Feral)"], rank = 3, duration = 40 },
		[17392] = { name = L["Faerie Fire (Feral)"], rank = 4, duration = 40 },

		[2637] = { name = L["Hibernate"], rank = 1, duration = 20 },
		[18657] = { name = L["Hibernate"], rank = 2, duration = 30 },
		[18658] = { name = L["Hibernate"], rank = 3, duration = 40 },

		[5570] = { name = L["Insect Swarm"], rank = 1, duration = 18, variable_duration = true },
		[24974] = { name = L["Insect Swarm"], rank = 2, duration = 18, variable_duration = true },
		[24975] = { name = L["Insect Swarm"], rank = 3, duration = 18, variable_duration = true },
		[24976] = { name = L["Insect Swarm"], rank = 4, duration = 18, variable_duration = true },
		[24977] = { name = L["Insect Swarm"], rank = 5, duration = 18, variable_duration = true },

		[8921] = { name = L["Moonfire"], rank = 1, duration = 9, variable_duration = true },
		[8924] = { name = L["Moonfire"], rank = 2, duration = 18, variable_duration = true },
		[8925] = { name = L["Moonfire"], rank = 3, duration = 18, variable_duration = true },
		[8926] = { name = L["Moonfire"], rank = 4, duration = 18, variable_duration = true },
		[8927] = { name = L["Moonfire"], rank = 5, duration = 18, variable_duration = true },
		[8928] = { name = L["Moonfire"], rank = 6, duration = 18, variable_duration = true },
		[8929] = { name = L["Moonfire"], rank = 7, duration = 18, variable_duration = true },
		[9833] = { name = L["Moonfire"], rank = 8, duration = 18, variable_duration = true },
		[9834] = { name = L["Moonfire"], rank = 9, duration = 18, variable_duration = true },
		[9835] = { name = L["Moonfire"], rank = 10, duration = 18, variable_duration = true },

		[1822] = { name = L["Rake"], rank = 1, duration = 9, variable_duration = true },
		[1823] = { name = L["Rake"], rank = 2, duration = 9, variable_duration = true },
		[1824] = { name = L["Rake"], rank = 3, duration = 9, variable_duration = true },
		[9904] = { name = L["Rake"], rank = 4, duration = 9, variable_duration = true },

		[1079] = { name = L["Rip"], rank = 1, duration = 12, variable_duration = true },
		[9492] = { name = L["Rip"], rank = 2, duration = 12, variable_duration = true },
		[9493] = { name = L["Rip"], rank = 3, duration = 12, variable_duration = true },
		[9752] = { name = L["Rip"], rank = 4, duration = 12, variable_duration = true },
		[9894] = { name = L["Rip"], rank = 5, duration = 12, variable_duration = true },
		[9896] = { name = L["Rip"], rank = 6, duration = 12, variable_duration = true },

		[2908] = { name = L["Soothe Animal"], rank = 1, duration = 15 },
		[8955] = { name = L["Soothe Animal"], rank = 2, duration = 15 },
		[9901] = { name = L["Soothe Animal"], rank = 3, duration = 15 },

		[5211] = { name = L["Bash"], rank = 1, duration = 2 },
		[6798] = { name = L["Bash"], rank = 2, duration = 3 },
		[8983] = { name = L["Bash"], rank = 3, duration = 4 },

		[99] = { name = L["Demoralizing Roar"], rank = 1, duration = 30 },
		[1735] = { name = L["Demoralizing Roar"], rank = 2, duration = 30 },
		[9490] = { name = L["Demoralizing Roar"], rank = 3, duration = 30 },
		[9747] = { name = L["Demoralizing Roar"], rank = 4, duration = 30 },
		[9898] = { name = L["Demoralizing Roar"], rank = 5, duration = 30 },

		[5209] = { name = L["Challenging Roar"], rank = 1, duration = 6 },
	}
end
