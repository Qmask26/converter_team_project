
function table.length(arr)
    local size = 0
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
function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function deepcopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
            end
            setmetatable(copy, deepcopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = ori
    end
    return copy
end