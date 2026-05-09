local kmap = vim.keymap

-- for split terminal
local function split_terminal()
	-- your two commands here

	vim.cmd("belowright 15split")
	vim.cmd("term")
end

kmap.set("n", "<C-s>", split_terminal, { desc = "Terminal in the Bottom window" })

-- opening :Lex
kmap.set("n", "<leader>e", ":Lex<CR>", { desc = "Explorer" })

-- LSP completion trigger in Insert mode
-- This makes <C-Space> behave like <C-x><C-o>
kmap.set("i", "<C-Space>", "<C-x><C-o>", { desc = "Trigger LSP completion" })

--[[
vim.keymap.set('n', '<leader>f', function()
    vim.lsp.buf.format({ async = true })
end, { desc = 'Format buffer' })
--]]
