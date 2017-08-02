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

function monkeypatch.patch_all()
  ipairs = monkeypatch.ipairs
  pairs = monkeypatch.pairs
end

return monkeypatch
