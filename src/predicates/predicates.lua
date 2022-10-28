local Grammar = require("src/model/grammar")
local Automaton_module = require("src/model/automaton")
local Set = require("src/model/set")

require("src/utils/common")
require("src/r2nfa_converter/thompson")
require("src/automaton_functions/determinization")
require("src/automaton_functions/minimization")
require("src/predicates/utils")

local Automaton = Automaton_module.Automaton
local Transition = Automaton_module.Transition

function EquivNFA(nfa1, nfa2)
    local e1 = Det(nfa1)
    local e2 = Det(nfa2)
    print(e1:tostring())
    --print(e2:tostring())
    e1 = minimization(e1)
    e2 = minimization(e2)
    print(e1:tostring())
    --print(e2:tostring())

    return Equal(e1, e2)
end

function EquivRegex(regex1, regex2)
    local nfa1 = create_thompson_automaton(regex1)
    local nfa2 = create_thompson_automaton(regex2)

    return EquivNFA(nfa1, nfa2)
end

function SubsetNFA(nfa1, nfa2)

end

function Annote(nfa, label_prefix)
    local transitions = {}
    local index = 1

    for state_from, table_symbols in pairs(nfa.transitions) do
        for symbol, table_labels in pairs(table_symbols) do
            for _, state_to in pairs(table_labels[""]) do
                transitions[#transitions + 1] = Transition:new(state_from, state_to, symbol, label_prefix..tostring(index))
                index = index + 1
            end
        end
    end

    local new_nfa = Automaton:new(nfa.states, nfa.final_states_raw, transitions, true, nfa.start_states_raw)
    return new_nfa
end

function Equal(nfa1, nfa2)
    local grammar_1 = Grammar.Grammar:new(nfa1, "S", false, "state")
    local grammar_2 = Grammar.Grammar:new(nfa2, "Q", false, "state")
    local grammar_1_reverse = Grammar.Grammar:new(nfa1, "S", false, "reverse")
    local grammar_2_reverse = Grammar.Grammar:new(nfa2, "Q", false, "reverse")

    local is_bisim, equiv_classes_1, equiv_classes_2
    is_bisim, equiv_classes_1, equiv_classes_2, equiv_classes1 = is_bisimilar(grammar_1, grammar_2)
    --print_equiv_classes(equiv_classes1)
    if not is_bisim then return false end

    local is_bisim_reverse, equiv_classes_reverse_1, equiv_classes_reverse_2
    is_bisim_reverse, equiv_classes_reverse_1, equiv_classes_reverse_2, equiv_classes2 = is_bisimilar(grammar_1_reverse, grammar_2_reverse)
    --print_equiv_classes(equiv_classes2)
    if not is_bisim_reverse then return false end

    local equiv_classes = classes_intersection(equiv_classes1, equiv_classes2)
    --print_equiv_classes(equiv_classes)

    local rules1, terminals1, nonterminals1 = grammar_from_transition(nfa1, "A", "S", equiv_classes)
    local rules2, terminals2, nonterminals2 = grammar_from_transition(nfa2, "B", "Q", equiv_classes)

    local transition_grammar_1 = Grammar.Grammar:new(nil, "A", false, "transition")
    local transition_grammar_2 = Grammar.Grammar:new(nil, "B", false, "transition")

    transition_grammar_1.rules = rules1
    transition_grammar_1.terminals = terminals1
    transition_grammar_1.nonterminals = nonterminals1

    transition_grammar_2.rules = rules2
    transition_grammar_2.terminals = terminals2
    transition_grammar_2.nonterminals = nonterminals2

    is_bisim = is_bisimilar(transition_grammar_1, transition_grammar_2)
    if not is_bisim then return false end
    
    return true
end

function Bisimilar(nfa1, nfa2)
    local grammar1 = Grammar.Grammar:new(nfa1, "S", false, "state")
    local grammar2 = Grammar.Grammar:new(nfa2, "Q", false, "state")

    local is_bisim, _ = is_bisimilar(grammar1, grammar2)

    return is_bisim
end

function MergeBisim(nfa)
    local grammar = Grammar.Grammar:new(nfa1, "S", false, "state")
    local new_nfa = merge_bisim(grammar)
    return new_nfa
end
