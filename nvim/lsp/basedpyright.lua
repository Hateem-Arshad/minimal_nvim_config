return {
	settings = {
		basedpyright = {
			analysis = {
				typeCheckingMode = "standard",
				autoImportCompletions = true,
				enableCodeLens = true,
			},
		},
		python = {
			inlayHints = {
				variableTypes = true,
				callArgumentNames = true,
				functionReturnTypes = true,
				genericTypes = true,
			},
		},
	},
}
