std = "lua51"
max_line_length = false
exclude_files = {
    "**/Libs/**/*.lua",
    ".luacheckrc"
}
ignore = {
    "11./SLASH_.*", -- Setting an undefined (Slash handler) global variable
    "11./BINDING_.*", -- Setting an undefined (Keybinding header) global variable
--  "113/LE_.*", -- Accessing an undefined (Lua ENUM type) global variable
--  "113/NUM_LE_.*", -- Accessing an undefined (Lua ENUM type) global variable
    -- "211", -- Unused local variable
    -- "211/L", -- Unused local variable "L"
    -- "211/CL", -- Unused local variable "CL"
    "212", -- Unused argument
--  "431", -- shadowing upvalue
    -- "43.", -- Shadowing an upvalue, an upvalue argument, an upvalue loop variable.
    -- "542", -- An empty if branch
}
globals = {
    "_G",
    "bit",
    "floor",

    -- Saved Variables
    "SYN_PRINT_TYPE",

    -- functions
    "syndicate_loot_table",
    "SYN",

    -- externals
    "EPGP",
    "LootReserve",
    "LibStub",

    -- CEPGP hooks
    "CEPGP",
    "CEPGP_LootFrame_Update",
    "CEPGP_distribute_popup_give",
    "CEPGP_frame",
    "CEPGP_getItemLink",
    "CEPGP_handleLoot",
    "CEPGP_lootSlot",
    "CEPGP_mode",
    "CEPGP_populateFrame",
    "CEPGP_toggleFrame",
    "OVERRIDE_INDEX",

    -- blizz
    "ChatEdit_InsertLink",
    "GameTooltip",
    "GetContainerItemID",
    "GetGuildInfo",
    "GetItemInfo",
    "GetRealmName",
    "HandleModifiedItemClick",
    "IsAltKeyDown",
    "IsInGroup",
    "IsInRaid",
    "Item",
    "ItemRefTooltip",
    "SendChatMessage",
    "SlashCmdList",
    "SocialPostFrame",
    "Social_InsertLink",
    "Social_IsShown",
    'SetGuildRosterShowOffline',
    'GuildRoster',
    'GetNumGuildMembers',
    'GetGuildRosterInfo',
    'GuildRosterSetOfficerNote',

    -- lua
    "strsub",
    "strsplit",
}
