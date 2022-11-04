require "src/automaton_functions/determinization"
require "src/automaton_functions/inverse"

function minimization(automaton, debug)
    if debug then
        print('before minimization')
        print(automaton:tostring())
    end
    local res = Det(inverse(Det(inverse(automaton))))
    if debug then
        print('after minimization')
        print(res:tostring())
    end
    return res
    
end
return minimization
