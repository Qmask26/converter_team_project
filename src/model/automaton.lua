local class = require("middleclass")

Automaton_module = {}

Automaton = class("Automaton")
Edge = class("Edge")
State = class("State")
Transition = class("Transition")

function Edge:initialize(symbol, label)
    self.symbol = symbol
    self.label = label
end

function State:initialize(index, finality, transitions)
    self.index = index
    self.finality = finality
    self.transitions = transitions
end

function Transition:initialize(to, edge)
    self.transition = {[edge] = to}
end

return Automaton_module