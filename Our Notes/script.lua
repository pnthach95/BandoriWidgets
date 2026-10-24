local meter = require("meter")
local fetch = require("fetch")
local json = require("json").decode
local eventsURL = "https://bdon.yatta.moe/Resources/en/MasterParsed/events.json"
local detailEventURL = "https://bdon.yatta.moe/Resources/en/MasterParsed/events/"
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

local function toSlug(str)
  return string.gsub(string.gsub(str,"[^ A-Za-z]",""),"[ ]+","-")
end

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function rain:init()
  local lang = rain:var("DisplayLang")
  local response = fetch(eventsURL)

  if response.ok then
    local eventsText = response:text()
    if not eventsText then
      error('Failed to get data')
    else
      local events = json(eventsText)
      local currentEventId = "0"
      for i in pairs(events.items) do
        if tonumber(i, 10) > tonumber(currentEventId, 10) then
          currentEventId = i
        end
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

      local detailResponse = fetch(detailEventURL..currentEventId..'.json')
      if detailResponse.ok then
        local detailText = detailResponse:text()
        if not detailText then
          error("Failed to get detail")
        else
          local detail = json(detailText)
          local effects = detail.effects
          local memberCardIds = {}
          local memberCardBonus = {}
          local bandIds = {}
          local bandBonus = {}
          local cardTypes = {}
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
          for i, v in ipairs(memberCardIds) do
            rain:bang("!SetVariable", "memberCardId"..i, v)
            rain:bang("!SetVariable", "memberCardId"..i.."Bonus", memberCardBonus[i]/100)
            rain:bang("!SetOption", "MeterMemberCardId"..i, "Hidden", 0)
            rain:bang("!SetOption", "MeterMemberCardId"..i.."Bonus", "Hidden", 0)
            rain:bang("!CommandMeasure", "MemberCardImg"..i, "Update")
          end
          for i, v in ipairs(bandIds) do
            rain:bang("!SetVariable", "bandId"..i, v)
            rain:bang("!SetVariable", "bandId"..i.."Bonus", bandBonus[i]/100)
            rain:bang("!SetOption", "MeterBandId"..i, "Hidden", 0)
            rain:bang("!SetOption", "MeterBandId"..i.."Bonus", "Hidden", 0)
          end
          for i, v in ipairs(cardTypes) do
            rain:bang("!SetVariable", "cardType"..i, v)
            rain:bang("!SetVariable", "cardType"..i.."Bonus", cardBonus[i]/100)
            rain:bang("!SetOption", "MeterCardType"..i, "Hidden", 0)
            rain:bang("!SetOption", "MeterCardType"..i.."Bonus", "Hidden", 0)
          end
        end
      end
    end
  end
end
