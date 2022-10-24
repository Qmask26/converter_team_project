require("src/utils/common")
require("src/automaton_functions/is_dfa")



local class = require("src/model/middleclass")
local Automaton_module = require("src/model/automaton")
local Automaton = Automaton_module.Automaton

function inverse(automaton)
    local transitions_inversed = {}
    for k, v in pairs(automaton.transitions_raw) do
        table.insert(transitions_inversed, Transition:new(v.to, v.from, v.symbol, v.label))
    end
    return Automaton:new(automaton.states, copy_table(automaton.start_states_raw), transitions_inversed, is_dfa(transitions_inversed), copy_table(automaton.final_states_raw))
end