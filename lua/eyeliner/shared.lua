-- Shared eyeliner functions for both always-on and on-keypress modes

local config = require("eyeliner.config")
local utils = require("eyeliner.utils")

local M = {}

-- Namespace for eyeliner highlights
M.ns_id = vim.api.nvim_create_namespace("eyeliner")

--- Enable eyeliner highlight groups and set up ColorScheme autocmd
function M.enable_highlights()
  local primary = utils.get_hl("Constant")
  local secondary = utils.get_hl("Define")
  local dimmed = utils.get_hl("Comment")

  utils.set_hl("EyelinerPrimary", primary.foreground)
  utils.set_hl("EyelinerSecondary", secondary.foreground)
  utils.set_hl("EyelinerDimmed", dimmed.foreground)

  utils.set_autocmd("ColorScheme", { callback = M.enable_highlights })
end

--- Apply eyeliner highlights to tokens on a line
---@param row number Line number (1-indexed)
---@param tokens table[] List of tokens with x, freq, char
function M.apply_eyeliner(row, tokens)
  for _, token in ipairs(tokens) do
    local hl_group = token.freq == 1 and "EyelinerPrimary" or "EyelinerSecondary"
    vim.api.nvim_buf_add_highlight(0, M.ns_id, hl_group, row - 1, token.x - 1, token.x)
  end
end

--- Clear eyeliner highlights on a line
---@param row number Line number (1-indexed)
function M.clear_eyeliner(row)
  if row <= 0 then
    vim.api.nvim_buf_clear_namespace(0, M.ns_id, 0, row + 1)
  else
    vim.api.nvim_buf_clear_namespace(0, M.ns_id, row - 1, row)
  end
end

--- Dim the line in a direction from cursor
---@param row number Line number (1-indexed)
---@param col number Column position (0-indexed)
---@param direction string "left" or "right"
function M.dim(row, col, direction)
  local line = utils.get_current_line()
  local opts = config.opts
  local start_col, end_col

  if direction == "right" then
    start_col = col + 1
    end_col = math.min(#line, start_col + opts.max_length)
  else
    start_col = math.max(0, col - opts.max_length)
    end_col = col
  end

  vim.api.nvim_buf_add_highlight(0, M.ns_id, "EyelinerDimmed", row - 1, start_col, end_col)
end

--- Set up autocmd to disable eyeliner for certain filetypes
function M.disable_filetypes()
  local opts = config.opts
  -- Use an impossible pattern if no filetypes are disabled
  local pattern = utils.is_empty(opts.disabled_filetypes) and "\\%<0" or opts.disabled_filetypes

  utils.set_autocmd("FileType", {
    pattern = pattern,
    callback = function()
      vim.b.eyelinerDisabled = true
    end,
  })
end

--- Set up autocmd to disable eyeliner for certain buftypes
function M.disable_buftypes()
  utils.set_autocmd({ "BufEnter", "BufWinEnter" }, {
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()
      local buftype = vim.bo[bufnr].buftype

      if utils.exists(config.opts.disabled_buftypes, buftype) then
        vim.b.eyelinerDisabled = true
      end
    end,
  })
end

return M
