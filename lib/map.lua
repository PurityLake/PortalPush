local Movable = require("lib.movable")
local Util = require("lib.util")

---@class map
---@field width number width of map in pixels
---@field height number height of map in pixels
---@field tile_width number width of tiles in pixels
---@field tile_height number height of tiles in pixels
---@field player table Movable representing the player
---@field boxes table movable[] boxes that are not in the correct position
---@field goals table vector[] positions of the goals
---@field correct_boxes table vector[] positions of the boxes that are in the correct position
---@field tiles table tile[][] tiles of the map
---@field game_won boolean if the game has been won
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
  game_won = false,
}

---@class Tile
---@field x number
---@field y number
---@field type number
Tile = {
  x = 0,
  y = 0,
  type = 0,
}

EmptyTile = 1
WallTile = 2
BlockTile = 3
PlayerTile = 4
GoalTile = 5

local function str_to_tile_id(s)
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

---Create Tile update_object
---@param x number
---@param y  number
---@param type number
---@return table Tile
function Tile.new(x, y, type)
  local self = setmetatable({}, {
    __index = Tile,
  })
  self.x = x
  self.y = y
  self.type = type
  return self
end

---Check if Tile is empty
---@return boolean
function Tile:is_empty()
  return self.type == EmptyTile
end

--- Check if Tile is wall
---@return boolean
function Tile:is_wall()
  return self.type == WallTile
end

---Check if Tile is block
---@return boolean
function Tile:is_block()
  return self.type == BlockTile
end

---Draw Tile to screen
---@param x number
---@param y number
---@param width number
---@param height number
function Tile:draw(x, y, width, height)
  if self:is_empty() then
    love.graphics.setColor(0, 0, 0)
  elseif self:is_wall() then
    love.graphics.setColor(255, 255, 255)
  end
  love.graphics.rectangle("fill", x * width, y * height, width, height)
end

---Create Map object
---@param filename string
---@return table
function Map.new(filename)
  local self = setmetatable({}, {
    __index = Map,
  })

  -- TODO: add error handling
  -- local m, err = love.filesystem.load(filename)
  local m, _ = love.filesystem.load(filename)
  local map_file = m()
  -- TODO: maybe use the name of the map somewhere
  -- local name = map_file.name
  self.width = map_file.width
  self.height = map_file.height
  self.goals = {}
  self.boxes = {}
  self.correct_boxes = {}

  for y, row in ipairs(map_file.rows) do
    self.tiles[y] = {}
    for x, col in ipairs(row) do
      local t = str_to_tile_id(col.type)
      if t == PlayerTile then
        self.player = Movable.new(x, y)
        t = EmptyTile
      elseif t == GoalTile then
        table.insert(self.goals, {
          x = x,
          y = y,
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

---Get Map width
---@return integer
function Map:getWidth()
  return self.width
end

---Get Map height
---@return integer
function Map:getHeight()
  return self.height
end

---Logic that updates the state of the map every tick
---@param dt number floating point delta time
function Map:update(dt)
  local should_update = self.player:update(dt)
  for _, box in ipairs(self.boxes) do
    if should_update then
      box:update(dt)
    else
      should_update = box:update(dt)
    end
  end

  if should_update then
    self:update_objects()
  end
end

---Draw Map to screen. Does not have to be same size as window
---so that the map can be scaled up or down
---@param width number
---@param height number
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
  love.graphics.rectangle(
    "fill",
    player_pos.x * tile_width,
    player_pos.y * tile_height,
    tile_width,
    tile_height,
    rx,
    ry
  )

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

---Move player in a direction
---@param dx number the change in x
---@param dy number the change in y
---@return number 1 if player moved, 0 if not
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
          return 0
        end
      end
    end

    if self.tiles[new_y][new_x]:is_empty() then
      self.player:move(dx, dy)
      return 1
    end
  end
  return 0
end

---Changes tile types and remove boxes that are placed correctly so
---that they are not drawn anymore and check if the game is won
function Map:update_objects()
  local indexes = {}
  for bi, value in pairs(self.boxes) do
    local gi, is_in = Util.is_in_table(self.goals, value.pos)
    if is_in then
      table.insert(indexes, { bi, gi })
      table.insert(self.correct_boxes, value.pos)
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
  BlockTile = BlockTile,
}
