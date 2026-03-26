local L = AceLibrary("AceLocale-2.2"):new("Cursive")
Cursive = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceDebug-2.0", "AceModuleCore-2.0", "AceConsole-2.0", "AceDB-2.0", "AceHook-2.1")
local function HasMinimumNampowerVersion(major, minor, patch)
  if GetNampowerVersion then
    local installedMajor, installedMinor, installedPatch = GetNampowerVersion()

    if installedMajor > major then
      return true
    elseif installedMajor == major and installedMinor > minor then
      return true
    elseif installedMajor == major and installedMinor == minor and installedPatch >= patch then
      return true
    end
  end

  return false
end

Cursive.nampower = HasMinimumNampowerVersion(2, 40, 0)

if not Cursive.nampower then
  DEFAULT_CHAT_FRAME:AddMessage("|cffff6060Cursive:|r could not detect nampower >= v2.40.0")
  return
end

Cursive:RegisterEvent("ADDON_LOADED", function(name)
  if GetCVar("NP_EnableSpellStartEvents") ~= "1" then
    DEFAULT_CHAT_FRAME:AddMessage("|cffff6060Cursive:|r Another addon disabled nampower spell start events.  Re-enabling as they are required.")
    SetCVar("NP_EnableSpellStartEvents", 1)
  end

  if GetCVar("NP_EnableSpellGoEvents") ~= "1" then
    DEFAULT_CHAT_FRAME:AddMessage("|cffff6060Cursive:|r Another addon disabled nampower spell go events.  Re-enabling as they are required.")
    SetCVar("NP_EnableSpellGoEvents", 1)
  end

  if GetCVar("NP_EnableUnitEventsGuid") ~= "1" then
    DEFAULT_CHAT_FRAME:AddMessage("|cffff6060Cursive:|r Another addon disabled nampower guid events.  Re-enabling as they are required.")
    SetCVar("NP_EnableUnitEventsGuid", 1)
  end
end)

function Cursive:OnEnable()
	if not Cursive.nampower then
		return
	end

	SetCVar("NP_EnableSpellStartEvents", 1)
	SetCVar("NP_EnableSpellGoEvents", 1)
	SetCVar("NP_EnableUnitEventsGuid", 1)

	DEFAULT_CHAT_FRAME:AddMessage(L["|cffffcc00Cursive:|cffffaaaa Loaded.  /cursive for commands and minimap icon for options."])

	Cursive.curses:LoadCurses()
	if Cursive.db.profile.enabled then
		Cursive.core.enable()
	end
end
