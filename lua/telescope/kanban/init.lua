local picker_config = require("telescope.kanban.picker_config")

local kanban = function(opts)
	picker_config.kanban_picker(opts):find()
end

return {
	kanban = kanban,
}
