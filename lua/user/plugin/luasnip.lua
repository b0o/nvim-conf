---- L3MON4D3/LuaSnip

vim.opt.runtimepath:append(vim.fn.stdpath 'config' .. '/snippets')

require('luasnip.loaders.from_vscode').lazy_load {}
