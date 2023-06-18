local Map = require("map").Map

local window_width = 800
local window_height = 600

local time_spent = 0

function draw_timer()
    local minutes = math.floor(time_spent / 60)
    local seconds = math.floor(time_spent % 60)
    local milliseconds = math.floor((time_spent * 100) % 100)
    local time_string = string.format("%02d:%02d:%02d", minutes, seconds, milliseconds)
    love.graphics.setColor(255, 255, 255)
    love.graphics.print(time_string, 450, 50)
end

function love.load()
    math.randomseed(os.time())
    love.window.setMode(window_width, window_height, {resizable=false, vsync=false})
    love.window.setTitle("Sokoban Love")
    love.graphics.setNewFont(50)
    map = Map.new("assets/maps/test.map")
end

function love.draw()
    map:draw(window_width / 2, window_height / 2)
    draw_timer()
    if map.game_won then
        love.graphics.setColor(0, 255, 255)
        love.graphics.print("YOU WON!", 450, 100)
    end
end

function love.update(dt)
    if not map.game_won then
        time_spent = time_spent + dt
    end
end

function love.keypressed(k)
    if map.game_won then
        return
    end

    if k == "up" then
        map:move_player(0, -1)
    elseif k == "down" then
        map:move_player(0, 1)
    elseif k == "left" then
        map:move_player(-1, 0)
    elseif k == "right" then
        map:move_player(1, 0)
    end
end