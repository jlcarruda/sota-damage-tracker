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
  x0 = 0
  y0 = 0
  x = 0
  y = 0
  initialize = false
  movable = false

  loadAssets()
end

function ShroudOnUpdate()
  charName = ShroudGetPlayerName()
  partyMembers = ShroudGetPartyMemberNamesInScene()
  if not ShroudServerTime then
    initialize = false
    return
  end

  initialize = true

end

function ShroudOnGUI()
  if initialize then
    drawWindow()
  end
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

-- ========================== BUSINESS METHODS =========================

-- Periodic function to calculate damage per second for all characters
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

-- Get damage sum for a character, in the actual second, from the damage table
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

-- Register the damage sum to a character in the damage table
function registerDamageThisSecond(name, damage)
  if not damageDoneThisSecond[name] then
    damageDoneThisSecond[name] = damage
  else
    damageDoneThisSecond[name] = damageDoneThisSecond[name] + damage
  end
end


-- ==================== UI METHODS =========================

function drawWindow()
  local width = 200
  local height = 100
  local border = 2
  if movable then
    x = ShroudMouseX
    y = ShroudMouseY
  else
    x = x0
    y = y0
  end

  -- Draw bg
  ShroudDrawTexture(x, y, width, height, bgTexture)

  -- Draw borders
  ShroudDrawTexture(x, y, border, height, borderTexture)
  ShroudDrawTexture(x + width, y, border, height, borderTexture)
  ShroudDrawTexture(x, y, width, border, borderTexture)
  ShroudDrawTexture(x, y + height, width + border, border, borderTexture)

  drawMoveButton()
  -- drawDamage()
end

function drawMoveButton()
  if movable then
    if ShroudButton(x - 2, y - 2, 24, 24, buttonTexture, ">") then
      x0 = ShroudMouseX
      y0 = ShroudMouseY
      movable = false
    end
  else
    if ShroudButton(x - 2, y - 2, 24, 24, buttonTexture, ">") then
      movable = true
    end
  end
end

function loadAssets()
  bgTexture = ShroudLoadTexture("damage-tracker/textures/bg.png")
  borderTexture = ShroudLoadTexture("damage-tracker/textures/border.png")
  buttonTexture = ShroudLoadTexture("damage-tracker/textures/button.png")
end

-- ==================== UTIL METHODS =========================

function tableLength(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end
