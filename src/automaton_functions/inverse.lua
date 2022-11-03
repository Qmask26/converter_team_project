require("src/utils/common")
require("src/automaton_functions/is_dfa")



local class = require("src/model/middleclass")
local Automaton_module = require("src/model/automaton")
local Automaton = Automaton_module.Automaton

function inverse(automaton, debug)
    if debug then
        print('before inverse')
        print(automaton:tostring())
    end
    local transitions_inversed = {}
    for k, v in pairs(automaton.transitions_raw) do
        table.insert(transitions_inversed, Transition:new(v.to, v.from, v.symbol, v.label))
    end
    local res = Automaton:new(automaton.states, copy_table(automaton.start_states_raw), transitions_inversed, is_dfa(transitions_inversed), copy_table(automaton.final_states_raw))
    if debug then
        print('after inverse')
        print(res:tostring())
    end
    return res
end

return inverse