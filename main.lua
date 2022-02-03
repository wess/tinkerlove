--
-- main.lua
-- neverside
-- 
-- Author: wess (me@wess.io)
-- Created: 02/01/2022
-- 
-- Copywrite (c) 2022 Wess.io
--

if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
end

local sti = require('libs.sti.sti')
local anim8 = require('libs.anim8.anim8')
local bump = require('libs.bump.bump')
local lenny = require('libs.lenny.lenny')
local switch = lenny.switch

local width,height = love.window.getMode()

local player = {}
player.image = love.graphics.newImage('assets/images/character.png')
player.grid = anim8.newGrid(16, 16, player.image:getWidth(), player.image:getHeight())
player.animation = {
  idle = {
    up = anim8.newAnimation(player.grid('1-4', 4), 0.1),
    right = anim8.newAnimation(player.grid('1-4', 3), 0.1),
    down = anim8.newAnimation(player.grid('1-4', 1), 0.1),
    left = anim8.newAnimation(player.grid('1-4', 2), 0.1),
  },
  walk = {
    up = anim8.newAnimation(player.grid('1-7', 4), 0.1),
    right = anim8.newAnimation(player.grid('1-7', 3), 0.1),
    down = anim8.newAnimation(player.grid('1-7', 1), 0.1),
    left = anim8.newAnimation(player.grid('1-7', 2), 0.1),
  },
}

player.speed = 100
player.idle = true
player.direction = 'down'
player.size = {
  width = 16,
  height = 16,
}
player.position = {
  x = (width / 2 - 4),
  y = (height / 2 - 4)
}


function love.load()
  print("Starting game...") 

  love.physics.setMeter(16)

  world = bump.newWorld()
  map = sti('assets/maps/tralgro.lua', {"bump"})
  
  map:bump_init(world)
  world:add(player, player.position.x, player.position.y, player.size.width, player.size.height)
end

function love.update(dt)

  player.position.last = {
    x = player.position.x,
    y = player.position.y,
  }

  local to_position = {
    x = player.position.x,
    y = player.position.y,
  }

  switch(player.direction, {
    ['up'] = function()
      if player.idle == false then
        to_position.y = player.position.y - player.speed * dt  
      end
      
      player.animation.idle.up:update(dt)
    end,
    ['right'] = function()
      if player.idle == false then
        to_position.x = player.position.x + player.speed * dt  
      end

      player.animation.idle.right:update(dt)
    end,
    ['down'] = function()
      if player.idle == false then
        to_position.y = player.position.y + player.speed * dt  
      end

      player.animation.idle.down:update(dt)
    end,
    ['left'] = function()
      if player.idle == false then
        to_position.x = player.position.x - player.speed * dt  
      end

      player.animation.idle.left:update(dt)
    end,
    ['default'] = function()

      player.animation.idle.down:update(dt)
    end
  })

  local x, y, cols, len = world:move(player, to_position.x, to_position.y)

  player.position = {
    x = x,
    y = y,
  }
  for i=1,len do
    print('collided with ' .. tostring(cols[i].other))
  end
end

function love.draw()
  map:draw()
  map:bump_draw()
  
  switch(player.direction, {
    ['up'] = function()
      player.animation.idle.up:draw(player.image, player.position.x, player.position.y)
    end,
    ['right'] = function()
      player.animation.idle.right:draw(player.image, player.position.x, player.position.y)
    end,
    ['down'] = function()
      player.animation.idle.down:draw(player.image, player.position.x, player.position.y)
    end,
    ['left'] = function()
      player.animation.idle.left:draw(player.image, player.position.x, player.position.y)
    end,
    ['default'] = function()
      player.animation.idle.down:draw(player.image, player.position.x, player.position.y)
    end
  })
end

function love.keypressed(key)
  player.idle = false

  switch(key, {
    ['up'] = function()
      player.direction = 'up'
    end,
    ['right'] = function()
      player.direction = 'right'
    end,
    ['down'] = function()
      player.direction = 'down'
    end,
    ['left'] = function()
      player.direction = 'left'
    end,
    ['escape'] = function()
      love.event.quit()
    end
  })
end

function love.keyreleased() 
  player.idle = true
end