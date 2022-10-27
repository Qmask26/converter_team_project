local Grammar = require("src/model/grammar")
local Automaton_module = require("src/model/automaton")
local Regexs = require("src/model/regex")
local Set = require("src/model/set")

require("src/utils/common")
require("src/r2nfa_converter/thompson")

local Automaton = Automaton_module.Automaton
local Transition = Automaton_module.Transition

function EquivNFA(nfa1, nfa2)
    local e1 = minimize(Determinize(nfa1))
    local e2 = minimize(Determinize(nfa2))

    return Equal(e1, e2)
end

function EquivRegex(regex1, regex2)
    local nfa1 = Antimirov(regex1)
    local nfa2 = Antimirov(regex2)

    return EquivNFA(nfa1, nfa2)
end

function SubsetNFA(nfa)

end

function add_label_to_nfa(nfa, label_prefix)
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

    local new_nfa = Automaton:new(nfa.states, nfa.final_states_raw, transitions, nfa.isDFA, nfa.start_states_raw)
    return new_nfa
end

function key_by_val_in_arr(val, table_)
    for key, arr in pairs(table_) do
        for i = 0, #arr, 1 do
            if arr[i] == val then return key end
        end
    end
end

function grammar_from_transition(nfa, transit_prefix, state_prefix, equiv_classes)
    local rules = {}
    local terminals = Set:new({})
    local nonterminals = Set:new({})
    --print(nfa:tostring())
    local new_nfa = add_label_to_nfa(nfa, transit_prefix)
    --print(new_nfa:tostring())

    for state_from, table_symbols in pairs(new_nfa.transitions) do
        for symbol, table_labels in pairs(table_symbols) do
            for label, state_to in pairs(table_labels) do
                local eq_class_num = key_by_val_in_arr(state_prefix..tostring(state_to[1]), equiv_classes)
                local state_from_s = string.char(state_from + 96)
                local state_to_s = string.char(eq_class_num + 96)
                if not terminals:has(state_to_s) then terminals:add(state_to_s) end
                if not key_in_table(label, rules) then
                    nonterminals:add(label)
                    rules[label] = {}
                end
                transitions_of_state_to = new_nfa:allTransitions(state_to[1])
                if transitions_of_state_to[1] == nil then
                    table.insert(rules[label], {state_to_s})
                else
                    for i = 1, #transitions_of_state_to, 1 do
                        table.insert(rules[label], {state_to_s, transitions_of_state_to[i][3]})
                    end
                end
            end
        end
    end
    
    --(table.concat(nonterminals:toarray(), ' '))
    --print(table.concat(terminals:toarray(), ' '))

    --print_rules(rules)
    return rules, terminals, nonterminals
end

function Equal(nfa1, nfa2)
    local grammar_1 = Grammar.Grammar:new(nfa1, "S", false, false, false)
    local grammar_2 = Grammar.Grammar:new(nfa2, "Q", false, false, false)
    local grammar_1_reverse = Grammar.Grammar:new(nfa1, "S", false, false, true)
    local grammar_2_reverse = Grammar.Grammar:new(nfa2, "Q", false, false, true)

    local is_bisim, equiv_classes_1, equiv_classes_2
    is_bisim, equiv_classes_1, equiv_classes_2, equiv_classes1 = is_bisimilar(grammar_1, grammar_2)
    print_equiv_classes(equiv_classes1)
    if not is_bisim then return false end
    --print_equiv_classes(equiv_classes_1)
    --print_equiv_classes(equiv_classes_2)

    local is_bisim_reverse, equiv_classes_reverse_1, equiv_classes_reverse_2
    is_bisim_reverse, equiv_classes_reverse_1, equiv_classes_reverse_2, equiv_classes2 = is_bisimilar(grammar_1_reverse, grammar_2_reverse)
    print_equiv_classes(equiv_classes2)
    --print_equiv_classes(equiv_classes_reverse_1)
    --print_equiv_classes(equiv_classes_reverse_2)
    if not is_bisim_reverse then return false end

    local equiv_classes1 = {}
    equiv_classes1[1] = {"S1"}
    equiv_classes1[2] = {"S3"}
    equiv_classes1[3] = {"S2"}
    equiv_classes1[4] = {"S4"}
    equiv_classes1[5] = {"S5"}

    local equiv_classes2 = {}
    equiv_classes2[1] = {"Q1"}
    equiv_classes2[2] = {"Q3"}
    equiv_classes2[3] = {"Q2"}
    equiv_classes2[4] = {"Q4"}
    equiv_classes2[5] = {"Q5"}

    local equiv_classes = {}
    equiv_classes[1] = {"S1", "Q1"}
    equiv_classes[2] = {"S2", "Q2"}
    equiv_classes[3] = {"S3", "Q3"}
    equiv_classes[4] = {"S4", "Q4"}
    equiv_classes[5] = {"S5", "Q5"}

    local rules1, terminals1, nonterminals1 = grammar_from_transition(nfa1, "A", "S", equiv_classes)
    local rules2, terminals2, nonterminals2 = grammar_from_transition(nfa2, "B", "Q", equiv_classes)

    local transition_grammar_1 = Grammar.Grammar:new(nil, "A", false, true, false)
    local transition_grammar_2 = Grammar.Grammar:new(nil, "B", false, true, false)

    transition_grammar_1.rules = rules1
    transition_grammar_1.terminals = terminals1
    transition_grammar_1.nonterminals = nonterminals1

    transition_grammar_2.rules = rules2
    transition_grammar_2.terminals = terminals2
    transition_grammar_2.nonterminals = nonterminals2

    is_bisim, _ = is_bisimilar(transition_grammar_1, transition_grammar_2)
    print('is equal:')
    if not is_bisim then return false end
    
    return true
end

function print_rules(rules)
    for nonterm, _ in pairs(rules) do
        for i = 1, #rules[nonterm], 1 do
            print(nonterm..' -> '..table.concat(rules[nonterm][i], ' '))
        end
    end
    print()
    print()
end

function print_equiv_classes(classes)
    for k, v in pairs(classes) do
        print(tostring(k) .. ': ' .. table.concat(v, ' '))
    end
    print()
    print()
end

function grammar_union(rules1, rules2, nonterminals1, nonterminals2)
    for nonterm, _ in pairs(rules2) do
        rules1[nonterm] = {}
        for i = 1, #rules2[nonterm], 1 do
            table.insert(rules1[nonterm], rules2[nonterm][i])
        end
    end
    for i = 1, #nonterminals2, 1 do
        nonterminals1[#nonterminals1 + 1] = nonterminals2[i]
    end
    return rules1, nonterminals1
end

function make_new_grammar(rules, empty_nonterminals, nonterminals, equiv_classes, classes)
    local new_rules = {}
    local new_terminals = {}
    local new_nonterminals = {}
    local empty_nonterm
    if empty_nonterminals[1] ~= nill then empty_nonterm = empty_nonterminals[1] end

    for _, eqNonterms in pairs(equiv_classes) do
        local nonterm = eqNonterms[1]
        new_rules[nonterm] = {}
        for i = 1, #rules[nonterm], 1 do
            new_rules[nonterm][#new_rules[nonterm] + 1] = {}
            for j = 1, #rules[nonterm][i], 1 do
                local symbol = rules[nonterm][i][j]
                if string_match(nonterminals, symbol) then
                    if classes[symbol] == '_' then
                        new_rules[nonterm][i][j] = empty_nonterm
                    else
                        new_rules[nonterm][i][j] = equiv_classes[classes[symbol]][1]
                    end
                else
                    new_rules[nonterm][i][j] = symbol
                end
            end
        end
    end

    if empty_nonterminals[1] ~= nill then
        new_rules[empty_nonterm] = {{}}

        equiv_classes[#equiv_classes + 1] = {}
        for i = 1, #empty_nonterminals, 1 do
            table.insert(equiv_classes[#equiv_classes], empty_nonterminals[i])
        end
    end

    for nonterm, _ in pairs(new_rules) do
        new_nonterminals[#new_nonterminals + 1] = nonterm
    end

    return new_rules, new_nonterminals, equiv_classes
end

function split_classes(rules, classes, nonterminals)
    new_rules = {}
    nonterminal_classes = {}

    for nonterm, _ in pairs(rules) do
        local words = {}
        for i = 1, #rules[nonterm], 1 do
            local word = {}
            for j = 1, #rules[nonterm][i], 1 do
                local symbol = rules[nonterm][i][j]
                if string_match(nonterminals, symbol) then
                    if type(classes[symbol]) == "number" then
                        word[#word + 1] = tostring(classes[symbol])
                    else
                        word[#word + 1] = classes[symbol]
                    end
                else
                    word[#word + 1] = symbol
                end
            end
            table.insert(words, word)
        end

        local w = ""
        for _, word in pairs(words) do
            for j = 1, #word, 1 do
                w = w..word[j]..","
            end
        end

        local w1 = {}
        for s in string.gmatch(w, "[^,]+") do
            table.insert(w1, s)
        end
        table.sort(w1)
        w = table.concat(w1, '')
        --print(w)
        
        if key_in_table(w, new_rules) then
            table.insert(nonterminal_classes[w], nonterm)
        else
            nonterminal_classes[w] = {nonterm}
            new_rules[w] = nonterm
        end
    end

    local equiv_classes = {}
    local index = 1
    for key, _ in pairs(nonterminal_classes) do
        equiv_classes[#equiv_classes + 1] = nonterminal_classes[key]
        for i = 1, #nonterminal_classes[key], 1 do
            classes[nonterminal_classes[key][i]] = index
        end
        index = index + 1
    end

    return classes, equiv_classes
end

function division_into_equivalence_classes(input_rules, nonterminals)
    local rules = {}
    local classes = {}
    local empty_nonterminals = {}

    for key, val in pairs(input_rules) do
        if #input_rules[key][1] ~= 0 then
            rules[key] = input_rules[key]
        else
            empty_nonterminals[#empty_nonterminals + 1] = key
        end
    end
    for i = 1, #nonterminals, 1 do
        classes[nonterminals[i]] = "_"
    end

    classes, equiv_classes = split_classes(rules, classes, nonterminals)
    local old_size = #equiv_classes

    while true do
        classes, equiv_classes = split_classes(rules, classes, nonterminals)
        if old_size == #equiv_classes then
            break
        end
        old_size = #equiv_classes
    end

    rules, nonterminals, equiv_classes = make_new_grammar(rules, empty_nonterminals, nonterminals, equiv_classes, classes)

    return rules, nonterminals, equiv_classes
end

function Bisimilar(nfa1, nfa2)
    local grammar1 = Grammar.Grammar:new(nfa1, "S", false, false)
    local grammar2 = Grammar.Grammar:new(nfa2, "Q", false, false)

    local is_bisim, _ = is_bisimilar(grammar1, grammar2)

    return is_bisim
end

function is_bisimilar(grammar1, grammar2)
    local input_rules1 = grammar1.rules
    local terminals1 = grammar1.terminals:toarray()
    local nonterminals1 = grammar1.nonterminals:toarray()
    
    local input_rules2 = grammar2.rules
    local terminals2 = grammar2.terminals:toarray()
    local nonterminals2 = grammar2.nonterminals:toarray()

    -- проверка на равенство количества терминналов
    if #terminals1 ~= #terminals2 then return false end
    table.sort(terminals1)
    table.sort(terminals2)
    for i = 1, #terminals1, 1 do
        if terminals1[i] ~= terminals2[i] then return false end
    end

    -- импользуем первую лабу (вариант 2 который 1)
    rules1, nonterminals1, classes1 = division_into_equivalence_classes(input_rules1, nonterminals1)
    print_rules(input_rules1)
    rules2, nonterminals2, classes2 = division_into_equivalence_classes(input_rules2, nonterminals2)
    print_rules(input_rules2)
    
    -- проверяем на равенство количество нетерминалов и правил переписывания
    if #nonterminals1 ~= #nonterminals2 then return false end
    if #rules1 ~= #rules2 then return false end

    -- объединяем грамматики и снова первую лабу
    local rules, nonterminals, classes
    rules, nonterminals = grammar_union(rules1, rules2, nonterminals1, nonterminals2)
    rules, nonterminals, classes = division_into_equivalence_classes(rules, nonterminals)
    
    -- проверяем на равенство количество классов в одной из грамматик с объединённой
    if #classes ~= #classes1 then return false, classes1, classes2 end

    local union_classes = classes_union(classes1, classes2, classes)
    
    return true, classes1, classes2, union_classes
end

function classes_union(classes1, classes2, classes)
    local state_prefix_1 = classes1[1][1]:sub(1,1)
    local new_equiv_classes = {}
    for _, class in pairs(classes) do
        new_equiv_classes[#new_equiv_classes + 1] = {}
        for j = 1, #class, 1 do
            if class[j]:sub(1,1) == state_prefix_1 then
                equiv_class_1 = arr_by_val_in_table(classes1, class[j])
                new_equiv_classes[#new_equiv_classes] = array_concat(new_equiv_classes[#new_equiv_classes], equiv_class_1)
            else
                equiv_class_2 = arr_by_val_in_table(classes2, class[j])
                new_equiv_classes[#new_equiv_classes] = array_concat(new_equiv_classes[#new_equiv_classes], equiv_class_2)
            end
        end
    end
    return new_equiv_classes
end

function arr_by_val_in_table(classes, val)
    for _, class in pairs(classes) do
        for i = 0, #class, 1 do
            if class[i] == val then return class end
        end
    end
end

function array_concat(arr1, arr2)
    for i = 1, #arr2, 1 do
        arr1[#arr1 + 1] = arr2[i]
    end
    return arr1
end