local Regexs = require("src/model/regex")
local Set = require("src/model/set")
require "src/derivatives/utils"

function antimirov_derivative(symbol, regex, verbose)
	print_if_verbose("Antimirov derivative from: "..regex.root.value, verbose)
	print_if_verbose("taking derivative by: "..symbol, verbose)
	local res = antimirov_derivative_rec(symbol, regex.root)

	print_if_verbose("Antimirov derivative result: "..res:str(), verbose)

	return res
end

function antimirov_derivative_rec(symbol, regex_node)
	local res

	if (regex_node.type == Regexs.operations.empty_set) then
		res = Set:new({})
	elseif (regex_node.type == Regexs.operations.symbol) then
		if (regex_node.value == symbol) then
			res = Set:new({""})
		else
			res = Set:new({})
		end
	elseif (regex_node.type == Regexs.operations.iter) then
		local first_child_set = antimirov_derivative_rec(symbol, regex_node.firstChild)
		local regex_str = regex_node.value
		res = Set:new({})
		first_child_set:foreach(
			function (v)
				res:add(v .. regex_str)
			end
		) 
	elseif (regex_node.type == Regexs.operations.alt) then
		local first_child_set = antimirov_derivative_rec(symbol, regex_node.firstChild)
		local second_child_set = antimirov_derivative_rec(symbol, regex_node.secondChild)
		res = first_child_set
		res:union(second_child_set)
	elseif (regex_node.type == Regexs.operations.concat) then
		local first_child_set = antimirov_derivative_rec(symbol, regex_node.firstChild)
		local arg2_regex_str = regex_node.secondChild.value
		res = Set:new({})
		first_child_set:foreach(
			function (v)
				res:add(v .. arg2_regex_str)
			end
		)

		if check_if_epsilon_in_regex_node(regex_node.firstChild) then
			local second_child_set = antimirov_derivative_rec(symbol, regex_node.secondChild)
			res:union(second_child_set)
		end
	end
	print(regex_node.value, res:str())
	return res
end

return antimirov_derivative