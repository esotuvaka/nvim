return {
    {
        "stevearc/conform.nvim",
        event = "BufWritePre", -- uncomment for format on save
        opts = require "configs.conform",
    },

    {
        "williamboman/mason.nvim",
        opts = {
            ensure_installed = {
                "rust-analyzer",
                "ruff",
                "pyright",
                "ts_ls",
            },
        },
    },
    {
        "williamboman/mason-lspconfig.nvim",
        lazy = false,
        opts = {
            auto_install = true,
        },
    },

    -- -- These are some examples, uncomment them if you want to see them work!
    {
        "hrsh7th/cmp-nvim-lsp",
    },

    {
        "neovim/nvim-lspconfig",
        lazy = false,
        config = function()
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            local lspconfig = require "lspconfig"

            lspconfig.ruff.setup {
                capabilities = capabilities,
            }
            lspconfig.pyright.setup {
                capabilities = capabilities,
            }
            lspconfig.rust_analyzer.setup {
                capabilities = capabilities,
            }
            lspconfig.ts_ls.setup {
                capabilities = capabilities,
            }
            lspconfig.lua_ls.setup {
                capabilities = capabilities,
            }

            vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
            vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
            vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = {
                "vim",
                "lua",
                "vimdoc",
                "html",
                "css",
                "markdown",
                "markdown_inline",
                "bash",
                "rust",
                "go",
                "python",
                "typescript",
                "javascript",
                "java",
            },
        },
    },

    -- nice bar at the bottom
    {
        "itchyny/lightline.vim",
        lazy = false, -- also load at start since it's UI
        config = function()
            -- no need to also show mode in cmd line when we have bar
            vim.o.showmode = false
            vim.g.lightline = {
                active = {
                    left = {
                        { "mode", "paste" },
                        { "readonly", "filename", "modified" },
                    },
                    right = {
                        { "lineinfo" },
                        { "percent" },
                        { "fileencoding", "filetype" },
                    },
                },
                component_function = {
                    filename = "LightlineFilename",
                },
            }
            function LightlineFilenameInLua(opts)
                if vim.fn.expand "%:t" == "" then
                    return "[No Name]"
                else
                    return vim.fn.getreg "%"
                end
            end
            -- https://github.com/itchyny/lightline.vim/issues/657
            vim.api.nvim_exec(
                [[
				function! g:LightlineFilename()
					return v:lua.LightlineFilenameInLua()
				endfunction
				]],
                true
            )
        end,
    },
    -- better %
    {
        "andymass/vim-matchup",
        config = function()
            vim.g.matchup_matchparen_offscreen = { method = "popup" }
        end,
    },
    -- auto-cd to root of git project
    -- 'airblade/vim-rooter'
    {
        "notjedi/nvim-rooter.lua",
        config = function()
            require("nvim-rooter").setup()
        end,
    },
    -- LSP-based code-completion
    {
        "hrsh7th/nvim-cmp",
        config = function()
            local cmp = require "cmp"
            require("luasnip.loaders.from_vscode").lazy_load()

            cmp.setup {
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert {
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm { select = true },
                },
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "vsnip" },
                }, {
                    { name = "buffer" },
                }),
            }
        end,
    },
    -- inline function signatures
    {
        "ray-x/lsp_signature.nvim",
        event = "VeryLazy",
        opts = {},
        config = function(_, opts)
            -- Get signatures (and _only_ signatures) when in argument lists.
            require("lsp_signature").setup {
                doc_lines = 0,
                handler_opts = {
                    border = "none",
                },
            }
        end,
    },
    -- language support
    -- terraform
    {
        "hashivim/vim-terraform",
        ft = { "terraform" },
    },
    -- svelte
    {
        "evanleck/vim-svelte",
        ft = { "svelte" },
    },
    -- toml
    "cespare/vim-toml",
    -- yaml
    {
        "cuducos/yaml.nvim",
        ft = { "yaml" },
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
    },
    -- rust
    {
        "rust-lang/rust.vim",
        ft = { "rust" },
        config = function()
            vim.g.rustfmt_autosave = 1
            vim.g.rustfmt_emit_files = 1
            vim.g.rustfmt_fail_silently = 0
            vim.g.rust_clip_command = "wl-copy"
        end,
    },
    -- fish
    "khaveesh/vim-fish-syntax",
    -- markdown
    {
        "plasticboy/vim-markdown",
        ft = { "markdown" },
        dependencies = {
            "godlygeek/tabular",
        },
        config = function()
            -- never ever fold!
            vim.g.vim_markdown_folding_disabled = 1
            -- support front-matter in .md files
            vim.g.vim_markdown_frontmatter = 1
            -- 'o' on a list item should insert at same level
            vim.g.vim_markdown_new_list_item_indent = 0
            -- don't add bullets when wrapping:
            -- https://github.com/preservim/vim-markdown/issues/232
            vim.g.vim_markdown_auto_insert_bullets = 0
        end,
    },
}
