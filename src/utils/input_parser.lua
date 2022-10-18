local class = require("src/model/middleclass")
local EM = require("src/model/expression")
local FL = require("src/utils/converter_functions")

identifiersList = {}

Parser = class("Parser") -- Парсит входные данные, предварительно проверенные статическим тайпчекером

function Parser:parse(filename)
    local parsed = {
        expressions = {},
        identifiers = {},
    }
    local expressions = {}
    for line in io.lines(filename) do
        local expression = nil
        if (line:find("=") ~= nil) then
            expression = parseDeclaration(line)
        elseif (line:find("Test") ~= nil) then
            expression = parseTest(line)
        else
            expression = parsePredicate(line)
        end
        expressions[#expressions + 1] = expression
    end
    parsed.expressions = expressions
    return parsed
end

function Parser:parsePredicate(line)
    local lines = split(line)
    local predicate = lines[1]
  --  print("PREDICATE: " .. predicate)
    local arg1 = Parser:parseArgs(predicate, lines[2])
    local arg2 = Parser:parseArgs(predicate, lines[3])
    return EM.computable:new(predicate, EM.computableType.func, arg1, arg2)
end


function Parser:parseArgs(func, arg)
    if (arg == nil) then
        return nil
    end
   -- print("ARG PARSING: " .. arg)
    if (identifiersList[arg] ~= nil) then
     --   print("ARG IS VAR ")
        return EM.computable:new(arg, EM.computableType.variable, identifiersList[arg])
    else
      --  print("ARG IS CONST")
        return EM.computable:new(arg, EM.computableType[FL[func].first])
    end
end

function parseTest(line)
    local args = split(line:sub(6, #line - 1), ",")
    local arg1 = EM.computable:new(trim(args[1]), whatType(trim(args[1])))
    local arg2 = EM.computable:new(trim(args[2]), EM.computableType.Regex)
    local arg3 = EM.computable:new(trim(args[3]), EM.computableType.Int)
    return EM.test:new(arg1, arg2, arg3)
end

function Parser:parseDeclaration(line)
    local lines = split(line, "=")
    local left = trim(lines[1])
    local right = parseRightSide(trim(lines[2]))
    identifiersList[left] = EM.computable:new(left, EM.computableType.variable, right)
    return identifiersList[left]
end

function parseRightSide(right)
    local lines = split(right, " ")
    if (#lines == 1) then
        --print("1: " .. " " .. lines[1] .. " " .. whatType(lines[1]))
        return EM.computable:new(lines[1], whatType(lines[1]))
    elseif (#lines == 2) then
        
        local funcs = split(lines[1], ".")
        funcs[#funcs + 1] = lines[2]
        funcs[#funcs] = EM.computable:new(funcs[#funcs], whatType(funcs[#funcs]))
        --print("2: " .. lines[2] .. " " .. whatType(lines[2]))
        for i = #funcs - 1, 1, -1 do
            funcs[i] = EM.computable:new(funcs[i], EM.computableType.func, funcs[i + 1])
         --   print(funcs[i].name .. " FROM " .. funcs[i + 1].name)
        end
        return funcs[1]
    else 
        --print("3")
        local funcs = split(lines[1], ".")
        funcs[#funcs + 1] = lines[2]
        funcs[#funcs + 1] = lines[3]
        funcs[#funcs] = EM.computable:new(funcs[#funcs], whatType(funcs[#funcs]))
        funcs[#funcs - 1] = EM.computable:new(funcs[#funcs - 1], whatType(funcs[#funcs - 1]))
        funcs[#funcs - 2] = EM.computable:new(funcs[#funcs - 2], EM.computableType.func, funcs[#funcs - 1], funcs[#funcs])
        for i = #funcs - 1, 1, -1 do
            funcs[i] = EM.computable:new(funcs[i], EM.computableType.func, funcs[i + 1])
        end
        return funcs[1]
    end
end

function whatType(c)
    if (#c:gsub("[%d]", "") == 0) then
        return EM.computableType.Int
    elseif (identifiersList[c] ~= nil) then
        return EM.computableType.variable
    else
        return EM.computableType.Regex
    end
end

function trim(line)
    local res = line
    while (res:byte(1) == 32) do
        res = res:sub(2)
    end
    while (res:byte(#res) == 32) do
        res = res:sub(1, #res - 1)
    end
    return res
end

function split(line, pattern)
    local sub = {}
    local tmp = ""
    line = line .. pattern
  --  print(line .. " " .. pattern)
    for i = 1, #line, 1 do
        if (line:byte(i) == pattern:byte(1)) then
            if (#tmp > 0) then
                sub[#sub + 1] = tmp
              --  print(tmp)
            end

            tmp = ""
        else
            tmp = tmp .. line:sub(i, i)
        end
    end
    return sub
end

--print("_" .. trim("    A = b   ") .. "_")
--split("R.f.F aAa.ff.ss.ss", ".")
--Parser:parsePredicate("SemDet 12")
--Parser:parsePredicate("SemDet N1")
--Parser:parsePredicate("SubsetRegex 1 1")
--Parser:parseDeclaration("N1 = Width.MergeBisim.Reverse N2"):compute()
--parseTest("Test((a|ab)*, ((ab*)a)*, 3)")