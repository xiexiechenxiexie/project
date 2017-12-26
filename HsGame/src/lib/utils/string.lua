
function string.unescape(url)
	url = string.gsub(url, "+", " ")
	url = string.gsub(url, "%%(%x%x)", function(hex)
		return string.char(tonumber(hex, 16))
	end)

	return url
end

-- -- Split a string by another string
-- -- Copied and adapted from http://luanet.net/lua/function/explode
function string.explode(s, sep)
	local pos, arr = 0, {}
	for st, sp in function() return string.find(s, sep, pos, true) end do -- for each divider found
		table.insert(arr, string.sub(s, pos, st-1)) -- Attach chars left of current divider
		pos = sp + 1 -- Jump past current divider
	end
	table.insert(arr, s:sub(pos)) -- Attach chars right of last divider
	return arr
end

-- -- find position of first occurrence of a string
function string.strpos(haystack, needle, offset)
	offset = offset or 1
	local start_, end_ = nil, nil
	start_, end_ = string.find(haystack, needle, offset)
	return start_ and start_ - 1 or false
end

function string.indexOf(haystack, needle, offset)
	local v = string.strpos(haystack, needle, offset)
	if v == false then v = -1 end
	return v
end

function string.camelCase(s)
	local splitTable = s:split("_")
	dump(splitTable)
	local result = table.remove(splitTable, 1)
	for i, chunk in ipairs(splitTable) do
		result = result .. chunk:sub(1,1):upper() .. chunk:sub(2)
	end

	return result
end
--------------------------------------------
--字符编码
--------------------------------------------

function string.escape(s)
	s = string.gsub(s, "([!%*'%(%);:@&=%+%$,/%?#%[%]<>~%.\"{}|\\%-`_%^%%%c])",
				function (c)
					return string.format("%%%02X", string.byte(c))
				end)
	s = string.gsub(s, " ", "+")

	return s
end

--------------------------------------------
--print(string.decodeEntities("frac14 divide"))  -- ¼ ÷	2
--------------------------------------------

function string.decodeEntities(s)
	local entities = {
		amp = "&",
		lt = "<",
		gt = ">",
		quot = "\"",
		apos = "'",
		nbsp = " ",
		iexcl = "¡",
		cent = "¢",
		pound = "£",
		curren = "¤",
		yen = "¥",
		brvbar = "¦",
		sect = "§",
		uml = "¨",
		copy = "©",
		ordf = "ª",
		laquo = "«",
		--    not = "¬",
		shy = "­",
		reg = "®",
		macr = "¯",
		deg = "°",
		plusmn = "±",
		sup2 = "²",
		sup3 = "³",
		acute = "´",
		micro = "µ",
		para = "¶",
		middot = "·",
		cedil = "¸",
		sup1 = "¹",
		ordm = "º",
		raquo = "»",
		frac14 = "¼",
		frac12 = "½",
		frac34 = "¾",
		iquest = "¿",
		times = "×",
		divide = "÷",
	}

	return string.gsub(s, "(%w+)", entities)
end


--	转换大小写
function string.caseInsensitive(s)
	s1 = string.gsub(s, "%a", function (c)
		return string.format("%s", string.lower(c))
	end)
	s2 = string.gsub(s, "%a", function (c)
		return string.format("%s", string.upper(c))
	end)
	return s1,s2
end


--字符串处理
function string.toTable(s)  
    local tb = {}  

    for utfChar in string.gmatch(s, "[%z\1-\127\194-\244][\128-\191]*") do  
        table.insert(tb, utfChar)  
    end  
    return tb  
end  

function string.getUTFLen(s)  
    local sTable = string.toTable(s)  
  
    local len = 0  
    local charLen = 0  
  
    for i=1,#sTable do  
        local utfCharLen = string.len(sTable[i])  
        if utfCharLen > 1 then -- 长度大于1的就认为是中文  
            charLen = 2  
        else  
            charLen = 1  
        end  
  
        len = len + charLen  
    end  
  
    return len  
end  



function string.getUTFLenWithCount(s, count)  
    local sTable = string.toTable(s)  
  
    local len = 0  
    local charLen = 0  
    local isLimited = (count >= 0)  
  
    for i=1,#sTable do  
        local utfCharLen = string.len(sTable[i])  
        if utfCharLen > 1 then -- 长度大于1的就认为是中文  
            charLen = 2  
        else  
            charLen = 1  
        end  
  
        len = len + utfCharLen  
  
        if isLimited then  
            count = count - charLen  
            if count <= 0 then  
                break  
            end  
        end  
    end  
  
    return len  
end  

function string.getMaxLen(s, maxLen)  
	maxLen=maxLen or 10

    local len = string.getUTFLen(s)  
    local dstString = s  
    -- 超长，裁剪，加...  
    if len > maxLen then  
        dstString = string.sub(s, 1, string.getUTFLenWithCount(s, maxLen))  
        dstString = dstString.."..."  
    end  
  
    return dstString  
end

function string.getStrLable(str,num)
  local len =string.getUTFLen(str)
  local strtable= {}
  local s=str
  if len>num then
    for i=1,len/num do
      local tmpstr=string.sub(s,1,string.getUTFLenWithCount(s,num))
      table.insert(strtable,tmpstr)
      s=string.sub(str,string.getUTFLenWithCount(str,num*i)+1,string.getUTFLenWithCount(str,len))    
    end
    if len%num>0 then
      table.insert(strtable,s)
    end
  else
      table.insert(strtable,str)
  end
  return strtable
end
