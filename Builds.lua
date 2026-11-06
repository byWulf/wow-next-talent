local _, ns = ...

-- One entry per talent point, in the order they are spent (first entry = first point).
-- Talents are matched by spell ID (the trait definition spell), with the localized spell
-- name as a fallback, so the build works with every client language.
ns.builds = {
    PRIEST = {
        name = ns.L.BUILD_PRIEST_SHADOW,
        source = "Icy Veins, WoW Forever Shadow Priest Leveling, as of 2026-11-02",
        firstLevel = 10,
        talents = {
            [14524] = "Wand Specialization",
            [15270] = "Spirit Tap",
            [15275] = "Improved Shadow Word: Pain",
            [15273] = "Improved Mind Blast",
            [15407] = "Mind Flay",
            [1225139] = "Improved Mind Flay",
            [17322] = "Shadow Reach",
            [15286] = "Vampiric Embrace",
            [1326159] = "Dark Inspiration",
            [1309950] = "Devouring Contagion",
            [15487] = "Silence",
            [15257] = "Shadow Weaving",
            [15259] = "Darkness",
            [15473] = "Shadowform",
            [1225132] = "Twin Disciplines",
            [18551] = "Mental Strength",
            [14521] = "Meditation",
            [14913] = "Twilight Focus",
            [15260] = "Shadow Focus",
        },
        order = {
            14524, 14524,                                   -- 10-11 Wand Specialization 2/2
            15270, 15270, 15270, 15270, 15270,              -- 12-16 Spirit Tap 5/5
            15275, 15275,                                   -- 17-18 Improved Shadow Word: Pain 2/2
            15273, 15273, 15273,                            -- 19-21 Improved Mind Blast 3/5
            15407,                                          -- 22    Mind Flay
            1225139, 1225139,                               -- 23-24 Improved Mind Flay 2/2
            15273,                                          -- 25    Improved Mind Blast 4/5
            17322,                                          -- 26    Shadow Reach 1/2
            15286,                                          -- 27    Vampiric Embrace
            1326159, 1326159, 1326159, 1326159, 1326159,    -- 28-32 Dark Inspiration 5/5
            1309950, 1309950,                               -- 33-34 Devouring Contagion 2/2
            15487,                                          -- 35    Silence
            15257,                                          -- 36    Shadow Weaving 1/3
            15259, 15259, 15259, 15259, 15259,              -- 37-41 Darkness 5/5
            15473,                                          -- 42    Shadowform
            1225132, 1225132, 1225132,                      -- 43-45 Twin Disciplines 3/5
            18551, 18551, 18551, 18551, 18551,              -- 46-50 Mental Strength 5/5
            14521, 14521, 14521,                            -- 51-53 Meditation 3/3
            14913, 14913, 14913,                            -- 54-56 Twilight Focus 3/3
            15257, 15257,                                   -- 57-58 Shadow Weaving 3/3
            15260, 15260,                                   -- 59-60 Shadow Focus 2/5
        },
    },
}
