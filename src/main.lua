if (#arg == 1 or arg[1] ~= "-d" and arg[1] ~= "-s") then
    print("Incorrect, try to: 'lua main.lua [-s | -d] [path/to/input/file]'")
    print(#arg)
    return
elseif (arg[1] == "-s") then
    typechecker = require("typechecker/static")
elseif (arg[1] == "-d") then
    typechecker = require("typechecker/dynamic")
end

io.input(arg[2])
inputFile = io.open(arg[2], "r")
outputFile = io.open("output.txt", "w")


--InputParser = require("parser/input_parser")
--input = InputParser:parseInput()

--identifiers = input.identifiers
--operations = input.operations