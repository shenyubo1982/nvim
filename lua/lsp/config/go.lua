-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#sumneko_lua
local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

local opts = {
	settings = {
		gopls = {
			analyses = {
				unusedparams = true,
			},
			staticcheck = true,
		},
	},
	cmd = { "gopls", "serve" },
	filetypes = { "go", "gomod" },
	--root_pattern("go.work", "go.mod", ".git"),

	-- flags = {
	-- 	debounce_text_changes = 150,
	-- },
	on_attach = function(client, bufnr)
		-- 禁用格式化功能，交给专门插件插件处理
		client.resolved_capabilities.document_formatting = false
		client.resolved_capabilities.document_range_formatting = false

		local function buf_set_keymap(...)
			vim.api.nvim_buf_set_keymap(bufnr, ...)
		end
		-- 绑定快捷键
		require("keybindings").mapLSP(buf_set_keymap)
		-- 保存时自动格式化
		vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
		-- Imports (To get your imports ordered on save, like goimports does, you can define a helper function in Lua:)
		-- local function OrgImports(wait_ms)
		-- 	local params = vim.lsp.util.make_range_params()
		-- 	params.context = { only = { "source.organizeImports" } }
		-- 	local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, wait_ms)
		-- 	for _, res in pairs(result or {}) do
		-- 		for _, r in pairs(res.result or {}) do
		-- 			if r.edit then
		-- 				vim.lsp.util.apply_workspace_edit(r.edit, "UTF-8")
		-- 			else
		-- 				vim.lsp.buf.execute_command(r.command)
		-- 			end
		-- 		end
		-- 	end
		-- end

		-- Omnifunc
		-- vim.cmd("autocmd FileType go setlocal omnifunc=v:lua.vim.lsp.omnifunc")
	end,
}

-- 查看目录等信息
return {
	on_setup = function(server)
		server:setup(opts)
	end,
}
