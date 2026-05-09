-- lsp/basedpyright.lua
return {
	settings = {
		basedpyright = {
			analysis = {
				typeCheckingMode = "standard", -- or basic
				autoImportCompletions = true,
				enableCodeLens = true,
			},
			inlayHints = {
				variableTypes = true,
				callArgumentNames = true,
				functionReturnTypes = true,
				genericTypes = true,
			},
		},
	},
}
