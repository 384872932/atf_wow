---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by hydra.
--- DateTime: 2020-01-05 14:36
---
local addonName, L = ...

local busy_state_context = {
  ["samples"] = {
    {["sample_ts"]=0, ["water"]=0, ["food"]=0}
  },
  ["is_busy"] = false,
  ["threshold_busy_low"] = 8,
  ["threshold_busy_high"] = 20,
  ["sample_interval"] = 60,
  ["sample_size"] = 5,
}