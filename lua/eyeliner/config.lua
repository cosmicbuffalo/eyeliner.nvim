local M = {}

M.opts = {
	dim = false,
	max_length = 9999,
	debug = false,
	disabled_filetypes = {},
	disabled_buftypes = {},
	default_keymaps = true,
	match = "[A-Za-z]",
	case_sensitive = true,
}

--- Setup eyeliner with user options
---@param user_opts? table User configuration options
function M.setup(user_opts)
	local main = require("eyeliner.main")
	local merged = vim.tbl_deep_extend("force", {}, M.opts, user_opts or {})

	-- Disable first if already enabled (see https://github.com/jinh0/eyeliner.nvim/pull/19)
	if main.is_enabled() then
		main.disable()
	end

	-- Apply merged options
	for key, value in pairs(merged) do
		M.opts[key] = value
	end

	if M.opts.debug then
		vim.notify("Eyeliner debug mode enabled")
	end

	main.enable()
end

return M
