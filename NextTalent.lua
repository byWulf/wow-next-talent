local addonName, ns = ...

local _, playerClass = UnitClass("player")
local L = ns.L
local build = ns.builds[playerClass]
if not build then return end

local PREFIX = "|cff55d2ffNextTalent|r: "

-------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------

local function readable(value)
    return value ~= nil and not (issecretvalue and issecretvalue(value))
end

local function spellNameIcon(spellID)
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellID)
        if info then return info.name, info.iconID end
    elseif GetSpellInfo then
        local name, _, icon = GetSpellInfo(spellID)
        return name, icon
    end
end

local function talentLabel(spellID, rank)
    local name, icon = spellNameIcon(spellID)
    name = name or build.talents[spellID] or ("#" .. spellID)
    local label = icon and ("|T" .. icon .. ":14:14:0:0|t " .. name) or name
    return string.format(L.RANK, label, rank)
end

-------------------------------------------------------------------------------
-- Reading the talent tree (Forever: Traits system, one tree per class)
-------------------------------------------------------------------------------

local function activeConfigID()
    if C_SpecializationInfo and C_SpecializationInfo.GetCombatConfigIDForSpecGroup and C_SpecializationInfo.GetActiveSpecGroup then
        local ok, id = pcall(C_SpecializationInfo.GetCombatConfigIDForSpecGroup, C_SpecializationInfo.GetActiveSpecGroup())
        if ok and readable(id) and id then return id end
    end
    if C_ClassTalents and C_ClassTalents.GetActiveConfigID then
        local ok, id = pcall(C_ClassTalents.GetActiveConfigID)
        if ok and readable(id) and id then return id end
    end
end

local function nodeRanks(node)
    -- currentRank includes ranks clicked but not applied yet, so the glow moves on right away
    for _, key in ipairs({"currentRank", "ranksPurchased", "activeRank"}) do
        local value = node[key]
        if readable(value) and tonumber(value) then return tonumber(value) end
    end
    return 0
end

-- Returns {bySpell = {[spellID] = {ranks, nodeID}}, byName = {...}, unspent = n or nil, spent = n}
local function readTalents()
    if not (C_Traits and C_Traits.GetConfigInfo) then return nil end
    local configID = activeConfigID()
    if not configID then return nil end
    local ok, config = pcall(C_Traits.GetConfigInfo, configID)
    if not ok or type(config) ~= "table" or type(config.treeIDs) ~= "table" then return nil end

    local tree = {bySpell = {}, byName = {}, spent = 0}
    for _, treeID in ipairs(config.treeIDs) do
        local okNodes, nodes = pcall(C_Traits.GetTreeNodes, treeID)
        for _, nodeID in ipairs(okNodes and nodes or {}) do
            local okNode, node = pcall(C_Traits.GetNodeInfo, configID, nodeID)
            if okNode and type(node) == "table" and readable(node.ID) and node.ID ~= 0 then
                local ranks = nodeRanks(node)
                tree.spent = tree.spent + ranks
                for _, entryID in ipairs(node.entryIDs or {}) do
                    local okEntry, entry = pcall(C_Traits.GetEntryInfo, configID, entryID)
                    local definitionID = okEntry and type(entry) == "table" and entry.definitionID
                    local okDef, definition = false, nil
                    if definitionID then okDef, definition = pcall(C_Traits.GetDefinitionInfo, definitionID) end
                    local spellID = okDef and type(definition) == "table" and definition.spellID
                    if spellID and readable(spellID) then
                        local info = {ranks = ranks, nodeID = node.ID}
                        tree.bySpell[spellID] = info
                        local name = spellNameIcon(spellID)
                        if name then tree.byName[name] = info end
                    end
                end
            end
        end

        if C_Traits.GetTreeCurrencyInfo then
            local okCur, currencies = pcall(C_Traits.GetTreeCurrencyInfo, configID, treeID, false)
            local first = okCur and type(currencies) == "table" and currencies[1]
            if first and readable(first.quantity) then tree.unspent = (tree.unspent or 0) + first.quantity end
        end
    end
    if not tree.unspent then
        tree.unspent = math.max(0, UnitLevel("player") - (build.firstLevel - 1) - tree.spent)
    end
    return tree
end

-- Next step of the build: {spellID, rank, nodeID}, plus the points still free. nil when done/unreadable.
local function nextStep()
    local tree = readTalents()
    if not tree then return nil end
    local planned = {}
    for _, spellID in ipairs(build.order) do
        planned[spellID] = (planned[spellID] or 0) + 1
        local info = tree.bySpell[spellID]
        if not info then
            local name = spellNameIcon(spellID)
            info = name and tree.byName[name]
        end
        if (info and info.ranks or 0) < planned[spellID] then
            return {spellID = spellID, rank = planned[spellID], nodeID = info and info.nodeID}, tree.unspent
        end
    end
    return nil, tree.unspent
end

-------------------------------------------------------------------------------
-- Glow in the talent window (PlayerSpellsFrame.TalentsFrame, Blizzard_PlayerSpells)
-------------------------------------------------------------------------------

local BORDER_GAP = 7       -- px between the talent button and the frame
local BORDER_WIDTH = 5     -- thickness of the frame
local BORDER_COLOR = {1, 0.75, 0.05, 1}

local glow = CreateFrame("Frame", nil, UIParent)
glow:Hide()
glow:SetFrameStrata("HIGH")

-- soft halo well beyond the button
local halo = glow:CreateTexture(nil, "BACKGROUND")
halo:SetTexture("Interface\\Buttons\\CheckButtonGlow")
halo:SetBlendMode("ADD")
halo:SetPoint("TOPLEFT", -18, 18)
halo:SetPoint("BOTTOMRIGHT", 18, -18)

-- thick solid frame: four edges around the button, BORDER_GAP outside of it
local edges = {}
for i = 1, 4 do
    local edge = glow:CreateTexture(nil, "OVERLAY")
    edge:SetColorTexture(unpack(BORDER_COLOR))
    edges[i] = edge
end
edges[1]:SetPoint("TOPLEFT", glow, "TOPLEFT")                -- top
edges[1]:SetPoint("TOPRIGHT", glow, "TOPRIGHT")
edges[1]:SetHeight(BORDER_WIDTH)
edges[2]:SetPoint("BOTTOMLEFT", glow, "BOTTOMLEFT")          -- bottom
edges[2]:SetPoint("BOTTOMRIGHT", glow, "BOTTOMRIGHT")
edges[2]:SetHeight(BORDER_WIDTH)
edges[3]:SetPoint("TOPLEFT", glow, "TOPLEFT", 0, -BORDER_WIDTH)        -- left
edges[3]:SetPoint("BOTTOMLEFT", glow, "BOTTOMLEFT", 0, BORDER_WIDTH)
edges[3]:SetWidth(BORDER_WIDTH)
edges[4]:SetPoint("TOPRIGHT", glow, "TOPRIGHT", 0, -BORDER_WIDTH)      -- right
edges[4]:SetPoint("BOTTOMRIGHT", glow, "BOTTOMRIGHT", 0, BORDER_WIDTH)
edges[4]:SetWidth(BORDER_WIDTH)

local pulse = glow:CreateAnimationGroup()
pulse:SetLooping("BOUNCE")
local fade = pulse:CreateAnimation("Alpha")
fade:SetFromAlpha(1)
fade:SetToAlpha(0.45)
fade:SetDuration(0.5)
fade:SetSmoothing("IN_OUT")

local function talentsFrame()
    return PlayerSpellsFrame and PlayerSpellsFrame.TalentsFrame
end

local function findButton(frame, nodeID)
    if frame.GetTalentButtonByNodeID then
        local ok, button = pcall(frame.GetTalentButtonByNodeID, frame, nodeID)
        if ok and button then return button end
    end
    if frame.EnumerateAllTalentButtons then
        local ok, iter = pcall(frame.EnumerateAllTalentButtons, frame)
        if ok and iter then
            for button in iter do
                local id = button.GetNodeID and button:GetNodeID() or button.nodeID
                if id == nodeID then return button end
            end
        end
    end
end

local function hideGlow()
    pulse:Stop()
    glow:Hide()
end

local lastAnnounced
local function refresh()
    local step, unspent = nextStep()

    -- chat hint once per free point (level up), the glow does the rest
    if step and (unspent or 0) > 0 then
        local key = step.spellID .. ":" .. step.rank
        if key ~= lastAnnounced then
            lastAnnounced = key
            print(PREFIX .. string.format(L.POINT_FREE, talentLabel(step.spellID, step.rank)))
        end
    end

    local frame = talentsFrame()
    if not (step and step.nodeID and (unspent or 0) > 0 and frame and frame:IsVisible()) then
        hideGlow()
        return
    end
    local button = findButton(frame, step.nodeID)
    if not (button and button:IsVisible()) then
        hideGlow()
        return
    end
    glow:SetParent(button)
    glow:SetFrameLevel(button:GetFrameLevel() + 5)
    glow:ClearAllPoints()
    local outer = BORDER_GAP + BORDER_WIDTH
    glow:SetPoint("TOPLEFT", button, "TOPLEFT", -outer, outer)
    glow:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", outer, -outer)
    glow:Show()
    if not pulse:IsPlaying() then pulse:Play() end
end

local pending = false
local function update()
    if pending then return end
    pending = true
    C_Timer.After(0.15, function()
        pending = false
        refresh()
    end)
end

local hooked = false
local function hookTalentsFrame()
    local frame = talentsFrame()
    if hooked or not frame then return end
    hooked = true
    frame:HookScript("OnShow", update)
    frame:HookScript("OnHide", hideGlow)
    PlayerSpellsFrame:HookScript("OnShow", update)
    -- the tree rebuilds its buttons on layout changes
    for _, method in ipairs({"UpdateTreeInfo", "UpdateAllTalentButtons", "OnTraitConfigUpdated"}) do
        if type(frame[method]) == "function" then hooksecurefunc(frame, method, update) end
    end
    update()
end

-------------------------------------------------------------------------------
-- Events
-------------------------------------------------------------------------------

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LEVEL_UP")
for _, event in ipairs({"TRAIT_CONFIG_UPDATED", "TRAIT_NODE_CHANGED", "TRAIT_TREE_CURRENCY_INFO_UPDATED",
                        "PLAYER_TALENT_UPDATE", "CHARACTER_POINTS_CHANGED", "ACTIVE_COMBAT_CONFIG_CHANGED"}) do
    pcall(events.RegisterEvent, events, event)
end
events:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == "Blizzard_PlayerSpells" then hookTalentsFrame() end
        return
    end
    if event == "PLAYER_LOGIN" then
        if C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("Blizzard_PlayerSpells") then hookTalentsFrame() end
        -- no chat hint at login for points that were already free
        local step, unspent = nextStep()
        if step and (unspent or 0) > 0 then lastAnnounced = step.spellID .. ":" .. step.rank end
    end
    update()
end)

SLASH_NEXTTALENT1 = "/nt"
SLASH_NEXTTALENT2 = "/nexttalent"
SlashCmdList.NEXTTALENT = function()
    local step, unspent = nextStep()
    if step then
        print(PREFIX .. string.format(L.NEXT, talentLabel(step.spellID, step.rank), unspent or 0))
        if not step.nodeID then print(PREFIX .. L.NOT_IN_TREE) end
    elseif unspent then
        print(PREFIX .. string.format(L.BUILD_DONE, build.name))
    else
        print(PREFIX .. L.TREE_UNREADABLE)
    end
end
