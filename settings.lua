if not Cursive.superwow then
	return
end

local L = AceLibrary("AceLocale-2.2"):new("Cursive")
Cursive:RegisterDB("CursiveDB")
Cursive:RegisterDefaults("profile", {
	caption = L["Cursive"],
	anchor = "CENTER",
	x = -240,
	y = 120,

	-- editable
	enabled = true,
	clickthrough = false,
	showbackdrop = false,
	showtitle = true,
	showtargetindicator = true,
	showraidicons = true,
	showhealthbar = true,
	showunitname = true,

	shareddebuffs = {
		faeriefire = false,
	},

	alwaysshowcurrenttarget = true,

	scale = 1,
	healthwidth = 100,
	height = 16,
	bartexture = "Interface\\TargetingFrame\\UI-StatusBar",

	raidiconsize = 16,
	curseiconsize = 16,
	maxcurses = 5,
	spacing = 4,
	maxrow = 10,
	maxcol = 1,
	textsize = 9,

	curseordering = L["Expiring soonest -> latest"],
	curseshowdecimals = false,
	invertbars = false,
	expandupwards = false,

	filterincombat = true,
	filterhostile = true,
	filterattackable = true,
	filterrange = false,
	filterraidmark = false,
	filterhascurse = false,
	filterignored = true,

	ignorelist = {},
})

local function splitString(str, delimiter)
	local result = {}
	local from = 1
	local delim_from, delim_to = string.find(str, delimiter, from)
	while delim_from do
		table.insert(result, string.sub(str, from, delim_from - 1))
		from = delim_to + 1
		delim_from, delim_to = string.find(str, delimiter, from)
	end
	table.insert(result, string.sub(str, from))
	return result
end

local barOptions = {
	["invertbars"] = {
		type = "toggle",
		name = "Invert Bar Display",
		desc = "Show sections in order 3-2-1 and reverse element order in sections 1 and 3",
		order = 1,
		get = function()
			return Cursive.db.profile.invertbars
		end,
		set = function(v)
			Cursive.db.profile.invertbars = v
			Cursive.UpdateFramesFromConfig()
		end,
	},
	["expandupwards"] = {
		type = "toggle",
		name = "Expand Bars Upwards",
		desc = "Make bars expand upwards instead of downwards",
		order = 2,
		get = function()
			return Cursive.db.profile.expandupwards
		end,
		set = function(v)
			Cursive.db.profile.expandupwards = v
			Cursive.UpdateFramesFromConfig()
		end,
	},
	["spacer1"] = {
		type = "header",
		name = "Section Display",
		order = 5,
	},
	["showtargetindicator"] = {
		type = "toggle",
		name = L["Show Targeting Arrow"],
		desc = L["Show Targeting Arrow"],
		order = 10,
		get = function()
			return Cursive.db.profile.showtargetindicator
		end,
		set = function(v)
			Cursive.db.profile.showtargetindicator = v
			Cursive.UpdateFramesFromConfig()
		end,
	},
	["showraidicons"] = {
		type = "toggle",
		name = L["Show Raid Icons"],
		desc = L["Show Raid Icons"],
		order = 15,
		get = function()
			return Cursive.db.profile.showraidicons
		end,
		set = function(v)
			Cursive.db.profile.showraidicons = v
			Cursive.UpdateFramesFromConfig()
		end,
	},
	["showhealthbar"] = {
		type = "toggle",
		name = L["Show Health Bar"],
		desc = L["Show Health Bar"],
		order = 20,
		get = function()
			return Cursive.db.profile.showhealthbar
		end,
		set = function(v)
			Cursive.db.profile.showhealthbar = v
			Cursive.UpdateFramesFromConfig()
		end,
	},
	["showunitname"] = {
		type = "toggle",
		name = L["Show Unit Name"],
		desc = L["Show Unit Name"],
		order = 25,
		get = function()
			return Cursive.db.profile.showunitname
		end,
		set = function(v)
			Cursive.db.profile.showunitname = v
			Cursive.UpdateFramesFromConfig()
		end,
	},
	["alwaysshowcurrenttarget"] = {
		type = "toggle",
		name = "Always Show Current Target",
		desc = "Always show current target at the bottom of the mob list if it is not already shown",
		order = 30,
		get = function()
			return Cursive.db.profile.alwaysshowcurrenttarget
		end,
		set = function(v)
			Cursive.db.profile.alwaysshowcurrenttarget = v
		end,
	},
	["spacer2"] = {
		type = "header",
		name = "Size & Appearance",
		order = 35,
	},
	["barwidth"] = {
		type = "range",
		name = L["Health Bar/Unit Name Width"],
		desc = L["Health Bar/Unit Name Width"],
		order = 40,
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
		name = L["Health Bar/Unit Name Height"],
		desc = L["Health Bar/Unit Name Height"],
		order = 50,
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
	["bartexture"] = {
		type = "text",
		name = L["Health Bar Texture"],
		desc = L["Health Bar Texture Desc"],
		order = 55,
		usage = "Interface\\TargetingFrame\\UI-StatusBar",
		get = function()
			return Cursive.db.profile.bartexture
		end,
		set = function(v)
			if v ~= Cursive.db.profile.bartexture then
				Cursive.db.profile.bartexture = v
				Cursive.UpdateFramesFromConfig()
			end
		end,
	},
	["raidiconsize"] = {
		type = "range",
		name = L["Raid Icon Size"],
		desc = L["Raid Icon Size"],
		order = 60,
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
		name = L["Curse Icon Size"],
		desc = L["Curse Icon Size"],
		order = 70,
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
	["curseordering"] = {
		type = "text",
		name = L["Curse Ordering"],
		desc = L["Curse Ordering"],
		order = 72,
		get = function()
			return Cursive.db.profile.curseordering
		end,
		validate = { L["Order applied"], L["Expiring soonest -> latest"], L["Expiring latest -> soonest"] },
		set = function(v)
			Cursive.db.profile.curseordering = v
		end,
	},
	["curseshowdecimals"] = {
		type = "toggle",
		name = L["Decimal Duration"],
		desc = L["Decimal Duration Desc"],
		order = 74,
		get = function()
			return Cursive.db.profile.curseshowdecimals
		end,
		set = function(v)
			Cursive.db.profile.curseshowdecimals = v
			Cursive.UpdateFramesFromConfig()
		end,
	},
	["spacing"] = {
		type = "range",
		name = L["Spacing"],
		desc = L["Spacing"],
		order = 80,
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
		name = L["Text Size"],
		desc = L["Text Size"],
		order = 90,
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
		name = L["Scale"],
		desc = L["Scale"],
		order = 100,
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
		name = L["In Combat"],
		desc = L["In Combat"],
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
		name = L["Hostile"],
		desc = L["Hostile"],
		order = 11,
		get = function()
			return Cursive.db.profile.filterhostile
		end,
		set = function(v)
			Cursive.db.profile.filterhostile = v
		end,
	},
	["attackable"] = {
		type = "toggle",
		name = L["Attackable"],
		desc = L["Attackable"],
		order = 22,
		get = function()
			return Cursive.db.profile.filterattackable
		end,
		set = function(v)
			Cursive.db.profile.filterattackable = v
		end,
	},
	["player"] = {
		type = "toggle",
		name = L["Player"],
		desc = L["Player Desc"],
		order = 33,
		get = function()
			return Cursive.db.profile.filterplayer
		end,
		set = function(v)
			Cursive.db.profile.filterplayer = v
		end,
	},
	["notplayer"] = {
		type = "toggle",
		name = L["Not Player"],
		desc = L["Not Player Desc"],
		order = 33,
		get = function()
			return Cursive.db.profile.filternotplayer
		end,
		set = function(v)
			Cursive.db.profile.filternotplayer = v
		end,
	},
	["range"] = {
		type = "toggle",
		name = IsSpellInRange and L["Within 45 Range"] or L["Within 28 Range"],
		desc = IsSpellInRange and L["Within 45 Range"] or L["Within 28 Range"],
		order = 44,
		get = function()
			return Cursive.db.profile.filterrange
		end,
		set = function(v)
			Cursive.db.profile.filterrange = v
		end,
	},
	["raidmark"] = {
		type = "toggle",
		name = L["Has Raid Mark"],
		desc = L["Has Raid Mark"],
		order = 55,
		get = function()
			return Cursive.db.profile.filterraidmark
		end,
		set = function(v)
			Cursive.db.profile.filterraidmark = v
		end,
	},
	["hascurse"] = {
		type = "toggle",
		name = L["Has Curse"],
		desc = L["Only show units you have cursed"],
		order = 66,
		get = function()
			return Cursive.db.profile.filterhascurse
		end,
		set = function(v)
			Cursive.db.profile.filterhascurse = v
		end,
	},
	["notignored"] = {
		type = "toggle",
		name = L["Not ignored"],
		desc = L["Not ignored"],
		order = 67,
		get = function()
			return Cursive.db.profile.filterignored
		end,
		set = function(v)
			Cursive.db.profile.filterignored = v
		end,
	},
	["ignorelist"] = {
		type = "text",
		name = L["Ignored Mobs List (Enter to save)"],
		desc = L["Comma separated list of strings to ignore if found in the unit name"],
		usage = "whelp, black dragonkin, player3",
		order = 68,
		get = function()
			if Cursive.db.profile.ignorelist and table.getn(Cursive.db.profile.ignorelist) > 0 then
				return table.concat(Cursive.db.profile.ignorelist, ",") or ""
			end
			return ""
		end,
		set = function(v)
			if not v or v == "" then
				Cursive.db.profile.ignorelist = {}
			else
				Cursive.db.profile.ignorelist = splitString(v, ",");
			end
		end,
	},
}

local sharedDebuffs = {
	["sharedFaerieFire"] = {
		type = "toggle",
		name = L["Shared Faerie Fire"],
		desc = L["This will show other player's Faerie Fires and avoid trying to cast Faerie Fire on those mobs"],
		order = 10,
		get = function()
			return Cursive.db.profile.shareddebuffs.faeriefire
		end,
		set = function(v)
			Cursive.db.profile.shareddebuffs.faeriefire = v
			Cursive.UpdateFramesFromConfig()
		end,
	},
}

Cursive.cmdtable = {
	type = "group",
	handler = Cursive,
	args = {
		["enabled"] = {
			type = "toggle",
			name = L["Enabled"],
			desc = L["Enable/Disable Cursive"],
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
			name = L["Show Title"],
			desc = L["Show the title of the frame"],
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
			name = L["Allow clickthrough"],
			desc = L["This will allow you to click through the frame to target mobs behind it, but prevents dragging the frame."],
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
			name = L["Show Frame Background"],
			desc = L["Toggle the frame background to help with positioning"],
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
			name = L["Reset Frame"],
			desc = L["Move the frame back to the default position"],
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
			name = L["Bar Display Settings"],
			desc = L["Bar Display Settings"],
			order = 13,
			args = barOptions
		},
		["filters"] = {
			type = "group",
			name = L["Mob filters"],
			desc = L["Target and Raid Marks always shown"],
			order = 19,
			args = mobFilters
		},
		["shareddebuffs"] = {
			type = "group",
			name = L["Shared Debuffs"],
			desc = L["Shared Debuffs"],
			order = 20,
			args = sharedDebuffs
		},
		["spacer2"] = {
			type = "header",
			name = " ",
			order = 21,
		},
		["maxcurses"] = {
			type = "range",
			name = L["Max Curses"],
			desc = L["Max Curses"],
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
			name = L["Max Rows"],
			desc = L["Max Rows"],
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
			name = L["Max Columns"],
			desc = L["Max Columns"],
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
