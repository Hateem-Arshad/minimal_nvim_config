-- =============================================================================
-- LSP UI & BEHAVIOUR
-- =============================================================================

-- 5. COMPLETION KIND ICONS
-- Maps LSP CompletionItemKind names to Nerd Font icons.
-- Used by the convert() function inside LspAttach to decorate pumenu entries.
-- Requires a Nerd Font patched terminal font (e.g. JetBrainsMono Nerd Font).
-- "Class" is intentionally absent — remapped to "Table" for SQL readability.
--
-- BLINK REPLACES THIS ENTIRE BLOCK —————————————————————————————————————————
-- blink.cmp has its own icon/kind system in its setup(). If switching,
-- comment out the kinds table below and the vim.lsp.completion.enable()
-- call inside LspAttach. Toggle: change ---[[ to --[[ to disable.
---[[
local kinds = {
    Text = "󰉿",
    Method = "󰆧",
    Function = "󰊕",
    Constructor = "󰒓",
    Field = "󰜢",
    Variable = "󰀫",
    Class = "󰠱",
    Interface = "󰌗",
    Module = "󰏗",
    Property = "󰖷",
    Unit = "󰑭",
    Value = "󰎟",
    Enum = "󰕘",
    Keyword = "󰌋",
    Snippet = "󰩫",
    Color = "󰏘",
    File = "󰈙",
    Reference = "󰈇",
    Folder = "󰉋",
    EnumMember = "󰕘",
    Constant = "󰏿",
    Struct = "󰙅",
    Event = "󰉁",
    Operator = "󰆕",
    TypeParameter = "󰅲",
}
--]]

-- 6. ON-ATTACH BEHAVIOUR
-- Fires every time an LSP server attaches to a buffer.
-- Sets up per-buffer completion, inlay hints, codelens, and signature help.
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)

        -- Format on save
        ---[[
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = args.buf,
            callback = function()
                local file_type = vim.bo[args.buf].filetype
                if file_type == "sql" then
                    return
                end
                vim.lsp.buf.format({ async = false, bufnr = args.buf })
            end,
        })
        --]]

        -- Manual format keymap
        vim.keymap.set("n", "<leader>f", function()
            local file_type = vim.bo[args.buf].filetype
            if file_type == "sql" then
                return
            end
            vim.lsp.buf.format({ async = true, bufnr = args.buf })
        end, { buffer = args.buf, desc = "Format buffer" })

        -- Native LSP completion with icon-decorated kind labels.
        -- autotrigger = false: completion is driven by the InsertCharPre autocmd
        -- below instead, giving us control over when it fires (e.g. skip on
        -- signature trigger chars like ( and ,).
        -- convert(): decorates each item with a Nerd Font icon and kind label.
        -- "Class" → "Table" remap makes SQL server completions read naturally.
        --
        -- Toggle: ---[[ to --[[
        ---[[
        vim.lsp.completion.enable(true, args.data.client_id, args.buf, {
            autotrigger = false,
            convert = function(item)
                local kind_idx = item.kind or 1
                local kind_name = vim.lsp.protocol.CompletionItemKind[kind_idx] or "Text"
                local icon = kinds[kind_name] or ""
                return {
                    abbr = string.format("%s %s", icon, item.label:gsub("%b()", "")),
                    kind = string.format("[%s]", kind_name == "Class" and "Table" or kind_name),
                    menu = "[LSP]",
                }
            end,
        })
        --]]

        -- Inlay hints: shows parameter names and inferred types inline.
        -- Only enabled if the attached server declares support for it.
        if client and client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
        end

        -- CodeLens: shows actionable annotations above functions (e.g. run, debug).
        -- Server support varies — lua_ls and clangd support it, sqls does not.
        if client and client.server_capabilities.codeLensProvider then
            vim.lsp.codelens.enable(true, { bufnr = args.buf })
        end
        -- 8. SIGNATURE HELP
        -- Auto-triggers the signature float when the server's declared trigger
        -- characters are typed (typically "(" and ","). Falls back gracefully
        -- when the server does not advertise signatureHelpProvider.
        -- <C-k> provides a manual trigger for re-opening it mid-argument.
        if client and client.server_capabilities.signatureHelpProvider then
            local triggers = client.server_capabilities.signatureHelpProvider.triggerCharacters or {}

            vim.api.nvim_create_autocmd("InsertCharPre", {
                buffer = args.buf,
                callback = function()
                    if vim.tbl_contains(triggers, vim.v.char) then
                        vim.schedule(vim.lsp.buf.signature_help)
                    end
                end,
            })

            vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, {
                buffer = args.buf,
                desc = "Signature help",
            })
        end
    end,
})

-- 7. OMNICOMPLETION TRIGGER (InsertCharPre)
-- Fires <C-x><C-o> on every keystroke while in insert mode, driving the
-- completion popup. autotrigger = false in completion.enable() above means
-- this is the sole trigger mechanism.
--
-- Guards:
--   lsp_continuous      → managed by InsertEnter/InsertLeave; prevents firing
--                         before the first insert session or after leaving it.
--   pumvisible()        → skips re-triggering when the menu is already open.
--   state("m")          → skips during macro playback.
--   signature chars     → skips on ( , ) to avoid competing with signature
--                         help which fires its own float on those characters.

vim.api.nvim_create_autocmd("InsertCharPre", {
    callback = function()
        if not vim.g.lsp_continuous then
            return
        end
        -- Only fire in buffers that actually have an LSP client
        if #vim.lsp.get_clients({ bufnr = 0 }) == 0 then
            return
        end

        if vim.fn.pumvisible() == 1 or vim.fn.state("m") == "m" then
            return
        end

        -- Don't compete with signature help on trigger characters
        local char = vim.v.char
        if char == "(" or char == "," or char == ")" then
            return
        end

        local key = vim.keycode("<C-x><C-o>")
        vim.api.nvim_feedkeys(key, "n", false)
    end,
})

-- lsp_continuous is intentionally not initialized at module load.
-- It becomes true on the first InsertEnter and resets on InsertLeave,
-- so completion only fires during active insert sessions.
---[[
vim.api.nvim_create_autocmd("InsertEnter", {
    callback = function()
        vim.g.lsp_continuous = true
    end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
    callback = function()
        vim.g.lsp_continuous = false
    end,
})
--]]
--[[
vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		vim.cmd("lcd " .. vim.fn.expand("%:p:h"))
	end,
})
--]]

-- 9. COMPLETION POPUP OPTIONS
-- completeopt flags:
--   "menuone"  → show the menu even when there is only one match
--   "noselect" → do not auto-select the first item (manual selection)
--   "popup"    → show documentation in a floating popup (respects winborder)
--   "fuzzy"    → fuzzy match candidates against what you have typed
-- pumheight: caps the popup menu at 25 visible items before scrolling.
-- pumblend:  applies subtle transparency to the popup (0 = opaque, 100 = invisible).
--
-- Toggle: ---[[ to --[[ to disable.
---[[
vim.opt.completeopt = { "menuone", "noselect", "popup", "fuzzy" }
vim.opt.pumheight = 25
vim.opt.pumblend = 30
--]]
