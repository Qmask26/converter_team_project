local Regexs = require("src/model/regex")

function brzozovski_derivative(symbol, re)

end

function check_if_epsilon_in_regex(regex_node)
	if (regex_node.type == Regexs.operations.iter) then
		return true
	elseif (regex_node.type == Regexs.operations.alt) then
		if (regex_node.firstChild.type == Regexs.operations.iter) and (regex_node.firstChild.value == '') then
			return true
		elseif (regex_node.secondChild.type == Regexs.operations.iter) and (regex_node.secondChild.value == '') then
			return true
		else
			return check_if_epsilon_in_regex(regex_node.firstChild) or check_if_epsilon_in_regex(regex_node.secondChild)
		end
	end

	return false
end