local class = require("src/model/middleclass")

Regex_module = {}


Regex_module.operations = {
    concat = 0,
    alt = 1,
    iter = 2,
    symbol = 3
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
    self.root = RegexNode:new(regex)
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
    end
    
    if parse then
        self.type, self.nchildren, firstChild, secondChild = parseRegexNodeAttributes(regex)
        print(self.nchildren)
        if firstChild then
            self.firstChild = firstChild
        end
        if secondChild then
            self.secondChild = secondChild
        end
    end
end

function parseRegexNodeAttributes(regex)
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
            for k, v in pairs(subexpressions) do
                if (k <= #subexpressions / 2) then
                    if (#firstRegex > 0) then
                        firstRegex = firstRegex .. separator .. v
                    else
                        firstRegex = v
                    end
                else
                    if (#secondRegex > 0) then
                        secondRegex = secondRegex .. separator .. v
                    else
                        secondRegex = v
                    end
                end
            end
            firstChild = RegexNode:new(firstRegex, true)
            secondChild = RegexNode:new(secondRegex, true) 
        else
            nchildren = 1
            firstChild = RegexNode:new(subexpressions[1], true)
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
    if (#regex == 1 or #regex == 0) then
        operation = Regex_module.operations.symbol
    elseif (#regex == 2 and regex:byte(2) == bytes["*"] or 
            #regex > 3 and regex:byte(1) == bytes["("] and 
            regex:byte(#regex - 1) == bytes[")"] and 
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

function altOptionEndsAt(regex, start)
    local i = start
    while i <= #regex do
        if (regex:byte(i) == bytes["("]) then
            i = cbsEndsAt(regex, i) + 1
        elseif (regex:byte(i) == bytes["|"]) then
            return i - 1
        else
            i = i + 1
        end
    end
    
    return #regex - 1
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
                subex = regex:sub(i, endsAt)
                if (#subex > 0) then
                    table.insert(subexpressions, subex)
                end
                i = endsAt + 1
            else 
                if (isAlphabetic(string.char(regex:byte(i)))) then
                    table.insert(subexpressions, string.char(regex:byte(i)))
                end
                i = i + 1
            end
        end
    elseif (tp == Regex_module.operations.alt) then
        regex = "|" .. regex .. "|"
        i = 1
        subexpressions = {}
        while i <= #regex do
            if (regex:byte(i) == bytes["|"]) then
                local endsAt = altOptionEndsAt(regex, i + 1)
                subex = regex:sub(i + 1, endsAt)
                if (#subex > 0) then
                    table.insert(subexpressions, subex)
                end
                i = endsAt + 2
            else 
                if (isAlphabetic(string.char(regex:byte(i)))) then
                    table.insert(subexpressions, string.char(regex:byte(i)))
                end
                i = i + 1
            end
        end
    else 
        subexpressions = {regex:sub(2, #regex - 2)}
    end
    return subexpressions
end

Regex_module.Regex = Regex
Regex_module.RegexNode = RegexNode

return Regex_module