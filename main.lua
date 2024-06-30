require("player")
require("HUD")
require("level")
require("home")
local bump = require("bump/bump")
local world = bump.newWorld()

local splashes = {
  ["o-ten-one"]           = {module="o-ten-one"},
}
local splash
local splashEnded = false

local music = love.audio.newSource("sounds/Music.mp3", "stream")
local earthquakeSound = love.audio.newSource("sounds/Earthquake.wav", "static")
local clickSound = love.audio.newSource("sounds/Click.ogg", "static")
local deathSound = love.audio.newSource("sounds/Death.wav", "static")
music:setVolume(0.08)
earthquakeSound:setVolume(0.3)
clickSound:setVolume(0.15)
deathSound:setVolume(0.4)

local inHome = true
local player
local HUD
local level
local timePassed
local home = createHome()


function restartGame()
    world = bump.newWorld()
    controls.up = "w"
    controls.down = "s"
    controls.left = "a"
    controls.right = "d"
    cameraSpeed = 50
    cameraX = 0
    player = createPlayer(world)
    HUD = createHUD(player)
    level = createLevel(world)
    timePassed = 0
end


function love.keypressed(key, scancode, isrepeat)
    splash:skip()
    if scancode == "escape" then
        love.event.quit(0)
    end
    if scancode == "space" and inHome and splashEnded then
        inHome = false
        restartGame()
    end
    if not inHome then
        if scancode == controls.up then
            clickSound:play()
        end
        if scancode == controls.down then
            clickSound:play()
        end
        if scancode == controls.left then
            clickSound:play()
        end
        if scancode == controls.right then
            clickSound:play()
        end
    end
end



function love.load()
    love.mouse.setVisible(false)
    love.window.setFullscreen(true)

    for name, entry in pairs(splashes) do
        entry.module = require(entry.module)
        splashes[name] = function ()
            return entry.module(unpack(entry))
        end
    end
    splash = splashes["o-ten-one"]()
    splash.onDone = function() 
        splashEnded = true 
        love.graphics.setBackgroundColor(backgroundColor)
        love.graphics.setColor(lineColor)
        titleFont = love.graphics.newFont("fonts/SyneMono-Regular.ttf", 100)
        normalFont = love.graphics.newFont("fonts/SyneMono-Regular.ttf", 25)
    end
    
    normalizeWidthValue = love.graphics.getWidth() / 1536
    normalizeHeightValue = love.graphics.getHeight() / 864
    playerSize = playerSize * (normalizeHeightValue + normalizeWidthValue)/2
    bridgeStartingHeight = bridgeStartingHeight * normalizeHeightValue
    bigHoleStartSize = bigHoleStartSize * normalizeHeightValue * normalizeWidthValue
    boundsHeight = boundsHeight * normalizeHeightValue
    levelSegmentWidth = levelSegmentWidth * normalizeWidthValue
    boundsWidth = levelSegmentWidth
    buttonLength = buttonLength * (normalizeHeightValue + normalizeWidthValue)/2
    holesCollisionOffset =  holesCollisionOffset * (normalizeHeightValue + normalizeWidthValue)/2
    holesDisappearDistance = holesDisappearDistance * normalizeWidthValue
    playerSpeed = playerSpeed * (normalizeHeightValue + normalizeWidthValue)/2
end

function love.update(dt)
    if not splashEnded then
        splash:update(dt)
    else
        if inHome then
            updateHome(dt, home)
            return
        end
        if not music:isPlaying( ) then
            love.audio.play(music)
        end
        if player.isDead then
            inHome = true
            if player.score > home.bestScore then
                home.bestScore = player.score
            end
            deathSound:play()
            music:stop()
        end
        if isEarthquake then
            earthquakeDuration = earthquakeDuration - dt
            if earthquakeDuration <= 0 then
                isEarthquake = false
                earthquakeDuration = 3
            end
            return
        elseif timePassed > earthquakeTimer then
            isEarthquake = earthquake(player)
            timePassed = 0
            earthquakeTimer = earthquakeTimer - love.math.random()
            if not earthquakeSound:isPlaying( ) then
                love.audio.play(earthquakeSound)
            end
        else
            timePassed = timePassed + dt
        end

        if cameraSpeed < player.speed * 0.93 then
            cameraSpeed = cameraSpeed + (dt * cameraAcceleration)
        end
        player.score = player.score + (dt * cameraSpeed / 10)
        cameraX = cameraX + (dt * cameraSpeed)
        updatePlayer(dt, player, world)
        updateLevel(dt, level, world)
        updateHUD(dt, HUD, isEarthquake)
    end
end

function love.draw()
    if not splashEnded then
        splash:draw()
    else
        if inHome then
            drawHome(home)
            return
        end

        if isEarthquake then
            love.graphics.translate(love.math.random(10), 0)
        end
        --move the camera
        love.graphics.translate(-cameraX, 0)

        drawLevel(level)
        drawPlayer(player)

        --reset the movement of the camera
        love.graphics.origin()

        drawHUD(HUD)
    end
end
