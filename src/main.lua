if (not (#arg == 2 and (arg[1] == "-s" or arg[1] == "-d") or #arg == 1 and arg[1] == "-r")) then
    print("Incorrect, try to: 'lua main.lua [[-s | -d] [path/to/input/file] | -r]'")
    print(#arg)
    return
end

needToPrintStepByStep = nil

if (arg[1] == '-r') then
    Parser = require("src/utils/input_parser")
    local parser = Parser:new(false)
    parser:parse('-r')
else 
    Parser = require("src/utils/input_parser")
    local parser = Parser:new(arg[1] == "-s")
    parser:parse(arg[2])
end


