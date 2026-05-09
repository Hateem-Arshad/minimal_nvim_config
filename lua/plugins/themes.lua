vim.pack.add({
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
})

require("catppuccin").setup({
	flavour = "frappe",
	integrations = {
		mason = true,
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

--[[
local groups = { "Normal", "NormalNC", "NonText", "SignColumn", "StatusLine", "StatusLineNC" }

for _, group in ipairs(groups) do
	vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
end
--]]
