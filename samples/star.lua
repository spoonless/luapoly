x = {}
for t in string.gmatch("40,30,30,30,20,20,20,10,30,0,40,0,50,10,50,20,40,30", "([%d%.]+),?") do 
  table.insert(x, t*14) 
end

for i,t in ipairs(x) do
  if i % 2 == 1 then
    x[i] = t - 105
  else
    x[i] = t + 85
  end
end

print(table.concat(x,","))



