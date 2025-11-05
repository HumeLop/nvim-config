-- This file contains custom key mappings for Neovim.

-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Map Ctrl+b in insert mode to delete to the end of the word without leaving insert mode
vim.keymap.set("i", "<C-b>", "<C-o>de")

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

-- Custom save function
local function SaveFile()
  local filepath = vim.fn.expand("%:p")

  -- Check if the file has a name
  if filepath == "" or filepath == "/dev/null" then
    -- The file has no name, so we prompt the user for one
    vim.ui.input({ prompt = "Save as: " }, function(filename)
      if filename then
        local fullpath = vim.fn.expand(filename)
        local success, err = pcall(function()
          vim.cmd("silent! write " .. fullpath)
        end)

        if success then
          vim.notify(filename .. " Saved!")
        else
          vim.notify("Error: " .. err, vim.log.levels.ERROR)
        end
      else
        vim.notify("Save operation cancelled.", vim.log.levels.INFO)
      end
    end)
  else
    -- The file already has a name, so we just save it
    local filename = vim.fn.expand("%:t")
    local success, err = pcall(function()
      vim.cmd("silent! write")
    end)

    if success then
      vim.notify(filename .. " Saved!")
    else
      vim.notify("Error: " .. err, vim.log.levels.ERROR)
    end
  end
end

-- Redefine Ctrl+s to save with the custom function
vim.keymap.set({ "n", "i" }, "<C-s>", function()
  vim.cmd("stopinsert") -- asegúrate de salir de insert
  SaveFile()
end, { noremap = true, silent = true })

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
