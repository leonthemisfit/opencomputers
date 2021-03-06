local sides = require("sides")
local component = require("component")
local term = require("term")
local os = require("os")
local inventory = require("inventory")
local filesystem = require("filesystem")
local io = require("io")
local serialization = require("serialization")

local CACHE_PATH = "/home/itemcache.dat"
local EMPTY_COUNT = 5

local transposer = component.transposer

local inv = {
  trash = inventory(transposer, sides.south),
  controller = inventory(transposer, sides.north),
  ender = inventory(transposer, sides.bottom)
}

local states = {
  CHECK = 1,
  DELETE = 2,
  IGNORE = 3
}

local cache = {}

local cache_changed = false

if filesystem.exists(CACHE_PATH) then
  local file = io.open(CACHE_PATH)
  local data = file:read("*a")
  file:close()
  cache = serialization.unserialize(data)
end

local function move(inv_a, slot, inv_b)
  local stack = inv_a:get_stack(slot)
  if stack then
    return transposer.transferItem(inv_a.side, inv_b.side, stack.size, slot)
  else
    return false
  end
end

local function iter()
  local i = 0
  return function()
    i = i + 1
    if i <= inv.controller.size then
      return i, inv.controller:get_stack(i)
    end
  end
end

local function learn(name)
  cache_changed = true
  term.write("Unknown item '" .. name .. "', (c)heck, (i)gnore, or (d)elete? ")
  local c = term.read()
  if c == "c\n" then
    cache[name] = states.CHECK
  elseif c == "i\n" then
    cache[name] = states.IGNORE
  elseif c == "d\n" then
    cache[name] = states.DELETE
  else
    learn(name)
  end
end

local function delete(slot)
  move(inv.controller, slot, inv.trash)
end

local function try_move(slot)
  return move(inv.controller, slot, inv.ender)
end

while true do
  local empty = 0
  for i, stack in iter() do
    if stack then
      if cache[stack.name] == states.DELETE then
        delete(i)
      elseif cache[stack.name] == states.CHECK then
        if #stack.enchantments > 0 then
          if not try_move(i) then
            delete(i)
          end
        else
          delete(i)
        end
      elseif cache[stack.name] ~= states.IGNORE then
        learn(stack.name)
      end
    else
      empty = empty + 1
      if empty >= EMPTY_COUNT then
        break
      end
    end
  end

  if cache_changed then
    local serial = serialization.serialize(cache)
    local file = io.open(CACHE_PATH, "w")
    file:write(serial)
    file:close()
    cache_changed = false
  end

  os.sleep(1)
end
