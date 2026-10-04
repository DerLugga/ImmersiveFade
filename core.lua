local addonName, privateTable = ...
local Utils = privateTable.Utils

local function FadeFrame(frame, targetAlpha, duration)
    if not frame then return end
    if not frame._fader then
        local animGroup = frame:CreateAnimationGroup()
        local alphaAnim = animGroup:CreateAnimationGroup("Alpha")
        alphaAnim:SetOrder(1)
        animGroup:SetScript("OnFinished", function(self)
            frame:setAlpha(self.targetAlpha or 1.0)
        end)
        animGroup:SetScript("OnStop", function(self)
            frame:setAlpha(self.targetAlpha or 1.0)
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
    return health >= maxHealth
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

local function IsMouseOverHierarchy(frame)
    if not frame or not frame:IsShown() then
        return false
    end

    if frame:IsMouseOver() then
        return true
    end

    local children = {frame:GetChildren()}
    for _, child in ipairs(children) do
        if IsMouseOverHierarchy(child) then
            return true
        end
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

    if frameName == "PlayerFrame" then
        if not IsPlayerHealthFull() then
            return config.alphaHealthLow or 0.5
        end
        if not IsPlayerManaFull() then
            return config.alphaManaLow or 0.5
        end
    end

    if IsHovered(frameName) then
        return config.alphaHover or 1.0
    end

    if UnitAffectingCombat("player") then
        return config.alphaCombat or 1.0
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