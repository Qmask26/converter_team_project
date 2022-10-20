
function table.length(arr)
    size = 0
    for _ in pairs(arr) do
        size = size + 1
    end
    return size
end