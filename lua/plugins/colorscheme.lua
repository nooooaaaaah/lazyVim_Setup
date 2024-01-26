return {
	{ "savq/melange-nvim" },
	{
		"LazyVim/LazyVim",
		opts = {
			termguicolors = true,
		},
	},
	require("notify").setup({
		background_colour = "#000000",
	}),
}
