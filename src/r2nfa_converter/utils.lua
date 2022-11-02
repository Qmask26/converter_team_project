local Automaton = require("src/model/automaton")
local Regex = require("src/model/regex")
local Set = require("src/model/set")
require("src/utils/common")

eps = Automaton.eps


function copy_transitions(tr)
    local res = {}
    for k, v in pairs(tr) do
        table.insert(res, Automaton.Transition(v.from, v.to, v.symbol))
    end
    return res
end

function transitions_increase_by_value(transitions, value)
    local tr = copy_transitions(transitions)
    for k, v in pairs(tr) do
        v.from = v.from + value
        v.to = v.to + value
    end
    return tr
end

function automatons_concat(m1, m2)
    local m1tr = copy_transitions(m1.transitions_raw)
    local m2tr = copy_transitions(m2.transitions_raw)

    local m1stateNumber = m1.states
    local m2stateNumber = m2.states
    local statesNumber = m1stateNumber + m2stateNumber
    
    m2tr = transitions_increase_by_value(m2tr, m1stateNumber)
    
    local tr = copy_transitions(m1tr)
    table.insert(tr, Automaton.Transition:new(m1stateNumber, m1stateNumber + 1, eps))
    for _, v in pairs(m2tr) do
        table.insert(tr, v)
    end
    
    return Automaton.Automaton(statesNumber, {statesNumber}, tr)
end

function automatons_alt(m1, m2)
    local m1stateNumber = m1.states
    local m2stateNumber = m2.states
    local stateNumber = m1stateNumber + m2stateNumber + 2

    local m1tr = copy_transitions(m1.transitions_raw)
    m1tr = transitions_increase_by_value(m1tr, 1)
    local m2tr = copy_transitions(m2.transitions_raw)
    m2tr = transitions_increase_by_value(m2tr, m1stateNumber + 1)
    local tr = {}
    table.insert(tr, Automaton.Transition:new(1, 2, eps))
    for _, v in pairs(m1tr) do
        table.insert(tr, v)
    end
    table.insert(tr, Automaton.Transition:new(1, m1stateNumber + 2, eps))
    for _, v in pairs(m2tr) do
        table.insert(tr, v)
    end
    table.insert(tr, Automaton.Transition:new(m1stateNumber + 1, stateNumber, eps))
    table.insert(tr, Automaton.Transition:new(stateNumber - 1, stateNumber, eps))
    return Automaton.Automaton(stateNumber, {stateNumber}, tr)
end

function automatons_iter(m, positive)
    local tr = copy_transitions(m.transitions_raw)
    local statesNumber = m.states + 2
    tr = transitions_increase_by_value(tr, 1)
    table.insert(tr, Automaton.Transition:new(1, 2, eps))
    if positive == nil or not positive then
        table.insert(tr, Automaton.Transition:new(1, statesNumber, eps))
    end
    table.insert(tr, Automaton.Transition:new(statesNumber - 1, 2, eps))
    table.insert(tr, Automaton.Transition:new(statesNumber - 1, statesNumber, eps))
    return Automaton.Automaton:new(statesNumber, {statesNumber}, tr)
end

function is_transition_in_table(transition, arr)
    if arr == nil or table.length(arr) == 0 then
        return false
    end
    for _, tr in pairs(arr) do
        local tmp = {}
        for _, v in pairs(tr) do
            table.insert(tmp, v)
        end
        if tmp[1] == transition[1] and tmp[2] == transition[2] and tmp[3] == transition[3] then
            return true
        end
    end
    return false
end


function linearize(regex)
    local label = 1

    function annote(regex_node)
        if regex_node.type == Regex.operations.symbol then
            regex_node.value = regex_node.value .. label
            label = label + 1
        elseif regex_node.type == Regex.operations.concat or regex_node.type == Regex.operations.alt then
            annote(regex_node.firstChild)
            annote(regex_node.secondChild)
        elseif regex_node.type == Regex.operations.iter or regex_node.type == Regex.operations.positive then
            annote(regex_node.firstChild)
        end
    end

    annote(regex.root)
end

function get_start_possible_symbols_regex(regex)
    return get_start_possible_symbols(regex.root)
end

function get_start_possible_symbols(regex)
    local symbols = Set:new({})

    function get_start_possible_symbols_node(regex_node)
        if regex_node.type == Regex.operations.symbol then
            symbols:add(regex_node.value)
        elseif regex_node.type == Regex.operations.alt then
            get_start_possible_symbols_node(regex_node.firstChild)
            get_start_possible_symbols_node(regex_node.secondChild)
        elseif regex_node.type == Regex.operations.concat then
            get_start_possible_symbols_node(regex_node.firstChild)
            if canParseEpsilonRec(regex_node.firstChild) then
                get_start_possible_symbols_node(regex_node.secondChild)
            end
        elseif regex_node.type == Regex.operations.iter or regex_node.type == Regex.operations.positive then
            get_start_possible_symbols_node(regex_node.firstChild)
        end
    end

    get_start_possible_symbols_node(regex)
    return symbols
end

function get_finish_possible_symbols_regex(regex)
    return get_finish_possible_symbols(regex.root)
end

function get_finish_possible_symbols(regex)
    local symbols = Set:new({})

    function get_finish_possible_symbols_node(regex_node)
        if regex_node.type == Regex.operations.symbol then
            symbols:add(regex_node.value)
        elseif regex_node.type == Regex.operations.alt then
            get_finish_possible_symbols_node(regex_node.firstChild)
            get_finish_possible_symbols_node(regex_node.secondChild)
        elseif regex_node.type == Regex.operations.concat then
            get_finish_possible_symbols_node(regex_node.secondChild)
            if canParseEpsilonRec(regex_node.secondChild) then
                get_finish_possible_symbols_node(regex_node.firstChild)
            end
        elseif regex_node.type == Regex.operations.iter or regex_node.type == Regex.operations.positive then
            get_finish_possible_symbols_node(regex_node.firstChild)
        end
    end

    get_finish_possible_symbols_node(regex)
    return symbols
end

function get_possible_symbol_pairs_regex(regex)
    return get_possible_symbol_pairs(regex.node)
end


function get_possible_symbol_pairs(regex)
    local symbol_pairs = {}

    local function in_pairs(p)
        for _, v in pairs(symbol_pairs) do
            if v[1] == p[1] and v[2] == p[2] then
                return true
            end
        end
        return false
    end

    local function get_pairs(regex_node)
        if regex_node.type == Regex.operations.alt then
            get_pairs(regex_node.firstChild)
            get_pairs(regex_node.secondChild)
        elseif regex_node.type == Regex.operations.concat then
            local f = get_finish_possible_symbols(regex_node.firstChild)
            local s = get_start_possible_symbols(regex_node.secondChild)
            for start in pairs(s.items) do
                for finish in pairs(f.items) do
                    local p = {finish, start}
                    if not in_pairs(p) then
                        table.insert(symbol_pairs, p)
                    end
                end
            end
            get_pairs(regex_node.firstChild)
            get_pairs(regex_node.secondChild)
        elseif regex_node.type == Regex.operations.iter or regex_node.type == Regex.operations.positive then
            local f = get_finish_possible_symbols(regex_node.firstChild)
            local s = get_start_possible_symbols(regex_node.firstChild)
            for start in pairs(s.items) do
                for finish in pairs(f.items) do
                    local p = {finish, start}
                    if not in_pairs(p) then
                        table.insert(symbol_pairs, p)
                    end
                end
            end
            get_pairs(regex_node.firstChild)
        elseif regex_node.type == Regex.operations.symbol then
            return
        end
    end
    get_pairs(regex.root)
    return symbol_pairs
end

function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
 end

function compare(src, tmp, _reverse)
        if (type(src) ~= "table" or type(tmp) ~= "table") then
            return src == tmp
        end

        for k, v in next, src do
            if type(v) == "table" then
                if type(tmp[k]) ~= "table" or not compare(v, tmp[k]) then
                    return false
                end
            else
                if tmp[k] ~= v then
                    return false
                end
            end
        end
        return _reverse and true or compare(tmp, src, true)
    end
    tableCompare = function(src, tmp, checkMeta)
    return compare(src, tmp) and (not checkMeta or compare(getmetatable(src), getmetatable(tmp)))
end