require "circular_table"
local new_poly = require "poly"

local msg = ""

local shape = {}

local function parse_args(args)
  local vertices_chain={}
  if args[2] then
    local f = io.open(args[2])
    if io.type(f) == "file" then
      for line in f:lines() do
        for t in string.gmatch(line, "([%d%.]+)[,%w]?") do
          table.insert(vertices_chain, tonumber(t))
        end
      end
      f:close()
    else
      for t in string.gmatch(args[2], "([%d%.]+)[,]?") do
        table.insert(vertices_chain, tonumber(t))
      end
    end
  end
  return vertices_chain
end

function love.load(args)
  love.graphics.setBackgroundColor(250,250,250)
  love.graphics.setColor(60,60,60)
  shape.poly = new_poly(parse_args(args))
end

function love.mousepressed(x, y, button)
  if button == 'l' and shape.is_cw_winding == nil then
    shape.poly:push_coord(x, y)
  elseif button == 'r' then
    shape.poly:close()
    shape.is_convex = shape.poly:is_convex()
    shape.is_cw_winding = shape.poly:is_cw()
    shape.triangles = shape.poly:get_triangles()
    print("triangulation of (".. table.concat(shape.poly, ",")..")")
    for _,triangle in ipairs(shape.triangles) do
      print("("..table.concat(triangle,",")..")")
    end
  end
end

function love.keypressed(key, isrepeat)
  if key == "backspace" or key == "delete" then
    shape.poly:pop_coord()
    shape.is_convex = nil
    shape.is_cw_winding = nil
    shape.triangles = nil
  end
end

function love.update(dt)
  if shape.is_cw_winding == nil then
    msg = "Add points (left click)"
    if shape.poly:get_coord_count() > 2 then
      msg = msg .. " or close the polygon (right click to close)"
    end
  else
    msg = shape.is_convex and "Convex polygon" or "Concave polygon"
    msg = msg .. (shape.is_cw_winding and " (clockwise winding)" or " (counterclockwise winding)")
  end
end

local color_components = to_circular_table{255,0,0, 125, 125, 0, 80, 175, 0}

function love.draw()

  if shape.triangles then
    local color = {love.graphics.getColor()}
    local color_index=1
    for _,triangle in ipairs(shape.triangles) do
      love.graphics.setColor(color_components[color_index], color_components[color_index+1], color_components[color_index+2], 150)
      color_index = color_index + 1
      local x1, y1 = shape.poly:get_coord(triangle[1])
      local x2, y2 = shape.poly:get_coord(triangle[2])
      local x3, y3 = shape.poly:get_coord(triangle[3])
      love.graphics.polygon("fill", x1, y1, x2, y2, x3, y3)
    end
    love.graphics.setColor(color)
  end

  local coord_count = shape.poly:get_coord_count()
  if coord_count == 1 then
    love.graphics.point(shape.poly:get_coord(1))
  elseif coord_count > 1 then
    love.graphics.line(shape.poly)
  end

  love.graphics.print(msg, 10, 10)
end
