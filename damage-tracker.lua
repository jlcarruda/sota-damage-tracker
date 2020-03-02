--[[
  Sota Damage Tracker
  v0.1
]]--

local TrackerUI = require("damage-tracker-ui")

function ShroudOnStart()
  charName = ""
end

function ShroudOnUpdate()
  charName = ShroudGetPlayerName()
  partyMembers = ShroudGetPartyMemberNamesInScene()
end

function ShroudOnGUI()
end

function ShroudOnConsoleInput(type, player, messasge)
end