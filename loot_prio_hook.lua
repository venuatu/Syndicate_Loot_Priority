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

function SYN:create_loot_lines(itemlink)
	if not itemlink then
		return {}
	end

	local iid = itemlink:match("item:(%d+):")
	local item = SYN:find_loot(iid)
	-- print(SYN:strconcat('scll ', iid, ": ", itemlink))

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
		local str = SYN:strjoin(arr, ', ')
		-- local fmt = string.format(TYPE_TOOLTIP_PREFIXES[k] or k .. ': %s', str)
		ret[k] = str
	end

	return ret
end

function SYN:append_tooltip(tooltip)
	local _, itemlink = tooltip:GetItem()

	local lines = SYN:create_loot_lines(itemlink)

	for k, str in pairs(lines) do
		local fmt = string.format(TYPE_TOOLTIP_PREFIXES[k] or k .. ': %s', str)
		tooltip:AddLine(fmt)
	end
end

GameTooltip:HookScript("OnTooltipSetItem", function (t) SYN:append_tooltip(t) end)
ItemRefTooltip:HookScript("OnTooltipSetItem", function (t) SYN:append_tooltip(t) end)

SYN_PRINT_TYPE = 'main'

function SYN:printloot(link)
	if ( not link ) then
		return false;
	end
	local lines = SYN:create_loot_lines(link)
	local msg = string.format(TYPE_CHAT_PREFIXES[SYN_PRINT_TYPE], lines[SYN_PRINT_TYPE] or 'none')
	msg = SYN:strconcat(link, " ", msg)
	if not (( ChatEdit_InsertLink(msg) ) or
		( SocialPostFrame and Social_IsShown() and Social_InsertLink(msg) )) then
		SYN:SendMessageGroup(msg)
	end
	return true
end

local orig_hmic = HandleModifiedItemClick
function SYN:itemclick(link)
	-- FrameXML/ItemButtonTemplate.lua
	if IsAltKeyDown() then
		return SYN:printloot(link)
	end
	-- if ( IsModifiedClick("DRESSUP") ) then
	-- 	return DressUpItemLink(link) or DressUpBattlePetLink(link) or DressUpMountLink(link)
	-- end
	return orig_hmic(link);
end

HandleModifiedItemClick = function (i) SYN:itemclick(i) end

function SYN:do_override(item, version)
	local link = CEPGP_getItemLink(item["id"])
	if not link then
		-- print(SYN:strconcat("pulling item info ", item["id"]))
		-- local itemobj = Item:CreateFromItemID(tonumber(item["id"]))
		-- itemobj:ContinueOnItemLoad(function()
		-- 	print(SYN:strconcat("loaded item info ", item["id"]))
		-- 	SYN:do_override(item, version)
		-- end)
		print(SYN:strconcat('error loading item ', item["id"], ": ", item["name"]))
		return
	end
	OVERRIDE_INDEX[link] = item[version]
end

function SYN:continue_override_cepgp(to_load, i, n, version)
	if not i then
		i = 1
	end
	if i % 10 == 0 then
		print(SYN:strconcat('Syn: download ', i, ' of ', #to_load, ' items'))
	end
	if i >= #to_load then
		print(SYN:strconcat('Syn: finished overriding ', n, ' items in CEPGP'))
	else
		local item = to_load[i]
		local itemobj = Item:CreateFromItemID(tonumber(item["id"]))
		itemobj:ContinueOnItemLoad(function()
			-- print(SYN:strconcat("loaded item info ", item["id"]))
			SYN:continue_override_cepgp(to_load, i + 1, n)
			SYN:do_override(item, version)
		end)
	end
	-- for i, item in ipairs(syndicate_loot_table) do
	-- 	if item[version] and item["phase"] <= "4" then
	-- 		SYN:do_override(item, version)
	-- 	end
	-- end
end

function SYN:override_cepgp(version)
	if not version then
		version = "gp"
	end
	local to_load = {}
	local n = 0
	for _, item in ipairs(syndicate_loot_table) do
		if item[version] then
			local _, link = GetItemInfo(item["id"])
			if not link then
				table.insert(to_load, item)
			else
				SYN:do_override(item, version)
			end
			n = n + 1
		end
	end
	print(SYN:strconcat('Syn: need to download ', #to_load, ' of ', n, ' items'))
	SYN:continue_override_cepgp(to_load, 1, n, version)
	CEPGP["Overrides"] = OVERRIDE_INDEX
end


-- /script local n, l = GetItemInfo(16900); CEPGP_announce(l, 1, 1, 1)
-- local id = "16900"; local name, link, quality, _, _, ty, sty, _, _, tex, _ = GetItemInfo(id); CEPGP_populateFrame({{[1]=tex, [2]=name, [3]=quality, [4]=link, [5]=id, [6]=1, [7]=1}})

-- /script SYN:loot_bags()

function SYN:cepgp_to_item(item)
	local it = {}
	local name, link, quality, _, _, _, _, _, _, tex, _ = GetItemInfo(item)
	if not link then
		print(SYN:strconcat("Syn: unknown item: ", item))
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

function SYN:loot_bags()
	local items = {}
	local seen = {}
	for b = 0, 4 do
		for s = 1, 30 do
			local iid = GetContainerItemID(b, s)
			if iid and not seen[iid] then
				seen[iid] = true
				local it = SYN:cepgp_to_item(iid)
				if SYN:find_loot(iid) then
					table.insert(items, it)
				end
			end
		end
	end
	table.sort(items, function(a, b)
		return tonumber(SYN:find_loot(a[8])["gp"]) > tonumber(SYN:find_loot(b[8])["gp"])
	end)
	SYN:cepgp_start_loot(items)
end

function SYN:loot_item(iid)
	local items = {
		SYN:cepgp_to_item(iid),
	}
	SYN:cepgp_start_loot(items)
end

function SYN:cepgp_start_loot(items)
	CEPGP_frame:Show();
	CEPGP_mode = "loot";
	CEPGP_toggleFrame("CEPGP_loot");
	CEPGP_populateFrame(items);
	CEPGP_distribute_popup_give = function()
		print("Syn: CEPGP_distribute_popup_give has been hooked, /reload to restore cepgp master looting integration")
		CEPGP_handleLoot("LOOT_SLOT_CLEARED", CEPGP_lootSlot)
	end
	CEPGP_LootFrame_Update = function () SYN:loot_bags() end
end

function SYN:PrintReserves()
    local state = LootReserve.Server.CurrentSession.AcceptingReserves and 'Open' or 'Closed'
    SYN:SendMessageGroup('Soft Reserve List: ', state)

    for item, x in pairs(LootReserve.Server.CurrentSession.ItemReserves) do
        SYN:PrintItem(item, x.Players)
    end
    SYN:SendMessageGroup('Loot Rules: Soft Reserve > Main-spec > Off-spec. People without reserves get 3 rounds of greens.')
    SYN:SendMessageGroup('Everyone gets one soft reserve(free), only people that have reserved can roll on soft reserved items')
    SYN:SendMessageGroup('Whisper me to soft reserve: !reserve itemNameOrLink')

    -- zg mounts
    LootReserve.Server.ReservableItems[19902] = nil
    LootReserve.Server.ReservableItems[19872] = nil
end

function SYN:PrintItem(item)
    print(tostring(item))
    local itemres = LootReserve.Server.CurrentSession.ItemReserves[item]
    local players = itemres and itemres.Players or {}
    local _, link = GetItemInfo(item)
    if link == nil then
        Item:CreateFromItemID(item):ContinueOnItemLoad(function()
            SYN:PrintItem(item)
        end)
        return
    end

    SYN:SendMessageGroup(link, ' for (', #players, '): ', SYN:strjoin(players, ', '))
end

SLASH_SYNLOOT1 = "/syn"
SLASH_SYNLOOT2 = "/slp"

SlashCmdList.SYNLOOT = function(input)
    -- input = string.lower(input)
    local bits = SYN:strtok(input:lower(), ' ')
    if bits[1] == 'main' then
        SYN_PRINT_TYPE = 'main'
    elseif bits[1] == 'open' then
        SYN_PRINT_TYPE = 'open'
    elseif bits[1] == 'gp' then
        SYN_PRINT_TYPE = 'gp'
    -- elseif bits[1] == 'override' then
    --     SYN:override_cepgp(bits[2])
    -- elseif bits[1] == 'loot' then
    --     SYN:loot_item(SYN:strjoin(SYN:slice(bits, 2), " "))
    -- elseif bits[1] == 'lootbags' then
    --     SYN:loot_bags()
    elseif bits[1] == 'pr' or bits[1] == 'res' or bits[1] == 'reserve' or bits[1] == 'printres' then
        SYN:PrintReserves()
    else
		print(SYN:strconcat('Use "/syn (main|open|gp|res|reserve)"'))
    end
	print(SYN:strconcat('Syndicate Loot Priority: in "', SYN_PRINT_TYPE, '" printing mode'))
end
