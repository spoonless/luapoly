
PolyMetaTable = {}
PolyMetaTable.__index = PolyMetaTable;

function PolyMetaTable.is_closed(poly)
  local nb = #poly
  return nb >=6 and poly[1] == poly[nb-1] and poly[2] == poly[nb]
end

function PolyMetaTable.is_convex(poly)
  if not poly:is_closed() then
    return false
  end

  local zsign = 0
  for i = 1,(#poly-2),2 do
    local n = i
    local x1, y1 = poly[n], poly[n+1]
    n = n + 2 < #poly and n + 2 or 3
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

local poly = setmetatable({}, PolyMetaTable)

if not love then
  love = {}
end

function findConvex(poly)
  local convex = {poly[1], poly[2]}
  local nbSection = 1

  local zsign = 0
  for i = 1,(#poly-2),2 do
    local n = i
    local x1, y1 = convex[#convex-1], convex[#convex]
    n = n + 2 < #poly and n + 2 or 3
    local x2, y2 = poly[n], poly[n+1]
    n = n + 2 < #poly and n + 2 or 3
    local x3, y3 = poly[n], poly[n+1]
    -- dot product of the z component
    local z = (x1 - x2) * (y3 - y2) - (y1 - y2) * (x3 - x2)

    if zsign == 0 then
      zsign = z
    end
    if zsign * z >= 0 then
      table.insert(convex, x2)
      table.insert(convex, y2)
    else
      nbSection = nbSection + 1
      if nbSection > 2 then
        break
      end
      break
    end
  end
  return convex
end

function love.load(args)
  love.graphics.setBackgroundColor(250,250,250)
  love.graphics.setColor(60,60,60)
end

function love.mousepressed(x, y, button)
  if button == 'l' then
    poly:push_coord(x, y)
  elseif button == 'r' then
    poly:close();
  end
end

function love.keypressed(key, isrepeat)
  if (key == "backspace" or key == "delete") then
     poly:pop_coord()
  end
end

local msg = ""

function love.update(dt)
  if poly:get_coord_count() < 3 then
    msg = "Add points (left click)"
  elseif poly:is_closed() then
    msg = poly:is_convex() and "Convex polygon" or "Concave polygon"
  else
    msg = "Add points (left click) or close the polygon (right click to close)"
  end
end

function love.draw()
  local nb_coord = poly:get_coord_count()
  if nb_coord > 1 then
    love.graphics.line(poly)
  elseif nb_coord == 1 then
    love.graphics.point(poly:get_coord(1))
  end
--[[  
  if poly:is_closed() then
    love.graphics.polygon('fill', findConvex(poly))
  end
--]]
  love.graphics.print(msg, 10, 10)
end
