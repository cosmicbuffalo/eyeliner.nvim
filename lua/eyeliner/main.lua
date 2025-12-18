-- Main module for eyeliner.nvim
-- Handles enabling/disabling the plugin

local shared = require("eyeliner.shared")
local on_key = require("eyeliner.on-key")
local utils = require("eyeliner.utils")
local config = require("eyeliner.config")

local M = {}

local enabled = false

--- Check if eyeliner is currently enabled
---@return boolean
function M.is_enabled()
	return enabled
end

--- Enable eyeliner
---@return boolean True if newly enabled, false if already enabled
function M.enable()
	if enabled then
		return false
	end

	local opts = config.opts

	utils.create_augroup("Eyeliner", { clear = true })
	shared.enable_highlights()
	on_key.enable()

	if opts.debug then
		vim.notify("Enabled eyeliner.nvim")
	end

	enabled = true
	return true
end

--- Disable eyeliner
---@return boolean True if newly disabled, false if already disabled
function M.disable()
	if not enabled then
		return false
	end

	local opts = config.opts
	local cursor = utils.get_cursor()
	local row = cursor[1]

	shared.clear_eyeliner(row)
	utils.del_augroup("Eyeliner")
	pcall(on_key.remove_keybinds)

	if opts.debug then
		vim.notify("Disabled eyeliner.nvim")
	end

	enabled = false
	return true
end

--- Toggle eyeliner on/off
---@return boolean New enabled state
function M.toggle()
	if enabled then
		M.disable()
	else
		M.enable()
	end
	return enabled
end

return M
