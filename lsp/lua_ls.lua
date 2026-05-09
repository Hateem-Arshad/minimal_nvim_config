-- lsp/lua_ls.lua
return {
    settings = {
        Lua = {
            diagnostics = { globals = { 'vim' } },
        },
    },
}
