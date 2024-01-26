local Popup = require("plenary.popup")

local Kanban = {
	win_id = nil,
	buf_id = nil,
	board_width = 100,
	board_height = 40,
	columns = { "To Do", "In Progress", "Done" },
}

function Kanban.decode_and_print_json(file_path)
	local expanded_path = file_path:gsub("^~", os.getenv("HOME"))
	local file, err = io.open(expanded_path, "r")
	if not file then
		error("Error opening file: " .. err)
		return nil
	end

	local content = file:read("*a")
	file:close()

	local success, data = pcall(vim.json.decode, content)
	if not success then
		error("JSON decoding error: " .. data)
	end
	return data
end

function Kanban.create_popup(board_width, board_height)
	local col = math.ceil((vim.o.columns - board_width) / 2)
	local row = math.ceil((vim.o.lines - board_height) / 2 - 1)

	local opts = {
		border = true,
		title = "Kanban Board",
		highlight = "Normal",
		line = row,
		col = col,
		minwidth = board_width,
		minheight = board_height,
		borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
	}

	Kanban.win_id = Popup.create("", opts)
	Kanban.buf_id = vim.api.nvim_win_get_buf(Kanban.win_id)
end

function Kanban.draw_columns(board_width, kanban_data)
	local column_width = math.floor(board_width / #kanban_data.cols)
	local lines = {} -- Initialize the lines table

	-- Function to add a line with proper padding
	local function add_line(text, padding)
		padding = padding or column_width
		return text .. string.rep(" ", padding - #text)
	end

	-- Draw headers
	local header_line = ""
	for _, col in ipairs(kanban_data.cols) do
		local header = col.title
		local header_padding = math.floor((column_width - #header) / 2)
		header_line = header_line .. add_line(header, column_width - header_padding)
	end
	table.insert(lines, header_line)

	-- Initialize the task lines for each column
	local task_lines = {}
	for _ = 1, #kanban_data.cols do
		table.insert(task_lines, {})
	end

	-- Fill task lines for each column
	for col_index, col in ipairs(kanban_data.cols) do
		for task_index, task in ipairs(col.tasks or {}) do
			local wrapped_text = Kanban.wrap_text(task.text, column_width)
			for line_index, text in ipairs(wrapped_text) do
				task_lines[col_index][task_index + line_index - 1] = add_line(text)
			end
		end
	end

	-- Add task lines to main lines table, ensuring each column is aligned
	for i = 1, 10 do -- Adjust the 10 to the maximum number of lines you want to handle
		local line = ""
		for col_index = 1, #kanban_data.cols do
			line = line .. (task_lines[col_index][i] or add_line(""))
		end
		table.insert(lines, line)
	end

	return lines
end

function Kanban.wrap_text(text, column_width)
	local lines = {}
	local line = ""
	for word in text:gmatch("%S+") do
		if #line + #word + 1 > column_width then
			table.insert(lines, line)
			line = string.rep(" ", 4) .. word
		else
			line = (#line > 0) and (line .. " " .. word) or word
		end
	end
	if #line > 0 then
		table.insert(lines, line)
	end
	return lines
end

function Kanban.setup_buffer(lines)
	if not Kanban.win_id or not vim.api.nvim_win_is_valid(Kanban.win_id) then
		print("Error: Invalid window ID.")
		return
	end

	vim.api.nvim_buf_set_option(Kanban.buf_id, "modifiable", true)
	vim.api.nvim_buf_set_lines(Kanban.buf_id, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(Kanban.buf_id, "modifiable", false)
end

function Kanban.create_board()
	Kanban.create_popup(Kanban.board_width, Kanban.board_height)
	local kanban_data = Kanban.decode_and_print_json("~/Projects/tools/Kanban/kanban.json")
	local lines = Kanban.draw_columns(Kanban.board_width, kanban_data) -- Pass the parsed JSON data
	Kanban.setup_buffer(lines)
end

function Kanban.update_dimensions()
	Kanban.board_width = math.floor(vim.o.columns * 0.8)
	Kanban.board_height = math.floor(vim.o.lines * 0.8)
end

function Kanban.toggle_board()
	if Kanban.win_id and vim.api.nvim_win_is_valid(Kanban.win_id) then
		vim.api.nvim_win_close(Kanban.win_id, true)
		Kanban.win_id = nil
		Kanban.buf_id = nil
	else
		Kanban.update_dimensions()
		Kanban.create_board()
	end
end

function Kanban.setup()
	vim.api.nvim_create_user_command("Kanban", Kanban.toggle_board, {})
	-- vim.api.nvim_set_keymap("n", "<leader>kb", ":Kanban<CR>", { noremap = true, silent = true })

	vim.cmd([[
    augroup Kanban
      autocmd!
      autocmd VimResized * lua require("plugins.kanban").update_dimensions()
    augroup end
  ]])
end

return {
	dir = "kanban",
	config = function()
		Kanban.setup()
	end,
}
