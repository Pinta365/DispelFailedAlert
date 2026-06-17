-- Configuration for DispelFailedAlert

local addonName, AddonTable = ...

AddonTable.name = addonName
AddonTable.title = C_AddOns.GetAddOnMetadata(addonName, "Title")
AddonTable.version = C_AddOns.GetAddOnMetadata(addonName, "Version")

-- LibSharedMedia lets players pick any sound registered by any addon. It's
-- optional: if the library is missing we fall back to the bundled sound below.
AddonTable.LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
AddonTable.SOUND_MEDIATYPE = "sound"

-- Sounds shipped with the addon. Each is registered into LibSharedMedia (so it
-- appears alongside other addons' media) and is used as the fallback list when
-- LSM isn't available. First entry is the default.
AddonTable.bundledSounds = {
    { name = "DFA: Plink", file = "Interface\\AddOns\\DispelFailedAlert\\sounds\\1.ogg" },
}

if AddonTable.LSM then
    for _, sound in ipairs(AddonTable.bundledSounds) do
        AddonTable.LSM:Register(AddonTable.SOUND_MEDIATYPE, sound.name, sound.file)
    end
end

AddonTable.defaultSound = AddonTable.bundledSounds[1].name

AddonTable.defaultSettings = {
    debug = false,
    alertsEnabled = true,
    soundName = AddonTable.defaultSound,
    showWelcome = true,
}

-- The selectable sound names: every sound registered with LSM, or just the
-- bundled sounds when LSM isn't present. Sorted for a stable, predictable order.
function AddonTable.GetSoundChoices()
    local names = {}
    if AddonTable.LSM then
        for name in pairs(AddonTable.LSM:HashTable(AddonTable.SOUND_MEDIATYPE)) do
            names[#names + 1] = name
        end
    else
        for _, sound in ipairs(AddonTable.bundledSounds) do
            names[#names + 1] = sound.name
        end
    end
    table.sort(names)
    return names
end

function AddonTable.GetCurrentSoundName()
    return (DispelFailedAlertDB and DispelFailedAlertDB.soundName) or AddonTable.defaultSound
end

function AddonTable.initSettings()
    DispelFailedAlertDB = DispelFailedAlertDB or {}

    -- Migrate the pre-LSM setting (soundKey = "plink") to the new soundName.
    if DispelFailedAlertDB.soundName == nil and DispelFailedAlertDB.soundKey ~= nil then
        DispelFailedAlertDB.soundName = AddonTable.defaultSound
    end
    DispelFailedAlertDB.soundKey = nil

    for key, value in pairs(AddonTable.defaultSettings) do
        if DispelFailedAlertDB[key] == nil then
            DispelFailedAlertDB[key] = value
        end
    end
end
