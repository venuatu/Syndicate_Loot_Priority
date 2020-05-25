-- searches for a specific item's information in loot_table.lua
loot_by_id = {}

do
    for index, value in next, inception_loot_table do
        loot_by_id[value["id"]] = value
    end
end
-- {["loot_zone"] = "Blackwing Lair", ["loot_bosses"] = "Razorgore the Untamed", ["loot_name"] = "Mantle of the Blackwing Cabal", ["loot_id"] = "19370", ["mainspec_1"] = "Caster DPS", ["mainspec_2"] = "Priest", ["offset"] = "", ["prio"] = ""},

function syn_find_loot(item_id)
    return loot_by_id[item_id]
end
