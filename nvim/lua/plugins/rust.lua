vim.pack.add({
	{ src = "https://github.com/rust-lang/rust.vim" },
})

-- Use rust-analyzer for formatting instead of the plugin's own formatter
-- since we already have it via Mason
vim.g.rustfmt_autosave = 1 -- format on save via rustfmt
vim.g.rust_clip_command = "xclip -selection clipboard"
