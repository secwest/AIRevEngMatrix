local ok, result = pcall(function()
    local text = arg[1]
    if text == nil then error("missing", 0) end
    if not text:match("^%d+$") then error("invalid", 0) end
    local value = tonumber(text)
    if value == nil or value > 255 then error("invalid", 0) end
    local amount = 7
    local function apply(number)
        if number > 255 - amount then error("overflow", 0) end
        return number + amount
    end
    return apply(value)
end)
if ok then print("ok:" .. string.format("%d", result))
else print("err:" .. result) end
