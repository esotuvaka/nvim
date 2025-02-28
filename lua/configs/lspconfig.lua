-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"

-- EXAMPLE
local servers = { "html", "cssls", "ruff" }
local nvlsp = require "nvchad.configs.lspconfig"

-- lsps with default config
for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup {
        on_attach = nvlsp.on_attach,
        on_init = nvlsp.on_init,
        capabilities = nvlsp.capabilities,
    }
end

-- configuring single server, example: typescript
lspconfig.ts_ls.setup {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
}

-- Rust
lspconfig.rust_analyzer.setup {
    -- Server-specific settings. See `:help lspconfig-setup`
    settings = {
        ["rust-analyzer"] = {
            cargo = {
                allFeatures = true,
            },
            imports = {
                group = {
                    enable = false,
                },
            },
            completion = {
                postfix = {
                    enable = false,
                },
            },
        },
    },
}

-- Bash LSP
-- lspconfig.bash_language_server.setup = {
--     cmd = { "bash-language-server", "start" },
--     filetypes = { "sh" },
--     root_dir = require("lspconfig").util.find_git_ancestor,
--     init_options = {
--         settings = {
--             args = {},
--         },
--     },
-- }

-- Pyright for Python
lspconfig.pyright.setup = {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
}

-- Ruff for Python
lspconfig.ruff.setup = {
    cmd = { "ruff" },
    filetypes = { "python" },
    root_dir = require("lspconfig").util.find_git_ancestor,
    init_options = {
        settings = {
            -- args = {},
            logLevel = "debug",
        },
    },
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
}
