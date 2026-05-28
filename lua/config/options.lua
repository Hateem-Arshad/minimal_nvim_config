local option = vim.opt

-- python provider -> pynvim to a venv and not root files, so no system break package flags on pip
-- activate the given block if you want to use pynvim from a venv, right now I am using a global pynvim install
--[[
vim.g.python3_host_prog = vim.env.HOME .. "/.local/share/nvim/venv/bin/python3"

vim.opt.runtimepath:append(vim.env.HOME .. "/.local/share/nvim/site")
--]]

-- sqls odd behaviour
vim.o.exrc = true -- allow per-project .nvim.lua files
vim.g.omni_sql_no_default_maps = 1
vim.g.loaded_sql_completion = 1
-- nvim has a built-in sql completion but depends on a third-party plugin `dbext`, so its counter intuitive to have a native compleiton that is dependent on third-party tool

-- netrw with :Lex
vim.g.netrw_winsize = 25
vim.g.netrw_liststyle = 3
vim.g.netrw_banner = 0

-- Line Numbers
option.number = true
option.relativenumber = true
option.cursorline = true

-- Indentation
option.shiftwidth = 4
option.tabstop = 4
option.softtabstop = 4
option.expandtab = true
--option.smartindent = true
option.autoindent = true

-- Search
option.ignorecase = true
option.smartcase = true
option.hlsearch = true
option.incsearch = true
option.path:append("**")

-- UI
option.termguicolors = true
option.signcolumn = "yes"
option.scrolloff = 12
option.sidescrolloff = 12
option.wrap = false
option.splitbelow = true
option.splitright = true
option.showmode = false
option.pumborder = "rounded"
option.winborder = "rounded"
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

-- Files
option.backup = false
option.swapfile = false
option.undofile = true
option.undodir = vim.fn.stdpath("data") .. "/undo"
--option.clipboard = "unnamedplus"

-- Performance
option.updatetime = 250
option.timeoutlen = 300
option.fileencoding = "utf-8"
option.confirm = true

-- Indent marks
option.list = true
option.listchars = { tab = "│ ", multispace = "│   ", leadmultispace = "│   " }

-- Misc
option.mouse = "a"

-- to tell its fine to not use perl and ruby
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_ruby_provider = 0
