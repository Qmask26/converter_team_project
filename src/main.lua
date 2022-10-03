if (#arg == 1 or arg[1] ~= "-d" and arg[1] ~= "-s") then
    print("Incorrect, try to: 'lua main.lua [-s | -d] [path/to/input/file]'")
    print(#arg)
    return
elseif (arg[1] == "-s") then
    Typechecker_module = require("typechecker/static")
elseif (arg[1] == "-d") then
    Typechecker_module = require("typechecker/dynamic")
end

IDENTIFIERS = {}

--Множество всех идентификаторов, которые встретились во входных данных и соответствующий им тип
--тип может меняться в ходе работы программы
--Объекты, не имеющие имени во входных данных, будут иметь идентификатор __TMP
--Пример: 
--При разборе строки "N1 = Glushkov ((ab)*|a)* !!"
--в IDENTIFIERS добавятся элементы {N1 = {"NFA", `Объект класса NFA`}}  и {__TMP = {"Regexp", `Объект класса Regexp`}}

local InputParser = require("parser/input_parser")
inputParser = InputParser:new()




