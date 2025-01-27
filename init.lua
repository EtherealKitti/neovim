------------------------------Basic Settings---------------------------------

vim.wo.number = true
vim.o.fillchars = "eob: ,vert:│,fold: ,diff:╱"
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.autoindent = true
vim.opt.scrolloff = 10

-----------------------------------------------------------------------------

vim.opt.rtp:prepend(vim.fn.stdpath("config").."/prepends/lazy.nvim")

require("lazy").setup({
    {
        "nvim-treesitter/nvim-treesitter",
        ["build"] = ":TSUpdate",
        ["config"] = function()
            require("nvim-treesitter.configs").setup({
                ["ensure_installed"] = {"lua","javascript"},
                ["highlight"] = {
                    ["enable"] = true,
                    ["additional_vim_regex_highlighting"] = false
                }
            })
        end
    },
    {"neovim/nvim-lspconfig"},
    {
        "hrsh7th/nvim-cmp",
        ["dependencies"] = {"hrsh7th/cmp-nvim-lsp"}
    },
    {"mfussenegger/nvim-lint"},
    {"williamboman/mason.nvim"}
})

require("mason").setup()

local cmp = require("cmp")
local lspConfig = require("lspconfig")
local lint = require("lint")

------------------------------Language Servers-------------------------------

lspConfig.lua_ls.setup({
    ["settings"] = {
        ["Lua"] = {
            ["runtime"] = {
                ["version"] = "LuaJIT",
            },
            ["diagnostics"] = {
                ["globals"] = {"vim"},
            },
            ["workspace"] = {
                ["library"] = vim.api.nvim_get_runtime_file("",true),
                ["checkThirdParty"] = false
            },
            ["telemetry"] = {
                ["enable"] = false
            }
        }
    }
})

lspConfig.ts_ls.setup({
    ["settings"] = {
        ["documentFormatting"] = false
    }
})

lspConfig.zls.setup({
    ["settings"] = {}
})

-----------------------------------------------------------------------------

cmp.setup({
    ["mapping"] = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({["select"] = true})
    }),
    ["sources"] = {
        {["name"] = "nvim_lsp"}
    }
})

----------------------------------Linters------------------------------------

lint.linters.eslint = {
    ["cmd"] = "eslint",
    ["{args}"] = {"--stdin","--stdin-filename","%filename" },
    ["stdin"] = true
}

lint.linters.lua = {
    ["cmd"] = "luacheck",
    ["args"] = {"--stdin","--stdin-filename","%filename"},
    ["stdin"] = true
}

lint.linters.zig = {
    ["cmd"] = "zig",
    ["args"] = {"fmt","--check"},
    ["stream"] = "stdout",
    ["ignore_exitcode"] = true
}

vim.api.nvim_create_autocmd(
    {"BufEnter","TextChanged"},
    {
        ["callback"] = function()
            lint.try_lint()
        end
    }
)

-----------------------------------------------------------------------------
