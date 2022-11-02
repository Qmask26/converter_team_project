local class = require("src/model/middleclass")
local Set = require("src/model/set")

Regex_module = {}


Regex_module.operations = {
    concat = 0,
    alt = 1,
    iter = 2,
    symbol = 3,
    empty_set = 4,
    positive = 5
}

bytes = {
    [" "] = 32,
    ["("] = 40,
    [")"] = 41,
    ["*"] = 42,
    ["+"] = 43,
    ["|"] = 124
}

Regex = class("Regex")
RegexNode = class("RegexNode")

--Класс Regex имеет единственное поле - root, корень дерева, представляющего regex
function Regex:initialize(regex)
    self.root = RegexNode:new(regex, #regex ~= 0)
    self.alphabet = parseNodeAlphabet(self.root, #regex ~= 0)
end

function parseNodeAlphabet(regex, parse)
    if not parse then
        return Set:new({})
    end
    if regex.type == Regex_module.operations.symbol then
        local res = Set:new({regex.value})
        return res
    elseif regex.nchildren == 1 then
        local res = parseNodeAlphabet(regex.firstChild, #regex.value ~= 0)
        return res
    else
        local res1 = parseNodeAlphabet(regex.firstChild, #regex.value ~= 0)
        local res2 = parseNodeAlphabet(regex.secondChild, #regex.value ~= 0)
        res2:union(res1)
        return res2
    end
end

function canParseEpsilon(regex)
    return canParseEpsilonRec(regex.root)
end

function canParseEpsilonRec(regex)
    if regex.type == Regex_module.operations.alt then
        return canParseEpsilonRec(regex.firstChild) or canParseEpsilonRec(regex.secondChild)
    elseif regex.type == Regex_module.operations.concat then
        return canParseEpsilonRec(regex.firstChild) and canParseEpsilonRec(regex.secondChild)
    elseif regex.type == Regex_module.operations.iter then
        return true
    elseif regex.type == Regex_module.operations.positive then
        return canParseEpsilonRec(regex.firstChild)
    elseif regex.type == Regex_module.operations.symbol then
        return false
    elseif regex.type == Regex_module.operations.empty_set then
        return true
    end
end

--Класс RegexNode представляет собой вершину в дереве, представляющее regex
--Поле value хранит строку-подвыражение в regex
--Поле value_for_print хранит строку-подвыражение в regex для вывода (отличие в epsilon, т.е. пустой строке)
--Поле type содержит операцию, которая соответствует данному подвыражению (альтернатива, конкатенация, итерация или просто символ)
--Поле nchildren содержит количество дочерних вершин (максимум две). Им соответствуют поля firstChild и secondChild

function RegexNode:initialize(regex, parse)
    self.value = regex
    self.value_for_print = self.value
    if (self.value == "") then
        self.value_for_print = "_epsilon_"
        self.type = Regex_module.operations.empty_set
        self.nchildren = 0
    end
    if parse then
        self.type, self.nchildren, firstChild, secondChild = parseRegexNodeAttributes(regex)
        if firstChild then
            self.firstChild = firstChild
        end
        if secondChild then
            self.secondChild = secondChild
        end
    end
end

function parseRegexNodeAttributes(regex)
    regex = trimBrackets(regex)
    local type = whatTypeOfRegex(regex)
    local nchildren, firstChild, secondChild
    if (type ~= Regex_module.operations.symbol) then 
        local subexpressions = extractSubexpressions(regex, type)
        if (#subexpressions > 1) then
            nchildren = 2
            local firstRegex = ""
            local secondRegex = ""
            local separator = ""
            if (type == Regex_module.operations.alt) then
                separator = "|"
            end
            local firstSize = 0
            local secondSize = 0

            for k, v in pairs(subexpressions) do
                if (k <= #subexpressions / 2) then
                    if (firstSize > 0) then
                        firstRegex = firstRegex .. separator .. v
                    else
                        firstRegex = v
                    end
                    firstSize = firstSize + 1
                else
                    if (secondSize > 0) then
                        secondRegex = secondRegex .. separator .. v
                    else
                        secondRegex = v
                    end
                    secondSize = secondSize + 1
                end
            end
            firstChild = RegexNode:new(firstRegex, #firstRegex ~= 0)
            secondChild = RegexNode:new(secondRegex, #secondRegex ~= 0) 
        else
            nchildren = 1
            firstChild = RegexNode:new(subexpressions[1], #subexpressions[1] ~= 0)
        end
    else
        nchildren = 0
    end
    return type, nchildren, firstChild, secondChild
end

function cbsEndsAt(str, start)
    balance = 0
    for i = start, #str, 1 do
        if (str:byte(i) == bytes["("]) then
            balance = balance + 1
        elseif (str:byte(i) == bytes[")"]) then
            balance = balance - 1
        end
        if (balance == 0) then
            return i
        end
    end
    return -1
end

function whatTypeOfRegex(regex)  
    local operation = 0
    if (#regex == 1) then
        operation = Regex_module.operations.symbol
    elseif (#regex == 2 and regex:byte(2) == bytes["*"] or 
            #regex > 3 and regex:byte(1) == bytes["("] and 
            cbsEndsAt(regex, 1) == #regex - 1 and 
            regex:byte(#regex) == bytes["*"]) then
        operation = Regex_module.operations.iter
    else
        alt = false
        i = 1
        while i <= #regex do
            if (regex:byte(i) == bytes["|"]) then
                alt = true
                break
            elseif (regex:byte(i) == bytes["("]) then
                i = cbsEndsAt(regex, i)
            else
                i = i + 1
            end
        end
        if alt then
            operation = Regex_module.operations.alt
        else
            operation = Regex_module.operations.concat
        end
    end
    return operation
end

function trimBrackets(regex) 
    while (regex:byte(1) == bytes["("] and cbsEndsAt(regex, 1) == #regex) do
        regex = regex:sub(2, #regex - 1)
    end
    return regex
end

function isAlphabetic(c)
    return 
           #c > 0 and
           c:byte(1) ~= bytes["("] and
           c:byte(1) ~= bytes[")"] and
           c:byte(1) ~= bytes["*"] and
           c:byte(1) ~= bytes["|"] and
           c:byte(1) ~= bytes["+"] and
           c:byte(1) ~= bytes[" "]
end

function extractSubexpressions(regex, tp)
    local subexpressions = {}
    if (tp == Regex_module.operations.symbol) then
        if (isAlphabetic(regex)) then
            subexpressions = {regex}
        else 
            subexpressions = {}
        end
    elseif (tp == Regex_module.operations.concat) then
        i = 1
        subexpressions = {}
        while i <= #regex do
            if (regex:byte(i) == bytes["("]) then
                local endsAt = cbsEndsAt(regex, i)
                if (regex:byte(endsAt + 1) == bytes["*"]) then
                    endsAt = endsAt + 1
                end
                subex = regex:sub(i, endsAt)
                if (#subex > 0) then
                    table.insert(subexpressions, subex)
                end
                i = endsAt + 1
            else 
                if (isAlphabetic(string.char(regex:byte(i)))) then
                    if (regex:byte(i + 1) == bytes["*"]) then
                        table.insert(subexpressions, regex:sub(i, i + 1))
                    else 
                        table.insert(subexpressions, string.char(regex:byte(i)))
                    end
                end
                i = i + 1
            end
        end
    elseif (tp == Regex_module.operations.alt) then
        i = 1
        subexpressions = {}
        local subex = ""
        local i = 1
        while i <= #regex do 
            if (regex:byte(i) == bytes["|"]) then
                table.insert(subexpressions, subex)
                subex = ""
                i = i + 1
            elseif (regex:byte(i) == bytes["("]) then
                local endsAt = cbsEndsAt(regex, i)
                if (regex:byte(endsAt + 1) == bytes["*"]) then
                    endsAt = endsAt + 1
                end
                local cbs = regex:sub(i, endsAt)
                if (#cbs > 0) then
                    subex = subex .. cbs
                end
                i = endsAt + 1
            else
                subex = subex .. string.char(regex:byte(i))
                i = i + 1
            end
        end
        table.insert(subexpressions, subex)
    else 
        if (#regex == 2) then
            subexpressions = {regex:sub(1, 1)}
        else 
            subexpressions = {regex:sub(2, #regex - 2)}
        end
    end
    return subexpressions
end

Regex_module.Regex = Regex
Regex_module.RegexNode = RegexNode

return Regex_module