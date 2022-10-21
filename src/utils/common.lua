
function table.length(arr)
    size = 0
    for _ in pairs(arr) do
        size = size + 1
    end
    return size
end

function table_tostring_as_array(table) 
    local k, v
    local s = "["
    for k, v in pairs(table) do
        s = s .. tostring(v) .. ", "
    end
    s = string.sub(s, 0, #s-2) .. "]"
    return s
end

function table_tostring(table)
    local k, v
    local s = "{"
    for k, v in pairs(table) do
        s = s .. tostring(k) .. ": " .. tostring(v) .. ", "
    end
    s = string.sub(s, 0, #s-2) .. "}"
    return s
end

function copy_table(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        table.insert(copy, v)
    end
    return copy
end