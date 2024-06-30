require("player")


function createHUD(player)
	HUD = {}
	HUD.player = player
	HUD.pressedColor = {}
	for i = 1, 3 do
		HUD.pressedColor[i] = player.color[i] - 0.18
	end 
	HUD.leftPressed = false
	HUD.rightPressed = false
	HUD.downPressed = false
	HUD.upPressed = false

	HUD.isEarthquake = false

	return HUD
end

function updateHUD(dt, HUD, isEarthquake)
	HUD.isEarthquake = isEarthquake
	HUD.leftPressed = false
	HUD.rightPressed = false
	HUD.downPressed = false
	HUD.upPressed = false
	if love.keyboard.isDown(controls.left) then
		HUD.leftPressed = true
	end
	if love.keyboard.isDown(controls.right) then
		HUD.rightPressed = true
	end
	if love.keyboard.isDown(controls.up) then
	    HUD.upPressed = true
	end
	if love.keyboard.isDown(controls.down) then
	    HUD.downPressed = true
	end
end

function drawHUD(HUD)
	love.graphics.push()

	height = love.graphics.getHeight()

	originX = buttonLength * 2
	originY = height - buttonLength * 2.5

	love.graphics.setColor(HUD.player.color)
	love.graphics.print("Score: " .. math.floor(HUD.player.score), originX * 0.5, buttonLength * 1.3, 0, 2, 2)
	love.graphics.setColor(lineColor)

	if HUD.isEarthquake then
		love.graphics.setFont(titleFont)
		love.graphics.printf("EARTHQUAKE!", 0, love.graphics.getHeight()/2 - love.graphics.getFont():getHeight()/2, love.graphics.getWidth(), "center")
		love.graphics.setFont(normalFont)
		love.graphics.setColor(HUD.player.color)
		love.graphics.printf("Controls have changed", 0, love.graphics.getHeight()/1.5, love.graphics.getWidth(), "center")
	end

	love.graphics.setLineWidth( 3 )
	if HUD.upPressed then 
		love.graphics.setColor(HUD.pressedColor)
	else
		love.graphics.setColor(HUD.player.color)
	end
	love.graphics.rectangle("fill", originX, originY, buttonLength, buttonLength)
	love.graphics.setColor(lineColor)
	love.graphics.rectangle("line", originX, originY, buttonLength, buttonLength)
	love.graphics.printf(string.upper(controls.up), originX, originY + buttonLength * 0.3, buttonLength, "center")
	love.graphics.translate(0, buttonLength)
	if HUD.downPressed then 
		love.graphics.setColor(HUD.pressedColor)
	else
		love.graphics.setColor(HUD.player.color)
	end
	love.graphics.rectangle("fill", originX, originY, buttonLength, buttonLength)
	love.graphics.setColor(lineColor)
	love.graphics.rectangle("line", originX, originY, buttonLength, buttonLength)
	love.graphics.printf(string.upper(controls.down), originX, originY + buttonLength * 0.3, buttonLength, "center")
	love.graphics.translate(-buttonLength, 0)
	if HUD.leftPressed then 
		love.graphics.setColor(HUD.pressedColor)
	else
		love.graphics.setColor(HUD.player.color)
	end
	love.graphics.rectangle("fill", originX, originY, buttonLength, buttonLength)
	love.graphics.setColor(lineColor)
	love.graphics.rectangle("line", originX, originY, buttonLength, buttonLength)
	love.graphics.printf(string.upper(controls.left), originX, originY + buttonLength * 0.3, buttonLength, "center")
	love.graphics.translate(2 * buttonLength, 0)
	if HUD.rightPressed then 
		love.graphics.setColor(HUD.pressedColor)
	else
		love.graphics.setColor(HUD.player.color)
	end
	love.graphics.rectangle("fill", originX, originY, buttonLength, buttonLength)
	love.graphics.setColor(lineColor)
	love.graphics.rectangle("line", originX, originY, buttonLength, buttonLength)
	love.graphics.printf(string.upper(controls.right), originX, originY + buttonLength * 0.3, buttonLength, "center")

	love.graphics.pop()
end


