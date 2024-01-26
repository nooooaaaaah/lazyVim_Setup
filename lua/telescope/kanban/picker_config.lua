-- picker_config.lua
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local tasks = require("telescope.kanban.tasks")

local M = {}

M.kanban_picker = function(opts)
	opts = opts or {}

	local entry_maker = function(entry)
		local display_str = entry[1] .. ": " .. table.concat(entry[2], ", ")
		local ordinal_str = entry[1] -- or some other string representation
		return {
			value = entry,
			display = display_str,
			ordinal = ordinal_str,
		}
	end

	return pickers.new(opts, {
		prompt_title = "Kanban Board",
		finder = finders.new_table({
			results = {
				{ "ToDo", tasks.todo },
				{ "Doing", tasks.doing },
				{ "Done", tasks.done },
			},
			entry_maker = entry_maker,
		}),
		sorter = conf.generic_sorter(opts),
	})
end

return M
