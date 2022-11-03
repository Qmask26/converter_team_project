local class = require("src/model/middleclass")
local Automaton = require("src/model/automaton")
local Regex = require("src/model/regex")
require "src/automaton_functions/determinization"

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
local function getTransition(trs, from, to)
    local tr = {}
    for i = 1, #trs, 1 do
        if trs[i].from == from and trs[i].to == to then 
            table.insert(tr, {from = from, symbol = trs[i].symbol, to = to, label = ""})
        end
    end

    return tr
end
local function  modifyNFA(nfa)
   local start = nfa.start_states_raw[1]
   local new_start = nfa.states + 1
   local startStates = {new_start}

   local new_final = nfa.states + 2
   local finalStates = {new_final}
   local transitions = {}
   for i = 1,nfa.states, 1 do
        for j = 1,nfa.states, 1 do
            local trs = getTransition(nfa.transitions_raw, i, j)
            local symbol = ""
            if #trs == 1 then 
                table.insert(transitions, {from = i, symbol = trs[1].symbol, to = j, label = ""})
            elseif #trs > 1 then
                for k = 1, #trs,1 do
                    if k ~= 1 then
                        symbol = symbol .. '|' .. trs[k].symbol
                    else
                        symbol = symbol .. trs[k].symbol
                    end
                end 
                table.insert(transitions, {from = i, symbol = symbol, to = j, label = ""})
            end
        end
   end

   for i = 1, #nfa.final_states_raw, 1 do
    table.insert(transitions, {from = nfa.final_states_raw[i], symbol = "_epsilon_", to = new_final, label = ""})
    end
   table.insert(transitions, {from = new_start, symbol = "_epsilon_", to = start, label = ""})

   return Automaton.Automaton:new(nfa.states + 2, finalStates, transitions, false, startStates)
end

local function ripState(nfa, state)
    local toState = {}
    local fromState= {}
    local selfLoop = false
    local selfLoopSymbol = ''
    local transitions = {}

    local self_trs = getTransition(nfa.transitions_raw, state, state)
    for i = 1, #self_trs, 1 do
        local sym = ""
        if self_trs[i].symbol ~= "_epsilon_" then sym = self_trs[i].symbol end
        if i == 1 then 
            selfLoopSymbol = '(' .. selfLoopSymbol .. sym
            selfLoop = true
        else
            selfLoopSymbol = selfLoopSymbol .. '|' .. sym
        end
    end
    if selfLoop then 
        selfLoopSymbol = selfLoopSymbol .. ')' .. '*'
    end

    for i = 1, #nfa.transitions_raw, 1 do
        if nfa.transitions_raw[i].to == state and nfa.transitions_raw[i].from ~= state then 
            table.insert(toState, nfa.transitions_raw[i].from) 
        elseif nfa.transitions_raw[i].from == state and nfa.transitions_raw[i].to ~= state then 
            table.insert(fromState, nfa.transitions_raw[i].to) 
        elseif nfa.transitions_raw[i].from ~= state and nfa.transitions_raw[i].to ~= state then
            local from = nfa.transitions_raw[i].from 
            local to = nfa.transitions_raw[i].to
            if from > state then from = from - 1 end
            if to > state then to = to - 1 end
            table.insert(transitions, {from = from, symbol = nfa.transitions_raw[i].symbol, to = to, label = ""})
        end
    end
    for i = 1, #toState, 1 do
        local symbol = ""
        local tr_to = getTransition(nfa.transitions_raw, toState[i], state)
        local to_symbol = ""
        for k = 1, #tr_to, 1 do
            local sym = ""
            if tr_to[k].symbol ~= "_epsilon_" then sym = tr_to[k].symbol end
            if to_symbol ~= "" then 
                to_symbol =  "|".. sym  .. to_symbol
            elseif tr_to[k].symbol ~= "_epsilon_" then 
                to_symbol = sym .. to_symbol
            end
        end
        for j = 1, #fromState, 1 do
            local tr_from = getTransition(nfa.transitions_raw, state, fromState[j])
            local from_symbol = ""
            for k = 1, #tr_from, 1 do
                local sym = ""
                if tr_from[k].symbol ~= "_epsilon_" then sym = tr_from[k].symbol end
                if from_symbol ~= "" then 
                    from_symbol = "|" .. sym .. from_symbol 
                elseif tr_from[k].symbol ~= "_epsilon_" then
                    from_symbol = sym .. from_symbol 
                end
            end 
            symbol = to_symbol .. selfLoopSymbol .. from_symbol
            -- if symbol == "" then symbol = "_epsilon_" end
            local added = false
            -- if selfLoop then symbol = "(".. symbol .. ")"  end
            if symbol ~= "" then 
                local from = fromState[j]
                local to = toState[i]
                if from > state then from = from - 1 end
                if to > state then to = to - 1 end
                local trs = getTransition(transitions, to, from)
                for k = 1, #trs,1 do
                    for m = 1, #transitions, 1 do
                        local sym = ""
                        if transitions[m].symbol ~= "_epsilon_" then sym = transitions[m].symbol end
                        if transitions[m].to == trs[k].to and transitions[m].from == trs[k].from then
                            transitions[m].symbol = '(' .. symbol .. '|' .. sym  .. ')'
                            added = true
                        end
                    end
                end
                if added ~= true then table.insert(transitions, {from = to, symbol = symbol , to = from, false,  label = ""}) end
            end
        end
    end

    local startStates = {nfa.start_states_raw[1] - 1}
    local finalStates = {nfa.final_states_raw[1] - 1}

    return Automaton.Automaton:new(nfa.states - 1, finalStates, transitions, false, startStates)
end

function Arden(nfaIn)
    local nfa
    if #nfaIn.start_states_raw > 1 then nfa = addStart(nfaIn) 
    else
        nfa = nfaIn
    end
    print("Arden -> Connect all initial states:")
    print(nfaIn:tostring())
    local new_nfa = modifyNFA(nfa)
    while new_nfa.states > 2 do
        new_nfa = ripState(new_nfa, 1)
    end
    local r = Regex.Regex:new(new_nfa.transitions_raw[1].symbol)
    print("Arden -> regex:")
    print(r.root.value)
    return r
end

return Arden
