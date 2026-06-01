-- Configuration for DispelFailedAlert

local addonName, AddonTable = ...

AddonTable.name = addonName
AddonTable.title = C_AddOns.GetAddOnMetadata(addonName, "Title")
AddonTable.version = C_AddOns.GetAddOnMetadata(addonName, "Version")

-- Selectable alert sounds: each entry plays a bundled file (`file`) or a
-- built-in kit sound (`soundKit`). First entry is the default.
AddonTable.alertSounds = {
    { key = "plink", label = "Plink", file = "Interface\\AddOns\\DispelFailedAlert\\sounds\\1.ogg" },
}

AddonTable.defaultSettings = {
    debug = false,
    alertsEnabled = true,
    soundKey = AddonTable.alertSounds[1].key,
}

function AddonTable.initSettings()
    DispelFailedAlertDB = DispelFailedAlertDB or {}

    for key, value in pairs(AddonTable.defaultSettings) do
        if DispelFailedAlertDB[key] == nil then
            DispelFailedAlertDB[key] = value
        end
    end
end
