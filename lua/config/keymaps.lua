-- This file contains custom key mappings for Neovim.

-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Map Ctrl+c to escape from other modes
vim.keymap.set({ "i", "n", "v" }, "<C-c>", [[<C-\><C-n>]])

-- Screen Keys
vim.keymap.set({ "n" }, "<leader>uk", "<cmd>Screenkey<CR>")

----- Tmux Navigation ------
local ok, nvim_tmux_nav = pcall(require, "nvim-tmux-navigation")

if ok then
  vim.keymap.set("n", "<C-h>", nvim_tmux_nav.NvimTmuxNavigateLeft)        -- Navigate to the left pane
  vim.keymap.set("n", "<C-j>", nvim_tmux_nav.NvimTmuxNavigateDown)        -- Navigate to the bottom pane
  vim.keymap.set("n", "<C-k>", nvim_tmux_nav.NvimTmuxNavigateUp)          -- Navigate to the top pane
  vim.keymap.set("n", "<C-l>", nvim_tmux_nav.NvimTmuxNavigateRight)       -- Navigate to the right pane
  vim.keymap.set("n", "<C-\\>", nvim_tmux_nav.NvimTmuxNavigateLastActive) -- Navigate to the last active pane
  vim.keymap.set("n", "<C-Space>", nvim_tmux_nav.NvimTmuxNavigateNext)    -- Navigate to the next pane
end

----- OBSIDIAN -----
vim.keymap.set("n", "<leader>oc", "<cmd>ObsidianCheck<CR>", { desc = "Obsidian Check Checkbox" })
vim.keymap.set("n", "<leader>ot", "<cmd>ObsidianTemplate<CR>", { desc = "Insert Obsidian Template" })
vim.keymap.set("n", "<leader>oo", "<cmd>Obsidian Open<CR>", { desc = "Open in Obsidian App" })
vim.keymap.set("n", "<leader>ob", "<cmd>ObsidianBacklinks<CR>", { desc = "Show ObsidianBacklinks" })
vim.keymap.set("n", "<leader>ol", "<cmd>ObsidianLinks<CR>", { desc = "Show ObsidianLinks" })
vim.keymap.set("n", "<leader>on", "<cmd>ObsidianNew<CR>", { desc = "Create New Note" })
vim.keymap.set("n", "<leader>os", "<cmd>ObsidianSearch<CR>", { desc = "Search Obsidian" })
vim.keymap.set("n", "<leader>oq", "<cmd>ObsidianQuickSwitch<CR>", { desc = "Quick Switch" })

----- OIL -----
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>-", function()
  local oil = require("oil")
  local current_buf = vim.api.nvim_get_current_buf()
  local current_file = vim.api.nvim_buf_get_name(current_buf)

  if current_file and current_file ~= "" then
    local dir = vim.fn.fnamemodify(current_file, ":h")
    oil.open(dir)
  else
    oil.open()
  end
end, { desc = "Open Oil in current file's directory" })
vim.keymap.set("n", "<leader>fo", "<CMD>Oil<CR>", { desc = "Open Oil file explorer" })
vim.keymap.set("n", "<leader>E", "<CMD>Oil --float<CR>", { desc = "Open Oil (floating)" })

-- Delete all buffers but the current one
vim.keymap.set(
  "n",
  "<leader>bq",
  '<Esc>:%bdelete|edit #|normal`"<Return>',
  { desc = "Delete other buffers but the current one" }
)

-- Disable unwanted key mappings
vim.keymap.set({ "i", "n", "x" }, "<A-j>", "<Nop>", { silent = true })
vim.keymap.set({ "i", "n", "x" }, "<A-k>", "<Nop>", { silent = true })
vim.keymap.set("x", "J", "<Nop>", { silent = true })
vim.keymap.set("x", "K", "<Nop>", { silent = true })

-- Simplified save with notification
vim.keymap.set("n", "<C-s>", function()
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname == "" then
    vim.ui.input({ prompt = "Nombre del archivo: " }, function(filename)
      if filename and filename ~= "" then
        vim.cmd("write " .. filename)
        vim.notify("💾 Guardado como: " .. filename, vim.log.levels.INFO)
      end
    end)
    return
  end
  vim.cmd("write")
  vim.notify("💾 Guardado!", vim.log.levels.INFO)
end, { desc = "Save file" })

-- Save from insert mode (escape first, then save)
vim.keymap.set("i", "<C-s>", function()
  vim.cmd("stopinsert")
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname == "" then
    vim.ui.input({ prompt = "Nombre del archivo: " }, function(filename)
      if filename and filename ~= "" then
        vim.cmd("write " .. filename)
        vim.notify("💾 Guardado como: " .. filename, vim.log.levels.INFO)
      end
    end)
    return
  end
  vim.cmd("write")
  vim.notify("💾 Guardado!", vim.log.levels.INFO)
end, { desc = "Save file" })

-- Quit buffer with Ctrl+q
vim.keymap.set("n", "<C-q>", "<cmd>quit<CR>", { desc = "Quit buffer" })
vim.keymap.set("i", "<C-q>", "<cmd>quit<CR>", { desc = "Quit buffer" })

-- Helper function for visual grep
local function visual_grep(opts)
  opts = opts or {}
  -- Get the selected text
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.fn.getline(start_pos[2], end_pos[2])

  if #lines == 0 then
    return
  end

  -- Handle single line selection
  if #lines == 1 then
    lines[1] = string.sub(lines[1], start_pos[3], end_pos[3])
  else
    -- Handle multi-line selection
    lines[1] = string.sub(lines[1], start_pos[3])
    lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
  end

  local selected_text = table.concat(lines, "\n")

  -- Escape special characters for grep
  selected_text = vim.fn.escape(selected_text, "\\.*[]^$()+?{}")

  local grep_opts = { search = selected_text, cwd = opts.cwd }

  -- Use the selected text for grep
  local ok_snacks, snacks = pcall(require, "snacks")
  if ok_snacks then
    snacks.picker.grep(grep_opts)
    return
  end

  local ok_fzf, fzf = pcall(require, "fzf-lua")
  if ok_fzf then
    fzf.live_grep(grep_opts)
    return
  end

  vim.notify("No grep picker available", vim.log.levels.ERROR)
end

-- Grep keybinding for visual mode - search selected text
vim.keymap.set("v", "<leader>sg", function()
  visual_grep()
end, { desc = "Grep Selected Text" })

-- Grep keybinding for visual mode with G - search selected text at root level
vim.keymap.set("v", "<leader>sG", function()
  -- Get git root or fallback to cwd
  local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
  local root = vim.v.shell_error == 0 and git_root ~= "" and git_root or vim.fn.getcwd()
  visual_grep({ cwd = root })
end, { desc = "Grep Selected Text (Root Dir)" })

-- Delete all marks
vim.keymap.set("n", "<leader>md", function()
  vim.cmd("delmarks!")
  vim.cmd("delmarks A-Z0-9")
  vim.notify("All marks deleted")
end, { desc = "Delete all marks" })

-- Colorscheme toggle
local colorschemes = { "gentleman-kanagawa-blur", "catppuccin", "oldworld", "kanagawa" }
local current_colorscheme_index = 1

local function toggle_colorscheme()
  -- Find the current colorscheme in the list
  for i, name in ipairs(colorschemes) do
    if vim.g.colors_name == name then
      current_colorscheme_index = i
      break
    end
  end

  -- Increment and wrap around the index
  current_colorscheme_index = (current_colorscheme_index % #colorschemes) + 1
  local next_colorscheme = colorschemes[current_colorscheme_index]

  -- Set the new colorscheme
  vim.cmd("colorscheme " .. next_colorscheme)
  vim.notify("🎨 Tema cambiado a: " .. next_colorscheme, vim.log.levels.INFO)
end

vim.keymap.set("n", "<leader>uc", toggle_colorscheme, { desc = "Cycle to next colorscheme" })

-- Reload configuration
vim.keymap.set("n", "<leader>ur", function()
  vim.cmd("source $MYVIMRC")
  vim.notify("🔄 Configuración recargada!", vim.log.levels.INFO)
end, { desc = "Reload Neovim configuration" })

-- Quick fix toggle
local qf_open = false
vim.keymap.set("n", "<leader>xq", function()
  if qf_open then
    vim.cmd("cclose")
    qf_open = false
  else
    vim.cmd("copen")
    qf_open = true
  end
end, { desc = "Toggle Quickfix list" })

-- Format keymaps
vim.keymap.set("n", "<leader>cf", function()
  vim.cmd("FormatInfo")
end, { desc = "Show format info" })

vim.keymap.set("n", "<leader>cF", function()
  vim.cmd("Format")
end, { desc = "Format buffer manually" })

vim.keymap.set("n", "<leader>uF", function()
  vim.cmd("FormatToggle")
end, { desc = "Toggle format on save" })

-- Performance keymaps
vim.keymap.set("n", "<leader>up", function()
  vim.cmd("Lazy profile")
end, { desc = "Lazy profile" })

vim.keymap.set("n", "<leader>us", function()
  vim.cmd("StartupTime")
end, { desc = "Measure startup time" })
