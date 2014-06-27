
local points={}

local function parse_args(args)
  local args_name = {}
  for i, k in ipairs(args) do
    if (k:match("^\\-\\-")) then
      args_name[k] = args[i+1] or true
    end
  end
  
  if args_name["-h"] or args_name["--help"] then
    print([[
Options:
  --cell-ratio     the maximum cells added at the beginning of the game
  --cell-width     cell width in pixels
  --cell-height    cell height in pixels
  --speed          evolution speed (100 means one evolution per second)
  --help or -h     this message
    ]])
    
    os.exit()
  end

  cell_ratio = tonumber(args_name["--cell-ratio"]) or 33
  cell_width = tonumber(args_name["--cell-width"]) or 15
  cell_height = tonumber(args_name["--cell-height"]) or 15
  speed = tonumber(args_name["--speed"]) or 100
  
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
    points[#points] = nil
    points[#points] = nil
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
end
