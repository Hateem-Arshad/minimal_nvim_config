function Statusline()
    local modes = {
        n = "NORMAL",
        i = "INSERT",
        v = "VISUAL",
        V = "V-LINE",
        c = "COMMAND",
        R = "REPLACE",
        t = "TERMINAL"
    }
    local mode = modes[vim.fn.mode()] or vim.fn.mode()
    local count = vim.diagnostic.count(0)
    local error = count[1] or 0
    local warning = count[2] or 0
    local hint = count[3] or 0
    local info = count[4] or 0


    return " "..mode.." | %f %m ".."%=".." E: "..error.." W: "..warning.." H: "..hint.." I: "..info.." | %l:%c"
end


vim.opt.statusline = "%!v:lua.Statusline()"
