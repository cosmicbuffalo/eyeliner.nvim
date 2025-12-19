local Config = require("eyeliner.config")
local Handler = require("eyeliner.handler")
local Highlights = require("eyeliner.highlights")
local Utils = require("eyeliner.utils")

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

	local opts = Config.opts

	Utils.create_augroup("Eyeliner", { clear = true })
	Highlights.enable()
	Handler.enable()

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

	local opts = Config.opts
	local cursor = Utils.get_cursor()
	local row = cursor[1]

	Highlights.clear(row)
	Utils.del_augroup("Eyeliner")
	pcall(Handler.remove_keybinds)

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

---@param user_opts? table User configuration options
function M.setup(user_opts)
	local merged = vim.tbl_deep_extend("force", {}, Config.opts, user_opts or {})

	if M.is_enabled() then
		M.disable()
	end

	for key, value in pairs(merged) do
		Config.opts[key] = value
	end

	if Config.opts.debug then
		vim.notify("Eyeliner debug mode enabled")
	end

	M.enable()
end

M.highlight = Handler.highlight

return M
