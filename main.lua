
new_poly = require "poly"

local poly = new_poly()

function love.load(args)
  love.graphics.setBackgroundColor(250,250,250)
  love.graphics.setColor(60,60,60)
end

function love.mousepressed(x, y, button)
  if button == 'l' and not poly:is_closed() then
    poly:push_coord(x, y)
  elseif button == 'r' then
    poly:close();
  end
end

function love.keypressed(key, isrepeat)
  if key == "backspace" or key == "delete" then
     poly:pop_coord()
  end
end

local msg = ""

function love.update(dt)
  if poly:get_coord_count() < 3 then
    msg = "Add points (left click)"
  elseif poly:is_closed() then
    msg = poly:is_convex() and "Convex polygon" or "Concave polygon"
    msg = msg .. (poly:is_cw() and " (clockwise)" or " (counterclockwise)")
  else
    msg = "Add points (left click) or close the polygon (right click to close)"
  end
end

function love.draw()
  local nb_coord = poly:get_coord_count()
  if nb_coord > 1 then
    local triangles = poly:get_triangles()
    if triangles then
      local color = {love.graphics.getColor()}
      local color_component = to_circular_array{100,50,200,45,67,125,34,230,80,0,150}
      local color_index=1
      for i = 1,#triangles,3 do
        love.graphics.setColor(color_component[color_index], color_component[color_index+1], color_component[color_index+2], 30)
        color_index = color_index + 1
        local x1, y1 = poly:get_coord(triangles[i])
        local x2, y2 = poly:get_coord(triangles[i+1])
        local x3, y3 = poly:get_coord(triangles[i+2])
        love.graphics.polygon("fill", x1, y1, x2, y2, x3, y3)
      end
      love.graphics.setColor(color)
    end
    love.graphics.line(poly)
  elseif nb_coord == 1 then
    love.graphics.point(poly:get_coord(1))
  end

  love.graphics.print(msg, 10, 10)
end
