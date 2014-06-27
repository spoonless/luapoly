
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
    love.graphics.line(poly)
  elseif nb_coord == 1 then
    love.graphics.point(poly:get_coord(1))
  end

  love.graphics.print(msg, 10, 10)
end
