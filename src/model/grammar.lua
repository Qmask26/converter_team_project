local class = require("src/model/middleclass")
local Set = require("src/model/set")
require("src/utils/common")

Grammar_module = {}

Grammar = class("Grammar")

function Grammar:initialize(automaton, isDFA)
	self.terminals = Set:new({})
	self.nonterminals = Set:new({})
	self.rules = {}
	if isDFA then
		print('TODO')
		self:from_DFA(automaton)
	else
		self:from_NFA(automaton)
	end
end

function Grammar:from_NFA(automaton)
    for state_from, table_symbols in pairs(automaton.transitions) do
    	local state_from = tostring(state_from)
    	self.nonterminals:add(state_from)
        for symbol, table_labels in pairs(table_symbols) do
            local states_to = table_labels[""]
            self.terminals:add(symbol)
            if not self.rules[state_from] then self.rules[state_from] = {} end

            for _, state_to in pairs(states_to) do
            	local state_to = tostring(state_to)
            	self.nonterminals:add(state_to)
            	if automaton:isStateFinal(state_to) then
            		table.insert(self.rules[state_from], {symbol})
        		else
        			table.insert(self.rules[state_from], {symbol, state_to})
    			end
        	end
        end
    end

    -- check final states and fill with empty table
    for state, is_final in pairs(automaton.finality) do
    	if is_final and not key_in_table(state, self.rules) then 
    		self.rules[state] = {{}}
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