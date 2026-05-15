local ok, blink = pcall(require, "blink.cmp")
if not ok then
	return
end

blink.setup({
	keymap = { preset = "default" }, -- <C-space> trigger, <C-y> confirm, <C-e> cancel

	appearance = {
		nerd_font_variant = "mono", -- matches JetBrainsMono Nerd Font Mono
	},

	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
	},

	completion = {
		menu = {
			border = "rounded",
		},
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 100,
			window = {
				border = "rounded",
			},
		},
	},

	signature = {
		enabled = true,
		window = {
			border = "rounded",
		},
	},
})
