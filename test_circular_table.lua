
local LuaUnit = require "luaunit"
require "circular_table"

TestCircularTable = {}

function TestCircularTable:test_circular_table()
  local a = {1,2,3}
  a = to_circular_table(a)
  
  assert_equals({1,2,3}, a)
  assert_equals(1, a[1])
  assert_equals(3, a[0])
  assert_equals(2, a[-1])
  assert_equals(1, a[4])
  assert_equals(3, a[-9])
end

LuaUnit:run()
