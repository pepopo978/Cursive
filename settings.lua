if not Cursive.superwow then
	return
end

Cursive:RegisterDB("CursiveDB")
Cursive:RegisterDefaults("profile", {
	caption = "Cursive",
	anchor = "CENTER",
	x = -240,
	y = 120,

	-- editable
	enabled = true,
	clickthrough = false,
	showbackdrop = false,
	showtitle = true,

	scale = 1,
	healthwidth = 100,
	height = 16,
	raidiconsize = 16,
	curseiconsize = 16,
	maxcurses = 3,
	spacing = 4,
	maxrow = 10,
	maxcol = 1,
	textsize = 9,

	filterincombat = true,
	filterhostile = true,
	filterattackable = true,
	filterrange = false,
	filterraidmark = false,
})

local barOptions = {
	["barwidth"] = {
		type = "range",
		name = "Health Bar Width",
		desc = "Health Bar Width",
		order = 10,
		min = 30,
		max = 150,
		step = 5,
		get = function()
			return Cursive.db.profile.healthwidth
		end,
		set = function(v)
			if v ~= Cursive.db.profile.healthwidth then
				Cursive.db.profile.healthwidth = v
				Cursive.UpdateFramesFromConfig()
			end
		end,
	},
	["barheight"] = {
		type = "range",
		name = "Health Bar Height",
		desc = "Health Bar Height",
		order = 20,
		min = 10,
		max = 30,
		step = 2,
		get = function()
			return Cursive.db.profile.height
		end,
		set = function(v)
			if v ~= Cursive.db.profile.height then
				Cursive.db.profile.height = v
				Cursive.UpdateFramesFromConfig()
			end
		end,
	},
	["raidiconsize"] = {
		type = "range",
		name = "Raid Icon Size",
		desc = "Raid Icon Size",
		order = 30,
		min = 10,
		max = 30,
		step = 1,
		get = function()
			return Cursive.db.profile.raidiconsize
		end,
		set = function(v)
			if v ~= Cursive.db.profile.raidiconsize then
				Cursive.db.profile.raidiconsize = v
				Cursive.UpdateFramesFromConfig()
			end
		end,
	},
	["curseiconsize"] = {
		type = "range",
		name = "Curse Icon Size",
		desc = "Curse Icon Size",
		order = 40,
		min = 10,
		max = 30,
		step = 1,
		get = function()
			return Cursive.db.profile.curseiconsize
		end,
		set = function(v)
			if v ~= Cursive.db.profile.curseiconsize then
				Cursive.db.profile.curseiconsize = v
				Cursive.UpdateFramesFromConfig()
			end
		end,
	},
	["spacing"] = {
		type = "range",
		name = "Spacing",
		desc = "Spacing",
		order = 50,
		min = 0,
		max = 10,
		step = 1,
		get = function()
			return Cursive.db.profile.spacing
		end,
		set = function(v)
			if v ~= Cursive.db.profile.spacing then
				Cursive.db.profile.spacing = v
				Cursive.UpdateFramesFromConfig()
			end
		end,
	},
	["textsize"] = {
		type = "range",
		name = "Text Size",
		desc = "Text Size",
		order = 60,
		min = 8,
		max = 20,
		step = 1,
		get = function()
			return Cursive.db.profile.textsize
		end,
		set = function(v)
			if v ~= Cursive.db.profile.textsize then
				Cursive.db.profile.textsize = v
				Cursive.UpdateFramesFromConfig()
			end
		end,
	},
	["scale"] = {
		type = "range",
		name = "Scale",
		desc = "Scale",
		order = 70,
		min = 0.5,
		max = 2,
		step = 0.1,
		get = function()
			return Cursive.db.profile.scale
		end,
		set = function(v)
			if v ~= Cursive.db.profile.scale then
				Cursive.db.profile.scale = v
				Cursive.UpdateFramesFromConfig()
			end
		end,
	},
}

local mobFilters = {
	["incombat"] = {
		type = "toggle",
		name = "In Combat",
		desc = "In Combat",
		order = 1,
		get = function()
			return Cursive.db.profile.filterincombat
		end,
		set = function(v)
			Cursive.db.profile.filterincombat = v
		end,
	},
	["hostile"] = {
		type = "toggle",
		name = "Hostile",
		desc = "Hostile",
		order = 2,
		get = function()
			return Cursive.db.profile.filterhostile
		end,
		set = function(v)
			Cursive.db.profile.filterhostile = v
		end,
	},
	["attackable"] = {
		type = "toggle",
		name = "Attackable",
		desc = "Attackable",
		order = 3,
		get = function()
			return Cursive.db.profile.filterattackable
		end,
		set = function(v)
			Cursive.db.profile.filterattackable = v
		end,
	},
	["range"] = {
		type = "toggle",
		name = "Within 28 Range",
		desc = "Within 28 Range",
		order = 4,
		get = function()
			return Cursive.db.profile.filterrange
		end,
		set = function(v)
			Cursive.db.profile.filterrange = v
		end,
	},
	["raidmark"] = {
		type = "toggle",
		name = "Has Raid Mark",
		desc = "Has Raid Mark",
		order = 5,
		get = function()
			return Cursive.db.profile.filterraidmark
		end,
		set = function(v)
			Cursive.db.profile.filterraidmark = v
		end,
	},
}

Cursive.cmdtable = {
	type = "group",
	handler = Cursive,
	args = {
		["enabled"] = {
			type = "toggle",
			name = "Enabled",
			desc = "Enable/Disable Cursive",
			order = 1,
			get = function()
				return Cursive.db.profile.enabled
			end,
			set = function(v)
				Cursive.db.profile.enabled = v
				if v == true then
					Cursive.core.enable()
				else
					Cursive.core.disable()
				end
			end,
		},
		["showtitle"] = {
			type = "toggle",
			name = "Show Title",
			desc = "Show the title of the frame",
			order = 3,
			get = function()
				return Cursive.db.profile.showtitle
			end,
			set = function(v)
				Cursive.db.profile.showtitle = v
				Cursive.UpdateFramesFromConfig()
			end,
		},
		["clickthrough"] = {
			type = "toggle",
			name = "Allow clickthrough",
			desc = "This will allow you to click through the frame to target mobs behind it, but prevents dragging the frame.",
			order = 5,
			get = function()
				return Cursive.db.profile.clickthrough
			end,
			set = function(v)
				Cursive.db.profile.clickthrough = v
				Cursive.UpdateFramesFromConfig()
			end,
		},
		["showbackdrop"] = {
			type = "toggle",
			name = "Show Frame Background",
			desc = "Toggle the frame background to help with positioning",
			order = 7,
			get = function()
				return Cursive.db.profile.showbackdrop
			end,
			set = function(v)
				Cursive.db.profile.showbackdrop = v
				Cursive.UpdateFramesFromConfig()
			end,
		},
		["resetframe"] = {
			type = "execute",
			name = "Reset Frame",
			desc = "Move the frame back to the default position",
			order = 9,
			func = function()
				Cursive.db.profile.anchor = "CENTER"
				Cursive.db.profile.x = -100
				Cursive.db.profile.y = -100
				Cursive.UpdateFramesFromConfig()
			end,
		},
		["spacer"] = {
			type = "header",
			name = " ",
			order = 11,
		},
		["bardisplay"] = {
			type = "group",
			name = "Bar Display Settings",
			desc = "Bar Display Settings",
			order = 13,
			args = barOptions
		},
		["filters"] = {
			type = "group",
			name = "Mob filters",
			desc = "Target and Raid Marks always shown",
			order = 20,
			args = mobFilters
		},
		["spacer2"] = {
			type = "header",
			name = " ",
			order = 21,
		},
		["maxcurses"] = {
			type = "range",
			name = "Max Curses",
			desc = "Max Curses",
			order = 22,
			min = 1,
			max = 8,
			step = 1,
			get = function()
				return Cursive.db.profile.maxcurses
			end,
			set = function(v)
				if v ~= Cursive.db.profile.maxcurses then
					Cursive.db.profile.maxcurses = v
					Cursive.UpdateFramesFromConfig()
				end
			end,
		},
		["maxrow"] = {
			type = "range",
			name = "Max Rows",
			desc = "Max Rows",
			order = 30,
			min = 1,
			max = 20,
			step = 1,
			get = function()
				return Cursive.db.profile.maxrow
			end,
			set = function(v)
				if v ~= Cursive.db.profile.maxrow then
					Cursive.db.profile.maxrow = v
					Cursive.UpdateFramesFromConfig()
				end
			end,
		},
		["maxcol"] = {
			type = "range",
			name = "Max Columns",
			desc = "Max Columns",
			order = 40,
			min = 1,
			max = 20,
			step = 1,
			get = function()
				return Cursive.db.profile.maxcol
			end,
			set = function(v)
				if v ~= Cursive.db.profile.maxcol then
					Cursive.db.profile.maxcol = v
					Cursive.UpdateFramesFromConfig()
				end
			end,
		},
	}
}

local deuce = Cursive:NewModule("Options Menu")
deuce.hasFuBar = IsAddOnLoaded("FuBar") and FuBar
deuce.consoleCmd = not deuce.hasFuBar

CursiveOptions = AceLibrary("AceAddon-2.0"):new("AceDB-2.0", "FuBarPlugin-2.0")
CursiveOptions.name = "FuBar - Cursive"
CursiveOptions:RegisterDB("CursiveDB")
CursiveOptions.hasIcon = "Interface\\Icons\\spell_shadow_deathcoil"
CursiveOptions.defaultMinimapPosition = 180
CursiveOptions.independentProfile = true
CursiveOptions.hideWithoutStandby = false

-- XXX total hack
CursiveOptions.OnMenuRequest = Cursive.cmdtable
local args = AceLibrary("FuBarPlugin-2.0"):GetAceOptionsDataTable(CursiveOptions)
for k, v in pairs(args) do
	if CursiveOptions.OnMenuRequest.args[k] == nil then
		CursiveOptions.OnMenuRequest.args[k] = v
	end
end
-- XXX end hack
