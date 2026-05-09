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
	local hint = count[vim.diagnostic.severity.INFO] or 0
	local info = count[vim.diagnostic.severity.HINT] or 0

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
