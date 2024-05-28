
local ScriptStartPosition

local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


function move(StartPosition, Axis, Distance)
    local EndPosition = vector.new(StartPosition.x, StartPosition.y, StartPosition.z)
    
    -- Adjust the appropriate axis based on the Axis parameter
    if Axis == "x" then
        EndPosition.x = EndPosition.x + Distance
    elseif Axis == "y" then
        EndPosition.y = EndPosition.y + Distance
    elseif Axis == "z" then
        EndPosition.z = EndPosition.z + Distance
    else
        -- Handle invalid axis (optional)
        print("Invalid axis specified")
    end
    
    return EndPosition
end


function fill_box(StartPosition, X_size, Y_size, Z_size, FillAlongAxis, ReplaceWith, PlaceNode, PlaceLocation, PlacePosition, ReturnToStart)
        -- Set default value for ReturnToStart if not provided
    if ReturnToStart == nil then
        ReturnToStart = false
    end

	--minetest.log("log","start")
	local EndPosition = vector.new(StartPosition.x, StartPosition.y, StartPosition.z)
	local DirPositive = false
	
    -- Adjust the start and end positions based on the FillAlongAxis and sizes
    if FillAlongAxis == 'X' then
        EndPosition.x = EndPosition.x + X_size
		if X_size > 0 then DirPositive = true end
    elseif FillAlongAxis == 'Y' then
        EndPosition.y = EndPosition.y + Y_size
		if Y_size > 0 then DirPositive = true end
    elseif FillAlongAxis == 'Z' then
        EndPosition.z = EndPosition.z + Z_size
		if Z_size > 0 then DirPositive = true end
    end
		--because we always add size, we adjust area to actual size by always subtracting -1.
		if X_size >= 0 then
			FillEndPositionX= StartPosition.x + X_size -1
		else 
			FillEndPositionX= StartPosition.x + X_size +1
		end
		if Y_size >= 0 then
			FillEndPositionY= StartPosition.y + Y_size -1
		else 
			FillEndPositionY= StartPosition.y + Y_size +1
		end
		if Z_size >= 0 then
			FillEndPositionZ= StartPosition.z + Z_size -1
		else 
			FillEndPositionZ= StartPosition.z + Z_size +1
		end
		
    -- Fill the area with new nodes
	    --minetest.log("x","StartPositionX:"..StartPosition.x)
		--minetest.log("x","FillEndPositionX:"..FillEndPositionX)
		--minetest.log("x","StartPositionY:"..StartPosition.y)
		--minetest.log("x","FillEndPositionY:"..FillEndPositionY)
		--minetest.log("x","StartPositionZ:"..StartPosition.z)
		--minetest.log("x","FillEndPositionZ:"..FillEndPositionZ)

		-- Determine the start and end points for each axis (always looping from the lower number to the larger number)
		local startX, endX = math.min(StartPosition.x, FillEndPositionX), math.max(StartPosition.x, FillEndPositionX)
		local startY, endY = math.min(StartPosition.y, FillEndPositionY), math.max(StartPosition.y, FillEndPositionY)
		local startZ, endZ = math.min(StartPosition.z, FillEndPositionZ), math.max(StartPosition.z, FillEndPositionZ)

		-- Iterate over the specified range for each axis
		for x = startX, endX do
			for y = startY, endY do
				for z = startZ, endZ do
					if ReplaceWith == "default:ladder" then
						minetest.set_node({x = x, y = y, z = z}, {name = ReplaceWith, param2 = 3})
					else
						minetest.set_node({x = x, y = y, z = z}, {name = ReplaceWith})
					end
					
					--minetest.log("x","x,y,z:"..x..","..y..","..z)
					--minetest.log("x","replacewith:"..ReplaceWith)
				end
			end
		end
	if(PlaceNode ~= nil and PlaceLocation ~= nil and PlacePosition ~= nil) then
    -- Place the special single node at the specified location
		local place_position
		if PlaceLocation == 'T' and FillAlongAxis == "Y" then  --top of new box
			place_position = {x = FillEndPositionX, y = StartPosition.y + (PlacePosition), z = StartPosition.z + math.floor(Z_size / 2)}
		elseif PlaceLocation == 'B' and FillAlongAxis == "Y" then  --top of new box
			place_position = {x = StartPosition.x, y = StartPosition.y + (PlacePosition), z = StartPosition.z + math.floor(Z_size / 2)}
		elseif PlaceLocation == 'T'   and FillAlongAxis == "X" then --top of new box
			place_position = {x = StartPosition.x + PlacePosition, y = FillEndPositionY, z = StartPosition.z + math.floor(Z_size / 2)}
		elseif PlaceLocation == 'B'   and FillAlongAxis == "X" then --top of new box
			place_position = {x = StartPosition.x + PlacePosition, y = StartPosition.y, z = StartPosition.z + math.floor(Z_size / 2)}
		elseif PlaceLocation == 'T'   and FillAlongAxis == "Z" then --top of new box
			place_position = {x = StartPosition.x + math.floor(X_size / 2), y = FillEndPositionY, z = StartPosition.z+PlacePosition }
		elseif PlaceLocation == 'B'   and FillAlongAxis == "Z" then --top of new box
			place_position = {x = StartPosition.x + math.floor(X_size / 2), y = StartPosition.y, z = StartPosition.z+PlacePosition}
		end
		--minetest.log("x","x,y,z:"..place_position.x..","..place_position.y..","..place_position.z)
		--minetest.log("log", "PlaceNode: "..PlaceNode)
		local param2dir = 0
		if (DirPositive) then param2dir = 2 end
		--minetest.log("x","param2dir: "..param2dir)
		minetest.set_node(place_position, {name = PlaceNode, param2 = param2dir })
	end
 -- minetest.log("log","end")
	if ReturnToStart then
		return StartPosition
	else
		return EndPosition
	end
end

function place_node(StartPosition, X_offset, Y_offset, Z_offset, ReplaceWith, ReturnToStart)
	--minetest.log("x","start place_node")
	
	--local EndPosition = vector.new(StartPosition.x, StartPosition.y, StartPosition.z)
	local EndPosition = deepcopy(StartPosition)
	EndPosition.x = EndPosition.x + X_offset
	EndPosition.y = EndPosition.y + Y_offset
	EndPosition.z = EndPosition.z + Z_offset
	--[[if(ReplaceWith == "boulder_dig:exit" or ReplaceWith == "boulder_dig:exit_dormant") then
		minetest.log("x","x,y,z:"..EndPosition.x..","..EndPosition.y..","..EndPosition.z)
	end]]
	--minetest.log("x","StartPos x,y,z:"..StartPosition.x..","..StartPosition.y..","..StartPosition.z)
	--minetest.log("x","EndPos x,y,z:"..EndPosition.x..","..EndPosition.y..","..EndPosition.z)
	minetest.set_node(EndPosition, {name = ReplaceWith})

	if ReturnToStart then
		--minetest.log("x","end place_node STARTPOS")	
		return StartPosition
	else
		--minetest.log("x","end place_node ENDPOS")		
		return EndPosition
	end
end


function build_level(pos, x_size, y_size, z_size, boulder_chance, gem_chance, cobble_every_x, cobble_chance_x, cobble_every_y, cobble_chance_y, cobble_every_z, cobble_chance_z)
    StartPosition = pos
	local minp = vector.new(pos)
    local maxp = vector.add(minp, {x=x_size-1, y=y_size-1, z=z_size-1})
    local manip = minetest.get_voxel_manip()

    local emerged_pos1, emerged_pos2 = manip:read_from_map(minp, maxp)
    local area = VoxelArea:new({MinEdge=emerged_pos1, MaxEdge=emerged_pos2})
    local data = manip:get_data()

    for z = pos.z, pos.z + z_size - 1 do
        for y = pos.y, pos.y + y_size - 1 do
            for x = pos.x, pos.x + x_size - 1 do
                local vi = area:index(x, y, z)
                local node = minetest.get_name_from_content_id(data[vi])

				
				-- Check if it's the bottom level
                if y == pos.y then
                    data[vi] = minetest.get_content_id("default:steelblock")
                -- Replace nodes along outer surface except the bottom
                elseif x == pos.x or x == pos.x + x_size - 1 or
                   y == pos.y or y == pos.y + y_size - 1 or
                   z == pos.z or z == pos.z + z_size - 1 then
                    data[vi] = minetest.get_content_id("xpanes:bar_flat")
                else
                    -- Default replacement node
                    local replacement_node = "default:dirt"

                    -- Check boulder_chance and gem_chance
                    local random_chance = math.random()
                    if random_chance <= boulder_chance then
                        replacement_node = "boulders:boulder"
                    elseif random_chance <= boulder_chance + gem_chance then
                        replacement_node = "boulder_dig:gemstone" 
                    else
                        -- Check for cobblestone placement
                        if x % cobble_every_x == 0 and math.random() <= cobble_chance_x then
                            replacement_node = "default:cobble"
                        elseif y % cobble_every_y == 0 and math.random() <= cobble_chance_y then
                            replacement_node = "default:cobble"
                        elseif z % cobble_every_z == 0 and math.random() <= cobble_chance_z then
                            replacement_node = "default:cobble"
                        end
                    end

                    data[vi] = minetest.get_content_id(replacement_node)
                end
            end
        end
    end

    manip:set_data(data)
    manip:write_to_map(true)
	return StartPosition
end

function move_to_script_start_position()
	local resetPosition = deepcopy(ScriptStartPosition)
	return resetPosition
end

function run_script(StartPosition, script_table)
    --sequentially runs all commands in the table along with their corresponding parameters.
	--called functions return an EndPosition value which should be passed in to the next row/function in the table until all the functions have been executed.
	
	--minetest.log("x","run_script")
	ScriptStartPosition = deepcopy(StartPosition)
	--minetest.log("x","ORIG: x:"..StartPosition.x.." y:"..StartPosition.y.." z:"..StartPosition.z)
	--ScriptStartPosition = StartPosition
	local current_position = StartPosition
	if(script_table == nil) then
		return
	else
		for i, func_data in ipairs(script_table) do
			local func_name = func_data[1]
			local func_params = {StartPosition}
			for j = 2, #func_data do
				table.insert(func_params, func_data[j])
			end

			if func_name == "move" then
				current_position = move(unpack(func_params))
			elseif func_name == "fill_box" then
				current_position = fill_box(unpack(func_params))
			elseif func_name == "build_level" then
				current_position = build_level(unpack(func_params))
			elseif func_name == "place_node" then
				current_position= place_node(unpack(func_params))
			elseif func_name == "move_to_script_start_position" then
				current_position= move_to_script_start_position(unpack(func_params))
			else
				print("Unknown function:", func_name)
			end			
			--if (func_name=="move_to_script_start_position") then			
			--	StartPosition = deepcopy(ScriptStartPosition)				
			--else
				StartPosition = current_position
			--end
			--minetest.log("x",func_name)
			--minetest.log("x","x:"..StartPosition.x.." y:"..StartPosition.y.." z:"..StartPosition.z)
		end
	end
end


--local StartPosition = {x = 0, y = -10, z = 0}
local X_size = 3
local Y_size = 8
local Z_size = 3
local FillAlongAxis = "Y"
local ReplaceWith = "default:stone"
local PlaceNode = "default:cobble"
local PlaceLocation = "B"
local PlacePosition = 4

-- Example script table
local script_table = {
    {"fill_box", 3, -10, 3, "Y", "air", "default:mese_post_light", "T", -5},
    {"move", "x", -1},
    {"fill_box", 6, 4, 3, "X", "air", nil, nil, nil},
	{"fill_box", 1, 4, 3, "X", "default:cobble", nil, nil, nil},
	{"fill_box", 10, 4, 3, "X", "air", "default:mese_post_light", "T", 5},
}

-- Example StartPosition
local StartPosition = {x = 0, y = 0, z = 0}

minetest.register_node("scripted_world_editor:script_runner", {
    description = "Script Runner",
    tiles = {"script_runner.png"},
    groups = {cracky = 3, oddly_breakable_by_hand = 1},
    on_punch = function(pos, node, puncher)
        -- fill_box(pos, X_size, Y_size, Z_size, FillAlongAxis, ReplaceWith, PlaceNode, PlaceLocation, PlacePosition)
		run_script(pos, script_table)
    end,
})





