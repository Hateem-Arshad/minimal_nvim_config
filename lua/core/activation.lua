-- =============================================================================
-- LSP CONFIGURATION (Neovim 0.12.x + Mason)
-- =============================================================================
-- Architecture:
--   Mason                → downloads/manages LSP server binaries
--   mason-lspconfig      → bridges Mason installs to Neovim's LSP client
--   mason-tool-installer → ensures formatters/linters are installed
--   vim.lsp.config       → per-server settings (in ~/.config/nvim/lsp/*.lua)
--   automatic_enable     → mason-lspconfig enables servers automatically
--
-- Switching to blink.cmp:
--   Three sections are marked with "BLINK REPLACES THIS". Toggle the
--   ---[[ / --]] comments to disable native completion and enable blink.
-- =============================================================================

-- 1. PLUGIN INSTALLATION (vim.pack — Neovim 0.12 built-in package manager)
vim.pack.add({
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },
	{ src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
	-- ADD THIS if switching to blink:
	--{ src = "https://github.com/saghen/blink.cmp" },
})

-- 2. MASON SETUP
-- Opens with :Mason — shows installed/pending servers and their status.
require("mason").setup()

-- 3. SERVER MANAGEMENT
-- ensure_installed: Mason will auto-download these servers if missing.
-- automatic_enable: replaces manual vim.lsp.enable() calls — servers activate
-- automatically when you open a matching filetype. No manual require() needed.
-- Per-server settings (root markers, filetypes, custom config) live in
-- ~/.config/nvim/lsp/<servername>.lua and are auto-discovered by Neovim.
require("mason-lspconfig").setup({
	ensure_installed = {
		"basedpyright", -- Python (community pyright fork, stricter types)
		"clangd", -- C/C++
		"lua_ls", -- Lua (with vim global awareness via lsp/lua_ls.lua)
		"bashls", -- Bash/Shell
		"sqls", -- SQL (connection configured per-project via .nvim.lua)
	},
	automatic_enable = true,
})

-- 4. FORMATTERS & LINTERS
-- mason-tool-installer manages non-LSP tools Mason can install.
-- These are separate from LSP servers — they handle code formatting only.
-- Wire them to a keymap or autocmd in keymaps.lua / autocmd.lua as needed.
require("mason-tool-installer").setup({
	ensure_installed = {
		"stylua", -- Lua formatter (respects .stylua.toml config)
		"shfmt", -- Shell script formatter
	},
})
