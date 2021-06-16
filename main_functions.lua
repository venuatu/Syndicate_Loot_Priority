-- searches for a specific item's information in loot_table.lua
SYN = {}

SYN.loot_by_id = {}

do
    for _, value in next, syndicate_loot_table do
        SYN.loot_by_id[value["id"]] = value
    end
end
-- {["loot_zone"] = "Blackwing Lair", ["loot_bosses"] = "Razorgore the Untamed", ["loot_name"] = "Mantle of the Blackwing Cabal", ["loot_id"] = "19370", ["mainspec_1"] = "Caster DPS", ["mainspec_2"] = "Priest", ["offset"] = "", ["prio"] = ""},

function SYN:find_loot(item_id)
    return SYN.loot_by_id[tonumber(item_id)]
end

function SYN:RCEPGP(itemID)
    local iid = tostring(itemID)
    local item = SYN:find_loot(iid)
    return tonumber(item and (item['ogp'] or item['gp']) or '1')
    -- ['ogp'] or SYN:find_loot(tostring(itemID))['gp'] or 1
end

function SYN:get_item_id(link)
    if link == nil then return nil end
    return link:match("item:(%d+):")
end

local class_item_cache = {}

function SYN:find_class_item(link, cls)
    if link == nil or cls == nil then return nil end
    cls = cls:lower()
    if class_item_cache[cls .. link] then
        return class_item_cache[cls .. link]
    end
    local tokid = SYN:get_item_id(link)
    local token = SYN:find_loot(tokid)
    local options = {}

    if token then
        -- print('convert ' .. tostring(name) .. ' '  .. tostring(link))
        for _, value in next, syndicate_loot_table do
            if value['token'] == token['name'] and value['class'] and value['class']:lower() == cls then
                print(SYN:strconcat('Converted ', link, ' -> ', value['name'] , ' for ', value['class']))
                table.insert(options, value)
            end
        end
    end
    if #options ~= 1 then
        -- print(SYN:strconcat('skipping conversion unable to find item: ', cls, ' ', link, ' ', #options))
        return nil
    end
    class_item_cache[cls .. link] = options[1]
    return options[1]
end

function SYN:strjoin(arr, sep)
    local str = ''
    local len = #arr

    for i, s in ipairs(arr) do
        str = str .. tostring(s)
        if i ~= len then
            str = str .. sep
        end
    end
    return str
end

function SYN:slice(tbl, first, last, step)
    -- https://stackoverflow.com/a/24823383
    local sliced = {}

    for i = first or 1, last or #tbl, step or 1 do
        sliced[#sliced+1] = tbl[i]
    end

    return sliced
end

function SYN:strtok(word, ch)
  local toks = {}
  local i
  local j = 0
  while j ~= nil do
    local start = j and j + 1 or 0
    i, j = word:find(ch, start)
    if i == nil then
      i = #word + 1
    end
    local str = word:sub(start, i - 1)
    table.insert(toks, str)
    -- print(str .. ',' .. tostring(i) .. ',' .. tostring(j))
  end
  return toks
end

function SYN:strconcat(...)
    local str = ''
    local args = {...}
    for i = 1, #args do
        str = str .. tostring(args[i])
    end
    return str
end

function SYN:SendMessageGroup(...)
    local words = SYN:strconcat(...)
    -- words = "Big" words
    if IsInRaid() then
        SendChatMessage(words, "RAID")
    elseif IsInGroup() then
        SendChatMessage(words, "PARTY")
    else--for solo raid
    --     SendChatMessage(words, "SAY")
        print(words)
    end
end

function SYN:UpdateBankNotes()
    local BANK_TOONS = {'Synchant','Synbank','Synherbs','Synmats','Synpots','Synterlink','Syntrelink'}
    SetGuildRosterShowOffline(true)
    GuildRoster()
    for i = 1,GetNumGuildMembers() do
        local n,_,_,_,_,_,_,ono=GetGuildRosterInfo(i)
        for _,x in ipairs(BANK_TOONS) do
            if n and n:find(x) then
                print(SYN:strconcat('updating bank toon ', i, " -> ", n, ': ', ono))
                GuildRosterSetOfficerNote(i, "gbank")
            end
        end
    end
end
