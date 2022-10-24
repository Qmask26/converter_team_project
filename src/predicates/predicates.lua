local class = require("src/model/middleclass")
local automaton = require("src/model/automaton")
require("src/utils/common")

local Automaton = automaton.Automaton
local Transition = automaton.Transition

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

function grammar_from_transition(nfa)
    local rules = {}
    local terminals = {}
    local nonterminals = {}

    local index = 65
    for inf_form, table_symbols in pairs(nfa.transitions) do
        for symbol, table_labels in pairs(table_symbols) do
            rules[index] = {}
            for i, to in pairs(table_labels[""]) do

            end
        end
    end

                
end

function Equal(nfa1, nfa2)
    rules1, terminals1, nonterminals1 = grammar_from_transition(nfa1)
    rules2, terminals2, nonterminals2 = grammar_from_transition(nfa1)
end

function printRules(rules)
    for k,_ in pairs(rules) do
        print(k, k, k)
        for i=1, #rules[k], 1 do
           for j=1, #rules[k][i], 1 do
                print(rules[k][i][j])
            end
            print('-----------')
        end
    end
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
    local empty_nonterm = empty_nonterminals[1]

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
    new_rules[empty_nonterm] = {{}}

    for nonterm, _ in pairs(new_rules) do
        if nonterm ~= empty_nonterm then
            new_nonterminals[#new_nonterminals + 1] = nonterm
        end
    end

    return new_rules, new_nonterminals
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
                    word[#word + 1] = classes[symbol]
                else
                    word[#word + 1] = symbol
                end
            end
            table.insert(words, word)
        end

        local w = ""
        for i = 1, #words, 1 do
            for j = 1, #words[i], 1 do
                w = w..words[i][j]
            end
        end
        
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

    rules, nonterminals = make_new_grammar(rules, empty_nonterminals, nonterminals, equiv_classes, classes)

    return rules, nonterminals, new_rules
end

function Bisimilar(nfa1, nfa2)
    --local input_rules = {['S'] = {'a', 'aSa', 'bR', 'fQSQa'}, ['T'] = {'a', 'aRa', 'bR', 'fQTRa'}, ['Q'] = {'b', 'bQ', 'fQSSa'}, ['R'] = {'a', 'aTa', 'bT', 'fQTRa'}}
    --local terminals = {'b', 'a', 'f'}
    --nonterminals = {'S', 'T', 'Q', 'R'}
    --local input_rules1 = {['S'] = {'a', 'bR', 'fSSRa'}, ['T'] = {'a', 'bR', 'fTRSa'}, ['Q'] = {'b', 'bQ', 'fQSSa'}, ['R'] = {'a', 'bT', 'fRSRa'}, ['a'] = {''}, ['f'] = {''}}
    --local terminals1 = {'b'}
    --local nonterminals1 = {'S', 'T', 'Q', 'R', 'a', 'f'}
    local input_rules1 = {['S'] = {{'a'}, {'b', 'R'}, {'f', 'S', 'S', 'R', 'a'}}, ['T'] = {{'a'}, {'b', 'R'}, {'f', 'T', 'R', 'S', 'a'}}, ['Q'] = {{'b'}, {'b', 'Q'}, {'f', 'Q', 'S', 'S', 'a'}}, ['R'] = {{'a'}, {'b', 'T'}, {'f', 'R', 'S', 'R', 'a'}}, ['a'] = {{}}, ['f'] = {{}}}
    local terminals1 = {'b'}
    local nonterminals1 = {'S', 'T', 'Q', 'R', 'a', 'f'}
    
    local input_rules2 = {['D'] = {{'n'}, {'b', 'U'}, {'m', 'D', 'D', 'U', 'n'}}, ['P'] = {{'b'}, {'b', 'P'}, {'m', 'P', 'D', 'D', 'n'}}, ['V'] = {{'n'}, {'b', 'U'}, {'m', 'V', 'U', 'D', 'n'}}, ['U'] = {{'n'}, {'b', 'V'}, {'m', 'U', 'D', 'U', 'n'}}, ['n'] = {{}}, ['m'] = {{}}}
    local terminals2 = {'b'}
    local nonterminals2 = {'n', 'm', 'D', 'V', 'P', 'U'}

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
    rules, nonterminals = grammar_union(rules1, rules2, nonterminals1, nonterminals2)
    rules, nonterminals, classes = division_into_equivalence_classes(rules, nonterminals)
    
    -- проверяем на равенство количество классов в одной из грамматик с объединённой
    if #classes ~= #classes2 then return false end
    
    return true
end

print(Bisimilar(0, 0))