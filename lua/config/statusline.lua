--[[
function Statusline()
	local modes = {
		n = "NORMAL",
		i = "INSERT",
		v = "VISUAL",
		V = "V-LINE",
		c = "COMMAND",
		R = "REPLACE",
		t = "TERMINAL",
	}
	local mode = modes[vim.fn.mode()] or vim.fn.mode()
	local count = vim.diagnostic.count(0)

	local error = count[vim.diagnostic.severity.ERROR] or 0
	local warning = count[vim.diagnostic.severity.WARN] or 0
	local hint = count[vim.diagnostic.severity.HINT] or 0
	local info = count[vim.diagnostic.severity.INFO] or 0

	return " "
		.. mode
		.. " | %f %m "
		.. "%="
		.. " E: "
		.. error
		.. " W: "
		.. warning
		.. " H: "
		.. hint
		.. " I: "
		.. info
		.. " | %l:%c"
end

vim.opt.statusline = "%!v:lua.Statusline()"
--]]

-- =============================================================================
-- STATUSLINE
-- =============================================================================

-- Complete mode map — covers all Neovim modes including pending, select,
-- ex, shell, confirm, and both visual-block notations (\22 = <C-v>).
local modes = {
	n = "NORMAL",
	no = "N·PENDING",
	nov = "N·PENDING",
	noV = "N·PENDING",
	["no\22"] = "N·PENDING",
	nt = "NORMAL",
	v = "VISUAL",
	vs = "VISUAL",
	V = "V-LINE",
	Vs = "V-LINE",
	["\22"] = "V-BLOCK",
	["\22s"] = "V-BLOCK",
	s = "SELECT",
	S = "S-LINE",
	["\19"] = "S-BLOCK",
	i = "INSERT",
	ic = "INSERT",
	ix = "INSERT",
	R = "REPLACE",
	Rc = "REPLACE",
	Rx = "REPLACE",
	Rv = "V-REPLACE",
	Rvc = "V-REPLACE",
	Rvx = "V-REPLACE",
	c = "COMMAND",
	cv = "EX",
	r = "PROMPT",
	rm = "MORE",
	["r?"] = "CONFIRM",
	["!"] = "SHELL",
	t = "TERMINAL",
}

-- Filetype icons (requires Nerd Font — same font already used in lsp.lua kinds).
local ft_icons = {
	lua = "󰢱",
	python = "󰌠",
	c = "",
	cpp = "",
	rust = "󱘗",
	sql = "󰆼",
	sh = "",
	bash = "",
	yaml = "",
	toml = "",
	json = "",
	markdown = "󰍔",
	text = "󰈙",
}

-- =============================================================================
-- GIT BRANCH (cached)
-- Runs a shell call only on BufEnter / DirChanged, never on every redraw.
-- shellescape() guards against paths with spaces.
-- =============================================================================
vim.g._git_branch = ""

local function refresh_git_branch()
	local dir = vim.fn.expand("%:p:h")
	if dir == "" or dir:find("^term://") then
		vim.g._git_branch = ""
		return
	end
	local branch =
		vim.fn.system("git -C " .. vim.fn.shellescape(dir) .. " branch --show-current 2>/dev/null"):gsub("\n", "")
	vim.g._git_branch = branch ~= "" and (" " .. branch) or ""
end

vim.api.nvim_create_autocmd({ "BufEnter", "DirChanged" }, {
	callback = refresh_git_branch,
})

-- =============================================================================
-- LSP CLIENT NAMES
-- vim.lsp.get_clients() is cheap (in-process table lookup, no IPC).
-- Returns e.g. "󰄭 basedpyright" or "" when no server is attached.
-- =============================================================================
local function lsp_segment()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	if #clients == 0 then
		return ""
	end
	local names = {}
	for _, c in ipairs(clients) do
		table.insert(names, c.name)
	end
	return " 󰄭 " .. table.concat(names, ", ")
end

-- =============================================================================
-- DIAGNOSTIC SEGMENT
-- Uses the same icons as diagnostics.lua.
-- Shows ✓ when clean; only lists non-zero counts to reduce noise.
-- Severity order: ERROR → WARN → HINT → INFO (matches severity_sort in
-- diagnostics.lua so statusline order mirrors virtual_lines order).
-- =============================================================================
local diag_icons = {
	[vim.diagnostic.severity.ERROR] = " ",
	[vim.diagnostic.severity.WARN] = " ",
	[vim.diagnostic.severity.INFO] = "󱛉 ",
	[vim.diagnostic.severity.HINT] = " ",
}

local function diag_segment()
	local count = vim.diagnostic.count(0)
	local parts = {}
	local order = {
		vim.diagnostic.severity.ERROR,
		vim.diagnostic.severity.WARN,
		vim.diagnostic.severity.HINT,
		vim.diagnostic.severity.INFO,
	}
	for _, sev in ipairs(order) do
		local n = count[sev] or 0
		if n > 0 then
			table.insert(parts, diag_icons[sev] .. n)
		end
	end
	return #parts > 0 and table.concat(parts, "  ") or "✓"
end

-- =============================================================================
-- MAIN STATUSLINE FUNCTION
-- Called on every redraw via %!v:lua.Statusline().
-- table.concat() avoids repeated string allocation from .. chaining.
-- =============================================================================
function Statusline()
	local mode = modes[vim.fn.mode()] or vim.fn.mode()
	local ft = vim.bo.filetype
	local icon = ft_icons[ft] or ""
	local ft_str = icon ~= "" and (icon .. " " .. ft) or (ft ~= "" and ft or "—")
	local branch = vim.g._git_branch or ""

	return table.concat({
		" ",
		mode,
		" │ %f %m", -- file path + [+] modified flag
		branch,
		"%=", -- push everything after this to the right
		diag_segment(),
		lsp_segment(),
		" │ ",
		ft_str,
		" │ %l:%c ",
	})
end

vim.opt.statusline = "%!v:lua.Statusline()"
