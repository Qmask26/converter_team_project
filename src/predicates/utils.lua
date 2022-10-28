local Set = require("src/model/set")
local Automaton_module = require("src/model/automaton")

local Automaton = Automaton_module.Automaton
local Transition = Automaton_module.Transition
local eps = Automaton_module.eps

require("src/utils/common")
require("src/r2nfa_converter/thompson")
require("src/automaton_functions/determinization")

function grammar_from_transition(nfa, transit_prefix, state_prefix, equiv_classes)
    local rules = {}
    local terminals = Set:new({})
    local nonterminals = Set:new({})
    local new_nfa = Annote(nfa, transit_prefix)

    for state_from, table_symbols in pairs(new_nfa.transitions) do
        for symbol, table_labels in pairs(table_symbols) do
            for label, state_to in pairs(table_labels) do
                local eq_class_num = key_by_val_in_arr(state_prefix..tostring(state_to), equiv_classes)
                local state_from_s = string.char(state_from + 96)
                local state_to_s = string.char(eq_class_num + 96)
                if not terminals:has(state_to_s) then terminals:add(state_to_s) end
                if not key_in_table(label, rules) then
                    nonterminals:add(label)
                    rules[label] = {}
                end
                transitions_of_state_to = new_nfa:allTransitions(state_to)
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
    
    return rules, terminals, nonterminals
end

function get_index_of_other_class(nonterm, class)
    for i = 1, #class, 1 do
        for j = 1, #class[i], 1 do
            if class[i][j] == nonterm then return i end
        end
    end
end

function classes_intersection(classes1, classes2)
    local new_classes = {}

    for i = 1, #classes1, 1 do
        if #classes1[i] == 2 then table.insert(new_classes, classes1[i])
        else
            local indexes = {}
            for j = 1, #classes1[i], 1 do
                local k = get_index_of_other_class(classes1[i][j], classes2)
                if indexes[k] == nil then
                    indexes[k] = {classes1[i][j]}
                else
                    table.insert(indexes[k], classes1[i][j])
                end
            end

            for key, nonterm_class in pairs(indexes) do
                table.insert(new_classes, nonterm_class)
            end
        end
    end
    return new_classes
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

    return rules, nonterminals, equiv_classes, classes
end

function is_bisimilar(grammar1, grammar2)
    local input_rules1 = grammar1.rules
    local terminals1 = grammar1.terminals:toarray()
    local nonterminals1 = grammar1.nonterminals:toarray()
    local start_states_1 = grammar1.start_states_raw
    
    local input_rules2 = grammar2.rules
    local terminals2 = grammar2.terminals:toarray()
    local nonterminals2 = grammar2.nonterminals:toarray()
    local start_states_2 = grammar2.start_states_raw

    -- проверка на равенство количества терминналов
    if #terminals1 ~= #terminals2 then return false end
    table.sort(terminals1)
    table.sort(terminals2)
    for i = 1, #terminals1, 1 do
        if terminals1[i] ~= terminals2[i] then return false end
    end

    -- импользуем первую лабу (вариант 2 который 1)
    rules1, nonterminals1, classes1 = division_into_equivalence_classes(input_rules1, nonterminals1)
    rules2, nonterminals2, classes2 = division_into_equivalence_classes(input_rules2, nonterminals2)
    
    -- проверяем на равенство количество нетерминалов и правил переписывания
    if #nonterminals1 ~= #nonterminals2 then return false end
    if #rules1 ~= #rules2 then return false end

    -- объединяем грамматики и снова первую лабу
    local rules, nonterminals, classes
    rules, nonterminals = grammar_union(rules1, rules2, nonterminals1, nonterminals2)
    rules, nonterminals, classes, nonterm_class_num = division_into_equivalence_classes(rules, nonterminals)
    
    for i = 1, #start_states_1, 1 do
        local key = false
        for j = 1, #start_states_2, 1 do
            if nonterm_class_num[start_states_1[i]] == nonterm_class_num[start_states_2[j]] then key = true end
        end
        if not key then return false end
    end
    
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

function make_NFA_from_grammar(rules, nonterminals, classes, nonterm_num_classes, grammar)
    local class_numbers = Set:new({})
    local state_num = {}
    local nonterm_prefix = nonterminals[1]:sub(1,1)
    local transitions = {}
    local new_nonterm_num_classes = {}

    local num = 1
    local diff = 0
    for _ in pairs(nonterm_num_classes) do
        for i = 1, #classes, 1 do
            for j = 1, #classes[i], 1 do
                state = nonterm_prefix .. tostring(num)
                if classes[i][j] == state then
                    if not class_numbers:has(i) then
                        class_numbers:add(i)
                        state_num[i] = num - diff
                    else
                        diff = diff + 1
                    end
                    new_nonterm_num_classes[state] = state_num[i]
                end
            end
        end
        num = num + 1
    end

    local class_numbers = Set:new({})
    local state_from, state_to, symbol
    local label =  ""
    for nonterm, class_num in pairs(new_nonterm_num_classes) do
        for rule_nonterm, nonterm_rules in pairs(rules) do
            state_from = new_nonterm_num_classes[rule_nonterm]
            if not class_numbers:has(state_from) then
                class_numbers:add(state_from)
                for _, rule in pairs(nonterm_rules) do
                    if #rule == 1 then
                        symbol = eps
                        state_to = new_nonterm_num_classes[rule[1]]
                        table.insert(transitions, Transition:new(state_from, state_to, symbol, label))
                    elseif #rule == 2 then
                        symbol = rule[1]
                        state_to = new_nonterm_num_classes[rule[2]]
                        table.insert(transitions, Transition:new(state_from, state_to, symbol, label))
                    end
                end
            end
        end
    end

    local new_start_states = Set:new({})
    for i = 1, #grammar.start_states_raw, 1 do
        for state, num in pairs(new_nonterm_num_classes) do
            if grammar.start_states_raw[i] == state and not new_start_states:has(num) then
                new_start_states:add(num)
            end
        end
    end

    local new_final_states = Set:new({})
    for i = 1, #grammar.final_states_raw, 1 do
        for state, num in pairs(new_nonterm_num_classes) do
            if grammar.final_states_raw[i] == state and not new_final_states:has(num) then
                new_final_states:add(num)
            end
        end
    end

    local nfa = Automaton:new(num - diff, new_final_states:toarray(), transitions, false, new_start_states:toarray())
    return nfa
end

function merge_bisim(grammar)
    local input_rules = grammar.rules
    local terminals = grammar.terminals:toarray()
    local nonterminals = grammar.nonterminals:toarray()

    rules, nonterminals, classes, nonterm_num_classes = division_into_equivalence_classes(input_rules, nonterminals)

    local nfa = make_NFA_from_grammar(rules, nonterminals, classes, nonterm_num_classes, grammar)
    return nfa
end