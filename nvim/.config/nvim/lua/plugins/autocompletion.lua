return {
	"saghen/blink.cmp",
	dependencies = { "rafamadriz/friendly-snippets" },

	version = "1.*",

	opts = {

		keymap = {
			preset = "enter",
			["<Up>"] = { "select_prev", "fallback" },
			["<Down>"] = { "select_next", "fallback" },
			["<C-k>"] = { "select_prev", "fallback" },
			["<C-j>"] = { "select_next", "fallback" },
			-- Might be better to map selcte_next on something else than Tab (used for snippets)
			["<Tab>"] = { "select_next", "fallback" },
			["<S-Tab>"] = { "select_prev", "fallback" },
		},

		appearance = {
			nerd_font_variant = "mono",
		},

		-- (Default) Only show the documentation popup when manually triggered
		completion = {
			documentation = { auto_show = false },
			ghost_text = { enabled = true },
			list = {
				selection = { preselect = true, auto_insert = false },
			},
		},

		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
		},

		fuzzy = { implementation = "prefer_rust_with_warning" },

		signature = { enabled = true },
	},
	opts_extend = { "sources.default" },
}
