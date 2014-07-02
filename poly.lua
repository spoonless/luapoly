local PolyMetaTable = {}
PolyMetaTable.__index = PolyMetaTable;

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
  for i = 1,(#poly-3),2 do
    local n = i
    local x1, y1 = poly[n], poly[n+1]
    n = n + 2
    local x2, y2 = poly[n], poly[n+1]
    n = n + 2 < #poly and n + 2 or 3
    local x3, y3 = poly[n], poly[n+1]
    -- dot product of the z component
    local z = (x1 - x2) * (y3 - y2) - (y1 - y2) * (x3 - x2)

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
  for i = 1,(#poly-3),2 do
    local n = i
    local x1, y1 = poly[n], poly[n+1]
    n = n + 2
    local x2, y2 = poly[n], poly[n+1]

    sum = sum + (x2 - x1) * (y2 + y1)
  end
  return sum >= 0
end

function PolyMetaTable.get_convex(poly)
  if not poly:is_closed() then
    return nil
  end

  local polySurface = 0
  local angleSigns = {0}
  for i = 1,(#poly-3),2 do
    local n = i
    local x1, y1 = poly[n], poly[n+1]
    n = n + 2
    local x2, y2 = poly[n], poly[n+1]
    n = n + 2 < #poly and n + 2 or 3
    local x3, y3 = poly[n], poly[n+1]
    -- dot product of the z component
    local z = (x1 - x2) * (y3 - y2) - (y1 - y2) * (x3 - x2)
    table.insert(angleSigns, z)
    polySurface = polySurface + (x2 - x1) * (y2 + y1)
  end
  angleSigns[1] = angleSigns[#angleSigns]
  table.remove(angleSigns)
  
  local sign = polySurface < 0 and -1 or 1
  
  local pivot = nil
  for i,s in pairs(angleSigns) do
    if s * sign < 0 then
      pivot = i
      break
    end
  end

  if pivot == nil then
    return poly
  end
  
  local j = pivot-1 > 0 and pivot-1 or #angleSigns
  local convex_poly = {pivot, j}

  local x2, y2 = poly:get_coord(pivot)
  local x1, y1 = poly:get_coord(j)

  while j~=pivot do
    j = j-1 > 0 and j-1 or #angleSigns
    local x3, y3 = poly:get_coord(j)
    -- dot product of the z component
    -- print ("(x1=" .. x1 .. ", y1=" .. y1 .. ")," .. "(x2=" .. x2 .. ", y2=" .. y2 .. ")," .. "(x3=" .. x3 .. ", y3=" .. y3 .. ")")
    local z = (x1 - x2) * (y3 - y2) - (y1 - y2) * (x3 - x2)
    if z * sign < 0 then
      break
    end
    if angleSigns[j] * sign < 0 then
      break
    end
    table.insert(convex_poly, j);
  end

  local result = {}
  setmetatable(result, PolyMetaTable)
  for _, i in pairs(convex_poly) do
    result:push_coord(poly:get_coord(i))
  end
  result:close()
  return result

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
