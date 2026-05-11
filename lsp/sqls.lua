return {
	filetypes = { "sql" },
	on_attach = function(client, bufnr)
		require("sqls").on_attach(client, bufnr)
	end,
	settings = {
		sqls = {
			lowercaseKeywords = false,
			connections = {},
		},
	},
	root_markers = { ".git", ".nvim.lua" },
}
