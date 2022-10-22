require "src/automaton_functions/determinization"
require "src/automaton_functions/inverse"

function minimization(automaton)
    return Det(inverse(Det(inverse(automaton))))
end
return minimization
