local util = {}

-- pretty print (structure, limit, indent)
-- Based on https://gist.github.com/stuby/5445834#file-rprint-lua
function util.pprint(s, d, i, p)
  d = d or 5
  i = i or ''
  p = p or ''
  if (d == 0) then
    return
  end
  local ts = type(s)
  if (ts ~= 'table') then
    print(i .. p .. ts, s)
    return
  end
  if (d == 1) then
    print(i .. p .. ts .. ' (...)')
    return
  end
  print(i .. p .. ts)
  for k,v in pairs(s) do
    util.pprint(v, d - 1, '  ' .. i, tostring(k) .. ': ')
  end
end

-- generally, functions that make copies of tables try to preserve the metatable.
-- However, when the source has no obvious type, then we attach appropriate metatables
-- like List, Map, etc to the result.
--
-- Lifted from lunarmodules/Penlight::tablex.setmeta
local function setmeta(res, tbl)
  local mt = getmetatable(tbl)
  return mt and setmetatable(res, mt) or res
end

-- Lifted from lunarmodules/Penlight::types.check_meta
local function check_meta(val)
  if type(val) == 'table' then return true end
  return getmetatable(val)
end

--- can an object be iterated over with `pairs`?
-- An object is iterable if:
--
-- - it is a table, or
-- - it has a metatable with a `__pairs` meta method
--
-- NOTE: since `__pairs` is 5.2+, on 5.1 is usually returns `false` for userdata
--
-- Lifted from lunarmodules/Penlight::types.is_iterable
--
-- @param val any value.
-- @return `true` if the object is iterable, otherwise a falsy value.
--
-- Lifted from lunarmodules/Penlight::types.is_iterable
local function is_iterable(val)
  local mt = check_meta(val)
  if mt == true then return true end
  return mt and mt.__pairs and true
end

-- Lifted from lunarmodules/Penlight::tablex.assert_arg_iterable
local function assert_arg_iterable(idx, val)
  if not is_iterable(val) then
    error(('argument %d is not iterable'):format(idx), 3)
  end
end

--- combine two tables, either as union or intersection. Corresponds to
-- set operations for sets () but more general. Not particularly
-- useful for list-like tables.
--
-- @within Merging
-- @tab t1 a table
-- @tab t2 a table
-- @bool dup true for a union, false for an intersection.
-- @usage merge({alice=23,fred=34},{bob=25,fred=34}) is {fred=34}
-- @usage merge({alice=23,fred=34},{bob=25,fred=34},true) is {bob=25,fred=34,alice=23}
--
-- Lifted from lunarmodules/Penlight::tablex.merge
function util.merge(t1, t2, dup)
  assert_arg_iterable(1, t1)
  assert_arg_iterable(2, t2)
  local res = {}
  for k,v in pairs(t1) do
    if dup or t2[k] then res[k] = v end
  end
  if dup then
    for k,v in pairs(t2) do
      res[k] = v
    end
  end
  return setmeta(res, t1)
end

return util
