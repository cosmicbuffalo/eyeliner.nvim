-- Core algorithm for calculating which characters to highlight
-- Analyzes the line and determines optimal jump targets

local str_utils = require("eyeliner.string")
local utils = require("eyeliner.utils")
local config = require("eyeliner.config")

local M = {}

--- Get the first "proper" index - the first position after the current word
---@param line string The line content
---@param col number Current cursor column (0-indexed)
---@param go_right boolean Whether we're moving right
---@return number First proper index (1-indexed)
local function get_first_proper(line, col, go_right)
  local idx = col + 1 -- Convert to 1-indexed
  local step = go_right and 1 or -1

  while str_utils.is_alphanumeric(line:sub(idx, idx)) do
    if go_right then
      if idx > #line then break end
    else
      if idx < 1 then break end
    end
    idx = idx + step
  end

  return idx
end

--- Reverse a list
---@param list table List to reverse
---@return table Reversed list
local function reverse(list)
  local result = {}
  for i = #list, 1, -1 do
    result[#result + 1] = list[i]
  end
  return result
end

--- Convert substring from cursor position into a list of tokens
--- Each token contains x-coordinate, cumulative frequency, and character
---@param line string Line content
---@param col number Cursor column (0-indexed)
---@param direction string "left" or "right"
---@return table[] List of tokens {x, freq, char}
local function get_tokens(line, col, direction)
  local go_right = direction == "right"
  local step = go_right and 1 or -1
  local opts = config.opts

  local freqs = {}
  local tokens = {}
  local chars = str_utils.to_list(line)
  local first_proper = get_first_proper(line, col, go_right)

  local start_idx, end_idx
  if go_right then
    start_idx = col + 2
    end_idx = math.min(#chars, start_idx + opts.max_length)
  else
    start_idx = col
    end_idx = math.max(1, start_idx - opts.max_length)
  end

  for idx = start_idx, end_idx, step do
    local char = chars[idx]
    if char ~= nil then
      local freq = freqs[char]
      if freq == nil then
        freqs[char] = 1
      else
        freqs[char] = freq + 1
      end
      tokens[#tokens + 1] = { x = idx, freq = freqs[char], char = char }
    end
  end

  -- Filter out characters from the word the cursor is on
  -- Reverse if going left to prioritize earlier (leftmost) letters
  local filtered = utils.filter(function(token)
    if go_right then
      return token.x >= first_proper
    else
      return token.x <= first_proper
    end
  end, go_right and tokens or reverse(tokens))

  return filtered
end

--- Split tokens into words (groups of alphanumeric tokens)
---@param tokens table[] List of tokens
---@return table[][] List of words, each word is a list of tokens
local function tokens_to_words(tokens)
  local words = {}
  local current_word = {}

  for _, token in ipairs(tokens) do
    if not str_utils.is_alphanumeric(token.char) then
      -- Non-alphanumeric character = word boundary
      if #current_word > 0 then
        words[#words + 1] = current_word
        current_word = {}
      end
    else
      current_word[#current_word + 1] = token
    end
  end

  -- Don't forget the last word
  if #current_word > 0 then
    words[#words + 1] = current_word
  end

  return words
end

--- Get the token with minimum frequency in a word
---@param word table[] List of tokens forming a word
---@param match_pattern string Pattern to match valid characters
---@return table|nil Token with minimum frequency, or nil
local function get_min_token(word, match_pattern)
  local min = { freq = 9999999 }

  for _, token in ipairs(word) do
    if token.char:match(match_pattern) then
      if token.freq < min.freq then
        min = token
      end
    end
  end

  return min.freq < 9999999 and min or nil
end

--- Get locations to highlight for eyeliner
---@param line string Line content
---@param col number Cursor column (0-indexed)
---@param direction string "left" or "right"
---@return table[] List of tokens to highlight
function M.get_locations(line, col, direction)
  local opts = config.opts
  local tokens = get_tokens(line, col, direction)
  local words = tokens_to_words(tokens)

  local result = {}
  for _, word in ipairs(words) do
    local min = get_min_token(word, opts.match)
    -- Only highlight if frequency is <= 2
    if min and min.freq <= 2 then
      result[#result + 1] = min
    end
  end

  return result
end

return M
