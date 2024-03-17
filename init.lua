
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


function fill_box(StartPosition, X_size, Y_size, Z_size, FillAlongAxis, ReplaceWith, PlaceNode, PlaceLocation, PlacePosition)
    minetest.log("log","start")
	local EndPosition = vector.new(StartPosition.x, StartPosition.y, StartPosition.z)
	
    -- Adjust the start and end positions based on the FillAlongAxis and sizes
    if FillAlongAxis == 'X' then
        EndPosition.x = EndPosition.x + X_size
    elseif FillAlongAxis == 'Y' then
        EndPosition.y = EndPosition.y + Y_size
    elseif FillAlongAxis == 'Z' then
        EndPosition.z = EndPosition.z + Z_size
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
	    minetest.log("x","StartPositionX:"..StartPosition.x)
		minetest.log("x","FillEndPositionX:"..FillEndPositionX)
		minetest.log("x","StartPositionY:"..StartPosition.y)
		minetest.log("x","FillEndPositionY:"..FillEndPositionY)
		minetest.log("x","StartPositionZ:"..StartPosition.z)
		minetest.log("x","FillEndPositionZ:"..FillEndPositionZ)

		-- Determine the start and end points for each axis (always looping from the lower number to the larger number)
		local startX, endX = math.min(StartPosition.x, FillEndPositionX), math.max(StartPosition.x, FillEndPositionX)
		local startY, endY = math.min(StartPosition.y, FillEndPositionY), math.max(StartPosition.y, FillEndPositionY)
		local startZ, endZ = math.min(StartPosition.z, FillEndPositionZ), math.max(StartPosition.z, FillEndPositionZ)

		-- Iterate over the specified range for each axis
		for x = startX, endX do
			for y = startY, endY do
				for z = startZ, endZ do
					minetest.set_node({x = x, y = y, z = z}, {name = ReplaceWith})
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
		minetest.log("x","x,y,z:"..place_position.x..","..place_position.y..","..place_position.z)
		minetest.log("log", "PlaceNode: "..PlaceNode)
		local param2dir = 1
		if (PlacePosition < 0) then param2dir = 3 end
		minetest.log("x","param2dir: "..param2dir)
		minetest.set_node(place_position, {name = PlaceNode, param2 = param2dir })
	end
  minetest.log("log","end")
    return EndPosition
end

function run_script(StartPosition, script_table)
    --sequentially runs all commands in the table along with their corresponding parameters.
	--called functions return an EndPosition value which should be passed in to the next row/function in the table until all the functions have been executed.
	local current_position = StartPosition

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
        else
            print("Unknown function:", func_name)
        end

        StartPosition = current_position
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



