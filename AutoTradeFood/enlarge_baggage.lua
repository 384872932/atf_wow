---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by hydra.
--- DateTime: 2020-01-30 01:21
---

local addonName, L = ...

local target_frame = L.F.create_macro_button("TargetTransfer", "/target targetname")
local frame = CreateFrame("FRAME")
frame:RegisterEvent("CHAT_MSG_ADDON")

local transfer_ctx = nil
local timeout = 60


local function build_transfer_ctx(target, num, direction)
    transfer_ctx = {
        request_ts = GetTime(),
        target = target,
        num = num,
        direction = direction,
        is_trading = false,
    }
end


function L.F.has_transfer_ctx()
    if transfer_ctx then
        if GetTime() - transfer_ctx.request_ts > timeout then
            transfer_ctx = nil
            return false
        end
        return true
    else
        return false
    end
end


local has_transfer_ctx = L.F.has_transfer_ctx


local function request_transfer(num, direction)
    -- called by frontend.
    -- direction: in, out
    local backend = L.F.choice_random_backend()
    if backend then
        C_ChatInfo.SendAddonMessage("ATF", "transfer_"..direction..":"..num, "whisper", backend)
        build_transfer_ctx(backend, num, direction)
    end
end


function L.F.drive_enlarge_baggage_frontend()
    if not(has_transfer_ctx()) then
        if L.F.get_free_slots() <= 2 then
            request_transfer(6, "out")
        elseif L.F.get_water_count() <= 12 then
            request_transfer(6, "in")
        end
    end
end


function L.F.drive_enlarge_baggage_backend()
    if has_transfer_ctx() then
        if UnitName("target") == transfer_ctx.target and not(transfer_ctx.is_trading) then
            if transfer_ctx.direction == "out" and L.F.get_water_count() > 0 then
                InitiateTrade("target")
            elseif transfer_ctx.direction == "in" and L.F.get_free_slots() >= transfer_ctx.num then
                InitiateTrade("target")
            else
                transfer_ctx = nil
                -- no stock or slots.
            end
        end
    end
end


function L.F.bind_set_enlarge_target()
    if has_transfer_ctx() then
        if not(UnitName("target") == transfer_ctx.target) then
            target_frame:SetAttribute("macrotext", "/targetexact "..transfer_ctx.target)
            SetBindingClick(L.hotkeys.interact_key, "TargetTransfer")
            return true
        end
    end
    return false
end


local function eventHandler(self, event, arg1, arg2, arg3, arg4)
    if event == "CHAT_MSG_ADDON" and arg1 == "ATF" then
        local message, author = arg2, arg4
        author = string.match(author, "([^-]+)")
        if L.F.is_frontend() then
            -- frontend do not respond to commands.
        else
            local cmd, num = string.match(message, "(.-):(.+)")
            num = tonumber(num)
            if cmd and num > 0 and num <= 6 then
                if cmd == "transfer_in" or cmd == "transfer_out" then
                    local direction = string.match(cmd, "transfer_(.*)")
                    author = string.match(author, "([^-]+)") or author
                    if not(has_transfer_ctx()) then
                        if direction == "in" then
                            build_transfer_ctx(author, num, "out")
                        elseif direction == "out" then
                            build_transfer_ctx(author, num, "in")
                        end
                    end
                end
            end
        end
    end
end


frame:SetScript("OnEvent", eventHandler)


local function should_enlarge(trade)
    if has_transfer_ctx() then
        local npc_name = trade.npc_name
        if npc_name == transfer_ctx.target then
            transfer_ctx.is_trading = true
            return true, false
        else
            return false, false
        end
    else
        return false, false
    end
end


local function feed_foods(trade)
    if has_transfer_ctx() then
        if transfer_ctx.direction == "out" then
            L.F.feed(L.items.water_name, transfer_ctx.num, 20)
            return true
        end
    end
end


local function should_accept(trade)
    return has_transfer_ctx()
end


local function trade_completed(trade)
    L.F.merge_statistics_plus_int("trade.enlarge.count."..date("%x"), 1)
    if L.F.is_frontend() then
        local direction
        if transfer_ctx.direction == "in" then
            direction = "加油"
        else
            direction = "储油"
        end
        L.F.queue_message("远程"..direction.."成功，传输大水"..transfer_ctx.num.."组，目标："..transfer_ctx.target)
    end
    transfer_ctx = nil
end


local function trade_cancel_or_err(trade)
    transfer_ctx = nil
    print("enlarge cancel or error.")
end

L.trade_hooks.enlarge = {
  ["should_hook"] = should_enlarge,
  ["feed_items"] = feed_foods,
  ["on_trade_complete"] = trade_completed,
  ["on_trade_cancel"] = trade_cancel_or_err,
  ["on_trade_error"] = trade_cancel_or_err,
  ["should_accept"] = should_accept,
  ["check_target_item"] = nil,
}
