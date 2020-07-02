-- searches for a specific item's information in loot_table.lua
local syn_loot_by_id = {}

do
    for index, value in next, inception_loot_table do
        syn_loot_by_id[value["id"]] = value
    end
end
-- {["loot_zone"] = "Blackwing Lair", ["loot_bosses"] = "Razorgore the Untamed", ["loot_name"] = "Mantle of the Blackwing Cabal", ["loot_id"] = "19370", ["mainspec_1"] = "Caster DPS", ["mainspec_2"] = "Priest", ["offset"] = "", ["prio"] = ""},

function syn_find_loot(item_id)
    return syn_loot_by_id[item_id]
end

function syn_strjoin(arr, sep)
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

function syn_slice(tbl, first, last, step)
    -- https://stackoverflow.com/a/24823383
    local sliced = {}

    for i = first or 1, last or #tbl, step or 1 do
        sliced[#sliced+1] = tbl[i]
    end

    return sliced
end

function syn_strtok(word, ch)
  local toks = {}
  local i, j = 0, 0
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

function syn_strconcat(...)
    local str = ''
    local args = {...}
    for i = 1, #args do
        str = str .. tostring(args[i])
    end
    return str
end

function syn_SendMessageGroup(...)
    local words = strconcat(...)
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
