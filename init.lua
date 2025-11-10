-- Performance optimizations (load first)
require("config.performance").setup()

-- Configure Node.js before loading plugins
require("config.nodejs").setup({ silent = true })

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
