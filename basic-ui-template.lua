-- UI Demo
--
-- Taken from "UI widgets demo" @ https://github.com/monome/we/blob/master/demos/ui.lua.
--
-- E1/K2 : Change page
-- K3 : Change tab
-- E2/3 : Adjust controls
--


local UI = require "ui"

local SCREEN_FRAMERATE = 15
local screen_refresh_metro
local screen_dirty = true

local pages
local tabs
local dial_l
local dial_r
local slider_l
local slider_r
local scrolling_list
local message

local list_content = {}
local message_result = ""


-- Init
function init()
  
  screen.aa(1)
  
  -- Init UI
  ---- Reference: https://github.com/monome/dust/blob/master/lib/lua/mark_eats/ui.lua
  pages = UI.Pages.new(1, 2)

  scrolling_list = UI.ScrollingList.new(8, 8, 0, list_content)
  
  -- Start drawing to screen
  screen_refresh_metro = metro.init()
  screen_refresh_metro.event = function()
    if screen_dirty then
      screen_dirty = false
      redraw()
    end
  end
  screen_refresh_metro:start(1 / SCREEN_FRAMERATE)
  
end


-- Encoder input
function enc(n, delta)
  
  if n == 1 then
    -- Page scroll
    pages:set_index_delta(util.clamp(delta, -1, 1), false)
  end
      
  if pages.index == 2 then
    if n == 2 then
      scrolling_list:set_index_delta(util.clamp(delta, -1, 1))
    end
    
  end
  
  screen_dirty = true
end

-- Key input
function key(n, z)
  if z == 1 then
    
    if n == 2 then
      
      if message then
        message = nil
        message_result = "Cancelled."
        
      else
        pages:set_index_delta(1, true)
      end
      
    elseif n == 3 then
      
      if message then
        message = nil
        message_result = "Confirmed!"
        
      elseif pages.index == 3 then
        message = UI.Message.new({"This is a message.", "", "KEY2 to cancel", "KEY3 to confirm"})
      end
      
    end
    
    screen_dirty = true
  end
end


-- Redraw
function redraw()
  screen.clear()
  
  if message then
    message:redraw()
      
  else
    
    pages:redraw()
      
    if pages.index == 1 then
      scrolling_list:redraw()
      
    elseif pages.index == 2 then
      screen.move(8, 24)
      screen.level(15)
      screen.text("Press KEY3 to")
      screen.move(8, 35)
      screen.text("display a message.")
      screen.move(8, 50)
      screen.level(3)
      screen.text(message_result)
      screen.fill()
      
    end
    
  end
  
  screen.update()
end
