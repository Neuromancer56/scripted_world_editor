

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
		FillEndPositionX= StartPosition.x + X_size -1 
		FillEndPositionY= StartPosition.y + Y_size -1
		FillEndPositionZ= StartPosition.z + Z_size -1
		
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
	
    -- Place the special single node at the specified location
    local place_position
    if PlaceLocation == 'T' then  --top of new box
        place_position = vector.new(StartPosition.x + math.floor(X_size / 2), EndPosition.y, StartPosition.z + math.floor(Z_size / 2))
    elseif PlaceLocation == 'B' then  --bottom of new box
        place_position = vector.new(StartPosition.x + math.floor(X_size / 2), StartPosition.y, StartPosition.z + math.floor(Z_size / 2))
    end

    minetest.set_node(place_position, {name = PlaceNode})
  minetest.log("log","end")
    return EndPosition
end

--local StartPosition = {x = 0, y = -10, z = 0}
local X_size = 2
local Y_size = -30
local Z_size = 2
local FillAlongAxis = "Y"
local ReplaceWith = "air"
local PlaceNode = "default:cobble"
local PlaceLocation = "T"

minetest.register_node("scripted_world_editor:script_runner", {
    description = "Script Runner",
    tiles = {"script_runner.png"},
    groups = {cracky = 3, oddly_breakable_by_hand = 1},
    on_punch = function(pos, node, puncher)
         fill_box(pos, X_size, Y_size, Z_size, FillAlongAxis, ReplaceWith, PlaceNode, PlaceLocation)
    end,
})



--local EndPositionOut = fill_box(StartPosition, X_size, Y_size, Z_size, FillAlongAxis, ReplaceWith, PlaceNode, PlaceLocation)
minetest.log("x","finished")