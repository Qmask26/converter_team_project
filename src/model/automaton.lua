local class = require("src/model/middleclass")

Automaton_module = {}

Automaton = class("Automaton")
Edge = class("Edge")
State = class("State")

function Automaton:initialize(states)
    self.states = states
end

function Edge:initialize(symbol, label)
    self.symbol = symbol
    self.lable = label
end

function Edge:annote(label)
    self.lable = label
end

function Edge:deannote()
    self.lable = nil
end

function State:initialize(isFinal, transitions)
    self.isFinal = isFinal --bool
    self.transitions = transitions -- пары ребро-индекс состояния
end

function State:transit(edge)
    return self.transitions[edge]
end

Automaton_module.Automaton = Automaton
Automaton_module.State = State
Automaton_module.Edge = Edge

return Automaton_module