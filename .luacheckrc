std = "lua51"
max_line_length = false
exclude_files = {
	"**/Libs/**/*.lua",
	".luacheckrc"
}
ignore = {
	"11./SLASH_.*", -- Setting an undefined (Slash handler) global variable
	"11./BINDING_.*", -- Setting an undefined (Keybinding header) global variable
--	"113/LE_.*", -- Accessing an undefined (Lua ENUM type) global variable
--	"113/NUM_LE_.*", -- Accessing an undefined (Lua ENUM type) global variable
	-- "211", -- Unused local variable
	-- "211/L", -- Unused local variable "L"
	-- "211/CL", -- Unused local variable "CL"
	"212", -- Unused argument
--	"431", -- shadowing upvalue
	-- "43.", -- Shadowing an upvalue, an upvalue argument, an upvalue loop variable.
	-- "542", -- An empty if branch
}
globals = {
	"_G",
	"bit",

	-- Saved Variables
    "SYN_PRINT_TYPE",

    -- functions
    "inception_loot_table",
    "syn_SendMessageGroup",
    "syn_append_tooltip",
    "syn_cepgp_start_loot",
    "syn_cepgp_to_item",
    "syn_continue_override_cepgp",
    "syn_create_loot_lines",
    "syn_do_override",
    "syn_find_loot",
    "syn_itemclick",
    "syn_loot_bags",
    "syn_loot_item",
    "syn_override_cepgp",
    "syn_printloot",
    "syn_slice",
    "syn_strconcat",
    "syn_strjoin",
    "syn_strtok",


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
    "GetItemInfo",
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

    -- lua
    "strsub",
    "strsplit",
}
