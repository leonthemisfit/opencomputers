local class = require("class")
local item_stack = require("item_stack")

local inventory = class("inventory")

inventory:add_readonly_property("proxy", {})
inventory:add_readonly_property("side", 1)

inventory:add_getter("size", function (self)
  return self.proxy.getInventorySize(self.side)
end)

inventory:add_getter("address", function (self)
  return self.proxy.address
end)

inventory:add_constructor({"table", "number"}, function (self, proxy, side)
  local _, err = proxy.getStackInSlot(side, 1)
  if err ~= nil then
    return nil, err
  end

  self.privates.proxy = proxy
  self.privates.side = side
end)

inventory:add_method("get_stack", function (self, slot)
  local raw_stack = self.proxy.getStackInSlot(self.side, slot)
  if raw_stack ~= nil then
    return item_stack(raw_stack)
  else
    return nil
  end
end)

inventory:add_method("are_stacks_equivalent", function (self, slot_a, slot_b)
  return self.proxy.areStacksEquivalent(self.side, slot_a, slot_b)
end)

inventory:add_overloaded_method("compare_stacks", {"number", "number"},
function (self, slot_a, slot_b)
  return self.proxy.compareStacks(self.side, slot_a, slot_b)
end)

inventory:add_overloaded_method("compare_stacks", {"number", "number", "boolean"},
function (self, slot_a, slot_b, compare_nbt)
  return self.proxy.compareStacks(self.side, slot_a, slot_b, compare_nbt)
end)

inventory:add_method("store", function (self, inv_slot, db_addr, db_slot)
  return self.proxy.store(self.side, inv_slot, db_addr, db_slot)
end)

inventory:add_overloaded_method("compare_to_db", {"number", "string", "number"}
function (self, inv_slot, db_addr, db_slot)
  return self.proxy.compareStackToDatabase(self.side, inv_slot, db_addr, db_slot)
end)

inventory:add_overloaded_method("compare_to_db", {"number", "string", "number", "boolean"},
function (self, inv_slot, db_addr, db_slot, compare_nbt)
  return self.proxy.compareStackToDatabase(self.side, inv_slot, db_addr, db_slot, compare_nbt)
end)

inventory:add_method("get_slot_max", function (self, slot)
  return self.proxy.getSlotMaxStackSize(self.side, slot)
end)

inventory:add_method("get_slot_size", function (self, slot)
  return self.proxy.getSlotStackSize(self.side, slot)
end)

inventory:add_method("scan", function (self)
  local inv = {}
  for i = 1, self.size do
    local raw_stack = self.proxy.getStackInSlot(self.side, i) or {}
    inv[#inv+1] = item_stack(raw_stack)
  end
  return inv
end)

return inventory
