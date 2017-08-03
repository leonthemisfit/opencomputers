local class_util = require("class_util")

local oipairs = ipairs
local opairs = pairs

local monkeypatch = {}

function monkeypatch.ipairs(t)
  local meta = getmetatable(t)
  if meta and meta.__ipairs then
    return meta.__ipairs(t)
  else
    return oipairs(t)
  end
end

function monkeypatch.pairs(t)
  local meta = getmetatable(t)
  if meta and meta.__pairs then
    return meta.__pairs(t)
  else
    return opairs(t)
  end
end

--[[ This duplicates the class.type functionality found in lua-objects but I'm
also including it here so it can be used to easily patch the built in type
checking function ]]
monkeypatch.type = class_util.type

function monkeypatch.patch_all()
  ipairs = monkeypatch.ipairs
  pairs = monkeypatch.pairs
  --type = monkeypatch.type <- this breaks OC tab completion, don't do it
end

return monkeypatch
