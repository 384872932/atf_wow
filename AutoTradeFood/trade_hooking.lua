---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by hydra.
--- DateTime: 2020-01-10 22:42
---

local addonName, L = ...


if L.F.is_frontend() then
    L.F.append_trade_hook(L.trade_hooks.trade_stone)
    L.F.append_trade_hook(L.trade_hooks.enlarge)
    L.F.append_trade_hook(L.trade_hooks.trade_refill)
    L.F.append_trade_hook(L.trade_hooks.trade_low_level_food)
    L.F.append_trade_hook(L.trade_hooks.trade_food)
else
    L.F.append_trade_hook(L.trade_hooks.enlarge)
end
