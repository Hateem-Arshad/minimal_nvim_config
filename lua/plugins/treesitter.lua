vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects" },
})

local ok, configs = pcall(require, "nvim-treesitter.configs")
if not ok then
	return
end

configs.setup({
	ensure_installed = {
		"lua",
		"python",
		"c",
		"bash",
		"sql",
		"markdown",
		"markdown_inline",
		"json",
		"yaml",
		"julia",
	},
	auto_install = true, -- installs parser when you open an unknown filetype
	highlight = {
		enable = true,
	},
	indent = {
		enable = true, -- treesitter-based indentation (replaces smartindent)
	},
	textobjects = {
		select = {
			enable = true,
			lookahead = true,
			keymaps = {
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
			},
		},
	},
})
