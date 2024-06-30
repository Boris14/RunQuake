local holeImage = love.graphics.newImage("assets/Hole.png")
local boundsImage = love.graphics.newImage("assets/Bounds.png")
local bridgeBoundsImage = love.graphics.newImage("assets/BridgeBounds.png")

local wallFilter = function(item, other)
  return 'cross'
end

local function contains(table, val)
   for i=1,#table do
      if table[i] == val then 
         return true
      end
   end
   return false
end

function createLevel(world)
	level = {}
	level.deathWall = createDeathWall(world)
	level.holes = {}
	level.bounds = {}
	createHorizontalBounds(world, level.bounds, 0, false)
	initSegments(level, world)
	return level
end

function updateLevel(dt, level, world)
	updateHoles(dt, world, level.holes)
	updateWall(dt, world, level.deathWall)
end

function drawLevel(level)
	drawHoles(level.holes)
	drawAllBounds(level)
	drawWall(level.deathWall)
end


function createDeathWall(world)
	wall = {}
	wall.x = cameraX
	wall.height = love.graphics.getHeight() * 1.6
	wall.trianglesCount = deathWallTriangles
	wall.triangleSize = wall.height / wall.trianglesCount
	wall.triangles = {}

	for i = 1, wall.trianglesCount do
		wall.triangles[i] = {}
		wall.triangles[i].x = wall.triangleSize
		wall.triangles[i].y = (i-2) * wall.triangleSize
	end

	--add it to the world
	world:add(wall, wall.x, 0, wall.triangleSize, wall.height)

	wall.maxOffset = 8
	wall.offset = 0
	wall.shakeUp = true

	return wall
end

--do the bounds
function createHorizontalBounds(world, bounds, x, isBridge)
	local height = love.graphics.getHeight()

	local topBound = {}
	topBound.x = x
	topBound.isTop = true
	topBound.isBridge = isBridge

	local bottomBound = {}
	bottomBound.x = x
	bottomBound.isTop = false
	bottomBound.isBridge = isBridge

	world:add(topBound, x, 0, boundsWidth, boundsHeight - holesCollisionOffset)
	world:add(bottomBound, x, height - boundsHeight + holesCollisionOffset, boundsWidth, boundsHeight - holesCollisionOffset)

	table.insert(bounds, 1, topBound)
	table.insert(bounds, 1, bottomBound)
end

function drawBound(bound)
	local image 
	if bound.isBridge then
		image = bridgeBoundsImage
	else
		image = boundsImage
	end

	local height = love.graphics.getHeight()

	love.graphics.setColor(255, 255, 255)
	if bound.isTop then
		love.graphics.draw(image, bound.x + boundsWidth, boundsHeight, math.pi, boundsWidth/image:getWidth(), boundsHeight/image:getHeight())
	else
		love.graphics.draw(image, bound.x, height - boundsHeight, 0, boundsWidth/image:getWidth(), boundsHeight/image:getHeight())
	end

	love.graphics.setColor(lineColor)
end

function drawAllBounds(level)
	for i = 1, #level.bounds do
		drawBound(level.bounds[i])
	end
end


function updateWall(dt, world, wall)
	local actualX, actualY, cols, len = world:move(wall, cameraX, 0, wallFilter)
	wall.x = actualX
	for i=1,len do
		cols[i].other.isDead = true
	end

	if wall.shakeUp  then
		wall.offset = wall.offset - dt * 100
		if wall.offset < -wall.maxOffset then
			wall.shakeUp = false
		end
	else
		wall.offset = wall.offset + dt * 100
		if wall.offset > wall.maxOffset then
			wall.shakeUp = true
		end
	end
end


function drawWall(wall)
	love.graphics.push()
	love.graphics.setColor(0.15,0.15,0.15)
	love.graphics.translate(0, wall.offset)
	love.graphics.rectangle("fill", wall.x - 30, 0, 30, wall.height)
	for i, v in ipairs(wall.triangles) do
		love.graphics.polygon("fill", wall.x, v.y,
										wall.x + v.x, v.y + wall.triangleSize / 2,
										wall.x, v.y + wall.triangleSize)
	end
	love.graphics.pop()
end

function createHole(world, x, y, width, height)
	hole = {}
	hole.x = x
	hole.y = y
	hole.width = width
	hole.height = height

	world:add(hole, hole.x + holesCollisionOffset, hole.y + holesCollisionOffset, hole.width - 2 * holesCollisionOffset, hole.height - 2 * holesCollisionOffset)
	return hole
end

function updateHoles(dt, world, holes)
	for i, v in ipairs(holes) do
		if v.x < cameraX - holesDisappearDistance then
			table.remove(holes, i)
			world:remove(v)
		end
	end
end


function drawHoles(holes)
	for i, v in ipairs(holes) do 
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(holeImage, v.x, v.y, 0, v.width/holeImage:getWidth(), v.height/holeImage:getHeight())
		love.graphics.setColor(lineColor)
	end
end

function earthquake(player)
	earthquakes = earthquakes + 1
	local magnitude = 1
	local newControls = {controls.up, controls.down, controls.left, controls.right}
	if earthquakes > 4 then
		magnitude = magnitude + 1
	end
	if earthquakes > 8 then
		magnitude = magnitude + 1
	end
	player.score = player.score + (100 * magnitude)
	local changedPositions = {0, 0, 0, 0}
	for i=1, magnitude do
		rNum = love.math.random(4)
		while changedPositions[rNum] == 1 do
			rNum = love.math.random(4)
		end
		changeControl(newControls, rNum)
		changedPositions[rNum] = 1
	end

	controls.up = newControls[1]
	controls.down = newControls[2]
	controls.left = newControls[3]
	controls.right = newControls[4]

    return true
end

function changeControl(inControls, position)
	rNum = love.math.random(string.len(keyboardKeys))
	newKey = string.sub(keyboardKeys, rNum, rNum)
	while contains(inControls, newKey) do
		rNum = love.math.random(string.len(keyboardKeys))
		newKey = string.sub(keyboardKeys, rNum, rNum)
	end
	inControls[position] = newKey
end

function initSegments(level, world)
	for i=1, levelSegmentCount do
		createSegment(love.math.random(2) == 2, i, level, world)
	end
end

function createSegment(isBridge, index, level, world)
	local height = love.graphics.getHeight()
	if isBridge and index > 4 then
		local bridgeHeight =  bridgeStartingHeight * (1 - index/500)
		local bridgeY = love.math.random() * (height - bridgeHeight) + boundsHeight
		table.insert(level.holes, 1, createHole(world, index * levelSegmentWidth, 0, levelSegmentWidth, bridgeY))
		table.insert(level.holes, 1, createHole(world, index * levelSegmentWidth, bridgeY + bridgeHeight, levelSegmentWidth, bridgeY + bridgeHeight))
	elseif index > 4 then
		local size = bigHoleStartSize * (1 + (index * 0.03))
		local holeWidth = love.math.random(math.floor(math.sqrt(size) * 0.7), math.floor(math.sqrt(size) * 1.3))
		local holeHeight = size / holeWidth
		table.insert(level.holes, 1, createHole(world, index * levelSegmentWidth + (love.math.random() * (levelSegmentWidth - holeWidth)), love.math.random() * (height - boundsHeight) + boundsHeight, holeWidth, holeHeight))
	else
		isBridge = false
	end

	createHorizontalBounds(world, level.bounds, index * levelSegmentWidth, isBridge)
end