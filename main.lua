
local points={}

if not love then
  love = {}
end

function isClosed(points)
  local nb = #points
  return nb >=6 and points[1] == points[nb-1] and points[2] == points[nb]
end

function isConvex(points)
  if not isClosed(points) then
    return false
  end

  local zsign = 0
  for i = 1,(#points-2),2 do
    local n = i
    local x1, y1 = points[n], points[n+1]
    n = n + 2 < #points and n + 2 or 3
    local x2, y2 = points[n], points[n+1]
    n = n + 2 < #points and n + 2 or 3
    local x3, y3 = points[n], points[n+1]
    local z = (x1 - x2) * (y3 - y2) - (y1 - y2) * (x3 - x2)
    z = (z > 0 and 1) or (z < 0 and -1) or 0
    if zsign == 0 then
      zsign = z
    elseif z ~= 0 and z ~= zsign then
      return false
    end
  end
  return true
end

function love.load(args)
  love.graphics.setBackgroundColor(250,250,250)
  love.graphics.setColor(60,60,60)
end

function love.mousepressed(x, y, button)
  if button == 'l' then
    table.insert(points, x)
    table.insert(points, y)
  elseif button == 'r' and #points >= 6 then
    table.insert(points, points[1])
    table.insert(points, points[2])
  end
end

function love.keypressed(key, isrepeat)
  if (key == "backspace" or key == "delete") and #points >= 2 then
    table.remove(points)
    table.remove(points)
  end
end

function love.update(dt)
end

function love.draw()
  if #points > 3 then
    love.graphics.line(points)
  elseif #points == 2 then
    love.graphics.point(points[1], points[2])
  end
  
  local msg = "None closed polygon"
  if isClosed(points) then
    msg = isConvex(points) and "Convex polygon" or "Concave polygon"
  end
  love.graphics.print(msg, 10, 10)
end
