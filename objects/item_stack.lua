local class = require("class")

local item_stack = class("item_stack")

item_stack:add_readonly_property("raw", {})

item_stack:add_getter("quantity", function (self)
  return self.raw.size
end)

item_stack:add_getter("max_quantity", function (self)
  return self.raw.maxSize
end)

item_stack:add_getter("damage", function (self)
  return self.raw.damage
end)

item_stack:add_getter("max_damage", function (self)
  return self.raw.maxDamage
end)

item_stack:add_getter("name", function (self)
  return self.raw.label
end)

item_stack:add_getter("id", function (self)
  return self.raw.name
end)

item_stack:add_getter("has_nbt", function (self)
  return self.raw.hasTag
end)

item_stack:add_constructor({"table"}, function (self, tbl)
  self.privates.raw = tbl
end)

return item_stack
