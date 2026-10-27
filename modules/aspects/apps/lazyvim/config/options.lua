-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- no automatic system clipboard usage
-- see also keybindings regarding yanking
-- vim.opt.clipboard = ""

-- turn off formatting on save
-- vim.g.autoformat = false

-- set spellcheck languages to English and Swiss German
vim.o.spelllang = "en,de_ch"

-- word lists for zg (English) and 2zg (German); Nix links them to the repository
vim.opt.spellfile = {
  vim.fn.stdpath("config") .. "/spell/en.utf-8.add",
  vim.fn.stdpath("config") .. "/spell/de.utf-8.add",
}

-- add support for bicep and bicepparam files
vim.filetype.add({
  extension = {
    bicep = "bicep",
    bicepparam = "bicep-params",
  },
})
