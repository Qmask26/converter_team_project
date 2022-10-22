if (#arg == 1 or arg[1] ~= "-d" and arg[1] ~= "-s") then
    print("Incorrect, try to: 'lua main.lua [-s | -d] [path/to/input/file]'")
    print(#arg)
    return
elseif (arg[1] == "-s") then
    typechecker = require("src/typecheck/static")
elseif (arg[1] == "-d") then
    typechecker = require("src/typecheck/dynamic")
end
parser = require("src/utils/input_parser")

typechecker:typecheck(arg[2])
expressions = parser:parse(arg[2])
print(#expressions)
for _, v in pairs(expressions) do
    if (v == nil) then
        print("nil")
    else
        print("Computing", v.value.name)
        v.value:compute()
    end
end