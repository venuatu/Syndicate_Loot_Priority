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
	if not itemlink then
		return {}
	end

	local iid = itemlink:match("item:(%d+):")
	local item = syn_find_loot(iid)
	-- print(syn_strconcat('scll ', iid, ": ", itemlink))

	if not item then
		return {}
	end

	local lines = {}

	for _, row in ipairs(LOOT_ROLES) do
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
	local _, itemlink = tooltip:GetItem()

	local lines = syn_create_loot_lines(itemlink)

	for k, str in pairs(lines) do
		local fmt = string.format(TYPE_TOOLTIP_PREFIXES[k] or k .. ': %s', str)
		tooltip:AddLine(fmt)
	end
end

GameTooltip:HookScript("OnTooltipSetItem", syn_append_tooltip)
ItemRefTooltip:HookScript("OnTooltipSetItem", syn_append_tooltip)

SYN_PRINT_TYPE = 'main'

function syn_printloot(link)
	if ( not link ) then
		return false;
	end
	local lines = syn_create_loot_lines(link)
	local msg = string.format(TYPE_CHAT_PREFIXES[SYN_PRINT_TYPE], lines[SYN_PRINT_TYPE] or 'none')
	msg = syn_strconcat(link, " ", msg)
	if not (( ChatEdit_InsertLink(msg) ) or
		( SocialPostFrame and Social_IsShown() and Social_InsertLink(msg) )) then
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

function syn_do_override(item, version)
	local link = CEPGP_getItemLink(item["id"])
	if not link then
		-- print(syn_strconcat("pulling item info ", item["id"]))
		-- local itemobj = Item:CreateFromItemID(tonumber(item["id"]))
		-- itemobj:ContinueOnItemLoad(function()
		-- 	print(syn_strconcat("loaded item info ", item["id"]))
		-- 	syn_do_override(item, version)
		-- end)
		print(syn_strconcat('error loading item ', item["id"], ": ", item["name"]))
		return
	end
	OVERRIDE_INDEX[link] = item[version]
end

function syn_continue_override_cepgp(to_load, i, n, version)
	if not i then
		i = 1
	end
	if i % 10 == 0 then
		print(syn_strconcat('Syn: download ', i, ' of ', #to_load, ' items'))
	end
	if i >= #to_load then
		print(syn_strconcat('Syn: finished overriding ', n, ' items in CEPGP'))
	else
		local item = to_load[i]
		local itemobj = Item:CreateFromItemID(tonumber(item["id"]))
		itemobj:ContinueOnItemLoad(function()
			-- print(syn_strconcat("loaded item info ", item["id"]))
			syn_continue_override_cepgp(to_load, i + 1, n)
			syn_do_override(item, version)
		end)
	end
	-- for i, item in ipairs(inception_loot_table) do
	-- 	if item[version] and item["phase"] <= "4" then
	-- 		syn_do_override(item, version)
	-- 	end
	-- end
end

function syn_override_cepgp(version)
	if not version then
		version = "gp"
	end
	local to_load = {}
	local n = 0
	for _, item in ipairs(inception_loot_table) do
		if item[version] then
			local _, link = GetItemInfo(item["id"])
			if not link then
				table.insert(to_load, item)
			else
				syn_do_override(item, version)
			end
			n = n + 1
		end
	end
	print(syn_strconcat('Syn: need to download ', #to_load, ' of ', n, ' items'))
	syn_continue_override_cepgp(to_load, 1, n, version)
	CEPGP["Overrides"] = OVERRIDE_INDEX
end


-- /script local n, l = GetItemInfo(16900); CEPGP_announce(l, 1, 1, 1)
-- local id = "16900"; local name, link, quality, _, _, ty, sty, _, _, tex, _ = GetItemInfo(id); CEPGP_populateFrame({{[1]=tex, [2]=name, [3]=quality, [4]=link, [5]=id, [6]=1, [7]=1}})

-- /script syn_loot_bags()

function syn_cepgp_to_item(item)
	local it = {}
	local name, link, quality, _, _, _, _, _, _, tex, _ = GetItemInfo(item)
	if not link then
		print(syn_strconcat("Syn: unknown item: ", item))
	end

	it[1] = tex
	it[2] = name
	it[3] = quality
	it[4] = link
	local itemString = string.find(link, "item[%-?%d:]+")
	itemString = strsub(link, itemString, string.len(link)-string.len(name)-6)
	it[5] = itemString
	it[6] = 1
	it[7] = 1
	local _, iid = strsplit(":", link)
	it[8] = iid
	return it
end

function syn_loot_bags()
	local items = {}
	local seen = {}
	for b = 0, 4 do
		for s = 1, 30 do
			local iid = GetContainerItemID(b, s)
			if iid and not seen[iid] then
				seen[iid] = true
				local it = syn_cepgp_to_item(iid)
				if syn_find_loot(iid) then
					table.insert(items, it)
				end
			end
		end
	end
	table.sort(items, function(a, b)
		return tonumber(syn_find_loot(a[8])["gp"]) > tonumber(syn_find_loot(b[8])["gp"])
	end)
	syn_cepgp_start_loot(items)
end

function syn_loot_item(iid)
	local items = {
		syn_cepgp_to_item(iid),
	}
	syn_cepgp_start_loot(items)
end

function syn_cepgp_start_loot(items)
	CEPGP_frame:Show();
	CEPGP_mode = "loot";
	CEPGP_toggleFrame("CEPGP_loot");
	CEPGP_populateFrame(items);
	CEPGP_distribute_popup_give = function()
		print("Syn: CEPGP_distribute_popup_give has been hooked, /reload to restore cepgp master looting integration")
		CEPGP_handleLoot("LOOT_SLOT_CLEARED", CEPGP_lootSlot)
	end
	CEPGP_LootFrame_Update = syn_loot_bags
end

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
    elseif bits[1] == 'override' then
        syn_override_cepgp(bits[2])
    elseif bits[1] == 'loot' then
        syn_loot_item(syn_strjoin(syn_slice(bits, 2), " "))
    elseif bits[1] == 'lootbags' then
        syn_loot_bags()
    else
		print(syn_strconcat('Use "/syn (main|open|gp)" to switch modes'))
    end
	print(syn_strconcat('Syndicate Loot Priority: in "', SYN_PRINT_TYPE, '" printing mode'))
end
