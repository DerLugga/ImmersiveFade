local addonName, privateTable = ...

privateTable.DefaultConfig = {

    globalFadeTime = 0.3,
    pollRate = 0.05,
    fadeDelay = 2.0, -- Wartezeit (Grace Period) vor dem Ausblenden

    frames = {
        ["MainMenuBar"] = {
            enabled = true,
            alphaExplore = 0.0,
            alphaCombat = 1.0,
            alphaTarget = 1.0,
            alphaHover = 1.0,
            hookChildren = true
        },
        ["PlayerFrame"] = {
            enabled = true,
            alphaExplore = 0.0,
            alphaCombat = 1.0,
            alphaTarget = 1.0,
            alphaHover = 1.0,
            alphaHealthLow = 0.5,
            alphaManaLow = 0.5,
            hookChildren = false
        },
        ["TargetFrame"] = {
            enabled = true,
            alphaExplore = 0.0,
            alphaCombat = 1.0,
            alphaTarget = 1.0,
            alphaHover = 1.0,
            hookChildren = false
        },
        ["ObjectiveTrackerFrame"] = {
            enabled = true,
            alphaExplore = 0.0,
            alphaCombat = 0.0,
            alphaTarget = 0.0,
            alphaHover = 1.0,
            hookChildren = true
        },
        ["PetActionBar"] = {
            enabled = true,
            alphaExplore = 0.0,
            alphaCombat = 1.0,
            alphaTarget = 1.0,
            alphaHover = 1.0,
            hookChildren = true
        },
        ["BagsBar"] = {
            enabled = true,
            alphaExplore = 0.0,
            alphaCombat = 1.0,
            alphaTarget = 1.0,
            alphaHover = 1.0,
            hookChildren = true
        },
        ["MicroMenu"] = {
            enabled = true,
            alphaExplore = 0.0,
            alphaCombat = 1.0,
            alphaTarget = 1.0,
            alphaHover = 1.0,
            hookChildren = true
        },
        ["MainActionBar"] = {
            enabled = true,
            alphaExplore = 0.0,
            alphaCombat = 1.0,
            alphaTarget = 1.0,
            alphaHover = 1.0,
            hookChildren = true
        },
        ["MultiBarBottomRight"] = {
            enabled = true,
            alphaExplore = 0.0,
            alphaCombat = 1.0,
            alphaTarget = 1.0,
            alphaHover = 1.0,
            hookChildren = true
        },
        ["MultiBarBottomLeft"] = {
            enabled = true,
            alphaExplore = 0.0,
            alphaCombat = 1.0,
            alphaTarget = 1.0,
            alphaHover = 1.0,
            hookChildren = true
        },
        ["MultiBar6"] = {
            enabled = true,
            alphaExplore = 0.0,
            alphaCombat = 1.0,
            alphaTarget = 1.0,
            alphaHover = 1.0,
            hookChildren = true
        },
        ["MultiBar5"] = {
            enabled = true,
            alphaExplore = 0.0,
            alphaCombat = 1.0,
            alphaTarget = 1.0,
            alphaHover = 1.0,
            hookChildren = true
        },
        ["MultiBar7"] = {
            enabled = true,
            alphaExplore = 0.0,
            alphaCombat = 1.0,
            alphaTarget = 1.0,
            alphaHover = 1.0,
            hookChildren = true
        },
        ["MultiBarRight"] = {
            enabled = true,
            alphaExplore = 0.0,
            alphaCombat = 1.0,
            alphaTarget = 1.0,
            alphaHover = 1.0,
            hookChildren = true
        },
        ["MultiBarLeft"] = {
            enabled = true,
            alphaExplore = 0.0,
            alphaCombat = 1.0,
            alphaTarget = 1.0,
            alphaHover = 1.0,
            hookChildren = true
        },
        ["MainStatusTrackingBarContainer"] = {
            enabled = true,
            alphaExplore = 0.0,
            alphaCombat = 1.0,
            alphaTarget = 1.0,
            alphaHover = 1.0,
            hookChildren = true
        },
        ["Minimap"] = {
            enabled = true,
            alphaExplore = 0.0,
            alphaCombat = 1.0,
            alphaTarget = 1.0,
            alphaHover = 1.0,
            hookChildren = true
        }
    }
}