local Config = require("eyeliner.config")
local Utils = require("eyeliner.utils")

local M = {}

M.ns_id = vim.api.nvim_create_namespace("eyeliner")

--- Enable eyeliner highlight groups and set up ColorScheme autocmd
function M.enable()
	local primary = Utils.get_hl("Constant")
	local secondary = Utils.get_hl("Define")
	local dimmed = Utils.get_hl("Comment")

	Utils.set_hl("EyelinerPrimary", primary.foreground)
	Utils.set_hl("EyelinerSecondary", secondary.foreground)
	Utils.set_hl("EyelinerDimmed", dimmed.foreground)

	Utils.set_autocmd("ColorScheme", { callback = M.enable })
end

--- Apply eyeliner highlights to tokens on a line
---@param row number Line number (1-indexed)
---@param tokens table[] List of tokens with x, freq, char
function M.apply(row, tokens)
	for _, token in ipairs(tokens) do
		local hl_group = token.freq == 1 and "EyelinerPrimary" or "EyelinerSecondary"
		vim.api.nvim_buf_add_highlight(0, M.ns_id, hl_group, row - 1, token.x - 1, token.x)
	end
end

--- Clear eyeliner highlights on a line
---@param row number Line number (1-indexed)
function M.clear(row)
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
	local line = Utils.get_current_line()
	local opts = Config.opts
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
	local opts = Config.opts
	-- Use an impossible pattern if no filetypes are disabled
	local pattern = Utils.is_empty(opts.disabled_filetypes) and "\\%<0" or opts.disabled_filetypes

	Utils.set_autocmd("FileType", {
		pattern = pattern,
		callback = function()
			vim.b.eyelinerDisabled = true
		end,
	})
end

--- Set up autocmd to disable eyeliner for certain buftypes
function M.disable_buftypes()
	Utils.set_autocmd({ "BufEnter", "BufWinEnter" }, {
		callback = function()
			local bufnr = vim.api.nvim_get_current_buf()
			local buftype = vim.bo[bufnr].buftype

			if Utils.exists(Config.opts.disabled_buftypes, buftype) then
				vim.b.eyelinerDisabled = true
			end
		end,
	})
end

return M
