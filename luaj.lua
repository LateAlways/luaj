luaj = {}



luaj.run = function(code)
    local stringCode = code
    stringCode = stringCode.."\n"
    -- var
    -- func
    function stringTable(string_)
        local table_ = {}
        local fullstr = tostring(string_)
        for i = 1, # string_, 1 do
            table.insert(table_, fullstr:sub(i, i))
        end
        return table_
    end
    function stringFind(string_,startPosition)
        if startPosition == nil then startPosition = 1 end
        for i=startPosition, #string_,1 do
            local v = stringTable(string_)[i]
            if v == "\n" then
                print(v)
                return i
            end
        end
    end
    function mysplit (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
    end
    local parser = {
        startString = 1;
        endString = 1;
        inString = false;
        start1String = 1;
        end1String = 1;
        in1String = false;
        startComment = 1;
        endComment = 1;
        inComment = false;
    }
    local lastParsedChar = "";
    local continuing = false
    repeat
        --print("Parsing")
        continuing = true
        local count = 1
        local newString = ""
        local comments = {}
        local lastComment = false
        local multilineCommentContinue = false
        repeat
            multilineCommentContinue = true
            for i,v in pairs(stringTable(stringCode)) do
                if v == "/" and stringTable(stringCode)[i+1] == "*" then
                    parser.startComment = i
                    parser.inComment = true;
                    multilineCommentContinue = false
                end
                if v == "*" and stringTable(stringCode)[i+1] == "/" then
                    parser.endComment = i+1
                    parser.inComment = false;
                    multilineCommentContinue = false
                end
                
                if lastComment == true and parser.inComment == false then
                    stringCode = stringCode:sub(0,parser.startComment)..stringCode:sub(parser.endComment)
                end
                lastComment = parser.inComment
            end
            if multilineCommentContinue then break end
        until false
        for i,v in pairs(mysplit(stringCode, "\n")) do
            local v = v
            local v1 = v
            local cont = false
            local l = 1
            repeat
                local c = {string.find(v1,"//",l)}
                if string.find(v1,"//",l) then
                    v1 = string.sub(v1,0,c[1]-1)
                    l = l + 1
                else
                    cont = true
                end
            until cont
            newString = newString..v1.."\n"
        end
        stringCode = newString
        for i,v in pairs(stringTable(stringCode)) do
            --print(v, parser.in1String, parser.inString)
            if v == "\"" and not parser.inString then
                parser.startString = count
                parser.inString = true;
            end
            if (v == "\"" and parser.inString and parser.startString ~= count) or v== "\n" then
                parser.endString = count
                parser.inString = false;
            end
            if v == '\'' and not parser.in1String then
                parser.start1String = count
                parser.in1String = true;
            end
            if (v == '\'' and parser.in1String and parser.start1String ~= count) or v== "\n" then
                parser.end1String = count
                parser.in1String = false;
            end
            if stringCode:sub(i,i+2) == "var" and not parser.inString and not parser.in1String and parser.startString ~= count-1 and parser.endString ~= count-1 and parser.start1String ~= count-1 and parser.end1String ~= count-1 then
                stringCode = stringCode:sub(0,count-1).."local"..stringCode:sub(count+3)
            end
            if stringCode:sub(i,i+3) == "func" and not parser.inString and not parser.in1String and parser.startString ~= count and parser.endString ~= count and parser.start1String ~= count and parser.end1String ~= count then
                stringCode = stringCode:sub(0,count-1).."function"..stringCode:sub(count+4)
            end
            count = count + 1
            lastParsedChar = v
        end
        if continuing == true then break end
    until false
    print(stringCode)
    return loadstring(stringCode)()
end
