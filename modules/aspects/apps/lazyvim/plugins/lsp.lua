-- Custom LSP configuration
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- automatically lsp configurations
        bashls = {},
        bicep = {},
        marksman = {},
        nixd = {},
        phpactor = false, -- disable if you're using devsense instead
        phptools = {
          settings = {
            php = {
              codelens = {
                enabled = true,
              },
            },
          },
        },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        ["markdownlint-cli2"] = {
          prepend_args = { "--config", vim.env.HOME .. "/.config/nvim/.markdownlint.yaml", "--" },
        },
      },
    },
  },
}
