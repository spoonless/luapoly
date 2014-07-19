local function normalize_index(index, max_index)
  return (index - 1) % max_index + 1
end

IndexedPoly = {}
IndexedPoly.__index = IndexedPoly

function IndexedPoly:previous(index)
  return self.previous_index[index] or normalize_index(index-1, self.chain_size)
end

function IndexedPoly:next(index)
  return self.next_index[index] or normalize_index(index+1, self.chain_size)
end

function IndexedPoly:get_triangle(index, revert)
  if revert then
    return {self:next(index), normalize_index(index, self.chain_size), self:previous(index)}
  else
    return {self:previous(index), normalize_index(index, self.chain_size), self:next(index)}
  end
end

function IndexedPoly:remove(index)
  local n = self:next(index)
  local p = self:previous(index)
  self.next_index[p] = n
  self.previous_index[n] = p
  self.next_index[index] = nil
  self.previous_index[index] = nil
end

function IndexedPoly.new(chain_size)
  local indexed_poly = {chain_size = chain_size, previous_index = {}, next_index = {}}
  return setmetatable(indexed_poly, IndexedPoly)
end

local Polygon = {}
Polygon.__index = Polygon

function Polygon.is_closed(poly)
  local nb = #poly
  return nb >=6 and poly[1] == poly[nb-1] and poly[2] == poly[nb]
end

-- I know löve already provides this method
function Polygon.is_convex(poly)
  if not poly:is_closed() then
    return false
  end

  local coord_count = poly:get_coord_count() - 1
  local prev_i = coord_count
  local zsign = 0
  for i = 1,coord_count do
    -- dot product of the z component
    local z = poly:compute_zcross_product(prev_i, i, i+1)
    if zsign == 0 then
      zsign = z
    elseif zsign * z < 0 then
      return false
    end
    prev_i = i
  end
  return true
end

function Polygon.revert_winding(poly)
  local last = poly:is_closed() and #poly-2 or #poly
  for i = 1,(last-2)/2,2 do
    poly[i+2],poly[last - i] = poly[last - i],poly[i+2]
    poly[i+3],poly[last - i+1] = poly[last - i+1],poly[i+3]
  end
end

function Polygon.is_cw(poly)
  if not poly:is_closed() then
    return false
  end

  local sum = 0
  for i = 1,(poly:get_coord_count()-1) do
    sum = sum + poly:compute_subsurface(i, i+1)
  end
  return sum >= 0
end

function Polygon.compute_zcross_product(poly, i1, i2, i3)
  local x1, y1 = poly:get_coord(i1)
  local x2, y2 = poly:get_coord(i2)
  local x3, y3 = poly:get_coord(i3)

  return (x1 - x2) * (y3 - y2) - (y1 - y2) * (x3 - x2)
end

function Polygon.compute_subsurface(poly, i1, i2)
  local x1, y1 = poly:get_coord(i1)
  local x2, y2 = poly:get_coord(i2)
  
  return (x2 - x1) * (y2 + y1)
end

local function check_ear(poly, triangle, reflex_vertices)
  for j,_ in pairs(reflex_vertices) do
    -- compute zcross_product for j and each edges of the triangle (i-1, i, i+1)
    -- check j is not inside the triangle (i-1, i, i+1)
    -- to be checked
    if poly:compute_zcross_product(j, triangle[2], triangle[3]) > 0
      and poly:compute_zcross_product(j, triangle[3], triangle[1]) > 0
      and poly:compute_zcross_product(j, triangle[1], triangle[2]) > 0 then
      return false
    end
  end
  return true
end

function Polygon.get_triangles(poly)
  if not poly:is_closed() then
    return nil
  end
  
  local poly_surface = 0
  local indexed_poly = IndexedPoly.new(poly:get_coord_count() -1)
  local reflex_vertices = {}
  local convex_vertices = {}
  local coord_count = poly:get_coord_count() - 1

  -- first phase :
  -- 1) separate reflex and convex vertices.
  -- 2) compute polygon surface to determine vertex chain winding.
  local prev_i = coord_count
  for i = 1,coord_count do
    -- dot product of the z component
    local z = poly:compute_zcross_product(prev_i, i, i+1)
    if z < 0 then
      reflex_vertices[i] = 0
    else
      convex_vertices[i] = 0
    end
    poly_surface = poly_surface + poly:compute_subsurface(i, i+1)
    prev_i = i
  end
  
  local sign = poly_surface < 0 and -1 or 1
  
  -- is it ok if sign == 0 for a given reflex vertex ?
  if sign < 0 then
    reflex_vertices, convex_vertices = convex_vertices, reflex_vertices
  end
  
  -- second phase : identify ears
  local ear_tips = {}
  for i,_ in pairs(convex_vertices) do
    if check_ear(poly, indexed_poly:get_triangle(i, sign < 0), reflex_vertices) then
      table.insert(ear_tips, i)
      convex_vertices[i] = #ear_tips
    end
  end

  local triangles = {}
  
  -- third phase : extract triangles
  local ear_tips_index = 0
  for i = 1,(coord_count - 2) do
    local ear_index
    if i % 2 == 1 then
      ear_tips_index = ear_tips_index + 1
      ear_index = ear_tips[ear_tips_index]
    else
      ear_index = ear_tips[#ear_tips]
      table.remove(ear_tips)
    end
    convex_vertices[ear_index] = nil
    
    local triangle = indexed_poly:get_triangle(ear_index, sign < 0)
    
    table.insert(triangles, triangle)
    
    indexed_poly:remove(ear_index)

    for pos,index in ipairs{triangle[1],triangle[3]} do
      triangle = indexed_poly:get_triangle(index, sign < 0)
      if reflex_vertices[index] and poly:compute_zcross_product(triangle[1], triangle[2], triangle[3]) >= 0 then
        reflex_vertices[index] = nil
        convex_vertices[index] = 0
      end
      if convex_vertices[index] then
        if check_ear(poly, triangle, reflex_vertices) then
          if convex_vertices[index] == 0 then
            if pos == 1 then
              ear_tips[ear_tips_index] = index
              convex_vertices[index] = ear_tips_index
              ear_tips_index = ear_tips_index - 1
            else
              table.insert(ear_tips, index)
              convex_vertices[index] = #ear_tips
            end
          end
        elseif convex_vertices[index] > 0 then
          for i,j in pairs(convex_vertices) do
            if j > convex_vertices[index] then convex_vertices[i] = j-1 end
          end
          table.remove(ear_tips, convex_vertices[index])
          convex_vertices[index] = 0
        end
      end
    end
  end
  return triangles
end

function Polygon.get_coord_count(poly)
  return #poly / 2
end

function Polygon.get_coord(poly, index)
  return poly[index*2-1], poly[index*2]
end

function Polygon.push_coord(poly, x, y)
  table.insert(poly, x)
  table.insert(poly, y)
end

function Polygon.pop_coord(poly)
  if #poly > 1 then
    table.remove(poly)
    table.remove(poly)
  end
end

function Polygon.close(poly)
  if #poly >= 6 and not poly:is_closed() then
    table.insert(poly, poly[1])
    table.insert(poly, poly[2])
    return true
  end
  return false
end

return function(vertices_chain)
  return setmetatable(vertices_chain and vertices_chain or {}, Polygon)
end
