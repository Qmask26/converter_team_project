local class = require("src/model/middleclass")
local EM = require("src/model/expression")
local FL = require("src/utils/converter_functions")

identifiersList = {

}

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
    print("PREDICATE: " .. predicate)
    local arg1 = Parser:parsePredicateArg(predicate, lines[2])
    local arg2 = Parser:parsePredicateArg(predicate, lines[3])
    return EM.expression:new(EM.computable:new(predicate, EM.computableType.func, arg1, arg2), EM.expressionType.computable)
end

function Parser:parsePredicateArg(predicate, arg)
    print("ARG PARSING: " .. arg)
    if (identifiersList[arg] ~= nil) then
        print("ARG IS FUNC ")
        return EM.computable:new(arg, EM.computableType.variable, identifiersList[arg])
    else
        print("ARG IS CONST")
        return EM.computable:new(arg, EM.computableType[FL[predicate].first])
    end
end

function split(line)
    local sub = {}
    line = line .. " "
    pattern = " "
    while #line > 0 do
        if (line:find(pattern) ~= nil) then
            local current = line:sub(1, line:find(pattern) - 1)
            if (#current > 0) then
                sub[#sub + 1] = current
                print(current)
            end
            line = line:sub(line:find(pattern) + 1, #line)
        end
    end
    return sub
end

Parser:parsePredicate("SemDet 12")