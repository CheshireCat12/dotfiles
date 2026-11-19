return {
    {
        "catppuccin/nvim",
        lazy = false,
        name = "catppuccin",
        priority = 1000,
        config = function()
            require("catppuccin").setup({
                -- TODO you can add comment style
                --comments = { italic = false }, -- Disable italics in comments
                flavour = "mocha",
                transparent_background = true,
                integrations = {
                    mason = true,
                    neotree = false,
                    which_key = true,
                },
            })
            vim.cmd.colorscheme("catppuccin-nvim")
        end,
    },
}
