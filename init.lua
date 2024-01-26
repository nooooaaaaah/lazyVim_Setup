-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

require("plugins.kanban")
-- require("telescope")
-- require("telescope").load_extension("kanban")

vim.cmd("colorscheme melange")
vim.cmd("highlight Normal guibg=NONE")
vim.cmd("highlight NeoTreeNormal guibg=NONE")
vim.cmd("highlight NvimTreeNormal guibg=NONE")

-- set key to toggle kanban
-- vim.api.nvim_set_keymap("n", "<Leader>kb", ":Kanban<CR>", { noremap = true, silent = true })
