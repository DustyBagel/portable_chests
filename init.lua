--[[
Copyright (C) 2024 Bob64 aka DustyBagel

This file is part of "portable_chests"

"portable_chests" is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 2.1 of the License, or
(at your option) any later version.

"portable_chests" is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with "portable_chests". If not, see <http://www.gnu.org/licenses/>.
]]--


portable_chests = {
    regular = {},
    locked = {},
}

local function drop_chest(nodename, digger, pos, oldmetadata)
    local chest_stuff = ItemStack(nodename)
    local meta = chest_stuff:get_meta()
  
    local inv = oldmetadata.inventory.main
    local empty = true
    for i, stack in ipairs(inv) do
        if stack:get_count() > 0 then
            empty = false
            break
        end
    end

    if not empty then
        local items = {}
        for listname, list in pairs(oldmetadata.inventory) do
            items[listname] = {}
            for i, stack in ipairs(list) do
                items[listname][i] = stack:to_string()
            end
        end
        meta:set_string("items", minetest.serialize(items))
        minetest.add_item(pos, chest_stuff)
    elseif digger:is_player() and not minetest.is_creative_enabled(digger:get_player_name()) then
        minetest.add_item(pos, chest_stuff)
    end
end


default.chest.register_chest("portable_chests:tin_chest", {
    description = "Portable Tin Chest",
    tiles = {
        "portable_chests_tin_chest_top.png",
        "portable_chests_tin_chest_top.png",
        "portable_chests_tin_chest_side.png",
        "portable_chests_tin_chest_side.png",
        "portable_chests_tin_chest_front.png",
        "portable_chests_inside.png"
    },
    sounds = default.node_sound_metal_defaults(),
    sound_open = "default_chest_open",
    sound_close = "default_chest_close",
    groups = {cracky = 3, oddly_breakable_by_hand = 2},
    on_dig = function(pos, node, digger)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        meta:set_string("description", "TEST TEST TEST TEST")
        drop_chest("portable_chests:tin_chest", digger, pos, meta:to_table())
        minetest.remove_node(pos)
    end,
    after_place_node = function(pos, placer, itemstack)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("main", 8 * 4)
        
        local items = minetest.deserialize(itemstack:get_meta():get_string("items"))
        if items then
            for listname, list in pairs(items) do
                for i, item in ipairs(list) do
                    inv:set_stack(listname, i, ItemStack(item))
                end
            end
            if placer:is_player() and minetest.is_creative_enabled(placer:get_player_name()) then
                itemstack:take_item()
            end
        end
    end,
    allow_metadata_inventory_put = function(inv, listname, index, stack, player)
        local name = stack:get_name()
        for i in ipairs(portable_chests.locked) do
            if portable_chests.locked[i] == name then
                return 0
            end
        end
        local stack_meta = stack:get_meta()
        local items = minetest.deserialize(stack_meta:get_string("items"))
        local is_portable_chest = false
        for i in ipairs(portable_chests.regular) do
            if portable_chests.regular[i] == name then
                is_portable_chest = true
                break
            end
        end
        if items and is_portable_chest then
            if not stack:is_empty() then
                return 0
            end
        end
        return stack:get_count()
    end,
})
table.insert(portable_chests.regular, "portable_chests:tin_chest")

-- To DO: Add locked portable_chests when
-- https://github.com/minetest/minetest_game/issues/3152
-- is fixed/resolved.

--[[
default.chest.register_chest("portable_chests:locked_tin_chest", {
    description = "Portable Locked Tin Chest",
    tiles = {
        "portable_chests_tin_chest_top.png",
        "portable_chests_tin_chest_top.png",
        "portable_chests_tin_chest_side.png",
        "portable_chests_tin_chest_side.png",
        "portable_chests_tin_chest_front_locked.png",
        "default_chest_inside.png"
    },
    sounds = default.node_sound_metal_defaults(),
    sound_open = "default_chest_open",
    sound_close = "default_chest_close",
    groups = {cracky = 3, oddly_breakable_by_hand = 2},
    on_dig = function(pos, node, digger)
        if default.can_interact_with_node(digger, pos) then
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            drop_chest("portable_chests:locked_tin_chest", pos, meta:to_table())
            minetest.remove_node(pos)
        end
    end,
    after_place_node = function(pos, placer, itemstack)
        local meta = minetest.get_meta(pos)
        meta:set_string("owner", placer:get_player_name() or "")
        meta:set_string("infotext", "Locked Portable Tin Chest (owned by @1)", meta:get_string("owner"))
        local inv = meta:get_inventory()
        
        local items = minetest.deserialize(itemstack:get_meta():get_string("items"))
        if items then
            for listname, list in pairs(items) do
                for i, item in ipairs(list) do
                    inv:set_stack(listname, i, ItemStack(item))
                end
            end
        end

        --meta:set_string("infotext", "Portable Tin Chest")
    end,
    allow_metadata_inventory_put = function(inv, listname, index, stack, player)
        if not default.can_interact_with_node(player, pos) then
            return 0
        end
        minetest.chat_send_all("This is running.")
        local name = stack:get_name()
        local stack_meta = stack:get_meta()
        local items = minetest.deserialize(stack_meta:get_string("items"))

       local is_portable_chest = false
        for table in ipairs(portable_chests) do
            for i in pairs(table) do
                if portable_chests.table[i] == name then
                    is_portable_chest = true
                    break
                end
            end
        end
        minetest.chat_send_all("is_portable_chest = "..tostring(is_portable_chest))
        if items and is_portable_chest then
            if not stack:is_empty() then
                return 0
            end
        end
        minetest.chat_send_all("is able to go into chest.")
        return stack:get_count()
    end,
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("main", 8*4)
    end,
})
table.insert(portable_chests.locked, "portable_chests:locked_tin_chest")
]]


minetest.register_craft({
    output = "portable_chests:tin_chest",
    recipe = {
        {"default:tin_ingot", "default:tin_ingot", "default:tin_ingot"},
        {"default:tin_ingot", "",                  "default:tin_ingot"},
        {"default:tin_ingot", "default:tin_ingot", "default:tin_ingot"}
    }
})