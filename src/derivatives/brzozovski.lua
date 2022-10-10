local Regexs = require("src/model/regex")


function new_regexnode(value, type, nchildren, firstChild, secondChild)
	local regexnode = Regexs.RegexNode:new(value, false)
	regexnode.type = type
	regexnode.nchildren = nchildren
	regexnode.firstChild = firstChild
	regexnode.secondChild = secondChild
	return regexnode
end

function node_is_empty_string(regex_node)
	return regex_node.type == Regexs.operations.symbol and regex_node.value == ''
end

function check_if_epsilon_in_regex(regex_node)
	if (regex_node.type == Regexs.operations.iter) then
		return true
	elseif (regex_node.type == Regexs.operations.alt) then
		if node_is_empty_string(regex_node.firstChild) then
			return true
		elseif node_is_empty_string(regex_node.secondChild) then
			return true
		else
			return check_if_epsilon_in_regex(regex_node.firstChild) or check_if_epsilon_in_regex(regex_node.secondChild)
		end
	end

	return false
end

function simplify_outer(regex_node)
	if regex_node.type == Regexs.operations.concat then
		if regex_node.firstChild.type == Regexs.operations.empty_set or regex_node.secondChild.type == Regexs.operations.empty_set then
			return new_regexnode("", Regexs.operations.empty_set, 0)
		elseif node_is_empty_string(regex_node.firstChild) then
			return regex_node.secondChild
		elseif node_is_empty_string(regex_node.secondChild) then
			return regex_node.firstChild
		end
	elseif regex_node.type == Regexs.operations.iter then
		if regex_node.firstChild.type == Regexs.operations.empty_set then
			return new_regexnode("", Regexs.operations.empty_set, 0)
		elseif node_is_empty_string(regex_node.firstChild) then
			return new_regexnode("", Regexs.operations.symbol, 0)
		end
	elseif regex_node.type == Regexs.operations.alt then
		if regex_node.firstChild.type == Regexs.operations.empty_set then
			return regex_node.secondChild
		elseif regex_node.secondChild.type == Regexs.operations.empty_set then
			return regex_node.firstChild
		end
	end
	return regex_node
end

function brzozovski_derivative(symbol, regex_node)
	local res

	if (regex_node.type == Regexs.operations.empty_set) then
		res = new_regexnode("", Regexs.operations.empty_set, 0)
	elseif (regex_node.type == Regexs.operations.symbol) then
		if (regex_node.value == symbol) then
			res = new_regexnode("", Regexs.operations.symbol, 0)
		else
			res = new_regexnode("", Regexs.operations.empty_set, 0)
		end
	elseif (regex_node.type == Regexs.operations.iter) then
		local first_child_deriv = brzozovski_derivative(symbol, regex_node.firstChild)
		res = simplify_outer(new_regexnode(
			first_child_deriv.value .. regex_node.value,
			Regexs.operations.concat,
			2,
			first_child_deriv,
			regex_node
		))
	elseif (regex_node.type == Regexs.operations.alt) then
		local first_child_deriv = brzozovski_derivative(symbol, regex_node.firstChild)
		local second_child_deriv = brzozovski_derivative(symbol, regex_node.secondChild)
		res = simplify_outer(new_regexnode(
			first_child_deriv.value .. "|" .. second_child_deriv.value,
			Regexs.operations.alt,
			2,
			first_child_deriv,
			second_child_deriv
		))
	elseif (regex_node.type == Regexs.operations.concat) then
		local first_child_deriv = brzozovski_derivative(symbol, regex_node.firstChild)
		local left_node = simplify_outer(new_regexnode(
			first_child_deriv.value .. regex_node.secondChild.value,
			Regexs.operations.concat,
			2,
			first_child_deriv,
			regex_node.secondChild
		))
		if check_if_epsilon_in_regex(regex_node.firstChild) then
			local second_child_deriv = brzozovski_derivative(symbol, regex_node.secondChild)
			res = simplify_outer(new_regexnode(
				left_node.value .. "|" .. second_child_deriv.value,
				Regexs.operations.alt,
				2,
				left_node,
				second_child_deriv
			))
		else
			res = left_node
		end
	end
	return res
end