-- Shared utilities for DispelFailedAlert

local addonName, AddonTable = ...

--- Print debug message if debug mode is enabled.
--- @param ... any Message parts
function AddonTable.Debug(...)
    if DispelFailedAlertDB and DispelFailedAlertDB.debug then
        print("|cff888888[DispelFailedAlert Debug]|r", ...)
    end
end
