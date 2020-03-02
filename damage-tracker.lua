--[[
  Sota Damage Tracker
  v0.1
]]--

local TrackerUI = require("damage-tracker-ui")

function ShroudOnStart()
  charName = ""
  charDamage = {}
  partyMembers = {}
end

function ShroudOnUpdate()
  charName = ShroudGetPlayerName()
  partyMembers = ShroudGetPartyMemberNamesInScene()
end

function ShroudOnGUI()
  --[[
    What it needs?
    - Draw the UI box for the tracker
    - Per second, needs to do:
      - Get damage from console and store in each character name table value (probably it will be another table)
      - Push damage to value table with damage as key and time as value
      - Pop damage from the value table which has timestamp older than threshold
      - Sum the damage value in the table
      - Display damage sum in the window, associated with the character name
  ]]--
end

function ShroudOnConsoleInput(type, player, message)
end