-- Utility functions for eyeliner.nvim
-- Provides vim API wrappers and functional programming helpers

local M = {}

--- Create an autocmd in the Eyeliner augroup
---@param event string|string[] Event(s) to trigger on
---@param opts table Autocmd options
---@return number Autocmd ID
function M.set_autocmd(event, opts)
  local merged = vim.tbl_deep_extend("force", { group = "Eyeliner" }, opts)
  return vim.api.nvim_create_autocmd(event, merged)
end

M.del_augroup = vim.api.nvim_del_augroup_by_name
M.create_augroup = vim.api.nvim_create_augroup
M.get_current_line = vim.api.nvim_get_current_line

--- Get cursor position as [row, col]
---@return number[] [row, col] (1-indexed row, 0-indexed col)
function M.get_cursor()
  return vim.api.nvim_win_get_cursor(0)
end

--- Get highlight group properties
---@param name string Highlight group name
---@return table Highlight properties
function M.get_hl(name)
  return vim.api.nvim_get_hl_by_name(name, true)
end

--- Set a highlight group with foreground color
---@param name string Highlight group name
---@param color number|string Color value
function M.set_hl(name, color)
  vim.api.nvim_set_hl(0, name, { fg = color, default = true })
end

--- Add highlight at cursor row
---@param ns_id number Namespace ID
---@param hl_group string Highlight group name
---@param x number Column position
function M.add_hl(ns_id, hl_group, x)
  local cursor = M.get_cursor()
  local y = cursor[1]
  vim.api.nvim_buf_add_highlight(0, ns_id, hl_group, y - 1, x, x + 1)
end

--- Map a function over a list
---@param fn function Function to apply
---@param list table List to map over
---@return table New list with mapped values
function M.map(fn, list)
  local result = {}
  for _, val in ipairs(list) do
    local mapped = fn(val)
    if mapped ~= nil then
      result[#result + 1] = mapped
    end
  end
  return result
end

--- Filter a list by a predicate
---@param fn function Predicate function
---@param list table List to filter
---@return table Filtered list
function M.filter(fn, list)
  local result = {}
  for _, val in ipairs(list) do
    if fn(val) then
      result[#result + 1] = val
    end
  end
  return result
end

--- Iterate over a list, applying a function to each element
---@param fn function Function to apply
---@param list table List to iterate
function M.iter(fn, list)
  for _, val in ipairs(list) do
    fn(val)
  end
end

--- Check if any element in the list satisfies the predicate
---@param fn function Predicate function
---@param list table List to check
---@return boolean
function M.some(fn, list)
  for _, val in ipairs(list) do
    if fn(val) then
      return true
    end
  end
  return false
end

--- Check if a value exists in a list
---@param list table List to search
---@param x any Value to find
---@return boolean
function M.exists(list, x)
  return M.some(function(y) return y == x end, list)
end

--- Check if a list is empty
---@param list table List to check
---@return boolean
function M.is_empty(list)
  return #list == 0
end

return M
