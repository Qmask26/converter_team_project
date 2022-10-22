--Все возможные функции преобразователя с типами их аргументов и возвращаемого значения
--argNum - количество аргументовф
--first - первый аргумент
--second - второй аргумент (может отсутсвовать)
--third - есть только у Test
--result - результат вычисления

local DATA_TYPES = {
    Regex = 3,
    NFA = 7,
    DFA = 8,
    Int = 2,
    String = 9,
    Value = 10,
}


local CONVETER_FUNCTIONS = {
    Thompson = {
        argNum = 1,
        first = DATA_TYPES.Regex,
        result = DATA_TYPES.NFA,
    },

    IlieYu = {
        argNum = 1,
        first = DATA_TYPES.Regex,
        result = DATA_TYPES.NFA
    },

    Antimirov = {
        argNum = 1,
        first = DATA_TYPES.Regex,
        result = DATA_TYPES.NFA
    },

    Arden = {
        argNum = 1,
        first = DATA_TYPES.NFA,
        result = DATA_TYPES.Regex
    },

    Glushkov = {
        argNum = 1,
        first = DATA_TYPES.Regex,
        result = DATA_TYPES.NFA
    },

    Determinize = {
        argNum = 1,
        first = DATA_TYPES.NFA,
        result = DATA_TYPES.DFA
    },

    RemEps = {
        argNum = 1,
        first = DATA_TYPES.NFA,
        result = DATA_TYPES.NFA
    },

    Linearize = {
        argNum = 1,
        first = DATA_TYPES.Regex,
        result = DATA_TYPES.Regex
    },

    Minimize = {
        argNum = 1,
        first = DATA_TYPES.DFA,
        result = DATA_TYPES.DFA
    },

    Reverse = {
        argNum = 1,
        first = DATA_TYPES.NFA,
        result = DATA_TYPES.NFA
    },

    Annote = {
        argNum = 1,
        first = DATA_TYPES.NFA,
        result = DATA_TYPES.DFA
    },

    DeLinearizeNFA = {
        argNum = 1,
        first = DATA_TYPES.NFA,
        result = DATA_TYPES.NFA,
    },

    DeLinearizeRegex = {
        argNum = 1,
        first = DATA_TYPES.Regex,
        result = DATA_TYPES.Regex,
    },
    
    Complement = {
        argNum = 1,
        first = DATA_TYPES.DFA,
        result = DATA_TYPES.DFA
    },

    DeAnnoteNFA = {
        argNum = 1,
        first = DATA_TYPES.NFA,
        result = DATA_TYPES.NFA
    },

    DeAnnoteRegex = {
        argNum = 1,
        first = DATA_TYPES.Regex,
        result = DATA_TYPES.Regex
    },

    MergeBisim = {
        argNum = 1,
        first = DATA_TYPES.NFA,
        result = DATA_TYPES.NFA
    },

    PumpLength = {
        argNum = 1,
        first = DATA_TYPES.Regex,
        result = DATA_TYPES.Int
    },

    ClassLength = {
        argNum = 1,
        first = DATA_TYPES.DFA,
        result = DATA_TYPES.Int
    },

    KSubSet = {
        argNum = 2,
        first = DATA_TYPES.Int,
        second = DATA_TYPES.NFA,
        result = DATA_TYPES.NFA
    },

    Normalize = {
        argNum = 2,
        first = DATA_TYPES.Regex,
        second = DATA_TYPES.String,
        result = "Bool"
    },

    States = {
        argNum = 1,
        first = DATA_TYPES.NFA,
        result = DATA_TYPES.Int
    },

    ClassCard = {
        argNum = 1,
        first = DATA_TYPES.DFA,
        result = DATA_TYPES.Int
    },

    Ambiguity = {
        argNum = 1,
        first = DATA_TYPES.NFA,
        result = DATA_TYPES.Value
        --Результат может иметь одно из следующих значений: 
        --"Экспоненициально неоднозначен", "Почти однозначен", "Полиномиально неоднозначен", "Однозначен"
    },

    Width = {
        argNum = 1,
        first = DATA_TYPES.NFA,
        result = DATA_TYPES.Int
    }, 

    MyhillNerode = {
        argNum = 1,
        first = DATA_TYPES.DFA,
        result = DATA_TYPES.Int
    },

    Simplify = {
        argNum = 1,
        first = DATA_TYPES.Regex,
        result = DATA_TYPES.Regex
    },

    Bisimilar = {
        argNum = 1,
        first = DATA_TYPES.NFA,
        second = DATA_TYPES.NFA,
        result = "Bool",
    },

    MinimalDFA = {
        first = DATA_TYPES.DFA,
        result = "Bool"
    },

    SubsetRegex = {
        argNum = 1,
        first = DATA_TYPES.Regex,
        second = DATA_TYPES.Regex,
        result = "Bool"
    },

    EquivNFA = {
        argNum = 2,
        first = DATA_TYPES.NFA,
        second = DATA_TYPES.NFA,
        result = "Bool"
    },

    EquivRegex = {
        argNum = 2,
        first = DATA_TYPES.Regex,
        second = DATA_TYPES.Regex,
        result = "Bool"
    },

    MinimalNFA = {
        argNum = 1,
        first = DATA_TYPES.NFA,
        result = "Bool"
    },

    SubsetNFA = {
        argNum = 2,
        first = DATA_TYPES.NFA,
        second = DATA_TYPES.NFA,
        result = "Bool"
    },

    Equal = {
        argNum = 2,
        first = DATA_TYPES.NFA,
        second = DATA_TYPES.NFA,
        result = "Bool"
    },

    SemDet = {
        argNum = 1,
        first = DATA_TYPES.NFA,
        result = "Bool"
    },

    TestNFA = {
        argNum = 3,
        first = DATA_TYPES.NFA,
        second = DATA_TYPES.Regex,
        third = DATA_TYPES.Int,
        result = "IO"
    },

    TestRegex = {
        argNum = 3,
        first = DATA_TYPES.Regex,
        second = DATA_TYPES.Regex,
        third = DATA_TYPES.Int,
        result = "IO"
    }
}

for key, value in pairs(CONVETER_FUNCTIONS) do
    setmetatable(value, {__call = function () 
    print("*COMPUTED*", key)  end})
end

Metadata = {
    functions = CONVETER_FUNCTIONS,
    dataTypes = DATA_TYPES,
}

return Metadata