return require("telescope").register_extension({
	exports = {
		kanban = require("telescope.kanban").kanban,
	},
})
