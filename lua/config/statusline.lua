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
-- Foreground-only highlights — compatible with transparency in themes.lua.
-- Colors match Catppuccin Frappé.
-- =============================================================================

local hl = {
	StatusNormal = { fg = "#8caaee", bold = true },
	StatusInsert = { fg = "#a6d189", bold = true },
	StatusVisual = { fg = "#ca9ee6", bold = true },
	StatusCommand = { fg = "#e5c890", bold = true },
	StatusReplace = { fg = "#e78284", bold = true },
	StatusTerminal = { fg = "#81c8be", bold = true },
	StatusPending = { fg = "#ef9f76", bold = true },
	StatusError = { fg = "#e78284" },
	StatusWarn = { fg = "#e5c890" },
	StatusInfo = { fg = "#8caaee" },
	StatusHint = { fg = "#a6d189" },
	StatusMuted = { fg = "#626880" },
}

for name, opts in pairs(hl) do
	vim.api.nvim_set_hl(0, name, opts)
end

-- =============================================================================
-- MODE MAP
-- Covers all Neovim modes including pending, select, ex, confirm, shell.
-- \22 = <C-v> (visual block), \19 = <C-s> (select block).
-- =============================================================================
local modes = {
	n = { "NORMAL", "StatusNormal" },
	no = { "N·PENDING", "StatusPending" },
	nov = { "N·PENDING", "StatusPending" },
	noV = { "N·PENDING", "StatusPending" },
	["no\22"] = { "N·PENDING", "StatusPending" },
	nt = { "NORMAL", "StatusNormal" },
	v = { "VISUAL", "StatusVisual" },
	vs = { "VISUAL", "StatusVisual" },
	V = { "V·LINE", "StatusVisual" },
	Vs = { "V·LINE", "StatusVisual" },
	["\22"] = { "V·BLOCK", "StatusVisual" },
	["\22s"] = { "V·BLOCK", "StatusVisual" },
	s = { "SELECT", "StatusVisual" },
	S = { "S·LINE", "StatusVisual" },
	["\19"] = { "S·BLOCK", "StatusVisual" },
	i = { "INSERT", "StatusInsert" },
	ic = { "INSERT", "StatusInsert" },
	ix = { "INSERT", "StatusInsert" },
	R = { "REPLACE", "StatusReplace" },
	Rc = { "REPLACE", "StatusReplace" },
	Rx = { "REPLACE", "StatusReplace" },
	Rv = { "V·REPLACE", "StatusReplace" },
	Rvc = { "V·REPLACE", "StatusReplace" },
	Rvx = { "V·REPLACE", "StatusReplace" },
	c = { "COMMAND", "StatusCommand" },
	cv = { "EX", "StatusCommand" },
	r = { "PROMPT", "StatusMuted" },
	rm = { "MORE", "StatusMuted" },
	["r?"] = { "CONFIRM", "StatusPending" },
	["!"] = { "SHELL", "StatusTerminal" },
	t = { "TERMINAL", "StatusTerminal" },
}

-- =============================================================================
-- FILETYPE ICONS
-- Requires a Nerd Font — same font already needed for LSP kind icons.
-- =============================================================================
local ft_icons = {
	lua = "󰢱 ",
	python = " ",
	c = " ",
	cpp = " ",
	rust = "󱘗",
	sql = " ",
	sh = " ",
	bash = " ",
	yaml = " ",
	toml = " ",
	json = " ",
	markdown = "󰍔 ",
	text = "󰦨 ",
}

-- =============================================================================
-- GIT BRANCH (cached)
-- Shell call runs only on BufEnter / DirChanged, not on every redraw.
-- shellescape() guards paths that contain spaces.
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
-- LSP SEGMENT
-- vim.lsp.get_clients() is an in-process table lookup — no IPC cost.
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
	return "%#StatusMuted# 󰒍 " .. table.concat(names, ", ")
end

-- =============================================================================
-- DIAGNOSTIC SEGMENT
-- Icons match diagnostics.lua signs exactly.
-- Shows ✓ when clean; only lists non-zero counts to reduce noise.
-- Severity order mirrors severity_sort = true in diagnostics.lua.
-- =============================================================================
local diag_order = {
	{ vim.diagnostic.severity.ERROR, "StatusError", " " },
	{ vim.diagnostic.severity.WARN, "StatusWarn", " " },
	{ vim.diagnostic.severity.HINT, "StatusHint", " " },
	{ vim.diagnostic.severity.INFO, "StatusInfo", "󱛉 " },
}

local function diag_segment()
	local count = vim.diagnostic.count(0)
	local parts = {}
	local reset = "%#StatusLine#"

	for _, entry in ipairs(diag_order) do
		local sev, grp, icon = entry[1], entry[2], entry[3]
		local n = count[sev] or 0
		if n > 0 then
			table.insert(parts, "%#" .. grp .. "#" .. icon .. n .. reset)
		end
	end

	return #parts > 0 and table.concat(parts, "  ") or "%#StatusHint#✓"
end

-- =============================================================================
-- MAIN STATUSLINE
-- Called on every redraw via %!v:lua.Statusline().
-- table.concat avoids repeated string allocation from .. chaining.
-- =============================================================================
function Statusline()
	local m = modes[vim.fn.mode()] or { vim.fn.mode(), "StatusNormal" }
	local reset = "%#StatusLine#"
	local muted = "%#StatusMuted#"
	local sep = muted .. "  │  " .. reset

	local ft = vim.bo.filetype
	local icon = ft_icons[ft] or ""
	local ft_str = icon ~= "" and (icon .. ft) or (ft ~= "" and ft or "—")
	local branch = vim.g._git_branch or ""

	return table.concat({
		" ",
		"%#" .. m[2] .. "#" .. m[1] .. reset, -- coloured mode name
		sep,
		"%f %m", -- filepath + [+] modified
		branch ~= "" and (muted .. branch .. reset) or "", -- git branch if in a repo
		"%=", -- right-align from here
		diag_segment() .. reset,
		lsp_segment() .. reset,
		sep,
		muted .. ft_str,
		sep,
		muted .. "%l:%c ",
	})
end

vim.opt.statusline = "%!v:lua.Statusline()"
