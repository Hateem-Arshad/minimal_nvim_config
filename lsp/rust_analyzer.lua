return {
	settings = {
		["rust-analyzer"] = {
			checkOnSave = true,
			check = {
				command = "clippy", -- stricter linting than default check
			},
		},
	},
}
