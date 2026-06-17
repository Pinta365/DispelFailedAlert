local addonName, AddonTable = ...

local function onEvent(self, event, ...)
    if event == "ADDON_LOADED" and ... == addonName then
        AddonTable.initSettings()
        AddonTable.initAlerts()
        AddonTable.initOptionsPanel()
        AddonTable.initCommands()
        if DispelFailedAlertDB.showWelcome ~= false then
            print("|cff45D388[DispelFailedAlert]|r v" .. AddonTable.version .. " loaded. Type |cffFFFFFF/dfa|r for commands.")
        end
    end
end

local frame = CreateFrame("Frame", "DispelFailedAlertFrame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", onEvent)
