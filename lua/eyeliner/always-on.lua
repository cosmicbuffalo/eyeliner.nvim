-- Always-on mode for eyeliner.nvim
-- Highlights jump targets continuously as the cursor moves

local liner = require("eyeliner.liner")
local shared = require("eyeliner.shared")
local config = require("eyeliner.config")
local utils = require("eyeliner.utils")

local M = {}

local prev_row = 0

--- Handle cursor movement - update highlights
local function handle_cursor_move()
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.b[bufnr].eyelinerDisabled then
    return
  end

  local line = utils.get_current_line()
  local cursor = utils.get_cursor()
  local row, col = cursor[1], cursor[2]

  local left = liner.get_locations(line, col, "left")
  local right = liner.get_locations(line, col, "right")

  shared.clear_eyeliner(prev_row)
  shared.apply_eyeliner(row, left)
  shared.apply_eyeliner(row, right)

  prev_row = row
end

--- Enable always-on mode
function M.enable()
  local opts = config.opts

  if opts.debug then
    vim.notify("Always-on mode enabled")
  end

  shared.disable_filetypes()
  shared.disable_buftypes()

  -- Update highlights on cursor movement
  utils.set_autocmd({ "CursorMoved", "WinScrolled", "BufReadPost" }, {
    callback = handle_cursor_move,
  })

  -- Clear highlights when entering insert mode or leaving buffer
  utils.set_autocmd({ "InsertEnter", "BufLeave", "BufWinLeave" }, {
    callback = function()
      shared.clear_eyeliner(prev_row)
    end,
  })
end

return M
