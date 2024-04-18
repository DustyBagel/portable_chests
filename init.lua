local function drop_chest(pos, oldmetadata)
    local chest_stuff = ItemStack("portable_chests:tin_chest")
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
    end

    minetest.add_item(pos, chest_stuff)
end


default.chest.register_chest("portable_chests:tin_chest", {
    description = "Portable Tin Chest",
    tiles = {
        "portable_chests_tin_chest_top.png",
        "portable_chests_tin_chest_top.png",
        "portable_chests_tin_chest_side.png",
        "portable_chests_tin_chest_side.png",
        "portable_chests_tin_chest_front.png",
        "default_chest_inside.png"
    },
    sounds = default.node_sound_metal_defaults(),
    sound_open = "default_chest_open",
    sound_close = "default_chest_close",
    groups = {craky = 3, oddly_breakable_by_hand = 2},
    on_dig = function(pos, node, digger)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        drop_chest(pos, meta:to_table())
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
        end
    end,
    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        local stack_meta = stack:get_meta()
        local items = minetest.deserialize(stack_meta:get_string("items"))
        if stack:get_name() == "portable_chests:tin_chest" and items then
            for listname, list in pairs(items) do
                for i, stack_string in ipairs(list) do
                    local stack = ItemStack(stack_string)
                    if not stack:is_empty() then
                        return 0
                    end
                end
            end
        end
        return stack:get_count()
    end,
})

minetest.register_craft({
    output = "portable_chests:tin_chest",
    recipe = {
        {"default:tin_ingot", "default:tin_ingot", "default:tin_ingot"},
        {"default:tin_ingot", "",                  "default:tin_ingot"},
        {"default:tin_ingot", "default:tin_ingot", "default:tin_ingot"}
    }
})

if minetest.get_modpath("hopper") then
    hopper:add_container({
		{"top", "portable_chests:tin_chest", "main"},
		{"side", "portable_chests:tin_chest", "main"},
        {"bottom", "portable_chests:tin_chest", "main"},

		{"top", "portable_chests:tin_chest_open", "main"},
		{"side", "portable_chests:tin_chest_open", "main"},
        {"bottom", "portable_chests:tin_chest_open", "main"},
    })
end

minetest.register_alias_force("metal_chests:tin_chest", "portable_chests:tin_chest")