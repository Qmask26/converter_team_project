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

function check_if_epsilon_in_regex_node(regex_node)
	if (regex_node.type == Regexs.operations.iter) then
		return true
	elseif (regex_node.type == Regexs.operations.alt) then
		if node_is_empty_string(regex_node.firstChild) then
			return true
		elseif node_is_empty_string(regex_node.secondChild) then
			return true
		else
			return check_if_epsilon_in_regex_node(regex_node.firstChild) or check_if_epsilon_in_regex_node(regex_node.secondChild)
		end
	end

	return false
end