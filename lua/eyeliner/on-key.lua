-- On-keypress mode for eyeliner.nvim
-- Highlights jump targets only when f/F/t/T keys are pressed

local liner = require("eyeliner.liner")
local config = require("eyeliner.config")
local shared = require("eyeliner.shared")
local utils = require("eyeliner.utils")

local M = {}

local prev_row = nil
local needs_cleanup = false

--- Highlight jump targets in a direction
---@param opts table Options: forward (boolean), case_sensitive (boolean|nil)
function M.highlight(opts)
	local plugin_opts = config.opts
	local line = utils.get_current_line()
	local cursor = utils.get_cursor()
	local row, col = cursor[1], cursor[2]

	local direction = opts.forward and "right" or "left"

	-- Use option from highlight call, or fall back to config
	local case_sensitive = opts.case_sensitive
	if case_sensitive == nil then
		case_sensitive = plugin_opts.case_sensitive
	end

	local processed_line = case_sensitive and line or string.lower(line)
	local targets = liner.get_locations(processed_line, col, direction)

	if plugin_opts.dim then
		shared.dim(row, col, direction)
	end

	shared.apply_eyeliner(row, targets)
	prev_row = row
	needs_cleanup = true

	vim.cmd("redraw")
end

--- Handle key press - highlight and return the key
---@param key string The key that was pressed
---@param forward boolean Whether movement is forward
---@return string The key to be executed
local function on_key(key, forward)
	M.highlight({ forward = forward })
	return key
end

--- Set up keybindings for f/F/t/T
local function enable_keybinds()
	local bufnr = vim.api.nvim_get_current_buf()
	if vim.b[bufnr].eyelinerDisabled then
		return
	end

	local opts = config.opts
	local default_keys = { "f", "t", "F", "T" }
	local enabled_keys = (opts.highlight_on_key == true) and default_keys or opts.highlight_on_key

	for _, key in ipairs(enabled_keys) do
		if key == "f" or key == "t" then
			vim.keymap.set({ "n", "x", "o" }, key, function()
				return on_key(key, true)
			end, { buffer = 0, expr = true })
		elseif key == "F" or key == "T" then
			vim.keymap.set({ "n", "x", "o" }, key, function()
				return on_key(key, false)
			end, { buffer = 0, expr = true })
		end
	end
end

--- Remove keybindings for f/F/t/T
function M.remove_keybinds()
	local bufnr = vim.api.nvim_get_current_buf()
	if vim.b[bufnr].eyelinerDisabled then
		return
	end

	for _, key in ipairs({ "f", "F", "t", "T" }) do
		vim.keymap.del({ "n", "x", "o" }, key, { buffer = 0 })
	end
end

--- Enable on-keypress mode
function M.enable()
	local opts = config.opts

	if opts.debug then
		vim.notify("On-keypress mode enabled")
	end

	shared.disable_filetypes()
	shared.disable_buftypes()

	-- Clean up highlights on cursor movement
	utils.set_autocmd("CursorMoved", {
		callback = function()
			if needs_cleanup then
				shared.clear_eyeliner(prev_row)
				needs_cleanup = false
			end
		end,
	})

	-- Clean up on Escape key
	vim.on_key(function(char)
		local key = vim.fn.keytrans(char)
		if key == "<Esc>" and needs_cleanup then
			shared.clear_eyeliner(prev_row)
			needs_cleanup = false
		end
	end, vim.api.nvim_get_current_buf())

	-- Set up keymaps if enabled
	if opts.default_keymaps then
		enable_keybinds()

		utils.set_autocmd("BufEnter", {
			callback = enable_keybinds,
		})

		utils.set_autocmd("BufLeave", {
			callback = function()
				pcall(M.remove_keybinds)
			end,
		})
	end
end

return M
