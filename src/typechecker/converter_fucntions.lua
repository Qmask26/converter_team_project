--Все возможные функции преобразователя с типами их аргументов и возвращаемого значения
--first - первый аргумент
--second - второй аргумент (может отсутсвовать)
--result - результат вычисления

local CONVETER_FUNCTIONS = {
    Thompson = {
        first = "Regex",
        result = "NFA"
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
        first = "NFA",
        result = "NFA"
    },
    
    Complement = {
        first = "DFA",
        result = "DFA"
    },

    DeAnnote = {
        first = "NFA",
        result = "NFA"
    },

    MergeBisim = {
        first = "NFA",
        second = "NFA"
    }
}

return CONVETER_FUNCTIONS