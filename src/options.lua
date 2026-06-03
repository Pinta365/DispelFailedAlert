-- Options panel for DispelFailedAlert

local addonName, AddonTable = ...

local INDENT = 16
local SECTION_GAP = 14
local AFTER_HEADER = 8
local ROW_CHECK = 28

local function sectionHeader(parent, label, yOffset)
    local fs = parent:CreateFontString(nil, "overlay", "GameFontNormal")
    fs:SetPoint("TOPLEFT", INDENT, yOffset)
    fs:SetText(label)
    local line = parent:CreateTexture(nil, "BACKGROUND")
    line:SetColorTexture(0.4, 0.4, 0.4, 0.6)
    line:SetHeight(1)
    line:SetPoint("LEFT", fs, "RIGHT", 6, 0)
    line:SetPoint("RIGHT", parent, "RIGHT", -INDENT, 0)
    return yOffset - AFTER_HEADER
end

local function checkbox(parent, label, yOffset)
    local cb = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    cb:SetPoint("TOPLEFT", INDENT, yOffset)
    cb.Text:SetText(label)
    cb.Text:SetFontObject("GameFontHighlightSmall")
    return cb, yOffset - ROW_CHECK
end

local function selectSound(name)
    DispelFailedAlertDB.soundName = name
    if AddonTable.PreviewAlertSound then
        AddonTable.PreviewAlertSound(name)
    end
end

-- Sound picker: a dropdown, with a cycle-button fallback if the dropdown
-- template isn't available.
local function createSoundSelector(panel, y)
    local label = panel:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
    label:SetPoint("TOPLEFT", INDENT, y - 4)
    label:SetText("Sound on missed dispel:")
    y = y - 22

    local hasDropdownTemplate = C_XMLUtil and C_XMLUtil.GetTemplateInfo
        and C_XMLUtil.GetTemplateInfo("WowStyle1DropdownTemplate")
    if hasDropdownTemplate then
        local dropdown = CreateFrame("DropdownButton", nil, panel, "WowStyle1DropdownTemplate")
        dropdown:SetPoint("TOPLEFT", INDENT, y)
        dropdown:SetWidth(220)
        dropdown:SetupMenu(function(_, rootDescription)
            rootDescription:SetScrollMode(GetScreenHeight() * 0.5)
            for _, name in ipairs(AddonTable.GetSoundChoices()) do
                rootDescription:CreateRadio(name, function()
                    return AddonTable.GetCurrentSoundName() == name
                end, function()
                    selectSound(name)
                end)
            end
        end)
        panel.soundDropdown = dropdown
        return y - 34
    end

    local cycleBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    cycleBtn:SetSize(220, 22)
    cycleBtn:SetPoint("TOPLEFT", INDENT, y)
    cycleBtn:SetScript("OnClick", function(self)
        local names = AddonTable.GetSoundChoices()
        local idx = 1
        for i, name in ipairs(names) do
            if name == AddonTable.GetCurrentSoundName() then
                idx = i
                break
            end
        end
        local nextName = names[(idx % #names) + 1]
        selectSound(nextName)
        self:SetText("Sound: " .. nextName)
    end)
    panel.soundCycleButton = cycleBtn
    return y - 34
end

local function initOptionsPanel()
    local parent = (Settings and Settings.RegisterCanvasLayoutCategory) and UIParent or nil
    local panel = CreateFrame("Frame", "DispelFailedAlertOptionsPanel", parent)
    panel.name = "Dispel Failed Alert"

    local header = panel:CreateFontString(nil, "overlay", "GameFontHighlightLarge")
    header:SetPoint("TOPLEFT", INDENT, -INDENT)
    header:SetText("Dispel Failed Alert")

    local y = -46
    y = sectionHeader(panel, "General", y - SECTION_GAP)

    local debugCb
    debugCb, y = checkbox(panel, "Show debug messages", y)
    debugCb:SetScript("OnClick", function(self)
        DispelFailedAlertDB.debug = self:GetChecked()
    end)

    local alertsCb
    alertsCb, y = checkbox(panel, "Enable failed dispel alert sound", y)
    alertsCb:SetScript("OnClick", function(self)
        DispelFailedAlertDB.alertsEnabled = self:GetChecked()
    end)

    y = sectionHeader(panel, "Alert Sound", y - SECTION_GAP)
    y = createSoundSelector(panel, y)
    y = y - SECTION_GAP

    local testBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    testBtn:SetSize(140, 22)
    testBtn:SetPoint("TOPLEFT", INDENT, y)
    testBtn:SetText("Test Alert Sound")
    testBtn:SetScript("OnClick", function()
        if AddonTable.TestAlert then
            AddonTable.TestAlert()
        end
    end)
    y = y - 28
    panel.debugCheckbox = debugCb

    local resetBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    resetBtn:SetSize(140, 22)
    resetBtn:SetPoint("TOPLEFT", INDENT, y)
    resetBtn:SetText("Reset to Defaults")
    resetBtn:SetScript("OnClick", function()
        StaticPopup_Show("DISPELFAILEDALERT_RESET_CONFIRM")
    end)

    local function RefreshOptions()
        debugCb:SetChecked(DispelFailedAlertDB.debug == true)
        alertsCb:SetChecked(DispelFailedAlertDB.alertsEnabled ~= false)
        if panel.soundDropdown and panel.soundDropdown.GenerateMenu then
            panel.soundDropdown:GenerateMenu()
        elseif panel.soundCycleButton then
            panel.soundCycleButton:SetText("Sound: " .. AddonTable.GetCurrentSoundName())
        end
    end

    panel:SetScript("OnShow", RefreshOptions)
    RefreshOptions()

    if Settings and Settings.RegisterCanvasLayoutCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(category)
        AddonTable.settingsCategory = category
    else
        InterfaceOptions_AddCategory(panel)
        AddonTable.optionsPanel = panel
    end
end

AddonTable.initOptionsPanel = initOptionsPanel
