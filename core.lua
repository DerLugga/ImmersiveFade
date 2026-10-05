local addonName, privateTable = ...
local Utils = privateTable.Utils

local activeFades = {}
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
    
    
    if not stillFading then
        self:Hide()
    end
end)

local function FadeFrame(frame, targetAlpha, duration)
    if not frame then return end
    
    local currentAlpha = frame:GetAlpha()
    if math.abs(currentAlpha - targetAlpha) < 0.01 then return end
    
    duration = duration or 0.3
    
    activeFades[frame] = {
        targetAlpha = targetAlpha,
        startAlpha = currentAlpha,
        alphaDelta = targetAlpha - currentAlpha,
        duration = duration,
        timeLeft = duration
    }
    
    customFader:Show()
end

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

local function IsHovered(frameName)
    local frame = _G[frameName]
    if not frame then return false end

    return IsMouseOverHierarchy(frame)
end
local fadeUntil = {}

local fadeUntil = {}
local lastActiveAlpha = {}

local function GetDesiredAlpha(frameName)
    if not ImmersiveFadeDB or not ImmersiveFadeDB.frames then return 1.0 end
    local config = ImmersiveFadeDB.frames[frameName]
    if not config or not config.enabled then return 1.0 end

    if frameName == "TargetFrame" and not UnitExists("target") then
        fadeUntil[frameName] = 0
        return 0.0
    end
    if frameName == "FocusFrame" and not UnitExists("focus") then
        fadeUntil[frameName] = 0
        return 0.0
    end

    local now = GetTime()
    local delay = ImmersiveFadeDB.fadeDelay or 1.5
    local baseExplore = config.alphaExplore or 0.0

    local isHovered = IsHovered(frameName)
    local inCombat = UnitAffectingCombat("player")
    local hasTarget = UnitExists("target")
    local playerHealthIsLow = false
    local playerManaIsLow = false

    local activeAlpha = nil

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

    if activeAlpha then
        fadeUntil[frameName] = now + delay
        lastActiveAlpha[frameName] = activeAlpha
        return activeAlpha
    end

    if (fadeUntil[frameName] or 0) > now then
        return lastActiveAlpha[frameName] or (config.alphaHover or 1.0)
    end

    return baseExplore
end

local currentTargetAlphas = {}

local function UpdateFrame(frameName)
    local config = ImmersiveFadeDB.frames[frameName]

    local frame = _G[frameName]
    if not frame then return end

    local desiredAlpha = GetDesiredAlpha(frameName)

    if currentTargetAlphas[frameName] ~= desiredAlpha then
        currentTargetAlphas[frameName] = desiredAlpha

        local duration = config.duration or 0.3
        FadeFrame(frame, desiredAlpha, duration)
    end
end

local function PollAllFrames()
    if not ImmersiveFadeDB or not ImmersiveFadeDB.frames then return end

    for frameName, config in pairs(ImmersiveFadeDB.frames) do
        if config.enabled then
            UpdateFrame(frameName)
        end
    end
end

local config = ImmersiveFadeDB or {}
local pollTicker = C_Timer.NewTicker(config.pollRate or 0.2, PollAllFrames)

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")

initFrame:SetScript("OnEvent", function(self, event, loadedAddonName)
    if loadedAddonName ~= addonName then
        return
    end

    ImmersiveFadeDB = ImmersiveFadeDB or {}

    if privateTable.DefaultConfig then
        for key, value in pairs(privateTable.DefaultConfig) do
            if ImmersiveFadeDB[key] == nil then
                ImmersiveFadeDB[key] = value
            end
        end
    end

    self:UnregisterEvent("ADDON_LOADED")
end)