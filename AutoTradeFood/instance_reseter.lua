---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by hydra.
--- DateTime: 2020-01-17 23:01
---

local addonName, L = ...

local frame = CreateFrame("FRAME", "ATFFrame")
frame:RegisterEvent("CHAT_MSG_SYSTEM")


local timeout = L.reset_instance_timeout

local reseter_context = {
    player=nil,
    request_ts=nil,
}


function L.F.drive_reset_instance()
    local player = reseter_context.player
    if player then
        if GetTime() - reseter_context.request_ts > timeout then
            SendChatMessage("未能重置，您未在规定时间内下线。", "WHISPER", "Common", player)
            LeaveParty()
            reseter_context = {}
        elseif UnitInParty(player) and not UnitIsConnected(player) then
            ResetInstances()
            reseter_context = {}
            SendChatMessage("米豪已帮【"..player.."】重置副本。请M我【"..L.cmds.reset_instance_help.."】查看使用方法。", "say")
            UninviteUnit(player)
        end
    end
end


function L.F.reset_instance_request(player)
    if not (L.F.watch_dog_ok()) then
        SendChatMessage(
                "米豪的驱动程序出现故障，重置副本功能暂时失效，请等待米豪的维修师进行修复。十分抱歉！",
                "WHISPER", "Common", player)
        return
    end

    if UnitInParty(player) then
        if reseter_context.player == player then
            SendChatMessage("【重置流程变更】当前版本只需在【未进组】的情况下M我一次请求即可。无需再次请求。", "WHISPER", "Common", player)
        else
            SendChatMessage("【重置流程变更】为避免高峰期重置冲突，重置流程发生变化，您务必在【未进组】的前提下想我发起请求。本次请求失败。", "WHISPER", "Common", player)
        end
        return
    end

    if reseter_context.player == nil then
        if L.F.gate_cooldown() > 35 then
            SendChatMessage("正在有玩家请求重置，请稍后再试。", "WHISPER", "Common", player)
        else
            reseter_context.player = player
            reseter_context.request_ts = GetTime()
            LeaveParty()
            InviteUnit(player)
            SendChatMessage("请接受组队邀请，然后立即下线。请求有效期"..timeout.."秒。", "WHISPER", "Common", player)
        end
    elseif reseter_context.player == player then
        SendChatMessage("请接受组队邀请，然后立即下线。", "WHISPER", "Common", player)
    else
        SendChatMessage("正在有玩家请求重置，请稍后再试。", "WHISPER", "Common", player)
    end
end


function L.F.say_reset_instance_help(to_player)
    SendChatMessage("重置副本功能可以帮您迅速传送至副本门口，并对副本内怪物进行重置。请按如下步骤操作", "WHISPER", "Common", to_player)
    SendChatMessage("1. 请确保您不在队伍中，然后M我【"..L.cmds.reset_instance_cmd.."】", "WHISPER", "Common", to_player)
    SendChatMessage("2. 如果请求成功，我会向您发起组队邀请。请您进入队伍后在"..timeout.."秒内下线。", "WHISPER", "Common", to_player)
    SendChatMessage("3. 一旦您下线，我会立即重置副本。", "WHISPER", "Common", to_player)
    SendChatMessage("4. 如果您未爆本，下次上线您将会出现在副本门口，且副本内怪物已重置。", "WHISPER", "Common", to_player)
end


local function invite_event(self, event, message)
    if not(L.atfr_run) then
        return
    end

    if event == 'CHAT_MSG_SYSTEM' then
        if reseter_context.player then
            if string.format(ERR_DECLINE_GROUP_S, reseter_context.player) == message
                    or string.format(ERR_ALREADY_IN_GROUP_S, reseter_context.player) == message then
                SendChatMessage("您拒绝了组队邀请，重置请求已取消。", "WHISPER", "Common", reseter_context.player)
                reseter_context = {}
            elseif string.format(ERR_JOINED_GROUP_S, reseter_context.player) == message
                    or string.format(ERR_RAID_MEMBER_ADDED_S, reseter_context.player) == message then
                SendChatMessage("请抓紧时间下线，我将在您下线后立即重置副本。", "WHISPER", "Common", reseter_context.player)
            elseif string.format(ERR_LEFT_GROUP_S, reseter_context.player) == message
                    or string.format(ERR_RAID_MEMBER_REMOVED_S, reseter_context.player) == message
                    or ERR_GROUP_DISBANDED == message then
                SendChatMessage("您离开了队伍，重置请求已取消。", "WHISPER", "Common", reseter_context.player)
                reseter_context = {}
            end
        end
    end
end

frame:SetScript("OnEvent", invite_event)
