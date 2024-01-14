local M = {}

---Split a string into a table by delimiter
---@param str string
---@param sep string seprator to split string by
---@return table
function M.str_split(str, sep)
  local result = {}
  for match in (str .. sep):gmatch("(.-)" .. sep) do
    table.insert(result, match)
  end
  return result
end

---Check if a table contains a value
---@param table table
---@param pos table vector to check for
---@return unknown
---@return boolean
function M.is_in_table(table, pos)
  for i, value in pairs(table) do
    if value.x == pos.x and value.y == pos.y then
      return i, true
    end
  end
  return -1, false
end

return M
