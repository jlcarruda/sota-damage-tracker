--[[
  Sota Damage Tracker
  v0.1
]]--

-- local DamageTrackerUI = require("damage-tracker-ui")

function ShroudOnStart()
  charName = ""
  partyMembers = {}
  damageDone = {}
  startTime = os.time()
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
  -- Console log input example: CharacterName attacks Target and hits, dealing 10 points of damage from Thrust
    if type == "CombatSelf" then
      local damageMessage = string.match(message, "dealing %d points? of damage")
      local damage = tonumber(string.match(damageMessage, "%s%d+%s"))
      registerDamage(charName, damage)
      ConsoleLog(damageDone[charName])
    elseif type == "CombatParty" then
      local damageDealer = string.match(message, "(.+)%sattacks")
      local damageMessage = string.match(message, "dealing %d points? of damage")
      local damage = tonumber(string.match(damageMessage, "%s%d+%s"))
    end

end

function registerDamage(name, damage)
  if not damageDone[name] then
    damageDone[name] = damage
  else
    damageDone[name] = damageDone[name] + damage
  end
end