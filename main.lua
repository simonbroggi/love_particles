-- reference resolution where window scale is 1 (constant!)
-- design for this resolution
local reference_resolution = {w = 640, h = 480} 

-- current translation and scale to make the reference resolution fit
-- into the windows resolution (letterbox/pillarbox)
-- calculated in resize function
local window = {translatex = 0, translatey = 0, scale = 1} 

local function resize_window(w, h)
  local w1, h1 = reference_resolution.w, reference_resolution.h
	local scale = math.min (w/w1, h/h1)
	window.translatex, window.translatey, window.scale = (w-w1*scale)/2, (h-h1*scale)/2, scale
end

function love.resize(w, h)
  print("resizing window to " .. w .. " / " .. h)
  resize_window(w, h)
end

function love.keypressed(key)
  if key == "q" then
    love.event.quit()
  end
end

function love.mousepressed(mx, my, button)
  -- or just use love.mouse.getX() etc in update..
end

function love.load()
  -- resize to scale window initially if needed
  local width, height = love.graphics.getDimensions ()
  resize_window(width, height)
  
  -- enable live coding with ZeroBrane Studio
  if arg and arg[#arg] == "-debug" then require("mobdebug").start() end

  -- create particle system with a white pixel as an image
  local particleImageData = love.image.newImageData(1,1)
  particleImageData:setPixel(0,0,1.0,1.0,1.0,255)
  particleImage = love.graphics.newImage(particleImageData)
  particleSystem = love.graphics.newParticleSystem(particleImage, 1024)
end

function love.update(dt)
  local degToRad = math.pi / 180
  
  particleSystem:setParticleLifetime(1.0, 1.5)
  particleSystem:setEmissionRate(20.0)
  particleSystem:setSpeed(100.0, 150.0)
  particleSystem:setDirection( -90.0 * degToRad)
  particleSystem:setSpread( 30.0 * degToRad)
  particleSystem:setSizes(1.0,16.1)
  particleSystem:setColors( 1.0,1.0,1.0,1.0,
                            1.0,1.0,1.0,1.0,
                            1.0,1.0,1.0,1.0,
                            1.0,1.0,1.0,0.0) 
  particleSystem:setPosition( 310.4, 384.7)
  particleSystem:setSpin( 0.0, 0.0)
  
  particleSystem:update(dt)
end

function love.draw()
  love.graphics.push()
  love.graphics.translate(window.translatex, window.translatey)
	love.graphics.scale(window.scale)

  love.graphics.draw(particleSystem)
  
  love.graphics.pop()
end
