local class = require("src/model/middleclass")
local Automaton = require("src/model/automaton")
local Set = require("src/model/set")
require("src/utils/common")

Grammar_module = {}

Grammar = class("Grammar")

function Grammar:initialize(automaton, nonterm_prefix, isDFA, purpose)
	self.nonterm_prefix = nonterm_prefix
	self.nonterminals = Set:new({})
	self.terminals = Set:new({})
	self.rules = {}
	self.start_states_raw = {}
	self.final_states_raw = {}
	if automaton ~= nil then
		for _, state in pairs(automaton.start_states_raw) do
			table.insert(self.start_states_raw, nonterm_prefix .. tostring(state))
		end
		for _, state in pairs(automaton.final_states_raw) do
			table.insert(self.final_states_raw, nonterm_prefix .. tostring(state))
		end
	end
	if purpose == "state" then
		if isDFA then
			self:from_DFA(automaton)
		else
			self:from_NFA(automaton)
		end
	elseif purpose == "reverse" then
		if isDFA then
			self:from_DFA_reverse(automaton)
		else
			self:from_NFA_reverse(automaton)
		end
	end
end

function Grammar:from_DFA(automaton)
    for state_from, table_symbols in pairs(automaton.transitions) do
    	local state_from_s = self.nonterm_prefix .. tostring(state_from)
    	self.nonterminals:add(state_from_s)
        for symbol, table_labels in pairs(table_symbols) do
			for label, state_to in pairs(table_labels) do
				if not (symbol == "" or symbol == Automaton.eps) then self.terminals:add(symbol) end
				if not self.rules[state_from_s] then self.rules[state_from_s] = {} end

				local state_to_s = self.nonterm_prefix .. tostring(state_to)
				self.nonterminals:add(state_to_s)
				table.insert(self.rules[state_from_s], {symbol, state_to_s})
			end
        end
    end

    -- check final states and fill with empty table
    for state, is_final in pairs(automaton.finality) do
    	local state_s = self.nonterm_prefix .. tostring(state)
    	if is_final and not key_in_table(state_s, self.rules) then 
    		self.rules[state_s] = {{}}
    	end
	end
end

function Grammar:from_NFA(automaton)
    for state_from, table_symbols in pairs(automaton.transitions) do
    	local state_from_s = self.nonterm_prefix .. tostring(state_from)
    	self.nonterminals:add(state_from_s)
        for symbol, table_labels in pairs(table_symbols) do
            local states_to = table_labels[""]

            if not (symbol == "" or symbol == Automaton.eps) then self.terminals:add(symbol) end
            if not self.rules[state_from_s] then self.rules[state_from_s] = {} end

            for _, state_to in pairs(states_to) do
            	local state_to_s = self.nonterm_prefix .. tostring(state_to)
            	self.nonterminals:add(state_to_s)
    			if symbol == "" or symbol == Automaton.eps then
    				table.insert(self.rules[state_from_s], {state_to_s})
				else
    				table.insert(self.rules[state_from_s], {symbol, state_to_s})
				end
        	end
        end
    end

    -- check final states and fill with empty table
    for state, is_final in pairs(automaton.finality) do
    	local state_s = self.nonterm_prefix .. tostring(state)
    	if is_final and not key_in_table(state_s, self.rules) then 
    		self.rules[state_s] = {{}}
    	end
	end
end

function Grammar:from_DFA_reverse(automaton)
    for state_from, table_symbols in pairs(automaton.transitions) do
    	local state_from_s = self.nonterm_prefix .. tostring(state_from)
		if string_match(self.start_states_raw, state_from_s) then self.rules[state_from_s] = {{}} end
    	self.nonterminals:add(state_from_s)
        for symbol, table_labels in pairs(table_symbols) do
			for label, state_to in pairs(table_labels) do
				if not (symbol == "" or symbol == Automaton.eps) then self.terminals:add(symbol) end
				local state_to_s = self.nonterm_prefix .. tostring(state_to)
				if not self.rules[state_to_s] then self.rules[state_to_s] = {} end
				self.nonterminals:add(state_to_s)
				table.insert(self.rules[state_to_s], {symbol, state_from_s})
        	end
        end
    end
end

function Grammar:from_NFA_reverse(automaton)
    for state_from, table_symbols in pairs(automaton.transitions) do
    	local state_from_s = self.nonterm_prefix .. tostring(state_from)
		if string_match(self.start_states_raw, state_from_s) then self.rules[state_from_s] = {{}} end
    	self.nonterminals:add(state_from_s)
        for symbol, table_labels in pairs(table_symbols) do
            local states_to = table_labels[""]

            if not (symbol == "" or symbol == Automaton.eps) then self.terminals:add(symbol) end

            for _, state_to in pairs(states_to) do
            	local state_to_s = self.nonterm_prefix .. tostring(state_to)
				if not self.rules[state_to_s] then self.rules[state_to_s] = {} end
            	self.nonterminals:add(state_to_s)
    			if symbol == "" or symbol == Automaton.eps then
    				table.insert(self.rules[state_to_s], {state_from_s})
				else
    				table.insert(self.rules[state_to_s], {symbol, state_from_s})
				end
        	end
        end
    end
end

function Grammar:tostring()
	local res = ""
    res = res .. "Nonterminals: " .. self.nonterminals:str() .. "\n"
    res = res .. "Terminals: " .. self.terminals:str() .. "\n"
    res = res .. "Rules:\n"
    for left, right in pairs(self.rules) do
    	local s = left .. " -> "
    	local rule_s = ""
    	for _, rule in pairs(right) do
    		for _, symbol in pairs(rule) do
    			rule_s = rule_s .. symbol .. " "
			end
			rule_s = rule_s .. "| "
		end
		rule_s = string.sub(rule_s, 0, #rule_s-2)
		s = s .. rule_s .. "\n"
		res = res .. s
	end
	return res
end


Grammar_module.Grammar = Grammar

return Grammar_module