--[[
  Sota Damage Tracker
  v0.1
]]--

function ShroudOnStart()
  charName = ""
  partyMembers = {}
  damageDone = {}
  damageDoneThisSecond = {}
  secondsThreshold = 5
  ShroudRegisterPeriodic("periodic_register_damage", "periodicRegisterDamage", 1.0, true)
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
      registerDamageThisSecond(charName, damage)
    end
end

-- BUSINESS METHODS

function periodicRegisterDamage()

  if tableLength(damageDoneThisSecond) == 0 then
    return
  end

  for name, damage in pairs(damageDoneThisSecond) do
    if not damageDone[name] then
      damageDone[name] = {}
    end

    if tableLength(damageDone[name]) == secondsThreshold then
      table.remove(damageDone[name]) -- removes the last element, because its the oldest
    end


    table.insert(damageDone[name], 1, damage) -- we add the damage always on the start of the table, so we will always pop the most oldest value
    damageDoneThisSecond[name] = 0;
  end
end

function GetDamagePerSecond(name)
  local totalDamage = 0
  for i, damage in pairs(damageDone[name]) do
    totalDamage = totalDamage + damage
  end
  return totalDamage
end

-- UTIL METHODS

function registerDamageThisSecond(name, damage)
  if not damageDoneThisSecond[name] then
    damageDoneThisSecond[name] = damage
  else
    damageDoneThisSecond[name] = damageDoneThisSecond[name] + damage
  end
end

function tableLength(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end
