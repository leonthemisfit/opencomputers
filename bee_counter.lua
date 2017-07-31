local component = require("component")
local sides = require("sides")

local controllers = {}
local controller_sides = { sides.top, sides.west }

local function find_controllers()
  for addr,name in pairs(component.list()) do
    if name == "inventory_controller" then
      controllers[#controllers+1] = component.proxy(addr)
    end
  end
  if #controllers == 0 then
    error("No controllers found!")
  end
end

local bees = {
  princess = {
    ignoble = {},
    pristine = {}
  },
  drone = {}
}

local function species(stack)
  return stack.individual.displayName
end

local function gender(stack)
  if stack.label:find("Princess") then
    return "princess"
  else
    return "drone"
  end
end

local function princess_type(stack)
  if stack.individual.isNatural then
    return "pristine"
  else
    return "ignoble"
  end
end

local function count(stack)
  return stack.size
end

local function count_bee(stack)
  local gender = gender(stack)
  local species = species(stack)
  if gender == "princess" then
    local type = princess_type(stack)
    if not bees.princess[type][species] then
      bees.princess[type][species] = 0
    end
    bees.princess[type][species] = bees.princess[type][species] + 1
  elseif gender == "drone" then
    local total = count(stack)
    if not bees.drone[species] then
      bees.drone[species] = 0
    end
    bees.drone[species] = bees.drone[species] + total
  else
    print("Something bad happened.")
  end
end

local function count_bees()
  for _,controller in ipairs(controllers) do
    for _, side in ipairs(controller_sides) do
      for i = 1, controller.getInventorySize(side)
        local stack = controller.getStackInSlot(side, i)
        if stack then
          count_bee(stack)
        end
      end
    end
  end
end

local function print_bees()
  print("PRINCESSES:")

  print("  IGNOBLE:")
  for k,v in pairs(bees.princess.ignoble) do
    print("    " .. k .. ": " .. tostring(v))
  end

  print("  PRISTINE:")
  for k,v in pairs(bees.princess.pristine) do
    print("    " .. k .. ": " .. tostring(v))
  end

  print("")
  print("DRONES:")
  for k,v in pairs(bees.drone) do
    print("  " .. k .. ": " .. tostring(v))
  end
end

find_controllers()
count_bees()
print_bees()
