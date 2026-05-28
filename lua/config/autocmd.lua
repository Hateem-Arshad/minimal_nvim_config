-- The Setting bwlow disable recursive/persistent commenting
---[[
vim.api.nvim_create_autocmd("FileType", {
	pattern = "*", -- applies to all file types
	callback = function()
		-- Remove the two flags responsible for auto-continuing comments
		vim.opt_local.formatoptions:remove({ "r", "o" })
	end,
})
--]]

-- Add to diagnostics.lua or a sql-specific autocmd
--[[
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "sql" },
	callback = function()
		vim.diagnostic.config({
			update_in_insert = false, -- wait until you leave insert
			virtual_lines = { current_line = true }, -- only show on cursor line
		}, vim.lsp.get_clients({ bufnr = 0 })[1] and vim.lsp.get_clients({ bufnr = 0 })[1].id or nil)
	end,
})
--]]

-- Override julials before_init: mason-lspconfig's version fails to inject
-- the project path. This programmatic call has highest config priority.
vim.api.nvim_create_autocmd("FileType", {
	pattern = "julia",
	callback = function(args)
		local root = vim.fs.root(args.buf, { "Project.toml", "JuliaProject.toml" }) or vim.fn.getcwd()
		vim.lsp.start({
			name = "julials",
			cmd = { "julia-lsp", root },
			root_dir = root,
		})
	end,
})
