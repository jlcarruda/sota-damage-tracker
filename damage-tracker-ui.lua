local damageTrackerUI = {}
local viewport = {}

damageTrackerUI.viewport = viewport

function damageTrackerUI.setup(vp_width, vp_height)
  damageTrackerUI.viewport.width = vp_width
  damageTrackerUI.viewport.height = vp_height

  damageTrackerUI.width = vp_width * 0.15
  damageTrackerUI.height = vp_height * 0.25
end

function damageTrackerUI.drawTracker()
  -- TODO
end

function damageTrackerUI.writeDamage(player, damage)
end

return damageTrackerUI