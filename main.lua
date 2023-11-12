local Map = require("./lib/map").Map

local window_width = 800
local window_height = 600

local time_spent = 0
local moves = 0

local level = "assets/maps/test.map"

function draw_timer()
    local minutes = math.floor(time_spent / 60)
    local seconds = math.floor(time_spent % 60)
    local milliseconds = math.floor((time_spent * 100) % 100)
    local time_string = string.format("%02d:%02d:%02d", minutes, seconds, milliseconds)
    love.graphics.setColor(255, 255, 255)
    love.graphics.print(time_string, 450, 50)
end

function draw_moves()
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("Moves: " .. moves, 450, 100)
end

function draw_win()
    love.graphics.setColor(0, 255, 255)
    love.graphics.print("YOU WON!", 450, 150)
    love.graphics.print("R to restart", 450, 200)
end

function reset_level()
    map = Map.new(level)
    time_spent = 0.0
    moves = 0
end

function love.load()
    math.randomseed(os.time())
    love.window.setMode(window_width, window_height, {
        resizable = false,
        vsync = false
    })
    love.window.setTitle("Portal Push")
    love.graphics.setNewFont(50)
    map = Map.new(level)
end

function love.draw()
    map:draw(window_width / 2, window_height / 2)
    draw_timer()
    draw_moves()
    if map.game_won then
        draw_win()
    end
end

function love.update(dt)
    if not map.game_won then
        time_spent = time_spent + dt
    end
end

function love.keypressed(k)
    if map.game_won then
        if k == "r" then
            reset_level()
        elseif k == "q" then
            love.event.quit()
        end
        return
    end

    if k == "up" then
        moves = moves + map:move_player(0, -1)
    elseif k == "down" then
        moves = moves + map:move_player(0, 1)
    elseif k == "left" then
        moves = moves + map:move_player(-1, 0)
    elseif k == "right" then
        moves = moves + map:move_player(1, 0)
    end
end
