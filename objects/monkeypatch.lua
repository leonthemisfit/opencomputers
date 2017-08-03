local oipairs = ipairs
local opairs = pairs
local otype = type

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
function monkeypatch.type(t)
  if otype(t) == "table" and t.__name then
    return t.__name
  else
    return otype(t)
  end
end

function monkeypatch.patch_all()
  ipairs = monkeypatch.ipairs
  pairs = monkeypatch.pairs
  --type = monkeypatch.type <- this breaks OC tab completion, don't do it
end

return monkeypatch
