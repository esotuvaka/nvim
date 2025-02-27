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
            },
        },
    },

    -- -- These are some examples, uncomment them if you want to see them work!
    {
        "neovim/nvim-lspconfig",
        config = function()
            require "configs.lspconfig"
        end,
    },

    -- {
    --     "rust-lang/rust.vim",
    --     ft = "rust",
    --     init = function()
    --         vim.g.rustfmt_autosave = 1
    --         vim.g.rustfmt_emit_files = 1
    --         vim.g.rustfmt_fail_silently = 0
    --         vim.g.rust_clip_command = "wl-copy"
    --     end,
    -- },
    --
    -- {
    --     "simrat39/rust-tools.vim",
    --     ft = "rust",
    --     dependencies = "neovim/nvim-lspconfig",
    --     opts = function()
    --         return require "configs.rust-tools"
    --     end,
    --     config = function(_, opts)
    --         require("rust-tools").setup(opts)
    --     end,
    -- },

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

    -- main color scheme
    {
        "wincent/base16-nvim",
        lazy = false, -- load at start
        priority = 1000, -- load first
        config = function()
            vim.cmd [[colorscheme gruvbox-dark-hard]]
            -- XXX: hi Normal ctermbg=NONE
            -- Make comments more prominent -- they are important.
            local bools = vim.api.nvim_get_hl(0, { name = "Boolean" })
            vim.api.nvim_set_hl(0, "Comment", bools)
            -- Make it clearly visible which argument we're at.
            local marked = vim.api.nvim_get_hl(0, { name = "PMenu" })
            vim.api.nvim_set_hl(
                0,
                "LspSignatureActiveParameter",
                { fg = marked.fg, bg = marked.bg, ctermfg = marked.ctermfg, ctermbg = marked.ctermbg, bold = true }
            )
            -- XXX
            -- Would be nice to customize the highlighting of warnings and the like to make
            -- them less glaring. But alas
            -- https://github.com/nvim-lua/lsp_extensions.nvim/issues/21
            -- call Base16hi("CocHintSign", g:base16_gui03, "", g:base16_cterm03, "", "", "")
        end,
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
    -- quick navigation
    {
        "ggandor/leap.nvim",
        config = function()
            require("leap").create_default_mappings()
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
    -- LSP
    {
        "neovim/nvim-lspconfig",
        config = function()
            -- Setup language servers.
            local lspconfig = require "lspconfig"

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
            local configs = require "lspconfig.configs"
            if not configs.bash_lsp and vim.fn.executable "bash-language-server" == 1 then
                configs.bash_lsp = {
                    default_config = {
                        cmd = { "bash-language-server", "start" },
                        filetypes = { "sh" },
                        root_dir = require("lspconfig").util.find_git_ancestor,
                        init_options = {
                            settings = {
                                args = {},
                            },
                        },
                    },
                }
            end
            if configs.bash_lsp then
                lspconfig.bash_lsp.setup {}
            end

            -- Ruff for Python
            local configs = require "lspconfig.configs"
            if not configs.ruff_lsp and vim.fn.executable "ruff-lsp" == 1 then
                configs.ruff_lsp = {
                    default_config = {
                        cmd = { "ruff-lsp" },
                        filetypes = { "python" },
                        root_dir = require("lspconfig").util.find_git_ancestor,
                        init_options = {
                            settings = {
                                args = {},
                            },
                        },
                    },
                }
            end
            if configs.ruff_lsp then
                lspconfig.ruff_lsp.setup {}
            end

            -- Global mappings.
            -- See `:help vim.diagnostic.*` for documentation on any of the below functions
            vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
            vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
            vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
            vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)

            -- Use LspAttach autocommand to only map the following keys
            -- after the language server attaches to the current buffer
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                callback = function(ev)
                    -- Enable completion triggered by <c-x><c-o>
                    vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

                    -- Buffer local mappings.
                    -- See `:help vim.lsp.*` for documentation on any of the below functions
                    local opts = { buffer = ev.buf }
                    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
                    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
                    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
                    vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
                    vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
                    vim.keymap.set("n", "<leader>wl", function()
                        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                    end, opts)
                    --vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
                    vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)
                    vim.keymap.set({ "n", "v" }, "<leader>a", vim.lsp.buf.code_action, opts)
                    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
                    vim.keymap.set("n", "<leader>f", function()
                        vim.lsp.buf.format { async = true }
                    end, opts)

                    local client = vim.lsp.get_client_by_id(ev.data.client_id)

                    -- When https://neovim.io/doc/user/lsp.html#lsp-inlay_hint stabilizes
                    -- *and* there's some way to make it only apply to the current line.
                    -- if client.server_capabilities.inlayHintProvider then
                    --     vim.lsp.inlay_hint(ev.buf, true)
                    -- end

                    -- None of this semantics tokens business.
                    -- https://www.reddit.com/r/neovim/comments/143efmd/is_it_possible_to_disable_treesitter_completely/
                    client.server_capabilities.semanticTokensProvider = nil
                end,
            })
        end,
    },
    -- LSP-based code-completion
    {
        "hrsh7th/nvim-cmp",
        -- load cmp on InsertEnter
        event = "InsertEnter",
        -- these dependencies will only be loaded when cmp loads
        -- dependencies are always lazy-loaded unless specified otherwise
        dependencies = {
            "hrsh7th/vim-vsnip",
            "hrsh7th/cmp-vsnip",
            "neovim/nvim-lspconfig",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
        },
        config = function()
            local cmp = require "cmp"
            cmp.setup {
                snippet = {
                    -- REQUIRED by nvim-cmp. get rid of it once we can
                    expand = function(args)
                        vim.fn["vsnip#anonymous"](args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert {
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    -- Accept currently selected item.
                    -- Set `select` to `false` to only confirm explicitly selected items.
                    ["<CR>"] = cmp.mapping.confirm { select = true },
                },
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "vsnip" },
                }, {
                    { name = "path" },
                }),
                experimental = {
                    ghost_text = true,
                },
            }

            -- Enable completing paths in :
            cmp.setup.cmdline(":", {
                sources = cmp.config.sources {
                    { name = "path" },
                },
            })
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
