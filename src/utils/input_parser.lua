local class = require("src/model/middleclass")
local EM = require("src/model/expression")
local FL = require("src/utils/converter_functions")

identifiersList = {}

Parser = class("Parser")
tchck = require("src/typecheck/static")

function Parser:initialize(typecheck)
    self.typecheck = typecheck
end

function Parser:parse(filename)
    local expressions = {}
    for line in io.lines(filename) do
        local expression = nil
        if (self.typecheck) then
            line = tchck:typecheck(line)
        end
        if (line:find("=") ~= nil) then
            expression = EM.expression:new(Parser:parseDeclaration(line), EM.expressionType.computable)
        elseif (line:lower():find("test") ~= nil) then
            expression = EM.expression:new(Parser:parseTest(line), EM.expressionType.test)
        else
            expression = EM.expression:new(Parser:parsePredicate(line), EM.expressionType.computable)
        end
        expressions[#expressions + 1] = expression
    end
    return expressions
end

function Parser:parsePredicate(line)
    local lines = split(line," ")
    local predicate = lines[1]
    local arg1 = Parser:parseArgs(predicate, lines[2])
    local arg2 = Parser:parseArgs(predicate, lines[3])
    local func = EM.computable:new(predicate, EM.computableType.func, arg1, arg2)
    return func
end


function Parser:parseArgs(func, arg)
    if (arg == nil) then
        return nil
    end
    if (identifiersList[arg] ~= nil) then
        return EM.computable:new(arg, EM.computableType.variable, identifiersList[arg].value)
    else
        return EM.computable:new(arg, FL.functions[func].first)
    end
end

function Parser:parseTest(line)
    local args = split(line:sub(6, #line - 1), ",")
    local arg1 = EM.computable:new(trim(args[1]), whatType(trim(args[1])))
    local arg2 = EM.computable:new(trim(args[2]), EM.computableType.Regex)
    local arg3 = EM.computable:new(trim(args[3]), EM.computableType.Int)
    local test = EM.test:new(arg1, arg2, arg3)
end

function Parser:parseDeclaration(line)
    local lines = split(line, "=")
    local left = trim(lines[1])
    local right = Parser:parseRightSide(trim(lines[2]))
    identifiersList[left] = {}
    identifiersList[left].value = EM.computable:new(left, EM.computableType.variable, right)
    identifiersList[left].type = FL.functions[right.name].result
    return identifiersList[left].value
end

function Parser:parseRightSide(right)
    local lines = split(right, " ")
    if (#lines == 1) then
        return EM.computable:new(lines[1], whatType(lines[1]))
    elseif (#lines == 2) then
        
        local funcs = split(lines[1], ".")
        funcs[#funcs + 1] = lines[2]
        funcs[#funcs] = EM.computable:new(funcs[#funcs], whatType(funcs[#funcs]))
        for i = #funcs - 1, 1, -1 do
            funcs[i] = EM.computable:new(funcs[i], EM.computableType.func, funcs[i + 1])
        end
        return funcs[1]
    else 
        local funcs = split(lines[1], ".")
        funcs[#funcs + 1] = lines[2]
        funcs[#funcs + 1] = lines[3]
        funcs[#funcs] = EM.computable:new(funcs[#funcs], whatType(funcs[#funcs]))
        funcs[#funcs - 1] = EM.computable:new(funcs[#funcs - 1], whatType(funcs[#funcs - 1]))
        funcs[#funcs - 2] = EM.computable:new(funcs[#funcs - 2], EM.computableType.func, funcs[#funcs - 1], funcs[#funcs])
        for i = #funcs - 3, 1, -1 do
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
    for i = 1, #line, 1 do
        if (line:byte(i) == pattern:byte(1)) then
            if (#tmp > 0) then
                sub[#sub + 1] = tmp
            end

            tmp = ""
        else
            tmp = tmp .. line:sub(i, i)
        end
    end
    return sub
end

return Parser