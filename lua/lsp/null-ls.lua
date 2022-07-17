local status, null_ls = pcall(require, "null-ls")
local status_helpers, helpers = pcall(require, "null-ls.helpers")

if not status then
	vim.notify("没有找到 null-ls")
	return
end

if not status_helpers then
	vim.notify("没有找到 null-ls.helpers")
	return
end

local formatting = null_ls.builtins.formatting
-- local builtins = null_ls.builtins

null_ls.setup({
	debug = false,
	sources = {
		-- Add by syb
		-- formatting.black.with({ extra_args = { "--fast" } }),
		-- formatting.isort,
		-- builtins.diagnostics.eslint,
		-- builtins.completion.spell,
		-- Add by syb
		-- Formatting ---------------------
		--  brew install shfmt
		formatting.shfmt,
		-- StyLua
		formatting.stylua,
		-- frontend
		formatting.prettier.with({ -- 只比默认配置少了 markdown
			filetypes = {
				"javascript",
				"javascriptreact",
				"typescript",
				"typescriptreact",
				"vue",
				"css",
				"scss",
				"less",
				"html",
				"json",
				"yaml",
				"graphql",
				"go",
				"python",
			},
			prefer_local = "node_modules/.bin",
			-- diagnostics
		}),
		-- formatting.fixjson,
		-- formatting.black.with({ extra_args = { "--fast" } }),
	},
	-- 保存自动格式化
	on_attach = function(client)
		if client.resolved_capabilities.document_formatting then
			vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
		end
	end,
})

local markdownlint = {
	method = null_ls.methods.DIAGNOSTICS,
	filetypes = { "markdown" },
	-- null_ls.generator creates an async source
	-- that spawns the command with the given arguments and options
	generator = null_ls.generator({
		command = "markdownlint",
		args = { "--stdin" },
		to_stdin = true,
		from_stderr = true,
		-- choose an output format (raw, json, or line)
		format = "line",
		check_exit_code = function(code, stderr)
			local success = code <= 1

			if not success then
				-- can be noisy for things that run often (e.g. diagnostics), but can
				-- be useful for things that run on demand (e.g. formatting)
				print(stderr)
			end

			return success
		end,
		-- use helpers to parse the output from string matchers,
		-- or parse it manually with a function
		on_output = helpers.diagnostics.from_patterns({
			{
				pattern = [[:(%d+):(%d+) [%w-/]+ (.*)]],
				groups = { "row", "col", "message" },
			},
			{
				pattern = [[:(%d+) [%w-/]+ (.*)]],
				groups = { "row", "message" },
			},
		}),
	}),
}
null_ls.register(markdownlint)
