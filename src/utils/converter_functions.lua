--Все возможные функции преобразователя с типами их аргументов и возвращаемого значения
--first - первый аргумент
--second - второй аргумент (может отсутсвовать)
--third - есть только у Test
--result - результат вычисления


local CONVETER_FUNCTIONS = {
    Thompson = {
        first = "Regex",
        result = "NFA",
    },

    IlieYu = {
        first = "Regex",
        result = "NFA"
    },

    Antimirov = {
        first = "Regex",
        result = "NFA"
    },

    Arden = {
        first = "NFA",
        result = "Regex"
    },

    Glushkov = {
        first = "Regex",
        result = "NFA"
    },

    Determinize = {
        first = "NFA",
        result = "DFA"
    },

    RemEps = {
        first = "NFA",
        result = "NFA"
    },

    Linearize = {
        first = "Regex",
        result = "Regex"
    },

    Minimize = {
        first = "Regex",
        result = "Regex"
    },

    Reverse = {
        first = "NFA",
        result = "NFA"
    },

    Annote = {
        first = "NFA",
        result = "DFA"
    },

    DeLinearize = {
        first = {"NFA", "Regexp"},
        result = {"NFA", "Regexp"},
    },
    
    Complement = {
        first = "DFA",
        result = "DFA"
    },

    DeAnnote = {
        first = {"NFA", "Regexp"},
        result = {"NFA", "Regexp"}
    },

    MergeBisim = {
        first = "NFA",
        result = "NFA"
    },

    PumpLength = {
        first = "Regex",
        result = "Int"
    },

    ClassLength = {
        first = "DFA",
        result = "Int"
    },

    KSubSet = {
        first = "Int",
        second = "NFA",
        result = "NFA"
    },

    Normalize = {
        first = "Regex",
        second = "String",
        result = "Bool"
    },

    States = {
        first = "NFA",
        result = "Int"
    },

    ClassCard = {
        first = "DFA",
        result = "Int"
    },

    Ambiguity = {
        first = "NFA",
        result = "Value"
        --Результат может иметь одно из следующих значений: 
        --"Экспоненициально неоднозначен", "Почти однозначен", "Полиномиально неоднозначен", "Однозначен"
    },

    Width = {
        first = "NFA",
        result = "Int"
    }, 

    MyhillNerode = {
        first = "DFA",
        result = "Int"
    },

    Simplify = {
        first = "Regex",
        result = "Regex"
    },

    Bisimilar = {
        first = "NFA",
        second = "NFA",
        result = "Bool",
    },

    Minimal = {
        first = "DFA",
        result = "Bool"
    },

    Subset = {
        first = "Regex",
        second = "Regex",
        result = "Bool"
    },

    Equiv = {
        first = {"NFA", "Regex"},
        second = {"NFA", "Regex"},
        result = "Bool"
    },

    Minimal = {
        first = "NFA",
        result = "Bool"
    },

    Subset = {
        first = "NFA",
        second = "NFA",
        result = "Bool"
    },

    Equal = {
        first = "NFA",
        second = "NFA",
        result = "Bool"
    },

    SemDet = {
        first = "NFA",
        result = "Bool"
    },

    Test = {
        first = {"NFA", "Regex"},
        second = "Regex",
        third = "Int",
        result = "IO"
    }
}

for key, value in pairs do
    value.__call = function () print(key) end
end

return CONVETER_FUNCTIONS
