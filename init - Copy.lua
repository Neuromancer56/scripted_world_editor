-- Function to dig a vertical shaft
local function dig_vertical_shaft(pos)
    local x = pos.x
    local y = pos.y
    local z = pos.z

    -- Define the dimensions of the shaft
    local shaft_width = math.random(1, 2) -- 1x3 or 2x3
    local shaft_depth = 30 -- 12 nodes deep

    -- Loop through each layer of the shaft and dig
    for i = 1, shaft_depth do
        -- Determine the current position based on the loop iteration
        local current_pos = {x = x, y = y - i, z = z}

		--[[
        -- Check if the current node is air
        local current_node = minetest.get_node(current_pos)
        if current_node.name == "air" then
            break  -- Stop digging if already reached air
        end
]]
        -- Dig the nodes based on the shaft width
        if shaft_width == 1 then
            for j = -1, 1 do
                for k = -1, 1 do
                    local current_pos_jk = {x = x + j, y = y - i, z = z + k}
                    minetest.set_node(current_pos_jk, {name = "air"})
                end
            end
        elseif shaft_width == 2 then
            for j = -2, 1 do
                for k = -1, 1 do
                    local current_pos_jk = {x = x + j, y = y - i, z = z + k}
                    minetest.set_node(current_pos_jk, {name = "air"})
                end
            end
        end
    end
	--[[
	local p = {x=pos.x, y=pos.y-10, z=pos.z}
	-- Start corridor system at p. Might fail if p is in open air
	minetest.log("verbose", "[tsm_railcorridors] Attempting to start rail corridor system at "..minetest.pos_to_string(p))
	if create_corridor_system(p, pr) then
		minetest.log("info", "[tsm_railcorridors] Generated rail corridor system at "..minetest.pos_to_string(p))
	else
		minetest.log("info", "[tsm_railcorridors] Rail corridor system generation attempt failed at "..minetest.pos_to_string(p))
	end]]
end

local startdig = {x = 5, y = 15, z = 5}
dig_vertical_shaft(startdig)

function dig_area(StartPosition, X_size, Y_size, Z_size, DigAlongAxis, ReplaceWith, PlaceNode, PlaceLocation)
    minetest.log("hello","start")
	local EndPosition = vector.new(StartPosition.x, StartPosition.y, StartPosition.z)
	
    -- Adjust the start and end positions based on the DigAlongAxis and sizes
    if DigAlongAxis == 'X' then
        EndPosition.x = EndPosition.x + X_size
    elseif DigAlongAxis == 'Y' then
        EndPosition.y = EndPosition.y + Y_size
    elseif DigAlongAxis == 'Z' then
        EndPosition.z = EndPosition.z + Z_size
    end
		DigEndPositionX= StartPosition.x + X_size
		DigEndPositionY= StartPosition.y + Y_size
		DigEndPositionZ= StartPosition.z + Z_size

	--[[
    -- Dig out the area and replace nodes
    for xc = StartPosition.x, EndPosition.x do
        for yc = StartPosition.y, EndPosition.y do
            for zc = StartPosition.z, EndPosition.z do
                --minetest.dig_node({x = x, y = y, z = z})
                --minetest.set_node({x = x, y = y, z = z}, {name = ReplaceWith})
				local current_pos_jk = {x = xc, y = yc, z = zc}
                minetest.set_node(current_pos_jk, {name = "air"})
				--minetest.set_node({x = x, y = y, z = z}, {name = "air"})
				minetest.log("x","x,y,z:"..xc..","..yc..","..zc)
				minetest.log("x","replacewith:"..ReplaceWith)
				
            end
        end
    end]]

	    minetest.log("x","StartPositionX:"..StartPosition.x)
		minetest.log("x","EndPositionX:"..EndPosition.x)
			    minetest.log("x","StartPositionY:"..StartPosition.y)
		minetest.log("x","EndPositionY:"..EndPosition.y)
		-- Dig out the area and replace nodes
    for x = StartPosition.x, DigEndPositionX do
        for y = StartPosition.y, DigEndPositionY do
            for z = StartPosition.z, DigEndPositionZ do
				local current_pos_jk = {x = x , y = y , z = z }
                minetest.set_node(current_pos_jk, {name = "default:cobble"})
			--minetest.dig_node({x = x, y = y, z = z})
                --minetest.set_node({x = x, y = y, z = z}, {name = ReplaceWith})
				minetest.log("x","x,y,z:"..x..","..y..","..z)
				minetest.log("x","replacewith:"..ReplaceWith)
				
            end
        end
    end
	
    -- Place the specified node at the specified location
    local place_position
    if PlaceLocation == 'T' then
        place_position = vector.new(StartPosition.x + math.floor(X_size / 2), EndPosition.y, StartPosition.z + math.floor(Z_size / 2))
    elseif PlaceLocation == 'B' then
        place_position = vector.new(StartPosition.x + math.floor(X_size / 2), StartPosition.y, StartPosition.z + math.floor(Z_size / 2))
    end

    minetest.set_node(place_position, {name = PlaceNode})
  minetest.log("hello","end")
    return EndPosition
end
local StartPosition = {x = 0, y = -10, z = 0}
local X_size = 1
local Y_size = 30
local Z_size = 2
local DigAlongAxis = "Y"
local ReplaceWith = "air"
local PlaceNode = "default:cobble"
local PlaceLocation = "T"

local EndPositionOut = dig_area(StartPosition, X_size, Y_size, Z_size, DigAlongAxis, ReplaceWith, PlaceNode, PlaceLocation)
minetest.log("x","finished")