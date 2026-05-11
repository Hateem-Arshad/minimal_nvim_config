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
