return {
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {
			ensure_installed = {
				"basedpyright",
				"bashls",
				"clangd",
				"docker_compose_language_service",
				"dockerls",
				"jsonls",
				"lua_ls",
				"ruff",
			},
		},
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig",
		},
	},
	{
		"neovim/nvim-lspconfig",

		dependencies = {
			{
				"folke/lazydev.nvim",
				ft = "lua", -- only load on lua files
				opts = {
					library = {
						-- See the configuration section for more details
						-- Load luvit types when the `vim.uv` word is found
						{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
					},
				},
			},
		},

		vim.lsp.config("basedpyright", {
			settings = {
				basedpyright = {
					analysis = {
						autoSearchPaths = true,
						diagnosticMode = "openFilesOnly", -- Only analyze open files
						useLibraryCodeForTypes = true,
						typeCheckingMode = "standard", -- Reduce strictness (or use "off" to suppress more)
						diagnosticSeverityOverrides = {
							reportOptionalSubscript = "none",
							reportOptionalMemberAccess = "none",
							reportOptionalCall = "none",
							reportPrivateImportUsage = "none",
							reportUnnecessaryIsInstance = "none",
							reportUnnecessaryCast = "none",
							reportGeneralTypeIssues = "error", -- keep core type issues
							reportUndefinedVariable = "error", -- keep undefined variable issues
						},
					},
				},
			},
		}),

		vim.lsp.enable("basedpyright"),
		vim.lsp.enable("bashls"),
		vim.lsp.enable("clangd"),
		vim.lsp.enable("docker_compose_language_service"),
		vim.lsp.enable("dockerls"),
		vim.lsp.enable("jsonls"),
		vim.lsp.enable("lua_ls"),

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
			-- Create a function that lets us more easily define mappings specific LSP related items.
			-- It sets the mode, buffer and description for us each time.
			callback = function(event)
				local map = function(keys, func, desc)
					vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
				end

				-- Go to
				map("gd", vim.lsp.buf.definition, "Goto Definition")
				map("gD", vim.lsp.buf.declaration, "Goto Declaration")
				map("gi", require("telescope.builtin").lsp_implementations, "Goto Implementation")
				map("gr", require("telescope.builtin").lsp_references, "Goto References")
				map("gt", vim.lsp.buf.type_definition, "Goto type Definition")

				-- Fuzzy find all the symbols in your current document.
				map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "Document Symbols")
				-- Fuzzy find all the symbols in your current workspace
				map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Workspace Symbols")

				-- Actions
				map("<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
				map("<leader>ca", vim.lsp.buf.code_action, "Code Action")

				-- Opens a popup that displays documentation about the word under your cursor
				--  See `:help K` for why this keymap
				map("K", vim.lsp.buf.hover, "Hover Documentation")
				map("<C-Space>", vim.lsp.buf.hover, "Hover Documentation")
				vim.keymap.set(
					"i",
					"<C-Space>",
					vim.lsp.buf.signature_help,
					{ buffer = event.buf, desc = "LSP: Hover Signature Help" }
				)

				-- The following two autocommands are used to highlight references of the
				-- word under your cursor when your cursor rests there for a little while.
				--    See `:help CursorHold` for information about when this is executed
				--
				-- When you move your cursor, the highlights will be cleared (the second autocommand).
				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if client and client.server_capabilities.documentHighlightProvider then
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buffer = event.buf,
						callback = vim.lsp.buf.document_highlight,
					})

					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						buffer = event.buf,
						callback = vim.lsp.buf.clear_references,
					})
				end
			end,
		}),

		-- Diagnostic Config
		-- See :help vim.diagnostic.Opts
		vim.diagnostic.config({
			underline = { severity = vim.diagnostic.severity.ERROR },
			virtual_text = {
				source = "if_many",
				prefix = "●",
				spacing = 2,
				format = function(diagnostic)
					return string.format("%s", diagnostic.code)
				end,
			},
			severity_sort = true,
			float = { border = "rounded", source = "if_many" },
			signs = vim.g.have_nerd_font and {
				text = {
					[vim.diagnostic.severity.ERROR] = "󰅚 ",
					[vim.diagnostic.severity.WARN] = "󰀪 ",
					[vim.diagnostic.severity.INFO] = "󰋽 ",
					[vim.diagnostic.severity.HINT] = "󰌶 ",
				},
			} or {},
		}),
	},

	-- Useful status updates for LSP.
	-- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
	{
		"j-hui/fidget.nvim",
		tag = "v1.4.0",
		opts = {
			progress = {
				display = {
					done_icon = "✓", -- Icon shown when all LSP progress tasks are complete
				},
			},
			notification = {
				window = {
					winblend = 0, -- Background color opacity in the notification window
				},
			},
		},
	},
}
-- TODO:
-- inlay_hint
--
