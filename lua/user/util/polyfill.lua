-- TODO: Remove once all plugins have migrated away from deprecated APIs
vim.tbl_islist = vim.islist

---@diagnostic disable-next-line: duplicate-set-field
vim.tbl_add_reverse_lookup = function(o)
  --- @cast o table<any,any>
  --- @type any[]
  local keys = vim.tbl_keys(o)
  for _, k in ipairs(keys) do
    local v = o[k]
    if o[v] then
      error(
        string.format(
          'The reverse lookup found an existing value for %q while processing key %q',
          tostring(v),
          tostring(k)
        )
      )
    end
    o[v] = k
  end
  return o
end

---@diagnostic disable-next-line: duplicate-set-field
vim.diagnostic.is_disabled = function(bufnr, namespace)
  vim.diagnostic.is_enabled {
    bufnr = bufnr,
    ns_id = namespace,
  }
end
