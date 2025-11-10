-- This file contains the configuration for the opencode.nvim plugin.

return {
  "sudo-tee/opencode.nvim",
  enabled = false,
  config = function() 
    -- full config from history
  end,
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "MeanderingProgrammer/render-markdown.nvim", opts = {}, ft = { "markdown", "Avante", "copilot-chat", "opencode_output" } },
  },
}
