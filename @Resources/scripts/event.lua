--#region
--Pure Lua JSON: https://gist.github.com/tylerneylon/59f4bcf316be525b30ab

local json = {}

-- Internal functions.

local function kind_of(obj)
  if type(obj) ~= 'table' then return type(obj) end
  local i = 1
  for _ in pairs(obj) do
    if obj[i] ~= nil then i = i + 1 else return 'table' end
  end
  if i == 1 then return 'table' else return 'array' end
end

local function escape_str(s)
  local in_char  = {'\\', '"', '/', '\b', '\f', '\n', '\r', '\t'}
  local out_char = {'\\', '"', '/',  'b',  'f',  'n',  'r',  't'}
  for i, c in ipairs(in_char) do
    s = s:gsub(c, '\\' .. out_char[i])
  end
  return s
end

-- Returns pos, did_find; there are two cases:
-- 1. Delimiter found: pos = pos after leading space + delim; did_find = true.
-- 2. Delimiter not found: pos = pos after leading space;     did_find = false.
-- This throws an error if err_if_missing is true and the delim is not found.
local function skip_delim(str, pos, delim, err_if_missing)
  pos = pos + #str:match('^%s*', pos)
  if str:sub(pos, pos) ~= delim then
    if err_if_missing then
      error('Expected ' .. delim .. ' near position ' .. pos)
    end
    return pos, false
  end
  return pos + 1, true
end

-- Expects the given pos to be the first character after the opening quote.
-- Returns val, pos; the returned pos is after the closing quote character.
local function parse_str_val(str, pos, val)
  val = val or ''
  local early_end_error = 'End of input found while parsing string.'
  if pos > #str then error(early_end_error) end
  local c = str:sub(pos, pos)
  if c == '"'  then return val, pos + 1 end
  if c ~= '\\' then return parse_str_val(str, pos + 1, val .. c) end
  -- We must have a \ character.
  local esc_map = {b = '\b', f = '\f', n = '\n', r = '\r', t = '\t'}
  local nextc = str:sub(pos + 1, pos + 1)
  if not nextc then error(early_end_error) end
  return parse_str_val(str, pos + 2, val .. (esc_map[nextc] or nextc))
end

-- Returns val, pos; the returned pos is after the number's final character.
local function parse_num_val(str, pos)
  local num_str = str:match('^-?%d+%.?%d*[eE]?[+-]?%d*', pos)
  local val = tonumber(num_str)
  if not val then error('Error parsing number at position ' .. pos .. '.') end
  return val, pos + #num_str
end

-- Public values and functions.

function json.stringify(obj, as_key)
  local s = {}  -- We'll build the string as an array of strings to be concatenated.
  local kind = kind_of(obj)  -- This is 'array' if it's an array or type(obj) otherwise.
  if kind == 'array' then
    if as_key then error('Can\'t encode array as key.') end
    s[#s + 1] = '['
    for i, val in ipairs(obj) do
      if i > 1 then s[#s + 1] = ', ' end
      s[#s + 1] = json.stringify(val)
    end
    s[#s + 1] = ']'
  elseif kind == 'table' then
    if as_key then error('Can\'t encode table as key.') end
    s[#s + 1] = '{'
    for k, v in pairs(obj) do
      if #s > 1 then s[#s + 1] = ', ' end
      s[#s + 1] = json.stringify(k, true)
      s[#s + 1] = ':'
      s[#s + 1] = json.stringify(v)
    end
    s[#s + 1] = '}'
  elseif kind == 'string' then
    return '"' .. escape_str(obj) .. '"'
  elseif kind == 'number' then
    if as_key then return '"' .. tostring(obj) .. '"' end
    return tostring(obj)
  elseif kind == 'boolean' then
    return tostring(obj)
  elseif kind == 'nil' then
    return 'null'
  else
    error('Unjsonifiable type: ' .. kind .. '.')
  end
  return table.concat(s)
end

json.null = {}  -- This is a one-off table to represent the null value.

function json.parse(str, pos, end_delim)
  pos = pos or 1
  if pos > #str then error('Reached unexpected end of input.') end
  local pos = pos + #str:match('^%s*', pos)  -- Skip whitespace.
  local first = str:sub(pos, pos)
  if first == '{' then  -- Parse an object.
    local obj, key, delim_found = {}, true, true
    pos = pos + 1
    while true do
      key, pos = json.parse(str, pos, '}')
      if key == nil then return obj, pos end
      if not delim_found then error('Comma missing between object items.') end
      pos = skip_delim(str, pos, ':', true)  -- true -> error if missing.
      obj[key], pos = json.parse(str, pos)
      pos, delim_found = skip_delim(str, pos, ',')
    end
  elseif first == '[' then  -- Parse an array.
    local arr, val, delim_found = {}, true, true
    pos = pos + 1
    while true do
      val, pos = json.parse(str, pos, ']')
      if val == nil then return arr, pos end
      if not delim_found then error('Comma missing between array items.') end
      arr[#arr + 1] = val
      pos, delim_found = skip_delim(str, pos, ',')
    end
  elseif first == '"' then  -- Parse a string.
    return parse_str_val(str, pos + 1)
  elseif first == '-' or first:match('%d') then  -- Parse a number.
    return parse_num_val(str, pos)
  elseif first == end_delim then  -- End of an object or array.
    return nil, pos + 1
  else  -- Parse true, false, or null.
    local literals = {['true'] = true, ['false'] = false, ['null'] = json.null}
    for lit_str, lit_val in pairs(literals) do
      local lit_end = pos + #lit_str - 1
      if str:sub(pos, lit_end) == lit_str then return lit_val, lit_end + 1 end
    end
    local pos_info_str = 'position ' .. pos .. ': ' .. str:sub(pos, pos + 10)
    error('Invalid json syntax starting at ' .. pos_info_str)
  end
end
--#endregion

---Parse JSON from bestdori, find event to show
---@param language number 1 is JP, 2 is EN, 3 is TW, 4 is CN, 5 is KR
function GetEvent(language)
  local raw = SKIN:GetMeasure('MeasureEventData'):GetStringValue()
  local data = json.parse(tostring(raw))
  --Previous event ID
  local prevEvent = ''
  --Current event ID
  local currentEvent = ''
  --Next event ID
  local nextEvent = ''
  local diffEndMax = -999999999999999999
  for eventId, eventData in pairs(data) do
    local startAt = eventData['startAt'][language]
    local endAt = eventData['endAt'][language]
    if (type(startAt) == 'string') then
      --startAt - current time
      local diff = os.difftime(tonumber(startAt), os.time() * 1000)
      --diff > 0 means this is next event
      if diff > 0 then
        nextEvent = eventId
      end
    end
    if type(endAt) == 'string' then
      --current time - startAt
      local diffStart = os.difftime(os.time() * 1000, tonumber(startAt))
      --endAt - current time
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
  local characters = eventData['characters']
  local attributes = eventData['attributes']
  local parameterBonus = eventData['eventCharacterParameterBonus']
  --Set option to measures
  SKIN:Bang('!SetOption', 'EventId', 'String', id)
  SKIN:Bang('!SetOption', 'EventType', 'String', eventData['eventType'])
  SKIN:Bang('!SetOption', 'EventName', 'String', eventData['eventName'][language])
  SKIN:Bang('!SetOption', 'EventBundle', 'String', eventData['bannerAssetBundleName'])
  SKIN:Bang('!SetOption', 'EventStart', 'String', eventData['startAt'][language])
  SKIN:Bang('!SetOption', 'EventEnd', 'String', eventData['endAt'][language])
  SKIN:Bang('!SetOption', 'EventAttribute', 'String', attributes[1]['attribute'])
  SKIN:Bang('!SetOption', 'EventAttributePercent', 'String', attributes[1]['percent'])
  for i=1,#characters do
    SKIN:Bang('!SetOption', 'EventCharacter' .. i, 'String', characters[i]['characterId'])
  end
  SKIN:Bang('!SetOption', 'EventCharacterPercent', 'String', characters[1]['percent'])
  if type(parameterBonus) == 'table' then
    for key, value in pairs(parameterBonus) do
      if key ~= 'eventId' and value > 0 then
        SKIN:Bang('!SetOption', 'EventCharacterParameterBonus', 'String', key:sub(1,1):upper()..key:sub(2)..' +'..value..'%')
      end
    end
  end
  SKIN:Bang('!EnableMeasureGroup', 'ImgDl')
  SKIN:Bang('!EnableMeasureGroup', 'Calcs')
end
