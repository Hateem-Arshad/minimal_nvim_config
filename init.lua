--=================================================================================================
--	This file initializes all the configs from dfferent files
--=================================================================================================

-- LSP
require("core.lsp")
require("core.activation")
require("core.diagnostics")

--[[
  configurations for the IDE
]]

---[[
require("config.options")
require("config.keymaps")
require("config.statusline")
require("config.autocmd")
--]]

require("plugins.themes")
require("plugins.treesitter")
require("plugins.telescope")
--require("plugins.blink")
