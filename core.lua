local addonName, privateTable = ...
local Utils = privateTable.Utils

local activeFades = {}
local currentTargetAlphas = {}
local fadeUntil = {}
local lastActiveAlpha = {}
local pollTicker = nil

-- Custom frame fader to avoid taint from Blizzard's UIFrameFade API
local customFader = CreateFrame("Frame")
customFader:Hide()

customFader:SetScript("OnUpdate", function(self, elapsed)
    local stillFading = false

    for frame, fade in pairs(activeFades) do
        stillFading = true
        fade.timeLeft = fade.timeLeft - elapsed

        if fade.timeLeft <= 0 then
            frame:SetAlpha(fade.targetAlpha)
            activeFades[frame] = nil
        else
            local progress = 1 - (fade.timeLeft / fade.duration)
            local currentAlpha = fade.startAlpha + (fade.alphaDelta * progress)
            frame:SetAlpha(currentAlpha)
        end
    end

    -- Stop OnUpdate script when no frames are actively fading
    if not stillFading then
        self:Hide()
    end
end)

local function FadeFrame(frame, targetAlpha, duration)
    if not frame then return end

    local currentAlpha = frame:GetAlpha()
    if math.abs(currentAlpha - targetAlpha) < 0.01 then
        frame:SetAlpha(targetAlpha)
        activeFades[frame] = nil
        return
    end

    if duration == nil then
        duration = (ImmersiveFadeDB and ImmersiveFadeDB.globalFadeTime) or 0.3
    end

    -- Apply immediately if fade duration is set to 0
    if duration <= 0 then
        frame:SetAlpha(targetAlpha)
        activeFades[frame] = nil
        return
    end

    activeFades[frame] = {
        targetAlpha = targetAlpha,
        startAlpha = currentAlpha,
        alphaDelta = targetAlpha - currentAlpha,
        duration = duration,
        timeLeft = duration
    }

    customFader:Show()
end

-- Fallback for client environments without secret value protection
local issecretvalue = issecretvalue or function() return false end

local function IsShownSafe(frame)
    if not frame then return false end
    local shown = frame:IsShown()
    if issecretvalue(shown) then
        return false
    end
    return shown and true or false
end

local function IsMouseOverSafe(frame)
    if not frame then return false end

    local over = false

    if frame.IsMouseOver then
        over = frame:IsMouseOver()
    elseif MouseIsOver then
        over = MouseIsOver(frame)
    end

    -- Fallback to manual cursor coordinate check if the return value is protected
    if issecretvalue(over) then
        local left, bottom, width, height = frame:GetRect()
        local scale = frame:GetEffectiveScale()
        if not left or not scale or scale == 0 or issecretvalue(left) or issecretvalue(scale) then
            return false
        end
        local x, y = GetCursorPosition()
        x, y = x / scale, y / scale
        return (x >= left and x <= left + width and y >= bottom and y <= bottom + height)
    end

    return over and true or false
end

local function IsMouseOverHierarchy(frame)
    if not IsShownSafe(frame) then
        return false
    end

    if IsMouseOverSafe(frame) then
        return true
    end

    return false
end

local function IsHovered(frame)
    if not frame then return false end
    return IsMouseOverHierarchy(frame)
end

-- Evaluates the target alpha for a given frame based on priority rules
local function GetDesiredAlpha(frameName, frame, config, now, inCombat, hasTarget)
    if frameName == "TargetFrame" and not hasTarget then
        fadeUntil[frameName] = 0
        return 0.0
    end
    if frameName == "FocusFrame" and not UnitExists("focus") then
        fadeUntil[frameName] = 0
        return 0.0
    end

    local delay = ImmersiveFadeDB.fadeDelay or 1.5
    local baseExplore = config.alphaExplore or 0.0

    local isHovered = IsHovered(frame)
    local playerHealthIsLow = false
    local playerManaIsLow = false

    local activeAlpha = nil

    -- Priority order: Hover > Combat > Target
    --if playerHealthIsLow and (config.alphaHealthLow or 0.8) ~= baseExplore then
    --    activeAlpha = config.alphaHealthLow or 0.8
    --elseif playerManaIsLow and (config.alphaManaLow or 0.8) ~= baseExplore then
    --    activeAlpha = config.alphaManaLow or 0.8
    if isHovered and (config.alphaHover or 1.0) ~= baseExplore then
        activeAlpha = config.alphaHover or 1.0
    elseif inCombat and (config.alphaCombat or 1.0) ~= baseExplore then
        activeAlpha = config.alphaCombat or 1.0
    elseif hasTarget and (config.alphaTarget or config.alphaCombat or 1.0) ~= baseExplore then
        activeAlpha = config.alphaTarget or config.alphaCombat or 1.0
    end

    -- Refresh grace period timer while an active state is triggered
    if activeAlpha then
        fadeUntil[frameName] = now + delay
        lastActiveAlpha[frameName] = activeAlpha
        return activeAlpha
    end

    -- Maintain last active alpha while within the grace period (fadeDelay)
    if (fadeUntil[frameName] or 0) > now then
        return lastActiveAlpha[frameName] or (config.alphaHover or 1.0)
    end

    return baseExplore
end

local function UpdateFrame(frameName, config, now, inCombat, hasTarget)
    local frame = _G[frameName]
    if not frame or (Utils and Utils.IsFrameAccessible and not Utils.IsFrameAccessible(frame)) then
        return
    end

    local desiredAlpha = GetDesiredAlpha(frameName, frame, config, now, inCombat, hasTarget)

    if currentTargetAlphas[frameName] ~= desiredAlpha then
        currentTargetAlphas[frameName] = desiredAlpha

        local duration = config.duration or ImmersiveFadeDB.globalFadeTime or 0.3
        FadeFrame(frame, desiredAlpha, duration)
    end
end

local function PollAllFrames()
    if not ImmersiveFadeDB or not ImmersiveFadeDB.frames then return end

    -- Query global states once per tick instead of per frame
    local now = GetTime()
    local inCombat = UnitAffectingCombat("player")
    local hasTarget = UnitExists("target")

    for frameName, config in pairs(ImmersiveFadeDB.frames) do
        if config.enabled then
            UpdateFrame(frameName, config, now, inCombat, hasTarget)
        end
    end
end

-- Restarts the polling ticker (e.g. after initialization or when changing pollRate in options)
function privateTable.RestartTicker()
    if pollTicker then
        pollTicker:Cancel()
    end
    local rate = (ImmersiveFadeDB and ImmersiveFadeDB.pollRate) or 0.05
    pollTicker = C_Timer.NewTicker(rate, PollAllFrames)
end
_G.ImmersiveFade_RestartTicker = privateTable.RestartTicker

-- Cancels active fades and restores full visibility when a frame module is disabled
function privateTable.ResetFrame(frameName)
    local frame = _G[frameName]
    currentTargetAlphas[frameName] = nil
    fadeUntil[frameName] = nil
    lastActiveAlpha[frameName] = nil

    if frame then
        activeFades[frame] = nil
        frame:SetAlpha(1.0)
        if frame.customHidden then
            frame:Show()
            frame.customHidden = false
        end
    end
end
_G.ImmersiveFade_ResetFrame = privateTable.ResetFrame

-- Addon initialization and SavedVariables synchronization
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")

initFrame:SetScript("OnEvent", function(self, event, loadedAddonName)
    if loadedAddonName ~= addonName then
        return
    end

    ImmersiveFadeDB = ImmersiveFadeDB or {}

    if privateTable.DefaultConfig then
        -- 1. Sync top-level settings (excluding the frames table)
        for key, value in pairs(privateTable.DefaultConfig) do
            if key ~= "frames" and ImmersiveFadeDB[key] == nil then
                ImmersiveFadeDB[key] = value
            end
        end

        -- 2. Deep-sync frame configurations and any newly added frame keys
        if privateTable.DefaultConfig.frames then
            ImmersiveFadeDB.frames = ImmersiveFadeDB.frames or {}
            for frameName, defaultFrameConfig in pairs(privateTable.DefaultConfig.frames) do
                if type(ImmersiveFadeDB.frames[frameName]) ~= "table" then
                    ImmersiveFadeDB.frames[frameName] = {}
                end
                for k, v in pairs(defaultFrameConfig) do
                    if ImmersiveFadeDB.frames[frameName][k] == nil then
                        ImmersiveFadeDB.frames[frameName][k] = v
                    end
                end
            end
        end
    end

    -- Start ticker after SavedVariables are loaded
    privateTable.RestartTicker()

    self:UnregisterEvent("ADDON_LOADED")
end)