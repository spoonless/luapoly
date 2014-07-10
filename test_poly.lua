
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
  assert_equals(poly:get_coord(4), poly:get_coord(1))
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

function TestPoly:test_is_cw()
  poly = new_poly();
  poly:push_coord(0,0)
  poly:push_coord(1,1)
  poly:push_coord(1,0)
  poly:close()
  
  assert(poly:is_cw())
end

function TestPoly:test_is_ccw()
  poly = new_poly();
  poly:push_coord(0,0)
  poly:push_coord(1,0)
  poly:push_coord(1,1)
  poly:close()
  
  assert(not poly:is_cw())
end

function TestPoly:test_get_convex()
  poly = new_poly();
  poly:push_coord(0,0)
  poly:push_coord(1,1)
  poly:push_coord(1,0)
  poly:close()
  
  assert_equals(poly:get_convex(), poly)
end

function TestPoly:test_get_convex_from_concave()
  poly = new_poly();
  poly:push_coord(0,0)
  poly:push_coord(1,1)
  poly:push_coord(1,0)
  poly:push_coord(0.6,0.5)
  poly:close()
  
  assert_equals(poly:get_convex(), {0.6, 0.5, 0, 0, 1, 1, 0.6, 0.5})
end

function TestPoly:test_get_triangles()
  poly = new_poly();
  poly:push_coord(0,0)
  poly:push_coord(1,1)
  poly:push_coord(0.5,0.3)
  poly:push_coord(1,0)
  poly:close()
  
  poly:get_triangles()
end

function TestPoly:test_cant_get_convex()
  poly = new_poly();
  poly:push_coord(0,0)
  poly:push_coord(1,1)
  poly:push_coord(1,0)
  
  assert_equals(poly:get_convex(), nil)
end

LuaUnit:run()
