local Module = {
    Minimize = require("src/automaton_functions/minimization"),
    Determinize = require("src/automaton_functions/determinization"),
    Reverse = require("src/automaton_functions/inverse"),
    RemEps = require("src/automaton_functions/rmeps"),
    Arden = require("src/automaton_functions/arden"),
    SemDet = require("src/automaton_functions/semdet")
}

return Module