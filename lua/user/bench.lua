require('mapx').setup { global = true, whichkey = true }

local function bench_native()
  vim.api.nvim_set_keymap('n', 'j', "v:count ? 'j' : 'gj'", { noremap = true, expr = true })
  vim.api.nvim_set_keymap('n', 'k', "v:count ? 'k' : 'gk'", { noremap = true, expr = true })

  vim.api.nvim_set_keymap('n', 'J', '5j', {})
  vim.api.nvim_set_keymap('n', 'K', '5k', {})

  vim.api.nvim_set_keymap(
    'i',
    '<Tab>',
    [[pumvisible() ? "\<C-n>" : "\<Tab>"]],
    { noremap = true, silent = true, expr = true }
  )
  vim.api.nvim_set_keymap(
    'i',
    '<S-Tab>',
    [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]],
    { noremap = true, silent = true, expr = true }
  )

  vim.api.nvim_set_keymap('', '<M-/>', ':Commentary<Cr>', { silent = true })
end

local function bench_mapx()
  nnoremap('j', "v:count ? 'j' : 'gj'", 'expr', 'foobar')
  nnoremap('k', "v:count ? 'k' : 'gk'", 'expr', 'foobar')

  nmap('J', '5j')
  nmap('K', '5k')

  inoremap('<Tab>', [[pumvisible() ? "\<C-n>" : "\<Tab>"]], 'silent', 'expr', 'foobar')
  inoremap('<S-Tab>', [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], 'silent', 'expr', 'foobar')

  map('<M-/>', ':Commentary<Cr>', 'silent')
end

local results = {
  native = vim.inspect(require('plenary.profile').benchmark(10000, bench_native)),
  mapx = vim.inspect(require('plenary.profile').benchmark(10000, bench_mapx)),
}

results.ratio = results.mapx / results.native

print(vim.inspect(results))
