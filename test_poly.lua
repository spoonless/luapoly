
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
  assert_equals(triangles, {{4,1,2},{3,4,2}})
end

function TestPoly:test_get_triangles_when_poly_is_concave()
  poly = new_poly();
  poly:push_coord(0,0)
  poly:push_coord(0.5,0.2)
  poly:push_coord(1,1)
  poly:push_coord(1,0)
  poly:close()
  
  local triangles = poly:get_triangles()
  assert_equals(triangles, {{4,1,2},{4,2,3}})
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
  assert_equals(triangles, {{3,4,5},{3,5,6},{2,3,6},{1,2,6},{7,8,1},{7,1,6}})
end

TestIndexedPoly = {}

function TestIndexedPoly:test_indexed_poly()
  indexed_poly = IndexedPoly.new(5)

  assert_equals(indexed_poly:previous(1), 5)
  assert_equals(indexed_poly:next(1), 2)

  assert_equals(indexed_poly:previous(2), 1)
  assert_equals(indexed_poly:next(2), 3)

  assert_equals(indexed_poly:previous(3), 2)
  assert_equals(indexed_poly:next(3), 4)

  assert_equals(indexed_poly:previous(4), 3)
  assert_equals(indexed_poly:next(4), 5)

  assert_equals(indexed_poly:previous(5), 4)
  assert_equals(indexed_poly:next(5), 1)

  indexed_poly:remove(1)

  assert_equals(indexed_poly:previous(2), 5)
  assert_equals(indexed_poly:next(2), 3)

  assert_equals(indexed_poly:previous(3), 2)
  assert_equals(indexed_poly:next(3), 4)

  assert_equals(indexed_poly:previous(4), 3)
  assert_equals(indexed_poly:next(4), 5)

  assert_equals(indexed_poly:previous(5), 4)
  assert_equals(indexed_poly:next(5), 2)
end

function TestIndexedPoly:test_get_triangle()
  indexed_poly = IndexedPoly.new(5)

  assert_equals(indexed_poly:get_triangle(1), {5,1,2})
  assert_equals(indexed_poly:get_triangle(-1), {3,4,5})
end

LuaUnit:run()
