-- eyeliner.nvim
-- Move faster with unique f/F indicators for each word on the line

local config = require("eyeliner.config")
local main = require("eyeliner.main")
local on_key = require("eyeliner.on-key")

return {
  setup = config.setup,
  enable = main.enable,
  disable = main.disable,
  toggle = main.toggle,
  highlight = on_key.highlight,
}
