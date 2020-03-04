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

  bgTexture = ShroudLoadTexture("damage-tracker/textures/bg.png")
  borderTexture = ShroudLoadTexture("damage-tracker/textures/border.png")
end

function ShroudOnUpdate()
  charName = ShroudGetPlayerName()
  partyMembers = ShroudGetPartyMemberNamesInScene()
end

function ShroudOnGUI()
  local width = 200
  local height = 100
  local border = 2
  local x = (ShroudGetScreenX() / 2) - (width * .5)
  local y = (ShroudGetScreenY() / 2) + (width * .6)

  -- Draw bg
  ShroudDrawTexture(x, y, width, height, bgTexture)

  -- Draw borders
  ShroudDrawTexture(x, y, border, height, borderTexture)
  ShroudDrawTexture(x + width, y, border, height, borderTexture)
  ShroudDrawTexture(x, y, width, border, borderTexture)
  ShroudDrawTexture(x, y + height, width + border, border, borderTexture)
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
      local damageMessage = string.match(message, "dealing %d points? of")
      if damageMessage then
        local damage = tonumber(string.match(damageMessage, "%s%d+%s"))
        local isCritical = string.match(damageMessage, "of critical damage")

        registerDamageThisSecond(charName, damage)
      end
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


    table.insert(damageDone[name], 1, damage) -- add the damage always on the start of the table, so it will always pop the most oldest value
    damageDoneThisSecond[name] = 0;
  end

  ConsoleLog("DPS: " .. getDamagePerSecond(charName))
end

function getDamagePerSecond(name)
  local totalDamage = 0
  local damageSize = tableLength(damageDone[name])
  for i, damage in pairs(damageDone[name]) do
    totalDamage = totalDamage + damage
  end

  if damageSize > 0 then
    return totalDamage / damageSize
  else
    return 0
  end

end

function registerDamageThisSecond(name, damage)
  if not damageDoneThisSecond[name] then
    damageDoneThisSecond[name] = damage
  else
    damageDoneThisSecond[name] = damageDoneThisSecond[name] + damage
  end
end

-- UTIL METHODS

function tableLength(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end
