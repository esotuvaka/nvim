-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"

-- EXAMPLE
local servers = { "html", "cssls" }
local nvlsp = require "nvchad.configs.lspconfig"

-- lsps with default config
for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup {
        on_attach = nvlsp.on_attach,
        on_init = nvlsp.on_init,
        capabilities = nvlsp.capabilities,
    }
end

-- Typescript
lspconfig.ts_ls.setup {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
}

-- Go
lspconfig.gopls.setup {
    on_attach = nvlsp.on_attach,
    capabilities = nvlsp.capabilities,
    root_dir = lspconfig.util.root_pattern(".git", "go.mod"),
    flags = {
        debounce_text_changes = 150,
    },
    settings = {
        gopls = {
            gofumpt = true,
            experimentalPostfixCompletions = true,
            staticcheck = true,
            usePlaceholders = true,
        },
    },
}
if not lspconfig.golangcilsp then
    local configs = require "lspconfig/configs"

    configs.golangcilsp = {
        default_config = {
            cmd = { "golangci-lint-langserver" },
            root_dir = lspconfig.util.root_pattern(".git", "go.mod"),
            init_options = {
                command = { "golangci-lint", "run", "--out-format", "json" },
            },
        },
    }
end
lspconfig.golangcilsp.setup {
    filetypes = { "go" },
}

-- ESLint linter
lspconfig.eslint.setup {
    on_attach = nvlsp.on_attach,
    capabilities = nvlsp.capabilities,
    filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
    },
    settings = {
        -- Use local ESLint config
        eslint = {
            useESLintClass = true,
        },
    },
}

-- Prettier formatter
lspconfig.prettier.setup {
    on_attach = nvlsp.on_attach,
    capabilities = nvlsp.capabilities,
    -- Will use local prettier config
    single_file_support = true,
    settings = {},
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
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
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
    cmd = { vim.fn.expand "~/.venvs/ruff/bin/ruff", "server", "--stdio" },
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
