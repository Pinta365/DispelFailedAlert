-- Core alert logic for DispelFailedAlert

local addonName, AddonTable = ...

local recentHandledByCastGUID = {}

-- Delay after a successful cast before reading its cooldown, so the cooldown
-- has registered.
local DISPEL_COOLDOWN_CHECK_DELAY = 0.1

-- Friendly cleanses only; offensive purges (Dispel Magic, Tranquilizing Shot,
-- Purge, Spellsteal) are excluded.
local trackedDispelSpells = {
    -- Priest
    [527] = true,      -- Purify (Disc/Holy: magic, +disease w/ Improved Purify)
    [213634] = true,   -- Purify Disease (Shadow: disease)
    [32375] = true,    -- Mass Dispel (friendly AoE harmful magic)
    -- Paladin
    [4987] = true,     -- Cleanse (Holy: magic, +poison/disease w/ Improved Cleanse)
    [213644] = true,   -- Cleanse Toxins (Prot/Ret: poison/disease)
    -- Shaman
    [77130] = true,    -- Purify Spirit (Resto: magic, +curse w/ Improved)
    [51886] = true,    -- Cleanse Spirit (Ele/Enh: curse)
    -- Monk
    [115450] = true,   -- Detox (Mistweaver, mana: magic/poison/disease)
    [218164] = true,   -- Detox (Brewmaster/Windwalker, energy: poison/disease)
    -- Druid
    [88423] = true,    -- Nature's Cure (Resto: magic, +poison/curse w/ Improved)
    [2782] = true,     -- Remove Corruption (Balance/Feral/Guardian: poison/curse)
    -- Evoker
    [365585] = true,   -- Expunge (Deva/Aug: poison)
    [360823] = true,   -- Naturalize (Preservation: magic/poison; replaces Expunge)
    [374251] = true,   -- Cauterizing Flame (bleed/poison/curse/disease)
    -- Mage
    [475] = true,      -- Remove Curse (curse)
}

local function isTrackedDispelSpell(spellID)
    return type(spellID) == "number" and trackedDispelSpells[spellID] == true
end

local function getSpellName(spellID)
    if C_Spell and C_Spell.GetSpellName then
        return C_Spell.GetSpellName(spellID)
    end
    return tostring(spellID)
end

-- Returns true if the spell's own (non-GCD) cooldown is running, false if only
-- the GCD (or nothing) is, or nil if it can't be determined. The cooldown's
-- start/duration are "secret" in instances and error if compared, but the
-- isActive / isOnGCD booleans stay readable -- so we read only those.
local function dispelWentOnCooldown(spellID)
    if not (C_Spell and C_Spell.GetSpellCooldown) then
        return nil
    end

    local info = C_Spell.GetSpellCooldown(spellID)
    if not info then
        return nil
    end

    local isActive, isOnGCD = info.isActive, info.isOnGCD
    if issecretvalue and (issecretvalue(isActive) or issecretvalue(isOnGCD)) then
        return nil
    end

    return isActive == true and isOnGCD ~= true
end

-- Resolve a sound name to something PlaySoundFile accepts (a file path or a
-- numeric fileDataID). Tries LSM first, then the bundled list, then the default.
local function resolveSoundFile(soundName)
    local LSM = AddonTable.LSM
    if LSM and soundName then
        local file = LSM:Fetch(AddonTable.SOUND_MEDIATYPE, soundName, true)
        if file then
            return file
        end
    end

    for _, sound in ipairs(AddonTable.bundledSounds or {}) do
        if sound.name == soundName then
            return sound.file
        end
    end

    local fallback = AddonTable.bundledSounds and AddonTable.bundledSounds[1]
    return fallback and fallback.file
end

-- Plays the configured (or given) alert sound. Returns whether audio played.
function AddonTable.PreviewAlertSound(soundName)
    soundName = soundName or (DispelFailedAlertDB and DispelFailedAlertDB.soundName)
    local file = resolveSoundFile(soundName)
    if not file then
        return false
    end
    local willPlay = PlaySoundFile(file, "Master")
    return willPlay ~= false
end

local function playDispelFailedAlert(spellID)
    if not DispelFailedAlertDB or not DispelFailedAlertDB.alertsEnabled then
        return
    end

    AddonTable.PreviewAlertSound(DispelFailedAlertDB.soundName)

    AddonTable.Debug("Dispel did nothing (no cooldown); alerting:", getSpellName(spellID))
end

local function handleSpellcastSucceeded(unitTarget, castGUID, spellID)
    if unitTarget ~= "player" then
        return
    end

    if not isTrackedDispelSpell(spellID) then
        return
    end

    if castGUID and recentHandledByCastGUID[castGUID] then
        return
    end
    if castGUID then
        recentHandledByCastGUID[castGUID] = true
        C_Timer.After(1.5, function()
            recentHandledByCastGUID[castGUID] = nil
        end)
    end

    C_Timer.After(DISPEL_COOLDOWN_CHECK_DELAY, function()
        local started = dispelWentOnCooldown(spellID)
        if started == nil then
            AddonTable.Debug("Cooldown state unreadable; no alert:", getSpellName(spellID))
        elseif started then
            AddonTable.Debug("Dispel went on cooldown; no alert:", getSpellName(spellID))
        else
            playDispelFailedAlert(spellID)
        end
    end)
end

function AddonTable.TestAlert()
    playDispelFailedAlert(527)
end

function AddonTable.initAlerts()
    local frame = CreateFrame("Frame", "DispelFailedAlertEventFrame")

    frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

    frame:SetScript("OnEvent", function(_, event, ...)
        if event == "UNIT_SPELLCAST_SUCCEEDED" then
            local unitTarget, castGUID, spellID = ...
            handleSpellcastSucceeded(unitTarget, castGUID, spellID)
        end
    end)

    AddonTable.alertFrame = frame
end
