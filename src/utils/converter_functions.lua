local Automaton_functions = require("src/automaton_functions/module")
local Derivatives = require("src/derivatives/module")
local r2nfa = require("src/r2nfa_converter/module")
local Predicates = require("src/predicates/predicates")
local pumplength = require("src/functions/pumplength")
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
    Bool = 11,
    IO = 12
}


local  CONVERTER_FUNCTIONS = {
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

    DeLinearize = {
        argNum = 1,
        first = {DATA_TYPES.NFA, DATA_TYPES.Regex},
        result = {DATA_TYPES.NFA, DATA_TYPES.Regex},
        call = {},
    },
    
    Complement = {
        argNum = 1,
        first = DATA_TYPES.DFA,
        result = DATA_TYPES.DFA
    },

    DeAnnote = {
        argNum = 1,
        first = {DATA_TYPES.NFA, DATA_TYPES.Regex},
        result = {DATA_TYPES.NFA, DATA_TYPES.Regex},
        call = {},
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
        result = DATA_TYPES.Bool
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
        result = DATA_TYPES.Bool,
    },

    Minimal = {
        argNum = 1,
        first = {DATA_TYPES.DFA, DATA_TYPES.NFA},
        result = {DATA_TYPES.Bool, DATA_TYPES.Bool},
        call = {}
    },

    Equiv = {
        argNum = 2,
        first = {DATA_TYPES.NFA, DATA_TYPES.Regex},
        second = {DATA_TYPES.NFA, DATA_TYPES.Regex},
        result = {DATA_TYPES.Bool, DATA_TYPES.Bool},
        call = {},
    },

    Subset = {
        argNum = 2,
        first = {DATA_TYPES.Regex, DATA_TYPES.NFA},
        second = {DATA_TYPES.Regex, DATA_TYPES.NFA},
        result = {DATA_TYPES.Bool, DATA_TYPES.Bool},
        call = {}
    },

    Equal = {
        argNum = 2,
        first = DATA_TYPES.NFA,
        second = DATA_TYPES.NFA,
        result = DATA_TYPES.Bool
    },

    SemDet = {
        argNum = 1,
        first = DATA_TYPES.NFA,
        result = DATA_TYPES.Bool
    },

    TestNFA = {
        argNum = 3,
        first = DATA_TYPES.NFA,
        second = DATA_TYPES.Regex,
        third = DATA_TYPES.Int,
        result = DATA_TYPES.IO
    },

    TestRegex = {
        argNum = 3,
        first = DATA_TYPES.Regex,
        second = DATA_TYPES.Regex,
        third = DATA_TYPES.Int,
        result = DATA_TYPES.IO
    },

    isOverloaded = {
        Equiv = true,
        DeLinearize = true,
        DeAnnote = true,
        Subset = true,
        Minimal = true,
    }
}

for key, value in pairs( CONVERTER_FUNCTIONS) do
    if (value.__call == nil) then
        setmetatable(value, {__call = function () 
        print("*COMPUTED*", key)  end})
    end
end

setmetatable( CONVERTER_FUNCTIONS.Thompson, {
     __call = function (x, arg) 
        return r2nfa.Thompson(arg)
     end
})

setmetatable( CONVERTER_FUNCTIONS.Antimirov, {
    __call = function (x, arg) 
        return r2nfa.Antimirov(arg, needToPrintStepByStep)
     end
})

setmetatable(CONVERTER_FUNCTIONS.Glushkov, {
    __call = function (x, arg) 
        return r2nfa.Glushkov(arg, needToPrintStepByStep)
     end
})


setmetatable(CONVERTER_FUNCTIONS.IlieYu, {
    __call = function (x, arg) 
        return r2nfa.IlieYu(arg, needToPrintStepByStep)
     end
})

setmetatable( CONVERTER_FUNCTIONS.Determinize, {
    __call = function (x, arg) 
        return Automaton_functions.Determinize(arg, needToPrintStepByStep)
     end
})

setmetatable( CONVERTER_FUNCTIONS.Minimize, {
    __call = function (x, arg) 
        return Automaton_functions.Minimize(arg, needToPrintStepByStep)
     end
})

setmetatable( CONVERTER_FUNCTIONS.Reverse, {
    __call = function (x, arg) 
        return Automaton_functions.Reverse(arg, needToPrintStepByStep)
     end
})

setmetatable( CONVERTER_FUNCTIONS.Arden, {
    __call = function (x, arg) 
        return Automaton_functions.Arden(arg, needToPrintStepByStep)
     end
})

setmetatable( CONVERTER_FUNCTIONS.RemEps, {
    __call = function (x, arg) 
        return Automaton_functions.RemEps(arg, needToPrintStepByStep)
     end
})

 CONVERTER_FUNCTIONS.Equiv.call[1] = function (arg1, arg2)
    return Predicates.EquivNFA(arg1, arg2, needToPrintStepByStep)
 end

 CONVERTER_FUNCTIONS.Equiv.call[2] = function (arg1, arg2)
    return Predicates.EquivRegex(arg1, arg2, needToPrintStepByStep)
 end

 CONVERTER_FUNCTIONS.Subset.call[1] = function (arg1, arg2)
    return Predicates.SubsetRegex(arg1, arg2, needToPrintStepByStep)
 end

 CONVERTER_FUNCTIONS.Subset.call[2] = function (arg1, arg2)
    return Predicates.SubsetNFA(arg1, arg2, needToPrintStepByStep)
 end



setmetatable( CONVERTER_FUNCTIONS.Equal, {
    __call = function (x, arg1, arg2) 
        return Predicates.Equal(arg1, arg2, needToPrintStepByStep)
     end
})

setmetatable( CONVERTER_FUNCTIONS.Bisimilar, {
    __call = function (x, arg1, arg2) 
        return Predicates.Bisimilar(arg1, arg2, needToPrintStepByStep)
     end
})

setmetatable( CONVERTER_FUNCTIONS.MergeBisim, {
    __call = function (x, arg1) 
        return Predicates.MergeBisim(arg1, needToPrintStepByStep)
     end
})

setmetatable( CONVERTER_FUNCTIONS.PumpLength, {
    __call = function (x, arg1) 
        return pumplength(arg1, needToPrintStepByStep)
     end
})

setmetatable( CONVERTER_FUNCTIONS.SemDet, {
    __call = function (x, arg1) 
        return Automaton_functions.SemDet(arg1, needToPrintStepByStep)
     end
})

setmetatable( CONVERTER_FUNCTIONS.States, {
    __call = function (x, arg1) 
        if (needToPrintStepByStep == true) then
            print("States number: ", arg1.states)
        end
        return arg1.states
     end
})



Metadata = {
    functions =  CONVERTER_FUNCTIONS,
    dataTypes = DATA_TYPES,
}

return Metadata
