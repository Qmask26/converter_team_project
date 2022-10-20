local class = require("src/model/middleclass")
local Automaton = require("src/model/automaton")
local Transition 

-- structures

tr = {}

local stack = {}
function stack.push(item)
    table.insert(stack, item) 
end
function stack.pop()
    return table.remove(stack)
end

-- utilitis

local function contains(q, C)
    local check = false
    if q == nil or #q == 0 then return true end
    for i = 1, #C, 1 do
        if #q ~= #C[i] then goto continue end
        for j = 1, #q, 1 do
            check = q[j] == C[i][j]
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
    for i = 1, #a, 1 do
        if a[i] ~= acc[i] then return false end        
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
        if trans[i].symbol == '' then goto continue end
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
        if nfa.transitions[q][''] ~= nil then
            local trarr = nfa.transitions[q][''][""]
            for i = 1, #trarr, 1 do
                dfs(nfa, trarr[i], C)
            end
        end
    end
end

local function closure(z, nfa)
    local C = {}
    for i = 1, #z, 1 do
            dfs(nfa, z[i], C)
    end
    return C
end

function Det(nfa)
    Q = {}
    F = {}
    X = getAlphabet(nfa)

    local q0 = closure({1}, nfa)
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
            print(X[i])
            for j = 1, #z, 1 do
                local collect = transition(nfa, z[j], X[i])
                print(#collect, collect[1], collect[2])
                if collect ~= nil then mergeTables(trarr, collect) end
            end
            print(trarr[1], trarr[2], trarr[3], trarr[4])

            local z1 = closure(trarr, nfa)
            
            if z1 ~= nil and contains(z1, Q) == false then
                table.insert(Q, z1)
                stack.push(z1)
            end
            if #z1 ~= 0 then
                table.insert(tr, {from = z, to = z1, symbol = X[i]})
            end
        end
    end

    io.write("States\n")
    for i = 1, #Q, 1 do
        io.write("state", i, " ")
        for j = 1, #Q[i], 1 do
            io.write(Q[i][j], " ")
        end
        io.write("\n")
    end
    io.write("Finals\n")
    for i = 1, #F, 1 do
        for j = 1, #F[i], 1 do
            io.write(F[i][j], " ")
        end
        print()
    end
    io.write("\nAlphabet\n")
    for i = 1, #X, 1 do
        io.write(X[i], " ")
    end
    io.write("\nTransitions\n")
    for i = 1, #tr, 1 do
        for j = 1, #tr[i].from, 1 do
            io.write(tr[i].from[j], " ")
        end
        io.write(tr[i].symbol, "-> ") 
        for j = 1, #tr[i].to, 1 do
            io.write(tr[i].to[j], " ")
        end
        print()
    end
end
