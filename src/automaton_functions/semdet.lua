local Automaton = require("src/model/automaton")
local Regex = require("src/model/regex")
require "src/derivatives/brzozovski"
require "src/derivatives/antimirov"
require "src/automaton_functions/determinization"
require "src/automaton_functions/arden"
require "src/predicates/predicates"

local function tableContains(tb, el) 
    for i = 1, #tb, 1 do
        if tb[i] == el then return true end
    end
    return false
end
local function uncertTransitions(nfa, from, alph)
    local trs = {}
    for i = 1, #alph, 1 do 
        trs[alph[i]] = {}
    end
    for j = 1, #nfa.transitions_raw, 1 do
        if nfa.transitions_raw[j].from == from then
            table.insert(trs[nfa.transitions_raw[j].symbol], nfa.transitions_raw[j].to)
        end
    end 
    return trs
end

local function uncertStates(nfa)
    local uncert = {}
    for i = 1, nfa.states, 1 do
        local alph = {}
        for j = 1, #nfa.transitions_raw, 1 do
            if nfa.transitions_raw[j].from == i and tableContains(alph, nfa.transitions_raw[j].symbol) == false then
                table.insert(alph, nfa.transitions_raw[j].symbol)
            elseif nfa.transitions_raw[j].from == i then
                table.insert(uncert, i)
                break
            end
        end 

    end
    return uncert
end
local function trsFrom(nfa, from, selfLoop) 
    local trs = {}
    for i = 1, #nfa.transitions_raw, 1 do
        if nfa.transitions_raw[i].from == from then 
            if selfLoop then 
                table.insert(trs, {from = from, symbol = nfa.transitions_raw[i].symbol, to = nfa.transitions_raw[i].to})
            elseif selfLoop == false and nfa.transitions_raw[i].to ~= from then 
                table.insert(trs, {from = from, symbol = nfa.transitions_raw[i].symbol, to = nfa.transitions_raw[i].to})
            end
        end
    end
    return trs
end
local function find_path(nfa, path, from, to, visited)
    local trs = trsFrom(nfa, from, false)
    for i = 1, #trs, 1 do
        if tableContains(visited, trs[i].to) == false then
            local path_check 
            if trs[i].symbol == "_epsilon_" then path_check = path
            else path_check = path .. trs[i].symbol end
            if trs[i].to == to then return path_check end
            table.insert(visited, trs[i].from)
            local gained = find_path(nfa, path_check, trs[i].to, to, visited)
            if gained ~= nil then return gained end
        end
    end
end
function SemDet(in_nfa) 
    local reg = Arden(in_nfa)
    local nfa
    if #in_nfa.start_states_raw > 1 then nfa = addStart(in_nfa) 
    else
        nfa = in_nfa
    end
    print("SemDet -> Connect all initial states:")
    print(nfa:tostring())
    local alph = getAlphabet(nfa)
    local uncert = uncertStates(nfa)
    for i = 1, #uncert, 1 do 
        local trs = uncertTransitions(nfa, uncert[i], alph)
        for j = 1, #alph, 1 do 
            local derives = {}
            if #trs[alph[j]] > 1 then 
                local words = {}
                for k = 1, #trs[alph[j]], 1 do
                    table.insert(words, find_path(nfa, "", 1, trs[alph[j]][k], {}))
                end
                for k = 1, #words, 1 do
                    local deriv = brzozovski_derivative_word(words[k], reg)
                    table.insert(derives, deriv)
                end
            end
            for k = 1, #derives, 1 do
                local check = false
                for m = 1, #derives, 1 do
                    if k ~= m then 
                        check = SubsetRegex(derives[k], derives[m])
                        if check then break end
                    end
                end 
                if check == false then  
                    print("SemDet -> result:")
                    print(false)
                    return false 
                end
            end
        end
    end
    print("SemDet -> result:")
    print(true)
    return true
end