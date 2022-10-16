local class = require("src/model/middleclass")

Automaton_module = {}

Automaton = class("Automaton")
Transition = class("Transition")

function Automaton:initialize(statesNumber, finalStates, transitions, isDFA)
    if (isDFA == nil) then
        self.isDFA = false
    else 
        self.isDFA = isDFA
    end

    self.states = statesNumber
    self.transitions = {}
    self.finality = {}
    for i = 1, statesNumber, 1 do
        finality[i] = false
    end
    for i = 1, #finalStates, 1 do
        finality[finalStates[i]] = true
    end
    for i = 1, statesNumber, 1 do
        self.transitions[i] = {}
    end

    for i = 1, #transitions, 1 do
        t = transitions[i]
        if (#self.transitions[t.from]) then
            if (self.isDFA) then
                self.transitions[t.from] = {[t.symbol] = {[t.label] = t.to}}
            else 
                self.transitions[t.from] = {[t.symbol] = {[t.label] = {t.to}}}
            end
        else 
            table.insert(self.transitions[t.from][t.symbol][t.label], t.to)
        end
    end

end

function Automaton:transit(state, symbol, label)
    if (label == nil) then
        label = ""
    end
    if (self.isDFA) then
        return self.transitions[state][symbol][label]
    else 
        return self.transitions[state][symbol][label][1]
    end
end

function Automaton:isStateFinal(state)
    return self.isStateFinal[state]
end

function Transition:initialize(from, to, symbol, label)
    self.from = from
    self.to = to
    self.symbol = symbol
    if (label == nil) then
        self.label = ""
    else 
        self.label = label
    end
end

Automaton_module.Automaton = Automaton
Automaton_module.Transition = Transition

return Automaton_module