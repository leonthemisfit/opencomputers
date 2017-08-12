local sides = require("sides")
local component = require("component")
local term = require("term")
local os = require("os")
local inventory = require("inventory")

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

local function move(inv_a, slot, inv_b)
  return transposer.transferItem(inv_a.side, inv_b.side, 1, slot)
end

local function iter()
  local i = 34
  return function()
    i = i + 1
    if i <= inv.controller.size then
      return i, inv.controller:get_stack(i)
    end
  end
end

local function learn(name)
  term.write("Unknown item '" .. name .. "', (c)heck, (i)gnore, or (d)elete?")
  local c = term.read()
  if c == "c" then
    cache[name] = states.CHECK
  elseif c == "i" then
    cache[name] = states.IGNORE
  elseif c == "d" then
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
    end
  end

  os.sleep(5)
end
