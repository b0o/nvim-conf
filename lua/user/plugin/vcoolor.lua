---- KabbAmine/vCoolor.vim
vim.g.vcoolor_lowercase = 0
vim.g.vcoolor_disable_mappings = 1

-- Use yad as the color picker (Linux)
if vim.fn.has 'unix' then
  vim.g.vcoolor_custom_picker = table.concat({
    'yad',
    '--title="Color Picker"',
    '--color',
    '--splash',
    '--on-top',
    '--skip-taskbar',
    '--init-color=',
  }, ' ')
end
