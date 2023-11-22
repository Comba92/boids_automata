package.path = package.path .. ";./libs/?.lua"
Vector = require('brinevector')

function scaledToWorld(x, y)
  return x*Ctx.scale, y*Ctx.scale
end

function worldToScaled(x, y)
  return x/Ctx.scale, y/Ctx.scale
end

function getMouseToScaled()
  return worldToScaled(love.mouse.getPosition())
end

function love.load()
  _W, _H = love.window.getMode()
  local scale = 2

  Ctx = {
    w = _W/scale,
    h = _H/scale,
    scale = 2,
    debug = false,
    running = false
  }
  local canvas = love.graphics.newCanvas(Ctx.w, Ctx.h)
  canvas:setFilter('nearest', 'nearest')
  Ctx.canvas = canvas

  Sliders = require('sliders')
  Boid = require('boid')
  Flock = {}
  for i = 1, 100 do
    table.insert(Flock, Boid.new())
  end

  love.graphics.setDefaultFilter('nearest', 'nearest')
  love.graphics.setLineStyle('rough')
  print("Dimensions: " .. Ctx.w .. " " .. Ctx.h)
end


function love.keypressed(key)
  if key == 'q' or key == 'escape' then
    love.event.quit()
  end

  if key == 'space' then
    Ctx.running = not Ctx.running
  end
end

function love.update(dt)
  local mx, my = getMouseToScaled()
  Sliders:update(mx, my)

  if love.mouse.isDown(2) then
    table.insert(Flock, Boid.new(mx, my))
  end

  if not Ctx.running then return end

  local new_flock = {}
  for _, boid in ipairs(Flock) do
    local new_boid = boid:copy()
    new_boid:separe(Flock)
    new_boid:align(Flock)
    new_boid:cohere(Flock)
    new_boid:update(dt)
    table.insert(new_flock, new_boid)
  end
  Flock = new_flock
end

function love.draw()
  love.graphics.print('Boids: ' .. #Flock, 10, 10)
  love.graphics.print('FPS: ' .. love.timer.getFPS(), 10, 22)

  love.graphics.setCanvas(Ctx.canvas)
    love.graphics.clear()

    for _, boid in ipairs(Flock) do
      boid:draw()
    end

    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle('fill', 0, Ctx.h - 20, Ctx.w, 20)
    love.graphics.setColor(1, 1, 1)
    love.graphics.line(0, Ctx.h - 20, Ctx.w, Ctx.h - 20)
    Sliders:draw()

    -- local mx, my = getMouseToScaled()
    -- love.graphics.circle('line', mx, my, 5)

  love.graphics.setCanvas()

  love.graphics.draw(Ctx.canvas, 0, 0, 0, Ctx.scale, Ctx.scale)
  Sliders:drawNames()
end