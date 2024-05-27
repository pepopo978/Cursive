if not Cursive.superwow then
	return
end

Cursive:RegisterDB("CursiveDB")
Cursive:RegisterDefaults("profile", {
	enabled = true,
	caption = "Cursive",
	anchor = "CENTER",
	x = -240,
	y = 120,
	maxcol = 1,

	-- editable
	scale = 1,
	width = 100,
	height = 14,
	spacing = 4,
	maxrow = 10,
})

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
		["barwidth"] = {
			type = "range",
			name = "Health Bar Width",
			desc = "Health Bar Width",
			order = 1,
			min = 30,
			max = 150,
			step = 5,
			get = function()
				return Cursive.db.profile.width
			end,
			set = function(v)
				Cursive.db.profile.width = v
			end,
		},
		["barheight"] = {
			type = "range",
			name = "Health Bar Height",
			desc = "Health Bar Height",
			order = 1,
			min = 10,
			max = 30,
			step = 2,
			get = function()
				return Cursive.db.profile.height
			end,
			set = function(v)
				Cursive.db.profile.height = v
			end,
		},
		["spacing"] = {
			type = "range",
			name = "Spacing",
			desc = "Spacing",
			order = 1,
			min = 0,
			max = 10,
			step = 1,
			get = function()
				return Cursive.db.profile.spacing
			end,
			set = function(v)
				Cursive.db.profile.spacing = v
			end,
		},
		["maxrow"] = {
			type = "range",
			name = "Max Rows",
			desc = "Max Rows",
			order = 1,
			min = 1,
			max = 20,
			step = 1,
			get = function()
				return Cursive.db.profile.maxrow
			end,
			set = function(v)
				Cursive.db.profile.maxrow = v
			end,
		},
		["scale"] = {
			type = "range",
			name = "Scale",
			desc = "Scale",
			order = 1,
			min = 0.5,
			max = 2,
			step = 0.1,
			get = function()
				return Cursive.db.profile.scale
			end,
			set = function(v)
				Cursive.db.profile.scale = v
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
