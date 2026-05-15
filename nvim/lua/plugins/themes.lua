-- THEME
-- Catppuccin Frappé with integrations declared for every active plugin.
-- Without explicit integration flags, Catppuccin falls back to generic
-- highlight groups for that plugin — colours may look inconsistent.

vim.pack.add({
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
})

require("catppuccin").setup({
	flavour = "frappe",
	integrations = {
		mason = true,
		treesitter = true,
		telescope = { enabled = true },
		native_lsp = {
			enabled = true,
			underlines = {
				errors = { "undercurl" },
				hints = { "undercurl" },
				warnings = { "undercurl" },
				information = { "undercurl" },
			},
		},
	},
})

vim.cmd.colorscheme("catppuccin")

-- TRANSPARENCY
-- Strip background from every surface that shows the terminal wallpaper.
-- Toggle: change ---[[ to --[[ to disable (restore Catppuccin backgrounds).
---[[
local transparent = {
	"Normal", -- main editing area
	"NormalNC", -- unfocused splits
	"NonText", -- virtual text, ~ end-of-buffer lines
	"EndOfBuffer", -- the ~ lines themselves
	"SignColumn", -- gutter (diagnostic signs, git markers)
	--	"StatusLine",    -- active statusline
	--	"StatusLineNC",  -- inactive statusline
	"WinSeparator", -- split border lines
	"FloatBorder", -- LSP / diagnostic floating window borders
	"NormalFloat", -- floating window body
}

for _, group in ipairs(transparent) do
	vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
end
--]]
