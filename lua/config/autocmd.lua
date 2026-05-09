-- The Setting bwlow disable recursive/persistent commenting
---[[
vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",  -- applies to all file types
    callback = function()
        -- Remove the two flags responsible for auto-continuing comments
        vim.opt_local.formatoptions:remove({ "r", "o" })
    end
})
--]]
