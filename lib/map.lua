---@diagnostic disable: duplicate-set-field
---@diagnostic disable-next-line: different-requires
local Util = require("lib.util")

Map = {
    width = 0,
    height = 0,
    player_pos = {
        x = 0,
        y = 0
    },
    box_positions = {},
    goal_positions = {},
    correct_box_positions = {},
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
    self.goal_positions = {}
    self.box_positions = {}
    self.correct_box_positions = {}

    for y, row in ipairs(map_file.rows) do
        self.tiles[y] = {}
        for x, col in ipairs(row) do
            local t = strToTileId(col.type)
            local tile = Tile.new(x, y, t)
            if t == PlayerTile then
                self.player_pos = {
                    x = x,
                    y = y
                }
                t = EmptyTile
            elseif t == GoalTile then
                table.insert(self.goal_positions, {
                    x = x,
                    y = y
                })
                t = EmptyTile
            elseif t == BlockTile then
                table.insert(self.box_positions, {
                    x = x,
                    y = y
                })
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

function Map:draw(width, height)
    local ratio = width / height
    local tile_width = width / self.width
    local tile_height = height / self.height * ratio
    for y = 1, self.height do
        for x = 1, self.width do
            if x == self.player_pos.x and y == self.player_pos.y then
                love.graphics.setColor(0, 255, 0)
                love.graphics.rectangle("fill", x * tile_width, y * tile_height, tile_width, tile_height, rx, ry)
            else
                self.tiles[y][x]:draw(x, y, tile_width, tile_height)
            end
        end
    end

    for _, value in pairs(self.box_positions) do
        love.graphics.setColor(255, 0, 0)
        love.graphics.rectangle("fill", value.x * tile_width, value.y * tile_height, tile_width, tile_height, rx, ry)
    end

    for _, value in pairs(self.goal_positions) do
        love.graphics.setColor(0, 0, 255)
        love.graphics.rectangle("fill", value.x * tile_width, value.y * tile_height, tile_width, tile_height, rx, ry)
    end

    for _, value in pairs(self.correct_box_positions) do
        love.graphics.setColor(255, 0, 255)
        love.graphics.rectangle("fill", value.x * tile_width, value.y * tile_height, tile_width, tile_height, rx, ry)
    end
end

function Map:move_player(dx, dy)
    local new_x = self.player_pos.x + dx
    local new_y = self.player_pos.y + dy

    for _, value in pairs(self.box_positions) do
        if value.x == new_x and value.y == new_y then
            if self.tiles[new_y + dy][new_x + dx]:is_empty() then
                value.x = new_x + dx
                value.y = new_y + dy
                break
            else
                return
            end
        end
    end

    if self.tiles[new_y][new_x]:is_empty() then
        self.player_pos.x = new_x
        self.player_pos.y = new_y
        self:update_objects()
        return 1
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
    for bi, value in pairs(self.box_positions) do
        local gi, is_in = is_in_table(self.goal_positions, value)
        if is_in then
            table.insert(indexes, { bi, gi })
            table.insert(self.correct_box_positions, value)
        else
            value.type = BlockTile
        end
    end

    for _, value in ipairs(indexes) do
        table.remove(self.box_positions, value[1])
        table.remove(self.goal_positions, value[2])
    end

    if #self.goal_positions == 0 then
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
