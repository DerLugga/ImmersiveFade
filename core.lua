local addonName, privateTable = ...
local Utils = privateTable.Utils

local function FadeFrame(frame, targetAlpha, duration)
    if not frame then return end
    if not frame._fader then
        local animGroup = frame:CreateAnimationGroup()
        local alphaAnim = animGroup:CreateAnimation("Alpha")
        alphaAnim:SetOrder(1)
        animGroup:SetScript("OnFinished", function(self)
            frame:SetAlpha(self.targetAlpha or 1.0)
        end)
        animGroup:SetScript("OnStop", function(self)
            frame:SetAlpha(self.targetAlpha or 1.0)
        end)

        frame.fadeAnimationGroup = animGroup
        frame.fadeAlphaAnim = alphaAnim
    end

    local currentAlpha = frame:GetAlpha()
    if math.abs(currentAlpha - targetAlpha) < 0.01 then return end

    local animGroup = frame.fadeAnimationGroup
    local alphaAnim = frame.fadeAlphaAnim

    animGroup:Stop()
    animGroup.targetAlpha = targetAlpha
    alphaAnim:SetDuration(duration or 0.3)
    alphaAnim:SetFromAlpha(currentAlpha)
    alphaAnim:SetToAlpha(targetAlpha)
    animGroup:Play()
end

local function IsPlayerHealthFull()
    local health = UnitHealth("player")
    local maxHealth = UnitHealthMax("player")
    local isFull = health >= maxHealth
    return isFull
end

local function IsPlayerManaFull()
    local powerType = UnitPowerType("player")
    if powerType == (Enum.PowerType.Mana or 0) then
        return true
    end

    local mana = UnitPower("player", powerType)
    local maxMana = UnitPowerMax("player", powerType)

    if not mana or not maxMana or maxMana == 0 then
        return true
    end
    return mana >= maxMana
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

local function GetDesiredAlpha(frameName)
    local config = ImmersiveFadeDB.frames[frameName]

    if not config or not config.enabled then
        return 1.0
    end

    --if frameName == "PlayerFrame" then
    --    if not IsPlayerHealthFull() then
    --        return config.alphaHealthLow or 0.5
    --    end
    --    if not IsPlayerManaFull() then
    --        return config.alphaManaLow or 0.5
    --    end
    --end

    --if frameName == "TargetFrame" and not UnitExists("target") then
    --    return 0.0
    --end
    if frameName == "FocusFrame" and not UnitExists("focus") then
        return 0.0
    end

    if IsHovered(frameName) then
        return config.alphaHover or 1.0
    end

    if UnitAffectingCombat("player") then
        return config.alphaCombat or 1.0
    end

    if UnitExists("target") then
        return config.alphaTarget or 1.0
    end

    return config.alphaExplore or 0.0
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

pollTicker:Start()