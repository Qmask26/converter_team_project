local class = require("src/model/middleclass")
local Automaton = require("src/model/automaton")
require("src/automaton_functions/is_dfa")

-- structures

local stack = {}
function stack.push(item)
    table.insert(stack, item) 
end
function stack.pop()
    return table.remove(stack)
end

-- utilities
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

local function contains(q, C)
    local check = false
    if q == nil or #q == 0 then return true end
    for i = 1, #C, 1 do
        if #q ~= #C[i] then goto continue end
        for j = 1, #q, 1 do
            for k = 1, #C[i], 1 do
                check = q[j] == C[i][k]
                if check == true then break end 
            end
            if check == false then break end
        end 
        if check then return true end
        ::continue::
    end
    return check 
end

local function isEqual(a, b)
    local acc 
    if type(a) == "number" and type(b) == "number" then return a == b end
    if type(b) == "number" then acc = {b} else acc = b end
    if #a ~= #acc then return false end
    local check = false
    for i = 1, #a, 1 do
        for j = 1, #acc, 1 do
            if a[i] == acc[j] then check = true break end  
        end
        if check == false then return false end      
    end
    return true
end

local function mergeTables(tb1, tb2) 
    for i = 1, #tb2, 1 do
        table.insert(tb1, tb2[i])
    end
end
local function transition(nfa, from, symbol)
    local arr = {}
    local raw = nfa.transitions_raw
    for i = 1, #raw, 1 do
        if isEqual(raw[i].from, from) and raw[i].symbol == symbol then 
            table.insert(arr, raw[i].to)
        end
    end
    return arr
end

local function getAlphabet(nfa) 
    local trans = nfa.transitions_raw
    local alph = {}
    for i = 1, #trans, 1 do
        if trans[i].symbol == "_epsilon_" then goto continue end
        local check = false
        for j = 1, #alph, 1 do
            check = alph[j] == trans[i].symbol
            if check == true then break end
        end
        if check == false then 
            alph[#alph + 1] = trans[i].symbol 
        end
        ::continue::
    end
    return alph
end

-- main functions

local function dfs(nfa, q, C)
    local check = false
    for i = 1, #C, 1 do
        check = C[i] == q 
        if check then break end 
    end
    if check == false then 
        table.insert(C, q)
        
        if nfa.transitions[q]["_epsilon_"] ~= nil then
            local trarr = nfa.transitions[q]["_epsilon_"][""]
            for i = 1, #trarr, 1 do
                dfs(nfa, trarr[i], C)
            end
        end
    end
end

function closure(z, nfa)
    local C = {}
    for i = 1, #z, 1 do
            dfs(nfa, z[i], C)
    end
    return C
end
local function addStart(nfa)
    local trs = {}
    local start = {}
    local final = {}
    local states = nfa.states + 1
    local isDFA = nfa.isDfa

    for i = 1, #nfa.transitions_raw, 1 do
        table.insert(trs, {from =nfa.transitions_raw[i].from + 1, symbol = nfa.transitions_raw[i].symbol, to = nfa.transitions_raw[i].to + 1, label = nfa.transitions_raw[i].label})
    end
    for i = 1, #nfa.start_states_raw, 1 do
        start[i] = nfa.start_states_raw[i] + 1
        table.insert(trs, {from = 1, symbol = "_epsilon_", to = start[i], label = nfa.transitions_raw[i].label})
    end
    table.insert(start, 1)
    for i = 1, #nfa.final_states_raw, 1 do
        final[i] = nfa.final_states_raw[i] + 1
    end
    
    return Automaton.Automaton:new(states, final, trs, isDFA, start)
end

function Det(nfaIn)
    if is_dfa(nfaIn.transitions_raw) then return nfaIn end
    local nfa = addStart(nfaIn)
    
    local start = 1
    local tr = {}
    Q = {}
    F = {}
    S = {1}
    X = getAlphabet(nfa)

    local q0 = closure({start}, nfa)
    table.insert(Q, q0)
    stack.push(q0)
    while table.length(stack) ~= 2 do
        local z = stack.pop()
        for i = 1, #z, 1 do 
            if nfa:isStateFinal(z[i]) then
                table.insert(F, z)
                break
            end
        end
        for i = 1, #X, 1 do
            local trarr = {}
            for j = 1, #z, 1 do
                local collect = transition(nfa, z[j], X[i])
                if collect ~= nil then mergeTables(trarr, collect) end
            end
            local z1 = closure(trarr, nfa)
            
            if z1 ~= nil and contains(z1, Q) == false then
                table.insert(Q, z1)
                stack.push(z1)
            end
            if #z1 ~= 0 then
                table.insert(tr, {from = z, to = z1, symbol = X[i], label = ""})
            end
        end
    end
    -- automaton assembly
    local rename = {}
    for i = 1, #Q, 1 do
        rename[i] = Q[i]
        Q[i] = i 
    end
    for i = 1, #F, 1 do
        for j = 1, #rename, 1 do
            if isEqual(rename[j], F[i]) then F[i] = j break end
        end
    end
    for i = 1, #S, 1 do
        for j = 1, #rename, 1 do
            if isEqual(rename[j], S[i]) then S[i] = j break end
        end
    end
    for i = 1, #tr, 1 do
        for j = 1, #rename, 1 do
            if isEqual(rename[j], tr[i].from) and type(tr[i].from) ~= "number" then tr[i].from = j  end
            if isEqual(rename[j], tr[i].to) and type(tr[i].to) ~= "number" then tr[i].to = j  end
        end
    end
    local automaton = Automaton.Automaton:new(#Q, F, tr, true, S)
    return automaton
end

return Det