local class = require("src/model/middleclass")
local Automaton_module = require("src/model/automaton")
local Automaton = Automaton_module.Automaton


function is_dfa(transitions_raw)
    local isDfa = true
    dict = {}
    for k, v in pairs(transitions_raw) do
        if dict[v.from] == nil then
            dict[v.from] = {}
        end
        if dict[v.from][v.symbol] == nil then
            dict[v.from][v.symbol] = 1
        else
            dict[v.from][v.symbol] = dict[v.from][v.symbol] + 1
        end
    end
    for k, v in pairs(transitions_raw) do
        if dict[v.from][v.symbol] > 1 then
            isDfa = false
            break
        end
    end
    return isDfa
end