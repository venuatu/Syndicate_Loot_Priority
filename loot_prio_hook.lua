BINDING_HEADER_DKP = "Syndicate Loot Priority";

local LOOT_ROLES = {
	{"ms1", "ms1: %s", 'main'},
	{"ms2", "ms2: %s", 'main'},
	{"os", "os1: %s", 'main'},
	{"open_ms1", "ms1: %s", 'open'},
	{"open_ms2", "ms2: %s", 'open'},
	{"ogp", "old: %s", 'gp'},
	{"gp", "new: %s", 'gp'},
}

local TYPE_TOOLTIP_PREFIXES = {
	["main"] = "|c00ff8000SynMain: %s",
	["open"] = "|c000070ddSynOpen: %s",
	["gp"] = "|c00ffff00SynGP: %s",
}

local TYPE_CHAT_PREFIXES = {
	["main"] = "SynMain: %s",
	["open"] = "SynOpen: %s",
	["gp"] = "SynGP: %s",
}

function syn_create_loot_lines(itemlink)
	local iid = itemlink:match("item:(%d+):")
	local item = syn_find_loot(iid)
	-- print(strconcat('scll ', iid, ": ", itemlink))
	if not item then
		return {}
	end

	local lines = {}
	
	for i, row in ipairs(LOOT_ROLES) do
		local key = row[1]
		local fmt = row[2]
		local line = row[3]
		local itemstring = item and item[key]
		if itemstring and itemstring ~= "" then
			fmt = string.format(fmt, itemstring)
			if not lines[line] then
				lines[line] = {}
			end
			table.insert(lines[line], fmt)
		end
	end

	local ret = {}

	for k, arr in pairs(lines) do
		local str = syn_strjoin(arr, ', ')
		-- local fmt = string.format(TYPE_TOOLTIP_PREFIXES[k] or k .. ': %s', str)
		ret[k] = str
	end

	return ret
end

function syn_append_tooltip(tooltip)
	local itemname, itemlink = tooltip:GetItem()

	local lines = syn_create_loot_lines(itemlink)

	for k, str in pairs(lines) do
		local fmt = string.format(TYPE_TOOLTIP_PREFIXES[k] or k .. ': %s', str)
		tooltip:AddLine(fmt)
	end
end

GameTooltip:HookScript("OnTooltipSetItem", syn_append_tooltip)
ItemRefTooltip:HookScript("OnTooltipSetItem", syn_append_tooltip)

local SYN_PRINT_TYPE = 'main'

function syn_printloot(link)
	if ( not link ) then
		return false;
	end
	local lines = syn_create_loot_lines(link)
	local msg = string.format(TYPE_CHAT_PREFIXES[SYN_PRINT_TYPE], lines[SYN_PRINT_TYPE] or 'none')
	msg = syn_strconcat(link, " ", msg)
	if ( ChatEdit_InsertLink(msg) ) then
	elseif ( SocialPostFrame and Social_IsShown() and Social_InsertLink(msg) ) then
	else
		syn_SendMessageGroup(msg)
	end
	return true
end

local orig_hmic = HandleModifiedItemClick
function syn_itemclick(link)
	-- FrameXML/ItemButtonTemplate.lua
	if IsAltKeyDown() then
		return syn_printloot(link)
	end
	-- if ( IsModifiedClick("DRESSUP") ) then
	-- 	return DressUpItemLink(link) or DressUpBattlePetLink(link) or DressUpMountLink(link)
	-- end
	return orig_hmic(link);
end

HandleModifiedItemClick = syn_itemclick

SLASH_SYNLOOT1 = "/syn"
SLASH_SYNLOOT2 = "/slp"

SlashCmdList.SYNLOOT = function(input)
    -- input = string.lower(input)
    local bits = syn_strtok(input:lower(), ' ')
    if bits[1] == 'main' then
        SYN_PRINT_TYPE = 'main'
    elseif bits[1] == 'open' then
        SYN_PRINT_TYPE = 'open'
    elseif bits[1] == 'gp' then
        SYN_PRINT_TYPE = 'gp'
    else
		print(syn_strconcat('Use "/syn (main|open|gp)" to switch modes'))
    end
	print(syn_strconcat('Syndicate Loot Priority: in "', SYN_PRINT_TYPE, '" printing mode'))
end
