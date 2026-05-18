local kmap = vim.keymap

-- for split terminal
local function split_terminal()
	-- your two commands here

	vim.cmd("belowright 10split")
	vim.cmd("term")
end

kmap.set("n", "<C-s>", split_terminal, { desc = "Terminal in the Bottom window" })

-- opening :Lex | i changed to :Ex because "Lex was showing some difficulties on repeated use, till now i do not know what that is
kmap.set("n", "<leader>e", ":Ex<CR>", { desc = "Explorer" })

-- LSP completion trigger in Insert mode
-- This makes <C-Space> behave like <C-x><C-o>
kmap.set("i", "<C-Space>", "<C-x><C-o>", { desc = "Trigger LSP completion" })

--[[
vim.keymap.set('n', '<leader>f', function()
    vim.lsp.buf.format({ async = true })
end, { desc = 'Format buffer' })
--]]

-- Sqls related keymaps, toggle it off if not using sqls at any point
---[[
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client or client.name ~= "sqls" then
			return
		end

		local function sql_action(title)
			return function()
				vim.lsp.buf.code_action({
					filter = function(action)
						return action.title == title
					end,
					apply = true,
				})
			end
		end

		vim.keymap.set(
			{ "n", "v" },
			"<leader>sq",
			sql_action("Execute Query"),
			{ buffer = args.buf, desc = "SQL: Execute query" }
		)
		vim.keymap.set(
			"n",
			"<leader>sc",
			sql_action("Switch Connections"),
			{ buffer = args.buf, desc = "SQL: Switch connection" }
		)
		vim.keymap.set(
			"n",
			"<leader>sd",
			sql_action("Switch Database"),
			{ buffer = args.buf, desc = "SQL: Switch database" }
		)
		vim.keymap.set("n", "<leader>sT", sql_action("Show Tables"), { buffer = args.buf, desc = "SQL: Show tables" })
		vim.keymap.set(
			"n",
			"<leader>sD",
			sql_action("Show Databases"),
			{ buffer = args.buf, desc = "SQL: Show databases" }
		)

		vim.keymap.set("n", "<leader>sa", vim.lsp.buf.code_action, { buffer = args.buf, desc = "SQL: All actions" })
	end,
})

--]]
