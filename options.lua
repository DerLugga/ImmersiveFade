local addonName, privateTable = ...

local panel = CreateFrame("Frame", "ImmersiveFadeOptionsPanel")
panel.name = "ImmersiveFade" 

local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("ImmersiveFade")

local function SetSliderText(slider, value, label)
    local rounded = math.floor(value * 100 + 0.5) / 100
    _G[slider:GetName() .. "Text"]:SetText(label .. ": " .. rounded .. "s")
end

--- 1. Global Fade Time Slider
local fadeSlider = CreateFrame("Slider", "ImmersiveFadeFadeSlider", panel, "OptionsSliderTemplate")
fadeSlider:SetPoint("TOPLEFT", 16, -70)
fadeSlider:SetMinMaxValues(0.0, 2.0)
fadeSlider:SetValueStep(0.1)
fadeSlider:SetObeyStepOnDrag(true)

fadeSlider:SetScript("OnShow", function(self)
    self:SetValue(ImmersiveFadeDB.globalFadeTime)
    SetSliderText(self, ImmersiveFadeDB.globalFadeTime, "Global Fade Time")
    _G[self:GetName() .. "Low"]:SetText("0.0s")
    _G[self:GetName() .. "High"]:SetText("2.0s")
end)
fadeSlider:SetScript("OnValueChanged", function(self, value)
    local rounded = math.floor(value * 10 + 0.5) / 10
    ImmersiveFadeDB.globalFadeTime = rounded
    SetSliderText(self, rounded, "Global Fade Time")
end)

--- 2. Polling Rate Slider
local pollSlider = CreateFrame("Slider", "ImmersiveFadePollSlider", panel, "OptionsSliderTemplate")
pollSlider:SetPoint("TOPLEFT", 16, -120)
pollSlider:SetMinMaxValues(0.01, 0.50)
pollSlider:SetValueStep(0.01)
pollSlider:SetObeyStepOnDrag(true)

pollSlider:SetScript("OnShow", function(self)
    self:SetValue(ImmersiveFadeDB.pollRate)
    SetSliderText(self, ImmersiveFadeDB.pollRate, "Polling Rate")
    _G[self:GetName() .. "Low"]:SetText("0.01s")
    _G[self:GetName() .. "High"]:SetText("0.5s")
end)
pollSlider:SetScript("OnValueChanged", function(self, value)
    local rounded = math.floor(value * 100 + 0.5) / 100
    ImmersiveFadeDB.pollRate = rounded
    SetSliderText(self, rounded, "Polling Rate")
    if _G.ImmersiveFade_RestartTicker then _G.ImmersiveFade_RestartTicker() end
end)

--- 3. Fade Delay (Grace Period) Slider
local delaySlider = CreateFrame("Slider", "ImmersiveFadeDelaySlider", panel, "OptionsSliderTemplate")
delaySlider:SetPoint("TOPLEFT", 260, -70)
delaySlider:SetMinMaxValues(0.0, 10.0)
delaySlider:SetValueStep(0.5)
delaySlider:SetObeyStepOnDrag(true)

delaySlider:SetScript("OnShow", function(self)
    self:SetValue(ImmersiveFadeDB.fadeDelay)
    SetSliderText(self, ImmersiveFadeDB.fadeDelay, "Fade Delay (Grace)")
    _G[self:GetName() .. "Low"]:SetText("0.0s")
    _G[self:GetName() .. "High"]:SetText("10.0s")
end)
delaySlider:SetScript("OnValueChanged", function(self, value)
    local rounded = math.floor(value * 10 + 0.5) / 10
    ImmersiveFadeDB.fadeDelay = rounded
    SetSliderText(self, rounded, "Fade Delay (Grace)")
end)

local moduleTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
moduleTitle:SetPoint("TOPLEFT", 16, -180)
moduleTitle:SetText("Modules (Click a name to edit its Alpha values):")

--- RECHTE SEITE: Detail Panel für spezifische Frame-Einstellungen
local detailPanel = CreateFrame("Frame", nil, panel)
detailPanel:SetPoint("TOPLEFT", panel, "TOPLEFT", 260, -210)
detailPanel:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -16, 50)
detailPanel.selectedFrame = nil

local detailTitle = detailPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
detailTitle:SetPoint("TOPLEFT", 0, 0)
detailTitle:SetText("Select a module to edit...")
detailTitle:SetTextColor(0.5, 0.5, 0.5)

local function CreateAlphaSlider(name, label, yOffset, dbKey)
    local slider = CreateFrame("Slider", name, detailPanel, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", 0, yOffset)
    slider:SetMinMaxValues(0.0, 1.0)
    slider:SetValueStep(0.05)
    slider:SetObeyStepOnDrag(true)
    slider:Hide()

    local text = _G[name .. "Text"]
    _G[name .. "Low"]:SetText("0.0")
    _G[name .. "High"]:SetText("1.0")

    slider:SetScript("OnValueChanged", function(self, value)
        if detailPanel.selectedFrame then
            local rounded = math.floor(value * 100 + 0.5) / 100
            ImmersiveFadeDB.frames[detailPanel.selectedFrame][dbKey] = rounded
            text:SetText(label .. ": " .. rounded)
        end
    end)
    return slider
end

local sliderExplore = CreateAlphaSlider("ImmersiveFadeSliderExplore", "Explore Alpha", -40, "alphaExplore")
local sliderTarget  = CreateAlphaSlider("ImmersiveFadeSliderTarget", "Target Alpha", -90, "alphaTarget")
local sliderCombat  = CreateAlphaSlider("ImmersiveFadeSliderCombat", "Combat Alpha", -140, "alphaCombat")
local sliderHover   = CreateAlphaSlider("ImmersiveFadeSliderHover", "Hover Alpha", -190, "alphaHover")

local function SelectFrameToEdit(frameName)
    detailPanel.selectedFrame = frameName
    detailTitle:SetText("Settings for: " .. frameName)
    detailTitle:SetTextColor(1, 0.82, 0)
    
    local cfg = ImmersiveFadeDB.frames[frameName]
    
    sliderExplore:SetValue(cfg.alphaExplore or 0)
    _G[sliderExplore:GetName().."Text"]:SetText("Explore Alpha: " .. (cfg.alphaExplore or 0))
    sliderExplore:Show()
    
    local tAlpha = cfg.alphaTarget
    if tAlpha == nil then tAlpha = cfg.alphaCombat or 1.0 end
    sliderTarget:SetValue(tAlpha)
    _G[sliderTarget:GetName().."Text"]:SetText("Target Alpha: " .. tAlpha)
    sliderTarget:Show()
    
    sliderCombat:SetValue(cfg.alphaCombat or 1)
    _G[sliderCombat:GetName().."Text"]:SetText("Combat Alpha: " .. (cfg.alphaCombat or 1))
    sliderCombat:Show()
    
    sliderHover:SetValue(cfg.alphaHover or 1)
    _G[sliderHover:GetName().."Text"]:SetText("Hover Alpha: " .. (cfg.alphaHover or 1))
    sliderHover:Show()
end

--- LINKE SEITE: ScrollFrame für Kategorien
local scrollFrame = CreateFrame("ScrollFrame", "ImmersiveFadeScrollFrame", panel, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 16, -210)
scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMLEFT", 230, 50)

local scrollChild = CreateFrame("Frame", "ImmersiveFadeScrollChild", scrollFrame)
scrollFrame:SetScrollChild(scrollChild)

local groupMap = {
    ["MainMenuBar"] = "Action Bars",
    ["MainActionBar"] = "Action Bars",
    ["PetActionBar"] = "Action Bars",
    ["MultiBarBottomLeft"] = "Action Bars",
    ["MultiBarBottomRight"] = "Action Bars",
    ["MultiBarLeft"] = "Action Bars",
    ["MultiBarRight"] = "Action Bars",
    ["MultiBar5"] = "Action Bars",
    ["MultiBar6"] = "Action Bars",
    ["MultiBar7"] = "Action Bars",
    ["StanceBar"] = "Action Bars",
    ["PlayerFrame"] = "Unit Frames",
    ["TargetFrame"] = "Unit Frames",
    ["FocusFrame"] = "Unit Frames",
    ["BagsBar"] = "Menus & Bags",
    ["MicroMenu"] = "Menus & Bags",
    ["ObjectiveTrackerFrame"] = "HUD & Trackers",
    ["Minimap"] = "HUD & Trackers",
    ["MinimapCluster"] = "HUD & Trackers",
    ["MainStatusTrackingBarContainer"] = "HUD & Trackers"
}

local groups = {
    { name = "Action Bars", frames = {}, expanded = true },
    { name = "Unit Frames", frames = {}, expanded = true },
    { name = "Menus & Bags", frames = {}, expanded = true },
    { name = "HUD & Trackers", frames = {}, expanded = true },
    { name = "Other", frames = {}, expanded = true },
}

local function GetGroup(name)
    for _, g in ipairs(groups) do
        if g.name == name then return g end
    end
    return groups[5]
end

for frameName, _ in pairs(privateTable.DefaultConfig.frames) do
    local gName = groupMap[frameName] or "Other"
    local grp = GetGroup(gName)
    table.insert(grp.frames, frameName)
end

for _, g in ipairs(groups) do
    table.sort(g.frames)
end

local uiElements = {}

local function UpdateLayout()
    local yOffset = -5
    local headerHeight = 24
    local rowHeight = 24

    for _, grp in ipairs(groups) do
        if #grp.frames > 0 then
            local header = uiElements["header_" .. grp.name]
            if not header then
                header = CreateFrame("Button", nil, scrollChild)
                header:SetSize(190, headerHeight)
                
                local highlight = header:CreateTexture(nil, "HIGHLIGHT")
                highlight:SetAllPoints()
                highlight:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
                highlight:SetBlendMode("ADD")
                
                local icon = header:CreateTexture(nil, "ARTWORK")
                icon:SetSize(14, 14)
                icon:SetPoint("LEFT", 5, 0)
                header.icon = icon
                
                local text = header:CreateFontString(nil, "ARTWORK", "GameFontNormal")
                text:SetPoint("LEFT", icon, "RIGHT", 5, 0)
                header.text = text
                
                header:SetScript("OnClick", function()
                    grp.expanded = not grp.expanded
                    UpdateLayout()
                end)
                uiElements["header_" .. grp.name] = header
            end
            
            header:SetPoint("TOPLEFT", 0, yOffset)
            header.text:SetText(grp.name)
            
            if grp.expanded then
                header.icon:SetTexture("Interface\\Buttons\\UI-MinusButton-Up")
            else
                header.icon:SetTexture("Interface\\Buttons\\UI-PlusButton-Up")
            end
            
            header:Show()
            yOffset = yOffset - headerHeight - 2
            
            if grp.expanded then
                for _, frameName in ipairs(grp.frames) do
                    local cb = uiElements["cb_" .. frameName]
                    local btn = uiElements["btn_" .. frameName]
                    
                    if not cb then
                        cb = CreateFrame("CheckButton", "ImmersiveFadeCB_" .. frameName, scrollChild, "InterfaceOptionsCheckButtonTemplate")
                        cb:SetSize(20, 20)
                        _G[cb:GetName() .. "Text"]:SetText("")
                        
                        cb:SetScript("OnShow", function(self)
                            self:SetChecked(ImmersiveFadeDB.frames[frameName].enabled)
                        end)
                        
                        cb:SetScript("OnClick", function(self)
                            local isEnabled = self:GetChecked()
                            ImmersiveFadeDB.frames[frameName].enabled = isEnabled
                            
                            if not isEnabled then
                                local targetFrame = _G[frameName]
                                if targetFrame then
                                    UIFrameFadeRemoveFrame(targetFrame)
                                    targetFrame:SetAlpha(1.0)
                                    if targetFrame.customHidden then
                                        targetFrame:Show()
                                        targetFrame.customHidden = false
                                    end
                                end
                            end
                        end)
                        
                        btn = CreateFrame("Button", nil, scrollChild)
                        btn:SetSize(160, 20)
                        
                        local btnText = btn:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
                        btnText:SetPoint("LEFT", 0, 0)
                        btnText:SetText(frameName)
                        btn.text = btnText
                        
                        btn:SetScript("OnClick", function()
                            SelectFrameToEdit(frameName)
                        end)
                        
                        local btnHighlight = btn:CreateTexture(nil, "HIGHLIGHT")
                        btnHighlight:SetAllPoints()
                        btnHighlight:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
                        btnHighlight:SetBlendMode("ADD")
                        
                        uiElements["cb_" .. frameName] = cb
                        uiElements["btn_" .. frameName] = btn
                    end
                    
                    cb:SetPoint("TOPLEFT", 10, yOffset)
                    btn:SetPoint("LEFT", cb, "RIGHT", 5, 0)
                    
                    cb:Show()
                    btn:Show()
                    
                    yOffset = yOffset - rowHeight
                end
            else
                for _, frameName in ipairs(grp.frames) do
                    if uiElements["cb_" .. frameName] then uiElements["cb_" .. frameName]:Hide() end
                    if uiElements["btn_" .. frameName] then uiElements["btn_" .. frameName]:Hide() end
                end
            end
            
            yOffset = yOffset - 5 
        end
    end
    
    scrollChild:SetSize(210, math.abs(yOffset))
end

UpdateLayout()

--- Button to clear config
local clearBtn = CreateFrame("Button", "ImmersiveFadeClearBtn", panel, "UIPanelButtonTemplate")
clearBtn:SetSize(120, 24)
clearBtn:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 16, 16)
clearBtn:SetText("Clear Config")
clearBtn:SetScript("OnClick", function()
    ImmersiveFadeDB = nil
    ReloadUI()
end)

--- Register the panel
local category
if Settings and Settings.RegisterCanvasLayoutCategory then
    category = Settings.RegisterCanvasLayoutCategory(panel, "ImmersiveFade")
    category.ID = "ImmersiveFade"
    Settings.RegisterAddOnCategory(category)
end

if InterfaceOptions_AddCategory then
    InterfaceOptions_AddCategory(panel)
end

--- Slash Command
SLASH_IMMERSIVEFADE1 = "/ifade"
SLASH_IMMERSIVEFADE2 = "/immersivefade"
SlashCmdList["IMMERSIVEFADE"] = function()
    if Settings and Settings.OpenToCategory and category then
        local catID = category.ID or (category.GetID and category:GetID()) or "ImmersiveFade"
        Settings.OpenToCategory(catID)
    elseif InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(panel)
        InterfaceOptionsFrame_OpenToCategory(panel)
    end
end