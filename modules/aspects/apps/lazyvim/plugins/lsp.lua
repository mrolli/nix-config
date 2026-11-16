-- Custom LSP configuration

-- Read a secret decrypted by sops-nix (see modules/aspects/apps/neovim.nix).
-- Returns nil when the secret is missing, e.g. before the first switch.
local function sops_secret(name)
  local file = io.open(vim.fn.expand("~/.config/sops-nix/secrets/" .. name), "r")
  if not file then
    return nil
  end
  local value = vim.trim(file:read("*a"))
  file:close()
  return value ~= "" and value or nil
end

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
          -- Premium license key; falls back to lspconfig's "no license" default.
          init_options = {
            ["0"] = sops_secret("devsense_php_tools/license_code") or "{}",
          },
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
          prepend_args = { "--config", vim.fn.stdpath("config") .. "/.markdownlint.yaml" },
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        ["markdownlint-cli2"] = {
          prepend_args = { "--config", vim.fn.stdpath("config") .. "/.markdownlint.yaml" },
        },
      },
    },
  },
}
