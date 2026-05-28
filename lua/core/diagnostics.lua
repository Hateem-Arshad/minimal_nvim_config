-- 8. DIAGNOSTICS UI
-- virtual_lines: each diagnostic appears on its own line below the code.
-- virtual_text: disabled to prevent clutter on the same line as code.
-- update_in_insert: diagnostics refresh while typing, not just on save.
-- severity_sort: errors shown before warnings before hints.
-- float.source: floating diagnostic popup names the server that raised it.
-- Floating window borders are handled globally by 'winborder' in options.lua.
vim.diagnostic.config({
	virtual_lines = false,
	virtual_text = true,
	underline = true,
	update_in_insert = true,
	severity_sort = true,
	float = {
		source = true,
	},
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.INFO] = "󱛉 ",
			[vim.diagnostic.severity.HINT] = " ",
		},
	},
})
