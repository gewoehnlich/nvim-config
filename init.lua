vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad", lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },
  { "williamboman/mason.nvim" },
  { "nvimtools/none-ls.nvim" },

  { import = "plugins" },
}, lazy_config)

require("mason").setup()

require("lspconfig").clangd.setup({
  cmd = { "clangd", "--background-index", "--clang-tidy"},
  filetypes = { "c", "cpp", "objc", "objcpp" },
  init_options = {
    clangdFileStatus = true,
    usePlaceholders = true,
    completeUnimported = true,
  },
  root_dir = require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt", ".git"),
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
});

require("lspconfig").pyright.setup({
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "strict",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace"
      }
    }
  }
})

require("nvim-treesitter.configs").setup({
  ensure_installed = { "python" },
  highlight = { enable = true }
})

require("lspconfig").intelephense.setup({
	settings = {
		intelephense = {
			format = {
				braces = "psr12",
				enable = true
			}
		}
	}
})

local none_ls = require("null-ls")
none_ls.setup({
	sources = {
		none_ls.builtins.diagnostics.phpcs.with({
			extra_args = { "--standard=PSR12" }
		})
	}
})

require("nvim-tree").setup({
  filters = {
    dotfiles = false,
    custom = {},
  },
  git = {
    enable = true,
    ignore = false,
  },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "vue" },
  callback = function()
    vim.opt.commentstring = "<!-- %s -->"
  end
})

-- php
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "php" },
  callback = function()
    vim.opt.commentstring = "// %s"
    vim.bo.shiftwidth = 4 
    vim.bo.tabstop = 4 
    vim.bo.softtabstop = 4 
    vim.bo.expandtab = true
    vim.bo.autoindent = true
    vim.bo.smartindent = true
  end
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "Makefile" },
  callback = function()
    vim.bo.shiftwidth = 4 
    vim.bo.tabstop = 4 
    vim.bo.softtabstop = 4 
    vim.bo.expandtab = false
  end
})

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
end)
