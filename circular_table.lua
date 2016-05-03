--[[

luapoly by David Gayerie

]]--

function to_circular_table(a)
  assert(type(a) == "table", "table expected")
  return setmetatable(a, {
    __index = function (table, key)
      if type(key) == "number" then
        local length = #table
        return rawget(table, (key - 1) % length + 1)
      else
        return rawget(table, key)
      end
    end
  })
end
