vim.filetype.add {
  extension = {
    astro = 'astro',
    mdx = 'mdx',
  },
  pattern = {
    ['**/__snapshots__/*.ts.snap'] = { 'jsonc' },
    ['**/__snapshots__/*.js.snap'] = { 'jsonc' },
  },
}

vim.filetype.add {
  extension = {
    pyx = 'cython',
    pxd = 'cython',
  },
}
