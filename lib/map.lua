---@diagnostic disable: duplicate-set-field
---@diagnostic disable-next-line: different-requires
local Util = require("lib.util")
local Movable = require("lib.movable")

Map = {
    width = 0,
    height = 0,
    tile_width = 0,
    tile_height = 0,
    player = Movable.new(0, 0),
    boxes = {},
    goals = {},
    correct_boxes = {},
    tiles = {},
    game_won = false
}

Tile = {
    x = 0,
    y = 0,
    type = 0
}

EmptyTile = 1
WallTile = 2
BlockTile = 3
PlayerTile = 4
GoalTile = 5

local function strToTileId(s)
    if s == "empty" then
        return EmptyTile
    elseif s == "wall" then
        return WallTile
    elseif s == "block" then
        return BlockTile
    elseif s == "player" then
        return PlayerTile
    elseif s == "goal" then
        return GoalTile
    else
        return -1
    end
end

local rx = 10
local ry = 10

function Tile.new(x, y, type)
    local self = setmetatable({}, {
        __index = Tile
    })
    self.x = x
    self.y = y
    self.type = type
    return self
end

function Tile:width()
    return self.width
end

function Tile:height()
    return self.height
end

function Tile:is_empty()
    return self.type == EmptyTile
end

function Tile:is_wall()
    return self.type == WallTile
end

function Tile:is_block()
    return self.type == BlockTile
end

function Tile:draw(x, y, width, height)
    if self:is_empty() then
        love.graphics.setColor(0, 0, 0)
    elseif self:is_wall() then
        love.graphics.setColor(255, 255, 255)
    end
    love.graphics.rectangle("fill", x * width, y * height, width, height)
end

function Map.new(filename)
    local self = setmetatable({}, {
        __index = Map
    })

    local m, err = love.filesystem.load(filename)
    local map_file = m()
    local name = map_file.name
    self.width = map_file.width
    self.height = map_file.height
    self.goals = {}
    self.boxes = {}
    self.correct_boxes = {}

    for y, row in ipairs(map_file.rows) do
        self.tiles[y] = {}
        for x, col in ipairs(row) do
            local t = strToTileId(col.type)
            local tile = Tile.new(x, y, t)
            if t == PlayerTile then
                self.player = Movable.new(x, y)
                t = EmptyTile
            elseif t == GoalTile then
                table.insert(self.goals, {
                    x = x,
                    y = y
                })
                t = EmptyTile
            elseif t == BlockTile then
                table.insert(self.boxes, Movable.new(x, y))
                t = EmptyTile
            end
            self.tiles[y][x] = Tile.new(x, y, t)
        end
    end

    return self
end

function Map:width()
    return self.width
end

function Map:height()
    return self.height
end

function Map:update(dt)
    local should_update = false

    should_update = self.player:update(dt)
    for i, box in ipairs(self.boxes) do
        should_update = should_update or box:update(dt)
    end

    if should_update then
        self:update_objects()
    end
end

function Map:draw(width, height)
    local ratio = width / height
    local tile_width = width / self.width
    local tile_height = height / self.height * ratio

    if self.tile_width ~= tile_width then
        self.tile_width = tile_width
    end
    if self.tile_height ~= tile_height then
        self.tile_height = tile_height
    end

    for y = 1, self.height do
        for x = 1, self.width do
            self.tiles[y][x]:draw(x, y, tile_width, tile_height)
        end
    end

    local player_pos = self.player:get_pos()

    love.graphics.setColor(0, 255, 0)
    love.graphics.rectangle("fill", player_pos.x * tile_width, player_pos.y * tile_height, tile_width, tile_height, rx,
        ry)

    for _, value in pairs(self.boxes) do
        local pos = value:get_pos()
        love.graphics.setColor(255, 0, 0)
        love.graphics.rectangle("fill", pos.x * tile_width, pos.y * tile_height, tile_width, tile_height, rx, ry)
    end

    for _, value in pairs(self.goals) do
        love.graphics.setColor(0, 0, 255)
        love.graphics.rectangle("fill", value.x * tile_width, value.y * tile_height, tile_width, tile_height, rx, ry)
    end

    for _, value in pairs(self.correct_boxes) do
        love.graphics.setColor(255, 0, 255)
        love.graphics.rectangle("fill", value.x * tile_width, value.y * tile_height, tile_width, tile_height, rx, ry)
    end
end

function Map:move_player(dx, dy)
    if not self.player:is_moving() then
        local new_x = self.player.pos.x + dx
        local new_y = self.player.pos.y + dy

        for _, value in pairs(self.boxes) do
            if value.pos.x == new_x and value.pos.y == new_y then
                if self.tiles[new_y + dy][new_x + dx]:is_empty() then
                    value.tween = Tween.new(value.pos, Vector.new(value.pos.x + dx, value.pos.y + dy), 0.75)
                    break
                else
                    return
                end
            end
        end

        if self.tiles[new_y][new_x]:is_empty() then
            self.player:move(dx, dy)
            self:update_objects()
            return 1
        end
    end
    return 0
end

local function is_in_table(table, pos)
    for i, value in pairs(table) do
        if value.x == pos.x and value.y == pos.y then
            return i, true
        end
    end
    return -1, false
end

function Map:update_objects()
    local indexes = {}
    for bi, value in pairs(self.boxes) do
        local gi, is_in = is_in_table(self.goals, value)
        if is_in then
            table.insert(indexes, { bi, gi })
            table.insert(self.correct_boxes, value)
        else
            value.type = BlockTile
        end
    end

    for _, value in ipairs(indexes) do
        table.remove(self.boxes, value[1])
        table.remove(self.goals, value[2])
    end

    if #self.goals == 0 then
        self.game_won = true
    end
end

return {
    Map = Map,
    Tile = Tile,
    EmptyTile = EmptyTile,
    WallTile = WallTile,
    BlockTile = BlockTile
}
