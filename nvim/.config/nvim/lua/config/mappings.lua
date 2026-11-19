-- Exit insert mode quickly
vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Clear highlight on pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- Quickly select all
vim.keymap.set("n", "<leader>a", "ggVG", { desc = "Select all text in file" })

-- Keeps selection active after indenting so you can indent multiple times.
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and keep selection" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and keep selection" })

-- Keep search results centered
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result centered" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Prev search result centered" })

-- Paste without overwriting register
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without replacing register" })

-- Quick replace
vim.keymap.set(
	"n",
	"<leader>sr",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "Search & replace word under cursor" }
)

-- Vertical scroll and center
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })

-- Navigate vim panes better
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Focus upper window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Focus lower window" })
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Focus left window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Focus right window" })

-- Resize panes
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize +5<CR>", { remap = true, desc = "Increase vertical size" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize -5<CR>", { remap = true, desc = "Decrease vertical size" })
vim.keymap.set("n", "<C-Up>", "<cmd>horizontal resize +2<CR>", { remap = true, desc = "Increase horizontal size" })
vim.keymap.set("n", "<C-Down>", "<cmd>horizontal resize -2<CR>", { remap = true, desc = "Decrease horizontal size" })

-- File tree toggle
vim.keymap.set("n", "<C-n>", "<cmd>Neotree toggle<CR>", { desc = "nvimtree toggle window" })

-- Diagnostics
vim.keymap.set("n", "<leader>k", function()
	vim.diagnostic.config({ virtual_lines = { current_line = true }, virtual_text = false })

	vim.api.nvim_create_autocmd("CursorMoved", {
		group = vim.api.nvim_create_augroup("line-diagnostics", { clear = true }),
		callback = function()
			vim.diagnostic.config({ virtual_lines = false, virtual_text = true })
			return true
		end,
	})
end)

vim.keymap.set("n", "<Leader>e", vim.diagnostic.open_float, { desc = "Show Diagnostic" })
vim.keymap.set("n", "<Leader>q", vim.diagnostic.setloclist, { desc = "Open Diagnostic" })

-- Toggle comment
vim.keymap.set("n", "_", "<Plug>(comment_toggle_linewise_current)", { desc = "Toggle comment" })
vim.keymap.set("x", "_", "<Plug>(comment_toggle_linewise_visual)", { desc = "Toggle comment" })
