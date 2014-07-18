
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

function TestPoly:test_get_triangles_when_poly_is_triangle()
  poly = new_poly();
  poly:push_coord(0,0)
  poly:push_coord(1,1)
  poly:push_coord(1,0)
  poly:close()
  
  local triangles = poly:get_triangles()
  assert_equals(triangles, {{3,1,2}})
end

function TestPoly:test_get_triangles_when_poly_is_convex()
  poly = new_poly();
  poly:push_coord(0,0)
  poly:push_coord(0,1)
  poly:push_coord(1,1)
  poly:push_coord(1,0)
  poly:close()
  
  local triangles = poly:get_triangles()
  assert_equals(triangles, {{4,1,2},{4,2,3}})
end

function TestPoly:test_get_triangles_when_poly_is_concave()
  poly = new_poly();
  poly:push_coord(0,0)
  poly:push_coord(0.5,0.2)
  poly:push_coord(1,1)
  poly:push_coord(1,0)
  poly:close()
  
  local triangles = poly:get_triangles()
  assert_equals(triangles, {{4,1,2},{3,4,2}})
end

function TestPoly:test_get_triangles_when_poly_is_star()
  poly = new_poly();
  poly:push_coord(-0.5,0.5)
  poly:push_coord(0,5)
  poly:push_coord(0.5,0.5)
  poly:push_coord(5,0)
  poly:push_coord(0.5,-0.5)
  poly:push_coord(0,-5)
  poly:push_coord(-0.5,-0.5)
  poly:push_coord(-5,0)
  poly:close()
  
  local triangles = poly:get_triangles()
  assert_equals(triangles, {{3,4,5},{2,3,5},{7,8,1},{6,7,1},{5,6,1},{1,2,5}})
end

TestPolyIndex = {}

function TestPolyIndex:test_poly_index()
  poly_index = PolyIndex.new(5)

  assert_equals(poly_index:previous(1), 5)
  assert_equals(poly_index:next(1), 2)

  assert_equals(poly_index:previous(2), 1)
  assert_equals(poly_index:next(2), 3)

  assert_equals(poly_index:previous(3), 2)
  assert_equals(poly_index:next(3), 4)

  assert_equals(poly_index:previous(4), 3)
  assert_equals(poly_index:next(4), 5)

  assert_equals(poly_index:previous(5), 4)
  assert_equals(poly_index:next(5), 1)

  poly_index:remove(1)

  assert_equals(poly_index:previous(2), 5)
  assert_equals(poly_index:next(2), 3)

  assert_equals(poly_index:previous(3), 2)
  assert_equals(poly_index:next(3), 4)

  assert_equals(poly_index:previous(4), 3)
  assert_equals(poly_index:next(4), 5)

  assert_equals(poly_index:previous(5), 4)
  assert_equals(poly_index:next(5), 2)
end

function TestPolyIndex:test_get_triangle()
  poly_index = PolyIndex.new(5)

  assert_equals(poly_index:get_triangle(1), {5,1,2})
  assert_equals(poly_index:get_triangle(-1), {3,4,5})
end

LuaUnit:run()
