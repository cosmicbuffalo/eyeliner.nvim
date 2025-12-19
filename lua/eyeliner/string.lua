-- String utility functions for eyeliner.nvim

local M = {}

--- Convert a string to a list of characters
---@param str string Input string
---@return string[] List of single characters
function M.to_list(str)
	local chars = {}
	for i = 1, #str do
		chars[i] = str:sub(i, i)
	end
	return chars
end

--- Check if a character is alphanumeric
---@param char string Single character
---@return boolean
function M.is_alphanumeric(char)
	return char:match("%w") ~= nil
end

--- Check if a character is alphabetic
---@param char string Single character
---@return boolean
function M.is_alphabetic(char)
	return char:match("[A-Za-z]") ~= nil
end

return M
