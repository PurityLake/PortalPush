local Util = require("util")

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

    local file = assert(io.open(filename, "r"))
    local magic = file:read("*line")

    assert(magic == "SOKOBAN", "Invalid map file")

    local dims = Util.str_split(file:read("*line"), ",")
    assert(#dims == 2, "Invalid map file dimensions, expected w,h")

    local width = dims[1]
    local height = dims[2]

    self.width = tonumber(width)
    self.height = tonumber(height)

    local y = 1
    self.box_positions = {}
    self.goal_positions = {}
    self.tiles = {}
    for line in file:lines() do
        self.tiles[y] = {}
        for x = 1, #line do
            local tile = Tile.new(x, y, tonumber(line:sub(x, x)))
            if tile.type == PlayerTile then
                self.player_pos = {
                    x = x,
                    y = y
                }
                tile.type = EmptyTile
            elseif tile.type == GoalTile then
                table.insert(self.goal_positions, {
                    x = x,
                    y = y
                })
                tile.type = EmptyTile
            elseif tile.type == BlockTile then
                table.insert(self.box_positions, {
                    x = x,
                    y = y
                })
                tile.type = EmptyTile
            end
            self.tiles[y][x] = tile
        end
        y = y + 1
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
                love.graphics.rectangle("fill", x * tile_width, y * tile_height, tile_width, tile_height)
            else
                self.tiles[y][x]:draw(x, y, tile_width, tile_height)
            end
        end
    end

    for _, value in pairs(self.box_positions) do
        love.graphics.setColor(255, 0, 0)
        love.graphics.rectangle("fill", value.x * tile_width, value.y * tile_height, tile_width, tile_height)
    end

    for _, value in pairs(self.goal_positions) do
        love.graphics.setColor(0, 0, 255)
        love.graphics.rectangle("fill", value.x * tile_width, value.y * tile_height, tile_width, tile_height)
    end

    for _, value in pairs(self.correct_box_positions) do
        love.graphics.setColor(255, 0, 255)
        love.graphics.rectangle("fill", value.x * tile_width, value.y * tile_height, tile_width, tile_height)
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
    end
end

function is_in_table(table, pos)
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
            table.insert(indexes, {bi, gi})
            table.insert(self.correct_box_positions, value)
        else
            value.type = BlockTile
        end
    end

    for _, value in pairs(indexes) do
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
