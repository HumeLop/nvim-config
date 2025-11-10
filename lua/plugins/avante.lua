-- This file contains the configuration for the avante.nvim plugin.

return {
  {
    "yetone/avante.nvim",
    enabled = false, -- Disabled: conflicts with other AI plugins
    build = function()
      if vim.fn.has("win32") == 1 then
        return "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
      else
        return "make"
      end
    end,
    event = "VeryLazy",
    version = false,
    opts = function(_, opts)
      -- opts for avante
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      { "HakonHarnes/img-clip.nvim", event = "VeryLazy", opts = {} },
    },
  },
}
