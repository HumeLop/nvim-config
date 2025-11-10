-- Performance optimizations for Neovim
-- This file contains various performance tweaks

local M = {}

function M.setup()
  -- Disable some built-in plugins for better performance
  local disabled_built_ins = {
    "gzip",
    "zip",
    "zipPlugin",
    "tar",
    "tarPlugin",
    "getscript",
    "getscriptPlugin",
    "vimball",
    "vimballPlugin",
    "2html_plugin",
    "logipat",
    "rrhelper",
    "spellfile_plugin",
    "matchit",
  }

  for _, plugin in pairs(disabled_built_ins) do
    vim.g["loaded_" .. plugin] = 1
  end

  -- Performance tweaks
  vim.opt.lazyredraw = false -- Don't use lazyredraw, it causes issues with some plugins

  -- Improve file reading performance
  vim.opt.shadafile = "NONE" -- Disable ShaDa during startup for faster loading
  vim.schedule(function()
    vim.opt.shadafile = ""   -- Re-enable after startup
  end)

  -- File size optimizations
  vim.api.nvim_create_autocmd("BufReadPre", {
    callback = function(args)
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(args.buf))
      if ok and stats and stats.size > 100000 then -- 100KB
        vim.notify("Large file detected, disabling some features", vim.log.levels.WARN)
        vim.opt_local.spell = false
        vim.opt_local.swapfile = false
        vim.opt_local.undofile = false
        vim.opt_local.breakindent = false
        vim.opt_local.colorcolumn = ""
        vim.opt_local.statuscolumn = ""
        vim.opt_local.signcolumn = "no"
        vim.opt_local.foldcolumn = "0"
        vim.opt_local.winbar = ""
        -- Disable treesitter for this buffer
        vim.cmd("TSBufDisable highlight")
        vim.cmd("TSBufDisable indent")
      end
    end,
  })
end

return M
