local class = require("src/model/middleclass")
local RM = require("src/model/regex")
local funcList = require("src/utils/converter_functions")

Expression = class("Expression")
Computable = class("Computable")
Test = class("Test")

computableType = {
    variable = 0,
    func = 1,
    Int = 2,
    Regex = 3,
}

expressionType = {
    computable = 0,
    test = 1,
}

function Expression:initialize(value, type)
    self.value = value
    self.type = type --Computable / Test
end

function Computable:initialize(name, type, arg1, arg2)
    self.name = name
    self.type = type
    self.arg1 = arg1
    self.arg2 = arg2
    if (self.type == computableType.Int) then
        self.value = tonumber(self.name)
    elseif (self.type == computableType.Regex) then
        self.value = RM.Regex:new(self.name)
    end
end

function Computable:compute()
    print(self.name, self.type, self.value)
    if (self.value == nil) then
        if (self.type == computableType.func) then
            if (self.arg2 == nil) then
                self.value = funcList.functions[self.name](self.arg1:compute())
            else
                if (self.arg2 ~= nil) then
                    self.value = funcList.functions[self.name](self.arg1:compute(), self.arg2:compute())
                else 
                    self.value = funcList.functions[self.name](self.arg1:compute())
                end
            end
        elseif (self.type == computableType.variable) then
            self.value = self.arg1:compute()
        end
    end
    return self.value
end

function Test:initialize(arg1, arg2, arg3)
    self.arg1 = arg1
    self.arg2 = arg2
    self.arg3 = arg3
end

function Test:execute()
    --Позже
end

Expression_module = {
    expression = Expression,
    test = Test,
    computable = Computable,
    computableType = computableType,
    expressionType = expressionType,
}

return Expression_module