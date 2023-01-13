local Automaton = require("src/model/automaton")
require "src/automaton_functions/inverse"
local queue = {}


local function buildInv(dfa)
  local inv = {}
  for i = 1, dfa.states, 1 do
    inv[i] = {}
  end
  for i = 1, #dfa.transitions_raw, 1 do
    if inv[dfa.transitions_raw[i].to][dfa.transitions_raw[i].symbol] == nil then
      inv[dfa.transitions_raw[i].to][dfa.transitions_raw[i].symbol] = {}
    end
    table.insert(inv[dfa.transitions_raw[i].to][dfa.transitions_raw[i].symbol], dfa.transitions_raw[i].from)
  end
  return inv
end

local function findEquivalenceClasses(dfa)
  -- Q — множество состояний 
  -- F — множество финальных состояний
  -- P — разбиение множества состояний ДКА
  -- nonFinal - множество не финальных состояний
  -- Class[r] — номер класса, которому принадлежит состояние  r
  local F = dfa.final_states_raw 
  local Q = {} 
  local nonFinal = {} 
  local class = {}
  for i = 1, dfa.states, 1 do
    table.insert(Q, i)
    if dfa:isStateFinal(i) == false then
      table.insert(nonFinal, i)
      class[i] = 2
    else 
      class[i] = 1
    end
  end
  local P = {F}
  
  if #nonFinal ~= 0 then
    table.insert(P, nonFinal)
  end

  -- inv[r][a] — массив состояний, из которых есть ребра по символу 'a' в состояние  r
  local inv = buildInv(dfa)

  local alph = dfa:getAlphabet():toarray()

  for i = 1, #alph, 1 do
    table.insert(queue, {states = F, symbol = alph[i]})
    table.insert(queue, {states = nonFinal, symbol = alph[i]})
  end
  while #queue ~= 0 do
    local pair = table.remove(queue, 1)
     -- Involved — ассоциативный массив из номеров классов в векторы из номеров вершин.
    local involved = {}
    for i = 1, #pair.states, 1 do
      local q = pair.states[i]
      if inv[q][pair.symbol] ~= nil then
        for j = 1, #inv[q][pair.symbol], 1 do
          local r = inv[q][pair.symbol][j]
          local a = class[r]
          if involved[a] == nil then 
            involved[a] = {}
          end
          table.insert(involved[a], r)
        end
      end
    end
    for i, val in pairs(involved) do
      local a = i
      if #involved[a] < #P[a] then
        table.insert(P, {})
        local b = #P
        for j = 1, #involved[a], 1 do
          local r = involved[a][j]
          local pos = 1
          while P[a][pos] ~= r do pos = pos + 1 end
          table.remove(P[a], pos)
          table.insert(P[b], r)
        end
        if #P[b] > #P[a] then P[a], P[b] = P[b], P[a] end
        for j = 1, #P[b], 1 do
          class[P[b][j]] = b
        end
        for j = 1, #alph, 1 do
          table.insert(queue, {states = {b}, symbol = alph[j]})
        end
      end
    end
  end
  return P
end

local function contains(Q, state)
  for i = 1, #Q, 1 do
    if Q[i] == state then return true end 
  end
  return false
end


local function collectReachable(Q, raw_trs, state)
  local trs = {}
  for i = 1, #raw_trs, 1 do
    if raw_trs[i].from == state then table.insert(trs, raw_trs[i]) end 
  end
  for i = 1, #trs, 1 do
    if contains(Q, trs[i].to) == false then 
      table.insert(Q, trs[i].to)
      Q = collectReachable(Q, raw_trs, trs[i].to)
    end
  end
  return Q
end

local function deleteUnreachables(dfa) 
  local R = collectReachable({dfa.start_states_raw[1]}, dfa.transitions_raw, dfa.start_states_raw[1])

  local rename = {}
  for i = 1, #R, 1 do
    rename[R[i]] = i
  end

  local start = {}
  for i = 1, #dfa.start_states_raw, 1 do
    if contains(R, dfa.start_states_raw[i]) then
      table.insert(start, rename[dfa.start_states_raw[i]])
    end
  end

  local finals = {}
  for i = 1, #dfa.final_states_raw, 1 do
    if contains(R, dfa.final_states_raw[i]) then
      table.insert(finals, rename[dfa.final_states_raw[i]])
    end
  end

  local trs = {}
  for i = 1, #dfa.transitions_raw, 1 do
    if contains(R, dfa.transitions_raw[i].from) and contains(R, dfa.transitions_raw[i].to) then
      table.insert(trs, 
      {
        from = rename[dfa.transitions_raw[i].from], 
        symbol = dfa.transitions_raw[i].symbol,
        to = rename[dfa.transitions_raw[i].to],
        label = dfa.transitions_raw[i].label
      })
    end
  end
  local dfa = Automaton.Automaton:new(#R, finals, trs, true, start)
  return dfa
end

local function deleteNondisting(dfa)
  local eqv = findEquivalenceClasses(dfa)
  
  local Q = #eqv
  local rename = {}
  for i = 1, #eqv, 1 do
    rename[i] = eqv[i]
  end
  local findEqv = false
  local F = {}
  local start  ={}
  local name = #eqv + 1
  for i = 1, dfa.states, 1 do
    for j = 1, #eqv, 1 do
      if contains(eqv[j], i) then
        findEqv = true
        if dfa:isStateFinal(i) then table.insert(F, j) end
        if contains(dfa.start_states_raw, i) then table.insert(start, j) end
        break
      end
    end
    if findEqv == false then
      Q = Q + 1
      rename[name] = {i}
      if dfa:isStateFinal(i) then table.insert(F, name) end
      if contains(dfa.start_states_raw, i) then table.insert(start, name) end
      name = name + 1
    else findEqv = false end
  end
  local trs = {}
  for i = 1, #dfa.transitions_raw, 1 do
    trs[i] = {
      from = dfa.transitions_raw[i].from,
      symbol = dfa.transitions_raw[i].symbol, 
      to = dfa.transitions_raw[i].to, 
      label = dfa.transitions_raw[i].label
    } 
  end
  local already_changed_to = {}
  local already_changed_from = {}
  for i = 1, #rename, 1 do
    for j = 1, #trs, 1 do
      if contains(already_changed_to, j) == false and contains(rename[i], trs[j].to) then
        trs[j].to = i
        table.insert(already_changed_to, j)
      end
      if contains(already_changed_from, j) == false and contains(rename[i], trs[j].from) then
        trs[j].from = i
        table.insert(already_changed_from, j)
      end
    end
  end

  local new_dfa = Automaton.Automaton:new(Q, F, trs, true, start)
  return new_dfa
end

local function deleteDead(dfa)
  local inv_dfa = inverse(dfa)

  inv_dfa.states = inv_dfa.states + 1
  inv_dfa.isDFA = false
  for i = 1, #inv_dfa.start_states_raw, 1 do
    inv_dfa:addTransition(inv_dfa.states, inv_dfa.start_states_raw[i], "", "")
  end
  table.insert(inv_dfa.start_states_raw, 1, inv_dfa.states)
  local undead_dfa = deleteUnreachables(inv_dfa)
  local states = undead_dfa.states - 1
  local start = {}
  for i = 2, #undead_dfa.start_states_raw, 1 do
    local start_state = undead_dfa.start_states_raw[i]
    if undead_dfa.start_states_raw[i] >= undead_dfa.start_states_raw[1] then 
      start_state = start_state - 1
    end
    table.insert(start, start_state)
  end

  local final = {}
  for i = 1, #undead_dfa.final_states_raw, 1 do
    local final_state = undead_dfa.final_states_raw[i]
    if undead_dfa.final_states_raw[i] >= undead_dfa.final_states_raw[1] then 
      final_state = final_state  - 1
    end
    table.insert(final, final_state )
  end

  local trs = {}
  for i = 1, #undead_dfa.transitions_raw, 1 do
    if undead_dfa.transitions_raw[i].from ~= undead_dfa.start_states_raw[1] then
      local to_state = undead_dfa.transitions_raw[i].to
      local from_state = undead_dfa.transitions_raw[i].from
      if undead_dfa.transitions_raw[i].from >= undead_dfa.start_states_raw[1] then 
        from_state = from_state - 1
      end
      if undead_dfa.transitions_raw[i].to >= undead_dfa.start_states_raw[1] then 
        to_state = to_state - 1
      end
      table.insert(trs, {
        from = from_state,
        symbol = undead_dfa.transitions_raw[i].symbol,
        to = to_state,
        label = undead_dfa.transitions_raw[i].label
      })
    end
  end
  local new_dfa = Automaton.Automaton:new(states, final, trs, false, start)
  return inverse(new_dfa)
end


function minimize(automaton, debug)
  if automaton.isDFA == false then return nil end

  local undead = deleteDead(automaton)
  if debug then 
    print("Hopcroft minimization -> dead states removed:")
    print(undead:tostring())
  end

  local reachable = deleteUnreachables(undead)
  if debug then 
    print("Hopcroft minimization -> unreachable states deleted:")
    print(reachable:tostring())
  end

  local distinguishable = deleteNondisting(reachable)
  if debug then 
    print("Hopcroft minimization -> nondistinguishable states merged - result acquired:")
    print(distinguishable:tostring())
  end
  return distinguishable
end