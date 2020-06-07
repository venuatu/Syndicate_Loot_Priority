BINDING_HEADER_DKP = "Syndicate Loot Priority";

local LOOT_ROLES = {
	{"ms1", "ms1: %s", 'main'},
	{"ms2", "ms2: %s", 'main'},
	{"os", "os1: %s", 'main'},
	{"open_ms1", "ms1: %s", 'open'},
	{"open_ms2", "ms2: %s", 'open'},
}

local TYPE_PREFIXES = {
	["main"] = "|c00ff8000Syn Main: %s",
	["open"] = "|c000070ddSyn Open: %s",
}

local function strjoin(arr, sep)
	local str = ''
	local len = #arr

	for i, s in ipairs(arr) do
		str = str .. s
		if i ~= len then
			str = str .. sep
		end
	end
	return str
end

local function append_tooltip(tooltip)
	local itemname, itemlink = tooltip:GetItem()
	local lines = {}

	if not itemlink then
		return
	end
	
	for i, row in ipairs(LOOT_ROLES) do
		local key = row[1]
		local fmt = row[2]
		local line = row[3]
		local item = syn_find_loot(itemlink:match("item:(%d+):"))
		local itemstring = item and item[key]
		if itemstring and itemstring ~= "" then
			fmt = string.format(fmt, itemstring)
			if not lines[line] then
				lines[line] = {}
			end
			table.insert(lines[line], fmt)
		end
	end

	for k, arr in pairs(lines) do
		local str = strjoin(arr, ', ')
		local fmt = string.format(TYPE_PREFIXES[k] or k .. ': %s', str)
		tooltip:AddLine(fmt)
	end
end

GameTooltip:HookScript("OnTooltipSetItem", append_tooltip)
ItemRefTooltip:HookScript("OnTooltipSetItem", append_tooltip)
