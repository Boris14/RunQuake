

function createHome()
	home = {}
	home.timePassed = 0
	home.bestScore = 0
	home.color = colors[love.math.random(4)]

	return home
end

function updateHome(dt, home)
	home.timePassed = home.timePassed + dt
	if home.timePassed >= 0.1 then
		home.timePassed = 0
		home.color = colors[love.math.random(4)]
	end
end

function drawHome(home)
	love.graphics.setFont(titleFont)
	love.graphics.printf("Run Quake", 0, love.graphics.getHeight()/2 - love.graphics.getFont():getHeight()/2, love.graphics.getWidth(), "center")
	love.graphics.setFont(normalFont)
	love.graphics.printf("Press Space to Play", 0, love.graphics.getHeight()/1.5, love.graphics.getWidth(), "center")
	if home.bestScore > 0 then
		love.graphics.setColor(home.color)
		love.graphics.printf("Highscore: " .. math.floor(home.bestScore), 0, love.graphics.getHeight()/1.3, love.graphics.getWidth(), "center")
		love.graphics.setColor(lineColor)
	end
end