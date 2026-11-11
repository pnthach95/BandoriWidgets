--#region Type Definitions

---@class BandoriEvent
---@field eventType string
---@field eventName string[]
---@field bannerAssetBundleName string
---@field assetBundleName string
---@field startAt string[]
---@field endAt string[]
---@field characters {characterId: integer, percent: integer}[]
---@field attributes {attribute: string, percent: integer}[]
---@field eventCharacterParameterBonus {performance: integer, technique: integer, visual: integer}?

--#endregion

local github = "https://api.github.com/repos/pnthach95/BandoriWidgets/releases/latest"

---Parse version to table
---@param v string | number
---@return Version
local function parseVersion(v)
  v = tostring(v)
  local major, minor = v:match("(%d+)%.(%d+)")
  return {
    major = tonumber(major) or 0,
    minor = tonumber(minor) or 0
  }
end

---Uppercase the first letter of a string
---@param name string
---@return string
local function attributeName(name)
  if name == "happy" then
    return "Happy"
  elseif name == "pure" then
    return "Pure"
  elseif name == "cool" then
    return "Cool"
  elseif name == "powerful" then
    return "Powerful"
  end
  return tostring(name)
end

---Uppercase the first letter of a string
---@param name string
---@return string
local function eventTypeName(name)
  if name == "story" then
    return "Story"
  elseif name == "challenge" then
    return "Challenge Live"
  elseif name == "versus" then
    return "Versus Live"
  elseif name == "live_try" then
    return "Live Goals"
  elseif name == "mission_live" then
    return "Mission Live"
  elseif name == "festival" then
    return "Team Live Festival"
  elseif name == "medley" then
    return "Medley Live"
  end
  return tostring(name)
end

local fetch = require("fetch")
local json = require("json").decode
local eventsURL = "https://bestdori.com/api/events/all.5.json"

function rain:init()
  ---@type integer 1 is JP, 2 is EN, 3 is TW, 4 is CN, 5 is KR
  local language = rain:var("DisplayLang")
  ---@type FetchResponse
  local response = fetch(eventsURL)

  if response.ok then
    local eventsText = response:text()
    if not eventsText then
      error('Failed to get data')
    else
      ---@type table<string, BandoriEvent>
      local data = json(eventsText)
      --Previous event ID
      local prevEvent = ''
      --Current event ID
      local currentEvent = ''
      --Next event ID
      local nextEvent = ''
      local diffEndMax = -999999999999999999
      for eventId, eventData in pairs(data) do
        local startAt = eventData.startAt[language]
        local endAt = eventData.endAt[language]
        if (type(startAt) == 'string') then
          ---@diagnostic disable-next-line: param-type-mismatch
          local diff = os.difftime(tonumber(startAt), os.time() * 1000)
          --diff > 0 means this is next event
          if diff > 0 then
            nextEvent = eventId
          end
        end
        if type(endAt) == 'string' then
          --current time - startAt
          ---@diagnostic disable-next-line: param-type-mismatch
          local diffStart = os.difftime(os.time() * 1000, tonumber(startAt))
          --endAt - current time
          ---@diagnostic disable-next-line: param-type-mismatch
          local diffEnd = os.difftime(tonumber(endAt), os.time() * 1000)
          --diffStart > 0 and diffEnd > 0 means this is current event, else means old event.
          if diffStart > 0 and diffEnd > 0 then
            currentEvent = eventId
            --We need to find the most recent old event by checking diff is greater than diffEndMax
          elseif diffEnd > diffEndMax then
            diffEndMax = diffEnd
            prevEvent = eventId
          end
        end
      end

      local id = prevEvent
      if string.len(currentEvent) > 0 then
        id = currentEvent
      elseif string.len(nextEvent) > 0 then
        id = nextEvent
      end

      local eventData = data[id]
      local characters = eventData.characters
      local attributes = eventData.attributes
      local parameterBonus = eventData.eventCharacterParameterBonus
      --Set option to measures
      rain:bang('!SetVariable', 'EventId', id)
      rain:bang('!SetVariable', 'EventType', eventTypeName(eventData.eventType))
      rain:bang('!SetVariable', 'EventName', eventData.eventName[language])
      rain:bang('!SetVariable', 'EventBundle', eventData.bannerAssetBundleName)
      rain:bang('!SetVariable', 'assetBundleName', eventData.assetBundleName)
      rain:bang('!SetVariable', 'EventStart', eventData.startAt[language])
      rain:bang('!SetVariable', 'EventEnd', eventData.endAt[language])
      rain:bang('!SetVariable', 'EventAttribute', attributes[1].attribute)
      rain:bang('!SetVariable', 'EventAttributeText', attributeName(attributes[1].attribute) .. " +" .. attributes[1].percent .. "%")
      for i = 1, #characters do
        rain:bang('!SetOption', 'EventCharacter' .. i, 'String', characters[i].characterId)
      end
      rain:bang('!SetVariable', 'EventCharacterPercent', characters[1].percent)
      if type(parameterBonus) == 'table' then
        for key, value in pairs(parameterBonus) do
          if key ~= 'eventId' and value > 0 then
            rain:bang('!SetVariable', 'EventCharacterParameterBonus',
              key:sub(1, 1):upper() .. key:sub(2) .. ' +' .. value .. '%')
            rain:bang("!SetOption", "MeterParameterBonusInfo", "Hidden", 0)
          end
        end
      end
      rain:bang("!SetOption", "MeterEventName", "Hidden", 0)
      rain:bang("!SetOption", "MeterEventType", "Hidden", 0)
      rain:bang("!SetOption", "MeterAttributeInfo", "Hidden", 0)
      rain:bang("!SetOption", "MeterCharacterBonus", "Hidden", 0)
      rain:bang('!EnableMeasureGroup', 'ImgDl')
      rain:bang('!EnableMeasureGroup', 'Calcs')
    end
  end

  ---@type FetchResponse
  local githubRes = fetch(github)
  if githubRes.ok then
    local gitResText = githubRes:text()
    if not gitResText then
      error('Failed to check version')
    else
      ---@type table<"tag_name", string>
      local gitResJson = json(gitResText)
      local gitVersion = parseVersion(gitResJson.tag_name)
      local currentVersion = parseVersion(rain:var("Version"))
      if gitVersion.major > currentVersion.major then
        rain:bang("!SetOption", "MeterDownloadImg", "Hidden", 0)
      elseif gitVersion.major == currentVersion.major then
        if gitVersion.minor > currentVersion.minor then
          rain:bang("!SetOption", "MeterDownloadImg", "Hidden", 0)
        end
      end
    end
  end
end
