if (#arg == 1 or arg[1] ~= "-d" and arg[1] ~= "-s") then
    print("Incorrect, try to: 'lua main.lua [-s | -d] [path/to/input/file]'")
    print(#arg)
    return
end

needToPrintStepByStep = nil

Parser = require("src/utils/input_parser")

local parser = Parser:new(arg[1] == "-s")

parser:parse(arg[2])
