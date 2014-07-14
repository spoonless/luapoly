local function normalize_index(index, max_index)
  return (index - 1) % max_index + 1
end

PolyIndex = {}
PolyIndex.__index = PolyIndex

function PolyIndex:previous(index)
  return self.previous_index[index] or normalize_index(index-1, self.chain_size)
end

function PolyIndex:next(index)
  return self.next_index[index] or normalize_index(index+1, self.chain_size)
end

function PolyIndex:remove(index)
  local n = self:next(index)
  local p = self:previous(index)
  self.next_index[p] = n
  self.previous_index[n] = p
  self.next_index[index] = nil
  self.previous_index[index] = nil
end

function PolyIndex.new(chain_size)
  local poly_index = {chain_size = chain_size, previous_index = {}, next_index = {}}
  return setmetatable(poly_index, PolyIndex)
end

local PolyMetaTable = {}
PolyMetaTable.__index = PolyMetaTable

function PolyMetaTable.is_closed(poly)
  local nb = #poly
  return nb >=6 and poly[1] == poly[nb-1] and poly[2] == poly[nb]
end

-- I know löve already provides this method
function PolyMetaTable.is_convex(poly)
  if not poly:is_closed() then
    return false
  end

  local zsign = 0
  for i = 1,(poly:get_coord_count()-1) do
    -- dot product of the z component
    local z = poly:compute_zcross_product(i, i+1, i+2)

    if zsign == 0 then
      zsign = z
    elseif zsign * z < 0 then
      return false
    end
  end
  return true
end

function PolyMetaTable.is_cw(poly)
  if not poly:is_closed() then
    return false
  end

  local sum = 0
  for i = 1,(poly:get_coord_count()-1) do
    local x1, y1 = poly:get_coord(i)
    local x2, y2 = poly:get_coord(i+1)

    sum = sum + (x2 - x1) * (y2 + y1)
  end
  return sum >= 0
end

function PolyMetaTable.compute_zcross_product(poly, i1, i2, i3)
  local coord_count = poly:get_coord_count() - 1
  
  i1 = normalize_index(i1, coord_count)
  i2 = normalize_index(i2, coord_count)
  i3 = normalize_index(i3, coord_count)
  
  local x1, y1 = poly:get_coord(i1)
  local x2, y2 = poly:get_coord(i2)
  local x3, y3 = poly:get_coord(i3)

  return (x1 - x2) * (y3 - y2) - (y1 - y2) * (x3 - x2)
end

function PolyMetaTable.compute_subsurface(poly, i1, i2)
  local coord_count = poly:get_coord_count() - 1
  i1 = normalize_index(i1, coord_count)
  i2 = normalize_index(i2, coord_count)
  
  local x1, y1 = poly:get_coord(i1)
  local x2, y2 = poly:get_coord(i2)
  
  return (x2 - x1) * (y2 + y1)
end

function PolyMetaTable.get_triangles(poly)
  if not poly:is_closed() then
    return nil
  end
  
  local polySurface = 0
  local poly_index = PolyIndex.new(poly:get_coord_count() -1)
  local reflex_vertices = {}
  local convex_vertices = {}
  local coord_count = poly:get_coord_count() - 1
  for i = 1,coord_count do
    -- dot product of the z component
    local z = poly:compute_zcross_product(i, i+1, i+2)
    if z < 0 then
      reflex_vertices[normalize_index(i+1, coord_count)] = true
    else
      convex_vertices[normalize_index(i+1, coord_count)] = true
    end
    polySurface = polySurface + poly:compute_subsurface(i, i+1)
  end
  
  local sign = polySurface < 0 and -1 or 1
  
  -- is it ok if sign == 0 for a given reflex vertex ?
  if sign < 0 then
    reflex_vertices, convex_vertices = convex_vertices, reflex_vertices
  end
  
  local ear_tips = {}
  for i,_ in pairs(convex_vertices) do
    local is_ear = true
    for j,_ in pairs(reflex_vertices) do
      -- compute zcross_product for j and each edges of the triangle (i-1, i, i+1)
      -- check j is not inside the triangle (i-1, i, i+1)
      -- to be checked
      local next_i = poly_index:next(i)
      local previous_i = poly_index:previous(i)
      if sign * poly:compute_zcross_product(j, i, next_i) > 0
         and sign * poly:compute_zcross_product(j, next_i, previous_i) > 0
         and sign * poly:compute_zcross_product(j, previous_i, i) > 0 then
         is_ear = false
         break;
      end
    end
    if is_ear then
      table.insert(ear_tips, i)
    end
  end
  
  triangles = {}

  while #triangles < coord_count - 2 do
    local ear_index = ear_tips[1]
    table.remove(ear_tips, 1)
    convex_vertices[ear_index] = nil
    
    local previous_ear_index = poly_index:previous(ear_index)
    local next_ear_index = poly_index:next(ear_index)
    
    table.insert(triangles, {previous_ear_index, ear_index, next_ear_index})
    
    poly_index:remove(ear_index)
    
    for _,index in ipairs{previous_ear_index, next_ear_index} do
      local previous_index = poly_index:previous(index)
      local next_index = poly_index:next(index)
      if reflex_vertices[index] 
        and sign * poly:compute_zcross_product(previous_index, index, next_index) >= 0 then
        reflex_vertices[index] = nil
        convex_vertices[index] = true
      end
      if convex_vertices[index] then
        local is_ear = true
        for j,_ in pairs(reflex_vertices) do
          -- compute zcross_product for j and each edges of the triangle (i-1, i, i+1)
          -- check j is not inside the triangle (i-1, i, i+1)
          -- to be checked
          local next_i = poly_index:next(index)
          local previous_i = poly_index:previous(index)
          if sign * poly:compute_zcross_product(j, index, next_i) > 0
            and sign * poly:compute_zcross_product(j, next_i, previous_i) > 0
            and sign * poly:compute_zcross_product(j, previous_i, index) > 0 then
            is_ear = false
            break;
          end
        end
        if is_ear then
          if not table.contains(ear_tips, index) then
            if index == previous_ear_index then
              table.insert(ear_tips, 1, index)
            else
              table.insert(ear_tips, index)
            end
          end
        else
          -- remove ear if no more an ear
          for i,j in ipairs(ear_tips) do
            if j == index then
              table.remove(ear_tips, i)
              break
            end
          end
        end
      end
    end
  end
  return triangles
end

function table.contains(t, v)
  for _,i in ipairs(t) do
    if i == v then return true end
  end
  return false
end

function PolyMetaTable.get_coord_count(poly)
  return #poly / 2
end

function PolyMetaTable.get_coord(poly, index)
  return poly[index*2-1], poly[index*2]
end

function PolyMetaTable.push_coord(poly, x, y)
  table.insert(poly, x)
  table.insert(poly, y)
end

function PolyMetaTable.pop_coord(poly)
  if #poly > 1 then
    table.remove(poly)
    table.remove(poly)
  end
end

function PolyMetaTable.close(poly)
  if #poly >= 6 and not poly:is_closed() then
    table.insert(poly, poly[1])
    table.insert(poly, poly[2])
  end
end

return function()
  return setmetatable({}, PolyMetaTable)
end
