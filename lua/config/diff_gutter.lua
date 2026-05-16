-- diff_gutter.lua
-- Tracks unsaved changes in the gutter without Git
-- Uses LCS (Longest Common Subsequence) algorithm
--
-- HOW IT WORKS:
--
-- 1. STORE ORIGINAL
--    When a file is opened (BufReadPost/BufEnter), we read the file from
--    disk into a table called `original`. This is our reference point —
--    what the file looked like when it was last saved.
--
-- 2. BUILD THE DP TABLE (lcs_table)
--    We compare `original` and `current` (the buffer) using a 2D table.
--    Each cell dp[i][j] stores the length of the longest common subsequence
--    between the first i lines of original and first j lines of current.
--    Rules:
--      - If lines match: dp[i][j] = dp[i-1][j-1] + 1  (extend the chain)
--      - If no match:    dp[i][j] = max(dp[i-1][j], dp[i][j-1])  (best so far)
--
-- 3. BACKTRACK (backtrack)
--    Starting from dp[m][n], we walk backwards to recover which lines
--    actually survived (the LCS):
--      - Match found → record the line, move diagonally (i-1, j-1)
--      - No match    → move to the larger neighbor (up or left)
--    The result is `matched` — lines that exist unchanged in both versions.
--
-- 4. MARK CHANGES (mark_changes)
--    Any line in `current` that is NOT in `matched` is new or changed.
--    We mark it in the gutter with a colored bar using nvim_buf_set_extmark.
--
-- 5. DEBOUNCE
--    Instead of running LCS on every keystroke (expensive), we wait 300ms
--    after the last keystroke before running. This keeps LSP and diagnostics
--    responsive.
--
-- 6. CLEAR ON SAVE
--    On BufWritePost, we reset `original` to the current buffer content
--    and clear all marks. The file is now saved — nothing is "changed".

-- Namespace for our extmarks
local ns = vim.api.nvim_create_namespace("my_diff")

-- Build the LCS dynamic programming table
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

-- Backtrack through the dp table to find surviving lines
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

-- Check if a value exists in a table
local function contains(tbl, value)
	for _, v in ipairs(tbl) do
		if v == value then
			return true
		end
	end
	return false
end

-- Custom highlight (VS Code purple)
vim.api.nvim_set_hl(0, "DiffGutterAdd", { fg = "#A855F7" })

-- Mark lines in current buffer that are not in matched
local function mark_changes(original, current, matched)
	if not original or #original == 0 then
		return
	end
	vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

	for i, line in ipairs(current) do
		if not contains(matched, line) then
			vim.api.nvim_buf_set_extmark(0, ns, i - 1, 0, {
				virt_text = { { "▎", "DiffGutterAdd" } },
				virt_text_pos = "right_align",
				priority = 50,
			})
		end
	end
end

-- Store original file content on open or buffer switch
local original = {}
vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter" }, {
	callback = function()
		if vim.bo.buftype ~= "" then
			return
		end
		if vim.bo.filetype == "netrw" then
			return
		end
		local path = vim.fn.expand("%:p")
		if path ~= "" and vim.fn.filereadable(path) == 1 then
			original = vim.fn.readfile(path)
		end
	end,
})

-- Debounced comparison on every edit
local timer = nil
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
	callback = function()
		if vim.bo.buftype ~= "" then
			return
		end
		if vim.bo.filetype == "netrw" then
			return
		end
		if timer then
			timer:stop()
		end
		timer = vim.defer_fn(function()
			if not original or #original == 0 then
				return
			end
			local current = vim.api.nvim_buf_get_lines(0, 0, -1, false)
			local dp = lcs_table(original, current)
			local matched = backtrack(original, current, dp)
			mark_changes(original, current, matched)
		end, 300)
	end,
})

-- Reset on save and clear marks
vim.api.nvim_create_autocmd("BufWritePost", {
	callback = function()
		original = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
	end,
})
