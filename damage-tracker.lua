--[[
  Sota Damage Tracker
  v0.1
]]--

function ShroudOnStart()
  configPath = ShroudLuaPath .. "/damage-tracker/damage-tracker-config"
  configs = getConfigs()

  charName = ""
  partyMembers = {}
  damageDone = {}
  damageDoneThisSecond = {}
  secondsThreshold = 5
  maxAnalyticsToShow = 5
  x = 0
  y = 0
  x0 = tonumber(configs.x)
  y0 = tonumber(configs.y)
  width = tonumber(configs.width)
  height = tonumber(configs.height)
  defaultTextColor = configs.textColor
  screenW = 0
  screenH = 0

  ShroudRegisterPeriodic("periodic_register_damage", "periodicRegisterDamage", 1.0, true)

  hideButtonLock = false
  initialize = false
  movable = false
  isVisible = true

  loadAssets()
end

function ShroudOnUpdate()
  charName = ShroudGetPlayerName()
  partyMembers = ShroudGetPartyMemberNamesInScene()
  screenW = ShroudGetScreenX()
  screenH = ShroudGetScreenY()
  if not ShroudServerTime then
    initialize = false
    return
  end

  initialize = true
  eventOnHideButton()

end

function ShroudOnGUI()
  if initialize and isVisible then
    drawWindow()
    drawMoveButton()
    drawHideButton()
    drawDamage()
  end

  --[[
    What it needs?
    - Draw the UI box for the tracker
    - Per second, needs to do
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

    if damage == 0 then
      table.remove(damageDone[name])
    else
      table.insert(damageDone[name], 1, damage) -- add the damage always on the start of the table, so it will always pop the most oldest value
      damageDoneThisSecond[name] = 0;
    end

  end
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
end

function drawMoveButton()
  if movable then
    if ShroudButton(x - 2, y - 2, 25, 15, buttonTexture, "< >") then
      x0 = ShroudMouseX
      y0 = ShroudMouseY
      configs.x = x0
      configs.y = y0
      saveConfigs()
      movable = false
    end
  else
    if ShroudButton(x - 2, y - 2, 25, 15, buttonTexture, "< >") then
      movable = true
    end
  end
end

function drawHideButton()
  if ShroudButton(x + 25, y - 2, 25, 15, buttonTexture, "-") then
    isVisible = not isVisible
  end
end

function loadAssets()
  bgTexture = ShroudLoadTexture("damage-tracker/textures/bg.png")
  borderTexture = ShroudLoadTexture("damage-tracker/textures/border.png")
  buttonTexture = ShroudLoadTexture("damage-tracker/textures/button.png")
end

function drawDamage()
  local tableSize = tableLength(damageDone)
  local count = 0
  local offsetX = 10
  local offsetY = 20
  local textColor = defaultTextColor

  for character in pairs(damageDone) do
    if count == maxAnalyticsToShow then return end
    local dps = getDamagePerSecond(character)
    if charName == character then textColor = "#00ff00" end
    ShroudGUILabel(x + offsetX, y + offsetY + (5 * count), screenW - (x + width), 20, string.format("<size=11><color=%s>%s : %s/s</color></size>", textColor, character, dps))
    count = count + 1
  end
end

function eventOnHideButton()
  if ShroudGetOnKeyDown("F10") and not hideButtonLock then
    isVisible = not isVisible
    hideButtonLock = true
  end

  if ShroudGetOnKeyUp("F10") then
    hideButtonLock = false
  end
end

-- ==================== UTIL METHODS =========================

function fileExists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

function saveConfigs()
  local file = io.open(configPath, "w")
  for k, v in pairs(configs) do
    local configToSave = k .. "=" .. v .. "\n"
    file:write(configToSave)
  end
  file:close()
end

function getConfigs()
  if not fileExists(configPath) then return {} end
  index = 0
  lines = {}
  for line in io.lines(configPath) do
    local splitted = string.split(line, "=")
    lines[splitted[1]] = splitted[2]
  end
  return lines
end

function tableLength(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end


-- Python Split String like function, made by JoanOrdinas
function string:split(sSeparator, bRegexp, nMax)
  assert(sSeparator ~= '')
  assert(nMax == nil or nMax >= 1)

  local aRecord = {}

  if self:len() > 0 then
     local bPlain = not bRegexp
     nMax = nMax or -1

     local nField, nStart = 1, 1
     local nFirst,nLast = self:find(sSeparator, nStart, bPlain)
     while nFirst and nMax ~= 0 do
        aRecord[nField] = self:sub(nStart, nFirst-1)
        nField = nField+1
        nStart = nLast+1
        nFirst,nLast = self:find(sSeparator, nStart, bPlain)
        nMax = nMax-1
     end
     aRecord[nField] = self:sub(nStart)
  end

  return aRecord
end
