local addonName, privateTable = ...

privateTable.DefaultConfig = {

    globalFadeTime = 0.3,
    pollRate = 0.05,
    fadeDelay = 2.0, -- Grace period (in seconds) before fading out

    frames = {
        ["MainMenuBar"] = {
            enabled = true,
            duration = -1, -- -1 = use globalFadeTime
            alphaExplore = 0.0,
            alphaCombat = 1.0,
            alphaTarget = 1.0,
            alphaHover = 1.0,
            hookChildren = true
        },
        ["PlayerFrame"] = {
            enabled = true,
            duration = -1,
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
            duration = -1,
            alphaExplore = 0.0,
            alphaCombat = 1.0,
            alphaTarget = 1.0,
            alphaHover = 1.0,
            hookChildren = false
        },
        ["FocusFrame"] = {
            enabled = true,
            duration = -1,
            alphaExplore = 0.0,
            alphaCombat = 1.0,
            alphaTarget = 1.0,
            alphaHover = 1.0,
            hookChildren = false
        },
        ["ObjectiveTrackerFrame"] = {
            enabled = true,
            duration = -1,
            alphaExplore = 0.0,
            alphaCombat = 0.0,
            alphaTarget = 0.0,
            alphaHover = 1.0,
            hookChildren = true
        },
        ["PetActionBar"] = {
            enabled = true,
            duration = -1,
            alphaExplore = 0.0,
            alphaCombat = 1.0,
            alphaTarget = 1.0,
            alphaHover = 1.0,
            hookChildren = true
        },
        ["StanceBar"] = {
            enabled = true,
            duration = -1,
            alphaExplore = 0.0,
            alphaCombat = 1.0,
            alphaTarget = 1.0,
            alphaHover = 1.0,
            hookChildren = true
        },
        ["BagsBar"] = {
            enabled = true,
            duration = -1,
            alphaExplore = 0.0,
            alphaCombat = 1.0,
            alphaTarget = 1.0,
            alphaHover = 1.0,
            hookChildren = true
        },
        ["MicroMenu"] = {
            enabled = true,
            duration = -1,
            alphaExplore = 0.0,
            alphaCombat = 1.0,
            alphaTarget = 1.0,
            alphaHover = 1.0,
            hookChildren = true
        },
        ["MainActionBar"] = {
            enabled = true,
            duration = -1,
            alphaExplore = 0.0,
            alphaCombat = 1.0,
            alphaTarget = 1.0,
            alphaHover = 1.0,
            hookChildren = true
        },
        ["MultiBarBottomRight"] = {
            enabled = true,
            duration = -1,
            alphaExplore = 0.0,
            alphaCombat = 1.0,
            alphaTarget = 1.0,
            alphaHover = 1.0,
            hookChildren = true
        },
        ["MultiBarBottomLeft"] = {
            enabled = true,
            duration = -1,
            alphaExplore = 0.0,
            alphaCombat = 1.0,
            alphaTarget = 1.0,
            alphaHover = 1.0,
            hookChildren = true
        },
        ["MultiBar6"] = {
            enabled = true,
            duration = -1,
            alphaExplore = 0.0,
            alphaCombat = 1.0,
            alphaTarget = 1.0,
            alphaHover = 1.0,
            hookChildren = true
        },
        ["MultiBar5"] = {
            enabled = true,
            duration = -1,
            alphaExplore = 0.0,
            alphaCombat = 1.0,
            alphaTarget = 1.0,
            alphaHover = 1.0,
            hookChildren = true
        },
        ["MultiBar7"] = {
            enabled = true,
            duration = -1,
            alphaExplore = 0.0,
            alphaCombat = 1.0,
            alphaTarget = 1.0,
            alphaHover = 1.0,
            hookChildren = true
        },
        ["MultiBarRight"] = {
            enabled = true,
            duration = -1,
            alphaExplore = 0.0,
            alphaCombat = 1.0,
            alphaTarget = 1.0,
            alphaHover = 1.0,
            hookChildren = true
        },
        ["MultiBarLeft"] = {
            enabled = true,
            duration = -1,
            alphaExplore = 0.0,
            alphaCombat = 1.0,
            alphaTarget = 1.0,
            alphaHover = 1.0,
            hookChildren = true
        },
        ["MainStatusTrackingBarContainer"] = {
            enabled = true,
            duration = -1,
            alphaExplore = 0.0,
            alphaCombat = 1.0,
            alphaTarget = 1.0,
            alphaHover = 1.0,
            hookChildren = true
        },
        ["Minimap"] = {
            enabled = true,
            duration = -1,
            alphaExplore = 0.0,
            alphaCombat = 1.0,
            alphaTarget = 1.0,
            alphaHover = 1.0,
            hookChildren = true
        }
    }
}