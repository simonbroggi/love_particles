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
  
  -- mic input
  local devices = love.audio.getRecordingDevices( )
  for i=1, #devices do
    local mic = devices[i]
    print("Audio Device " .. i)
    print("  bit depth:  ", mic:getBitDepth())
    print("  num chanels:", mic:getChannelCount())
    print("  mic name:   ", mic:getName())
    print("  sample rate:", mic:getSampleRate())
  end
  
  local selectedDevice = 1
  mic = devices[selectedDevice]

  if mic then
    mic_recording = mic:start(256)
    print("\nAudio device " .. selectedDevice .. " recording started.\n")
  end
end

function love.update(dt)
  local degToRad = math.pi / 180
  
  particleSystem:setParticleLifetime(1.0, 1.5)
  
  averageDelta = 0.0
  
  if mic_recording then
    local soundData = mic:getData()
    --local pointer = soundData:getFFIPointer()
    if soundData then
      local lastSample = soundData:getSample(0)
      local sumDelta = 0.0
      local sampleCount = soundData:getSampleCount()
      for i=1, sampleCount-1 do
        local sample = soundData:getSample(i)
        local delta = math.abs(sample - lastSample)
        sumDelta = sumDelta + delta
        lastSample = sample
      end
      
      averageDelta = sumDelta / sampleCount
    end
  end
  
  particleSystem:setEmissionRate(averageDelta * 1000.0)
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
  love.graphics.print(averageDelta, 400, 300)

  love.graphics.draw(particleSystem)
  
  love.graphics.pop()
end

function love.quit()
  if mic_recording then
    mic:stop()
  end
end