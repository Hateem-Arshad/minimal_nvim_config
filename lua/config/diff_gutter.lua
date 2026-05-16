-- diff_gutter.lua
-- Tracks unsaved changes in the gutter without Git

-- 1. Namespace
local ns = vim.api.nvim_create_namespace("my_diff")

-- 2. LCS table
local function lcs_table(old, new)
	local m = #old
	local n = #new
	local dp = {}
	for i = 0, m do
		dp[i] = {}
		for j = 0, n do
			dp[i][j] = 0
		end
	end
	for i = 1, m do
		for j = 1, n do
			if old[i] == new[j] then
				dp[i][j] = dp[i - 1][j - 1] + 1
			else
				dp[i][j] = math.max(dp[i - 1][j], dp[i][j - 1])
			end
		end
	end
	return dp
end

-- 3. Backtrack
local function backtrack(old, new, dp)
	local m = #old
	local n = #new
	local matched = {}
	local i = m
	local j = n
	while i > 0 and j > 0 do
		if old[i] == new[j] then
			table.insert(matched, old[i])
			i = i - 1
			j = j - 1
		else
			if dp[i - 1][j] > dp[i][j - 1] then
				i = i - 1
			else
				j = j - 1
			end
		end
	end
	return matched
end

-- 4. Contains
local function contains(tbl, value)
	for _, v in ipairs(tbl) do
		if v == value then
			return true
		end
	end
	return false
end

-- 5. Mark changed lines
local function mark_changes(original, current, matched)
	if not original or #original == 0 then
		return
	end
	vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

	-- added lines
	for i, line in ipairs(current) do
		if not contains(matched, line) then
			vim.api.nvim_buf_set_extmark(0, ns, i - 1, 0, {
				sign_text = "▎",
				sign_hl_group = "DiffAdd",
			})
		end
	end

	-- deleted/changed lines
	for i, line in ipairs(original) do
		if not contains(matched, line) then
			vim.api.nvim_buf_set_extmark(0, ns, i - 1, 0, {
				sign_text = "▎",
				sign_hl_group = "DiffDelete",
			})
		end
	end
end

-- 6. Store original on file open
local original = {}
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function()
		original = vim.fn.readfile(vim.fn.expand("%:p"))
	end,
})

-- 7. Compare on every edit
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
	callback = function()
		if not original or #original == 0 then
			return
		end
		local current = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		local dp = lcs_table(original, current)
		local matched = backtrack(original, current, dp)
		mark_changes(original, current, matched)
	end,
})

-- 8. Clear on save and reset original
vim.api.nvim_create_autocmd("BufWritePost", {
	callback = function()
		original = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
	end,
})
