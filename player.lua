
function createPlayer(world)
	player = {}

	player.angle = 0
	player.x = love.graphics.getWidth()/2
	player.y = love.graphics.getHeight()/2

	player.dx = 0
	player.dy = 0

	player.color = PLAYER_COLORS[love.math.random(table.getn(colors))]
	player.score = 0
	player.isDead = false

	world:add(player, player.x, player.y, PLAYER_SIZE, PLAYER_SIZE)
end



function updatePlayer(dt, player, world)
	if player.isDead then
		return
	end

	if love.keyboard.isDown(controls.left) then
		player.dx = -player.speed
	end
	if love.keyboard.isDown(controls.right) then
		player.dx = player.speed
	end
	if love.keyboard.isDown(controls.down) then
	    player.dy = player.speed
	end
	if love.keyboard.isDown(controls.up) then
	    player.dy = -player.speed
	end

	if(math.abs(player.dx) == player.speed and math.abs(player.dy) == player.speed) then
		player.dx = player.dx * 0.7
		player.dy = player.dy * 0.7
	end

	if love.keyboard.isDown(controls.right)  and love.keyboard.isDown(controls.left) then
		player.dx = 0
	end

	if love.keyboard.isDown(controls.up)  and love.keyboard.isDown(controls.down) then
		player.dy = 0
	end

	if not love.keyboard.isDown(controls.left) and not love.keyboard.isDown(controls.right) then
		if player.dx > player.speed * 0.05 then
			player.dx = player.dx - (player.speed * 0.04) 
		elseif player.dx < -player.speed * 0.05 then
			player.dx = player.dx + (player.speed * 0.04) 
		else
			player.dx = 0
		end 
	end

	if not love.keyboard.isDown(controls.up) and not love.keyboard.isDown(controls.down) then
		if player.dy > player.speed * 0.05 then
			player.dy = player.dy - (player.speed * 0.04) 
		elseif player.dy < -player.speed * 0.05 then
			player.dy = player.dy + (player.speed * 0.04) 
		else
			player.dy = 0
		end 
	end


	local goalX, goalY = player.x + player.dx * dt, player.y + player.dy * dt
  	local actualX, actualY, cols, len = world:move(player, goalX, goalY)
  	player.x, player.y = actualX, actualY
  	-- deal with the collisions
  	for i=1,len do
  	  player.isDead = true
  	  world:remove(player)
 	end

	if player.dx ~= 0 or player.dy ~= 0 then 
		player.angle = math.atan2(player.dy, player.dx) + math.pi/2
	end

end


function drawPlayer(player)
	if player.isDead then
		return
	end
	love.graphics.push()
	love.graphics.translate(player.x, player.y)
	love.graphics.rotate(player.angle)
	love.graphics.translate(-player.x, -player.y)

	love.graphics.setColor(player.color)
	--draw all the points of the players polygon
	love.graphics.polygon("fill", player.x - playerSize, player.y,
									player.x, player.y - playerSize,
									player.x + playerSize, player.y,
									player.x + playerSize, player.y + playerSize,
									player.x - playerSize, player.y + playerSize)
	love.graphics.setColor(lineColor)

	--reset the draw translation
	love.graphics.pop()
end