--Все возможные функции преобразователя с типами их аргументов и возвращаемого значения
--argNum - количество аргументовф
--first - первый аргумент
--second - второй аргумент (может отсутсвовать)
--third - есть только у Test
--result - результат вычисления


local CONVETER_FUNCTIONS = {
    Thompson = {
        argNum = 1,
        first = "Regex",
        result = "NFA",
    },

    IlieYu = {
        argNum = 1,
        first = "Regex",
        result = "NFA"
    },

    Antimirov = {
        argNum = 1,
        first = "Regex",
        result = "NFA"
    },

    Arden = {
        argNum = 1,
        first = "NFA",
        result = "Regex"
    },

    Glushkov = {
        argNum = 1,
        first = "Regex",
        result = "NFA"
    },

    Determinize = {
        argNum = 1,
        first = "NFA",
        result = "DFA"
    },

    RemEps = {
        argNum = 1,
        first = "NFA",
        result = "NFA"
    },

    Linearize = {
        argNum = 1,
        first = "Regex",
        result = "Regex"
    },

    Minimize = {
        argNum = 1,
        first = "Regex",
        result = "Regex"
    },

    Reverse = {
        argNum = 1,
        first = "NFA",
        result = "NFA"
    },

    Annote = {
        argNum = 1,
        first = "NFA",
        result = "DFA"
    },

    DeLinearizeNFA = {
        argNum = 1,
        first = "NFA",
        result = "NFA",
    },

    DeLinearizeRegex = {
        argNum = 1,
        first = "Regex",
        result = "Regex",
    },
    
    Complement = {
        argNum = 1,
        first = "DFA",
        result = "DFA"
    },

    DeAnnoteNFA = {
        argNum = 1,
        first = "NFA",
        result = "NFA"
    },

    DeAnnoteRegex = {
        argNum = 1,
        first = "Regex",
        result = "Regex"
    },

    MergeBisim = {
        argNum = 1,
        first = "NFA",
        result = "NFA"
    },

    PumpLength = {
        argNum = 1,
        first = "Regex",
        result = "Int"
    },

    ClassLength = {
        argNum = 1,
        first = "DFA",
        result = "Int"
    },

    KSubSet = {
        argNum = 2,
        first = "Int",
        second = "NFA",
        result = "NFA"
    },

    Normalize = {
        argNum = 2,
        first = "Regex",
        second = "String",
        result = "Bool"
    },

    States = {
        argNum = 1,
        first = "NFA",
        result = "Int"
    },

    ClassCard = {
        argNum = 1,
        first = "DFA",
        result = "Int"
    },

    Ambiguity = {
        argNum = 1,
        first = "NFA",
        result = "Value"
        --Результат может иметь одно из следующих значений: 
        --"Экспоненициально неоднозначен", "Почти однозначен", "Полиномиально неоднозначен", "Однозначен"
    },

    Width = {
        argNum = 1,
        first = "NFA",
        result = "Int"
    }, 

    MyhillNerode = {
        argNum = 1,
        first = "DFA",
        result = "Int"
    },

    Simplify = {
        argNum = 1,
        first = "Regex",
        result = "Regex"
    },

    Bisimilar = {
        argNum = 1,
        first = "NFA",
        second = "NFA",
        result = "Bool",
    },

    MinimalDFA = {
        first = "DFA",
        result = "Bool"
    },

    SubsetRegex = {
        argNum = 1,
        first = "Regex",
        second = "Regex",
        result = "Bool"
    },

    EquivNFA = {
        argNum = 2,
        first = "NFA",
        second = "NFA",
        result = "Bool"
    },

    EquivRegex = {
        argNum = 2,
        first = "Regex",
        second = "Regex",
        result = "Bool"
    },

    MinimalNFA = {
        argNum = 1,
        first = "NFA",
        result = "Bool"
    },

    SubsetNFA = {
        argNum = 2,
        first = "NFA",
        second = "NFA",
        result = "Bool"
    },

    Equal = {
        argNum = 2,
        first = "NFA",
        second = "NFA",
        result = "Bool"
    },

    SemDet = {
        argNum = 1,
        first = "NFA",
        result = "Bool"
    },

    TestNFA = {
        argNum = 3,
        first = "NFA",
        second = "Regex",
        third = "Int",
        result = "IO"
    },

    TestRegex = {
        argNum = 3,
        first = "Regex",
        second = "Regex",
        third = "Int",
        result = "IO"
    }
}

for key, value in pairs(CONVETER_FUNCTIONS) do
    setmetatable(value, {__call = function () print(key) end})
end

return CONVETER_FUNCTIONS
