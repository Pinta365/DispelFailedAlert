-- Slash commands for DispelFailedAlert

local addonName, AddonTable = ...

StaticPopupDialogs["DISPELFAILEDALERT_RESET_CONFIRM"] = {
    text = "Reset all Dispel Failed Alert settings to defaults and reload the UI?",
    button1 = "Reset",
    button2 = "Cancel",
    OnAccept = function()
        wipe(DispelFailedAlertDB)
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

function AddonTable.initCommands()
    local function printHelp()
        local c = "|cff45D388[DispelFailedAlert]|r"
        print(c, "Commands:")
        print(c, "|cffFFFFFF/dfa debug|r - toggle debug output")
        print(c, "|cffFFFFFF/dfa on|r - enable failed dispel alert")
        print(c, "|cffFFFFFF/dfa off|r - disable failed dispel alert")
        print(c, "|cffFFFFFF/dfa sound|r - list/select the alert sound")
        print(c, "|cffFFFFFF/dfa test|r - play test alert sound")
        print(c, "|cffFFFFFF/dfa reset|r - reset settings to defaults")
    end

    SlashCmdList["DISPELFAILEDALERT"] = function(msg)
        local cmd, rest = msg:match("^%s*(%S*)%s*(.-)%s*$")
        cmd = cmd or ""
        if cmd == "debug" then
            DispelFailedAlertDB.debug = not DispelFailedAlertDB.debug
            print("|cff45D388[DispelFailedAlert]|r Debug", DispelFailedAlertDB.debug and "|cff00FF00ON|r" or "|cffFF4444OFF|r")
        elseif cmd == "on" then
            DispelFailedAlertDB.alertsEnabled = true
            print("|cff45D388[DispelFailedAlert]|r Alert sound |cff00FF00ON|r")
        elseif cmd == "off" then
            DispelFailedAlertDB.alertsEnabled = false
            print("|cff45D388[DispelFailedAlert]|r Alert sound |cffFF4444OFF|r")
        elseif cmd == "sound" then
            local sounds = AddonTable.alertSounds or {}
            local index = tonumber(rest)
            if index and sounds[index] then
                DispelFailedAlertDB.soundKey = sounds[index].key
                local played = AddonTable.PreviewAlertSound and AddonTable.PreviewAlertSound(sounds[index].key)
                local note = played and "" or " |cffFF4444(no audio)|r"
                print("|cff45D388[DispelFailedAlert]|r Sound set to |cffFFFFFF" .. sounds[index].label .. "|r" .. note)
            else
                print("|cff45D388[DispelFailedAlert]|r Sounds (|cffFFFFFF/dfa sound <number>|r):")
                for i, sound in ipairs(sounds) do
                    local marker = (sound.key == DispelFailedAlertDB.soundKey) and " |cff00FF00(current)|r" or ""
                    print(string.format("  |cffFFFFFF%d|r - %s%s", i, sound.label, marker))
                end
            end
        elseif cmd == "test" then
            if AddonTable.TestAlert then
                AddonTable.TestAlert()
            end
        elseif cmd == "reset" then
            StaticPopup_Show("DISPELFAILEDALERT_RESET_CONFIRM")
        else
            printHelp()
        end
    end
    SLASH_DISPELFAILEDALERT1 = "/dfa"
end
