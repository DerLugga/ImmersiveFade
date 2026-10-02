local addonName, privateTable = ...
local Utils = privateTable.Utils

local state = {
    inCombat = false,
    hasTarget = false,
    hoveredFrames = {}
}

local hoverUntil = {}
local hoverTicker
local combatTimer
local targetTimer

local function CopyTable(src)
    local copy = {}
    for k, v in pairs(src) do
        copy[k] = type(v) == "table" and CopyTable(v) or v
    end
    return copy
end

local function UpdateFrameVisibility(frameName)
    local config = ImmersiveFadeDB.frames[frameName]
    if not config or not config.enabled then return end

    local frame = _G[frameName]
    if not frame or not Utils.IsFrameAccessible(frame) then return end

    if (frameName == "TargetFrame" or frameName == "FocusFrame") and not state.hasTarget then
        if frame:GetAlpha() > 0 then
            frame:SetAlpha(0)
        end
        return
    end

    local targetAlpha = config.alphaExplore

    if state.hoveredFrames[frameName] then
        targetAlpha = config.alphaHover
    elseif state.inCombat then
        targetAlpha = config.alphaCombat
    elseif state.hasTarget then
        targetAlpha = config.alphaTarget or config.alphaCombat
    end

    local currentAlpha = frame:GetAlpha()

    if frameName == "MinimapCluster" or frameName == "Minimap" then
        if targetAlpha == 0 then
            if currentAlpha > 0 then
                UIFrameFadeOut(frame, ImmersiveFadeDB.globalFadeTime, currentAlpha, 0)
            end
            if not frame.customHidden and frame:IsShown() then
                frame.customHidden = true
                C_Timer.After(ImmersiveFadeDB.globalFadeTime + 0.05, function()
                    if frame:GetAlpha() < 0.05 then
                        frame:SetAlpha(0)
                        frame:Hide()
                    end
                end)
            end
        else
            if not frame:IsShown() then
                frame:Show()
                frame.customHidden = false
            end
            if math.abs(currentAlpha - targetAlpha) > 0.01 then
                if targetAlpha > currentAlpha then
                    UIFrameFadeIn(frame, ImmersiveFadeDB.globalFadeTime, currentAlpha, targetAlpha)
                else
                    UIFrameFadeOut(frame, ImmersiveFadeDB.globalFadeTime, currentAlpha, targetAlpha)
                end
            end
        end
        return
    end

    if math.abs(currentAlpha - targetAlpha) > 0.01 then
        if targetAlpha > currentAlpha then
            UIFrameFadeIn(frame, ImmersiveFadeDB.globalFadeTime, currentAlpha, targetAlpha)
        else
            UIFrameFadeOut(frame, ImmersiveFadeDB.globalFadeTime, currentAlpha, targetAlpha)
        end
    end
end

local function UpdateAllFrames()
    for frameName, _ in pairs(ImmersiveFadeDB.frames) do
        UpdateFrameVisibility(frameName)
    end
end

local issecretvalue = issecretvalue or function() return false end

local function CursorInFrameRect(frame)
    local left, bottom, width, height = frame:GetRect()
    local scale = frame:GetEffectiveScale()
    if issecretvalue(left) or issecretvalue(bottom) or issecretvalue(width)
        or issecretvalue(height) or issecretvalue(scale) then
        return false
    end
    if not left or not scale or scale == 0 then return false end

    local x, y = GetCursorPosition()
    x, y = x / scale, y / scale
    return x >= left and x <= left + width and y >= bottom and y <= bottom + height
end

local function IsShownSafe(frame)
    local shown = frame:IsShown()
    if issecretvalue(shown) then return false end
    return shown
end

local function IsMouseOverFrame(frame)
    local over
    if frame.IsMouseOver then
        over = frame:IsMouseOver()
    else
        over = MouseIsOver(frame)
    end

    if issecretvalue(over) then
        return CursorInFrameRect(frame)
    end
    return over and true or false
end

local function AnyChildMouseOver(...)
    for i = 1, select("#", ...) do
        local child = select(i, ...)
        if Utils.IsFrameAccessible(child) and IsShownSafe(child) then
            if IsMouseOverFrame(child) or AnyChildMouseOver(child:GetChildren()) then
                return true
            end
        end
    end
    return false
end

local function PollHover()
    local now = GetTime()
    local delay = ImmersiveFadeDB.fadeDelay or 2.0

    for frameName, config in pairs(ImmersiveFadeDB.frames) do
        if config.enabled then
            local frame = _G[frameName]
            if frame and Utils.IsFrameAccessible(frame) then
                
                if IsShownSafe(frame) or frame.customHidden then
                    local over = false
                    
                    if frame.customHidden then
                        over = CursorInFrameRect(frame)
                    else
                        over = IsMouseOverFrame(frame)
                        if not over and config.hookChildren then
                            over = AnyChildMouseOver(frame:GetChildren())
                        end
                    end

                    if over then
                        hoverUntil[frameName] = now + delay
                    end
                end

                local hovered = (hoverUntil[frameName] or 0) > now
                if state.hoveredFrames[frameName] ~= hovered then
                    state.hoveredFrames[frameName] = hovered
                    UpdateFrameVisibility(frameName)
                end
            end
        end
    end
end

function _G.ImmersiveFade_RestartTicker()
    if hoverTicker then
        hoverTicker:Cancel()
    end
    local rate = ImmersiveFadeDB.pollRate or 0.05
    hoverTicker = C_Timer.NewTicker(rate, PollHover)
end

local eventHandler = CreateFrame("Frame")
eventHandler:RegisterEvent("ADDON_LOADED")
eventHandler:RegisterEvent("PLAYER_REGEN_DISABLED")
eventHandler:RegisterEvent("PLAYER_REGEN_ENABLED")
eventHandler:RegisterEvent("PLAYER_TARGET_CHANGED")
eventHandler:RegisterEvent("PLAYER_ENTERING_WORLD")

eventHandler:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        ImmersiveFadeDB = ImmersiveFadeDB or {}

        for key, value in pairs(privateTable.DefaultConfig) do
            if ImmersiveFadeDB[key] == nil then
                ImmersiveFadeDB[key] = type(value) == "table" and CopyTable(value) or value
            end
        end

        ImmersiveFadeDB.frames = ImmersiveFadeDB.frames or {}
        for frameName, frameConfig in pairs(privateTable.DefaultConfig.frames) do
            if ImmersiveFadeDB.frames[frameName] == nil then
                ImmersiveFadeDB.frames[frameName] = CopyTable(frameConfig)
            end
            if ImmersiveFadeDB.frames[frameName].alphaTarget == nil then
                ImmersiveFadeDB.frames[frameName].alphaTarget = ImmersiveFadeDB.frames[frameName].alphaCombat or 1.0
            end
        end

        _G.ImmersiveFade_RestartTicker()

        self:UnregisterEvent("ADDON_LOADED")
        return
    end

    local delay = ImmersiveFadeDB.fadeDelay or 2.0

    if event == "PLAYER_REGEN_DISABLED" then
        if combatTimer then combatTimer:Cancel(); combatTimer = nil end
        state.inCombat = true
        UpdateAllFrames()
    elseif event == "PLAYER_REGEN_ENABLED" then
        combatTimer = C_Timer.NewTimer(delay, function()
            state.inCombat = false
            UpdateAllFrames()
            combatTimer = nil
        end)
    elseif event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
        if UnitExists("target") then
            if targetTimer then targetTimer:Cancel(); targetTimer = nil end
            state.hasTarget = true
            UpdateAllFrames()
        else
            targetTimer = C_Timer.NewTimer(delay, function()
                state.hasTarget = false
                UpdateAllFrames()
                targetTimer = nil
            end)
        end
    end
end)