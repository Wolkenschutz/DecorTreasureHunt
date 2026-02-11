local ADDON_NAME, DTH = ...;

local L = DTH.L;

local addonTitle = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Title");
addonTitle = addonTitle:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "");

local function EnsureDB()
    if not DecorTreasureHuntDB then
        DecorTreasureHuntDB = {};
    end

    if DecorTreasureHuntDB.autoAccept == nil then
        DecorTreasureHuntDB.autoAccept = true;
    end

    if DecorTreasureHuntDB.autoTurnIn == nil then
        DecorTreasureHuntDB.autoTurnIn = true;
    end
end

-- ============================================================
-- Addon Compartment Menu (Blizzard)
-- ============================================================

local function MenuGenerator(owner, rootDescription)
    EnsureDB();

    rootDescription:CreateTitle(addonTitle);

    rootDescription:CreateCheckbox(
        L.AUTO_ACCEPT,
        function()
            return DecorTreasureHuntDB.autoAccept;
        end,
        function()
            DecorTreasureHuntDB.autoAccept = not DecorTreasureHuntDB.autoAccept;
            local message = DecorTreasureHuntDB.autoAccept and L.AUTO_ACCEPT_ENABLED or L.AUTO_ACCEPT_DISABLED;
            print("|cffe6c619" .. addonTitle .. ":|r " .. message);
        end
    );

    rootDescription:CreateCheckbox(
        L.AUTO_TURNIN,
        function()
            return DecorTreasureHuntDB.autoTurnIn;
        end,
        function()
            DecorTreasureHuntDB.autoTurnIn = not DecorTreasureHuntDB.autoTurnIn;
            local message = DecorTreasureHuntDB.autoTurnIn and L.AUTO_TURNIN_ENABLED or L.AUTO_TURNIN_DISABLED;
            print("|cffe6c619" .. addonTitle .. ":|r " .. message);
        end
    );
end

AddonCompartmentFrame:RegisterAddon({
    text = addonTitle,
    icon = "dashboard-panel-homestone-teleport-button",
    func = function(frame, button)
        MenuUtil.CreateContextMenu(frame, MenuGenerator);
    end,
    funcOnEnter = function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT");
        GameTooltip:SetText(addonTitle, 1, 1, 1);
        GameTooltip:AddLine(L.TOOLTIP_TEXT, nil, nil, nil, true);
        GameTooltip:Show();
    end,
    funcOnLeave = function()
        GameTooltip:Hide();
    end
});

-- ============================================================
-- Blizzard Settings (Modern)
-- ============================================================

local function RegisterSettings()
    EnsureDB();

    local category = Settings.RegisterVerticalLayoutCategory(addonTitle);

    do
        local defaultValue = true;
        local setting = Settings.RegisterAddOnSetting(
            category,
            "autoAccept",            -- variable (SavedVariables key)
            "DTH_AUTO_ACCEPT",       -- variableKey (unique setting key)
            DecorTreasureHuntDB,     -- variableTbl (SavedVariables table)
            type(defaultValue),
            L.AUTO_ACCEPT,
            defaultValue
        );

        Settings.CreateCheckbox(category, setting, L.OPTIONS_DESCRIPTION);
    end

    do
        local defaultValue = true;
        local setting = Settings.RegisterAddOnSetting(
            category,
            "autoTurnIn",
            "DTH_AUTO_TURNIN",
            DecorTreasureHuntDB,
            type(defaultValue),
            L.AUTO_TURNIN,
            defaultValue
        );

        Settings.CreateCheckbox(category, setting, L.OPTIONS_DESCRIPTION);
    end

    Settings.RegisterAddOnCategory(category);
end

local settingsFrame = CreateFrame("Frame");
settingsFrame:RegisterEvent("ADDON_LOADED");
settingsFrame:SetScript("OnEvent", function(self, event, name)
    if name ~= ADDON_NAME then
        return;
    end

    RegisterSettings();
end);

-- Slash command (optional quick access)
SLASH_DECORTREASUREHUNT1 = "/dth";
SLASH_DECORTREASUREHUNT2 = "/decortreasurehunt";
SlashCmdList["DECORTREASUREHUNT"] = function()
    Settings.OpenToCategory(addonTitle);
end;

-- Contributor: Earthenmist (PR: Blizzard Settings panel + localization)
