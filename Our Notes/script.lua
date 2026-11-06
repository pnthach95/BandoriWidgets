--#region Type Definitions

---@class FetchResponse
---@field ok boolean
---@field text fun(): string

---@class (exact) Event
---@field id integer
---@field name table<integer, string>
---@field type integer
---@field startAt integer
---@field endAt integer
---@field logo string

---@class EventEffect
---@field memberCardId integer|nil
---@field bandId integer|nil
---@field cardType integer|nil
---@field rankEffects table<integer, integer>

---@class EventMemberCard
---@field id integer
---@field name table<integer, string>
---@field subtitle table<integer, string>
---@field attribute integer
---@field character integer

---@class EventSupportCard
---@field id integer
---@field name table<integer, string>
---@field subtitle table<integer, string>
---@field attribute integer
---@field characters integer[]

---@class EventDetailRefs
---@field supportCards table<integer, EventSupportCard>
---@field memberCards table<integer, EventMemberCard>

---@class (exact) EventDetail
---@field effects table<integer, EventEffect>
---@field refs EventDetailRefs

---@class (exact) Version
---@field major integer
---@field minor integer
--#endregion

local meter = require("meter")
local fetch = require("fetch")
local json = require("json").decode
local eventsURL = "https://bdon.yatta.moe/Resources/en/MasterParsed/events.json"
local detailEventURL = "https://bdon.yatta.moe/Resources/en/MasterParsed/events/"
local github = "https://api.github.com/repos/pnthach95/BandoriWidgets/releases/latest"
local eventTypeName = {
  [1] = "Challenge"
}
local displayLanguage = {
  [0] = "ja",
  [1] = "en",
  [2] = "zh-Hant",
  [3] = "zh-Hans",
  [4] = "ko"
}

---Convert string to slug
---@param str string
---@return string
local function toSlug(str)
  local a = string.gsub(string.gsub(str,"[^ A-Za-z]",""),"[ ]+","-")
  return a
end

---table.contains
---@param table table
---@param element integer
---@return boolean
function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

---Convert attribute number to string
---@param type integer
---@return string
local function attributeName(type)
  if type == 1 then
    return "Ruby"
  elseif type == 2 then
    return "Azure"
  elseif type == 3 then
    return "Jade"
  elseif type == 4 then
    return "Amber"
  end
  return "Violet"
end

---Convert band number to string
---@param name integer
---@return string
local function bandName(name)
  if name == 1 then
    return "MyGO!!!!!"
  elseif name == 2 then
    return "Ave Mujica"
  elseif name == 3 then
    return "Mugendai MewType"
  elseif name == 4 then
    return "millsage"
  elseif name == 5 then
    return "Ikka Dumb Rock!"
  end
  return tostring(name)
end

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

function rain:init()
  ---@type integer
  local lang = rain:var("DisplayLang")
  ---@type FetchResponse
  local response = fetch(eventsURL)

  if response.ok then
    local eventsText = response:text()
    if not eventsText then
      error('Failed to get data')
    else
      ---@type table<"items", table<string, Event>>
      local events = json(eventsText)
      local currentEventId = "0"
      local lastEventId = "0"
      local currentTime = os.time()
      for i, v in pairs(events.items) do
        if (currentTime >= v.startAt and currentTime <= v.endAt) then
          currentEventId = i
        end
        if tonumber(i, 10) > tonumber(lastEventId, 10) then
          lastEventId = i
        end
      end
      if (currentEventId == "0") then
        currentEventId = lastEventId
      end
      local logoImg = events.items[currentEventId].logo
      local bgImg = string.gsub(string.gsub(logoImg,'logo', 'top'), 'Logo', 'Top')
      local startAt = events.items[currentEventId].startAt
      local endAt = events.items[currentEventId].endAt
      local eventType = events.items[currentEventId].type
      local name = events.items[currentEventId].name[lang + 1]
      rain:bang("!SetVariable", "eventName", name)
      rain:bang("!SetVariable", "logoImg", logoImg)
      rain:bang("!SetVariable", "bgImg", bgImg)
      rain:bang("!SetVariable", "eventId", currentEventId..'/'..toSlug(events.items[currentEventId].name[2]))
      rain:bang("!SetVariable", "startAt", startAt)
      rain:bang("!SetVariable", "endAt", endAt)
      rain:bang("!SetVariable", "displayLanguage", displayLanguage[lang])
      meter("MeterEventType"):text(eventTypeName[eventType] or eventType):update()

    ---@type FetchResponse
      local detailResponse = fetch(detailEventURL..currentEventId..'.json')
      if detailResponse.ok then
        local detailText = detailResponse:text()
        if not detailText then
          error("Failed to get detail")
        else
          ---@type EventDetail
          local detail = json(detailText)
          local effects = detail.effects
          local supportCards = detail.refs.supportCards
          local memberCards = detail.refs.memberCards
          ---@type integer[]
          local memberCardIds = {}
          ---@type integer[]
          local memberCardBonus = {}
          ---@type integer[]
          local bandIds = {}
          ---@type integer[]
          local bandBonus = {}
          ---@type integer[]
          local cardTypes = {}
          ---@type integer[]
          local cardBonus = {}
          for _, v in ipairs(effects) do
            if v.memberCardId and not table.contains(memberCardIds, v.memberCardId) then
              table.insert(memberCardIds, v.memberCardId)
              table.insert(memberCardBonus, v.rankEffects[5])
            end
            if v.bandId and not table.contains(bandIds, v.bandId) then
              table.insert(bandIds, v.bandId)
              table.insert(bandBonus, v.rankEffects[5])
            end
            if v.cardType and not table.contains(cardTypes, v.cardType) then
              table.insert(cardTypes, v.cardType)
              table.insert(cardBonus, v.rankEffects[5])
            end
          end
          for _, v in pairs(supportCards) do
            rain:bang("!SetVariable", "snapId", v.id)
            break
          end
          for i, v in ipairs(memberCardIds) do
            ---@type EventMemberCard|nil
            local memberCard = nil
            for _, vv in pairs(memberCards) do
              if vv.id == v then
                memberCard = vv
                break
              end
            end
            rain:bang("!SetVariable", "memberCardId"..i, v)
            if (memberCard ~= nil)then
              rain:bang("!SetVariable", "memberCardId"..i.."Title", memberCard.name[lang+1])
              rain:bang("!SetVariable", "memberCardId"..i.."Bonus", memberCard.subtitle[lang+1]..": +"..(memberCardBonus[i]/100).."%")
            end
            rain:bang("!SetOption", "MeterMemberCardId"..i, "Hidden", 0)
            rain:bang("!CommandMeasure", "MemberCardImg"..i, "Update")
          end
          for i, v in ipairs(bandIds) do
            rain:bang("!SetVariable", "bandId"..i, v)
            rain:bang("!SetVariable", "bandId"..i.."Bonus", bandName(v).." +"..(bandBonus[i]/100).."%")
            rain:bang("!SetOption", "MeterBandId"..i, "Hidden", 0)
          end
          for i, v in ipairs(cardTypes) do
            rain:bang("!SetVariable", "cardType"..i, v)
            rain:bang("!SetVariable", "cardType"..i.."Bonus", attributeName(v).." +"..(cardBonus[i]/100).."%")
            rain:bang("!SetOption", "MeterCardType"..i, "Hidden", 0)
          end
        end
      end
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
