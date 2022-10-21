local class = require("src/model/middleclass")
require("src/utils/common")

Automaton_module = {}

Automaton = class("Automaton")
Transition = class("Transition")

Automaton_module.eps = "_epsilon_"

function Automaton:initialize(statesNumber, finalStates, transitions, isDFA)
    if (isDFA == nil) then
        self.isDFA = false
    else 
        self.isDFA = isDFA
    end
    self.states = statesNumber
    self.transitions = {}
    self.transitions_raw = transitions
    self.finality = {}

    for i = 1, statesNumber, 1 do
        self.finality[i] = false
    end
    for i = 1, #finalStates, 1 do
        self.finality[finalStates[i]] = true
    end
    for i = 1, statesNumber, 1 do
        self.transitions[i] = {}
    end

    for i = 1, #transitions, 1 do
        t = transitions[i]
        if (table.length(self.transitions[t.from]) == 0) then
            if (self.isDFA) then
                self.transitions[t.from] = {[t.symbol] = {[t.label] = t.to}}
            else 
                self.transitions[t.from] = {[t.symbol] = {[t.label] = {t.to}}}
            end
        elseif self.transitions[t.from][t.symbol] == nil then
            if (self.isDFA) then
                self.transitions[t.from][t.symbol] = {[t.label] = t.to}
            else 
                self.transitions[t.from][t.symbol] = {[t.label] = {t.to}}
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

function Automaton:allTransitions(state)
    local t = {}
    for k1, v1 in pairs(self.transitions_raw) do
        if v1.from == state then
            table.insert(t, {v1.to, v1.symbol, v1.label})
        end
    end
    return t
end

function Automaton:isStateFinal(state)
    return self.finality[state]
end

function Automaton:changeStateFinality(state)
    self.finality[state] = not self.finality[state]
end

function Automaton:addTransition(from, to, symbol, label)
    if (table.length(self.transitions[from]) == 0) then
        if (self.isDFA) then
            self.transitions[from] = {[symbol] = {[label] = to}}
        else 
            self.transitions[from] = {[symbol] = {[label] = {to}}}
        end
    else 
        table.insert(self.transitions[from][symbol][label], to)
        table.insert(self.transitions_raw, Transition:new(from, to, symbol, label))
    end
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