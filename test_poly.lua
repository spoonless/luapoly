
local LuaUnit = require "luaunit"
local new_poly = require "poly"

TestPoly = {}

function TestPoly:test_close_poly()
  poly = new_poly();
  poly:push_coord(0,0)
  poly:push_coord(1,0)
  poly:push_coord(1,1)
  
  assert(not poly:is_closed())

  poly:close()
  assert(poly:is_closed())
  assert_equals(poly:get_coord(1), poly:get_coord(4))
end

function TestPoly:test_is_convex()
  poly = new_poly();
  poly:push_coord(0,0)
  poly:push_coord(1,0)
  poly:push_coord(1,1)
  
  assert(not poly:is_convex())

  poly:close()
  
  assert(poly:is_convex())
end

function TestPoly:test_is_not_convex()
  poly = new_poly();
  poly:push_coord(0,0)
  poly:push_coord(1,0)
  poly:push_coord(1,1)
  poly:push_coord(0.6,0.5)
  
  assert(not poly:is_convex())

  poly:close()
  
  assert(not poly:is_convex())
end

LuaUnit:run()
