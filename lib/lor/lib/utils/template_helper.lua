local template_helper = {}

template_helper.time =function()
  return ngx.time()
end


template_helper.date =function(format,time)
    if not format then format = '%Y-%m-%d' end
    if not time then time = ngx.time() end
    return os.date(format,tonumber(time))
end

template_helper.substr=function (sName,nMaxCount,nShowCount)

  if sName == nil or nMaxCount == nil then

    return

  end

  local sStr = sName

  local tCode = {}

  local tName = {}

  local nLenInByte = #sStr

  local nWidth = 0

  if nShowCount == nil then

    nShowCount = nMaxCount - 3

  end

  for i=1,nLenInByte do

    local curByte = string.byte(sStr, i)

    local byteCount = 0;

    if curByte>0 and curByte<=127 then

      byteCount = 1

    elseif curByte>=192 and curByte<223 then

      byteCount = 2

    elseif curByte>=224 and curByte<239 then

      byteCount = 3

    elseif curByte>=240 and curByte<=247 then

      byteCount = 4

    end

    local char = nil

    if byteCount > 0 then

      char = string.sub(sStr, i, i+byteCount-1)

      i = i + byteCount -1

    end

    if byteCount == 1 then

      nWidth = nWidth + 1

      table.insert(tName,char)

      table.insert(tCode,1)

    elseif byteCount > 1 then

      nWidth = nWidth + 2

      table.insert(tName,char)

      table.insert(tCode,2)

    end

  end

  if nWidth > nMaxCount then

    local _sN = ""

    local _len = 0

    for i=1,#tName do

      _sN = _sN .. tName[i]

      _len = _len + tCode[i]

      if _len >= nShowCount then

        break

      end

    end

    sName = _sN .. "..."

  end

  return sName

end

return template_helper
