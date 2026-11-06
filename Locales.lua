local _, ns = ...

-- English is the base table, every other locale only overrides keys.
local L = {
    RANK = "%s (rank %d)",
    POINT_FREE = "Talent point available, next: %s",
    NEXT = "Next: %s, unspent points: %d",
    NOT_IN_TREE = "Talent not found in the talent tree, it cannot be highlighted.",
    BUILD_DONE = "Build complete (%s).",
    TREE_UNREADABLE = "Talent tree not readable yet.",
    BUILD_PRIEST_SHADOW = "Shadow (leveling)",
    BUILD_MAGE_FROST = "Frost (leveling)",
}

local locales = {
    deDE = {
        RANK = "%s (Rang %d)",
        POINT_FREE = "Talentpunkt frei, als Nächstes: %s",
        NEXT = "Als Nächstes: %s, freie Punkte: %d",
        NOT_IN_TREE = "Talent nicht im Talentbaum gefunden, es kann nicht markiert werden.",
        BUILD_DONE = "Build komplett (%s).",
        TREE_UNREADABLE = "Talentbaum noch nicht lesbar.",
        BUILD_PRIEST_SHADOW = "Schatten (Leveling)",
        BUILD_MAGE_FROST = "Frost (Leveling)",
    },
}

for key, value in pairs(locales[GetLocale()] or {}) do
    L[key] = value
end

ns.L = L
