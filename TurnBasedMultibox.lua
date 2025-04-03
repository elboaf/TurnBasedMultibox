-- TurnBasedMultibox.lua for Vanilla WoW 1.12
local ADDON_NAME = "TurnBasedMultibox"
local PREFIX = "TBM"
local isCasting = false
local partnerCasting = false
local partnerName = nil
local BLOCK_DELAY = 1.0  -- 1 second delay after leader casts
local timerStart = 0
local mySlashCommand = nil
local mySlashFunc = nil
local lastMessageState = nil  -- Track last message state to prevent spamming

-- Create frames
local f = CreateFrame("Frame", "TurnBasedMultiboxFrame")
local timerFrame = CreateFrame("Frame")

-- Send casting notification
local function SendCastingNotification(isStarting)
    if not partnerName then return end
    
    local msg = isStarting and "CAST_START" or "CAST_END"
    
    if GetNumPartyMembers() > 0 then
        SendAddonMessage(PREFIX, msg, "PARTY")
    else
        SendChatMessage("TBM_"..msg, "WHISPER", nil, partnerName)
    end
end

-- Timer for automatic cast completion
timerFrame:SetScript("OnUpdate", function()
    if timerStart > 0 then
        local currentTime = GetTime()
        local elapsed = currentTime - timerStart
        if elapsed >= BLOCK_DELAY then
            timerStart = 0
            this:Hide()
            if isCasting then
                isCasting = false
                SendCastingNotification(false)
                if lastMessageState ~= "cast_complete" then
                    DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: Casting complete (auto)")
                    lastMessageState = "cast_complete"
                end
            end
        end
    end
end)
timerFrame:Hide()

local function StartCastTimer()
    timerStart = GetTime()
    timerFrame:Show()
end

-- Execute command with casting coordination
local function ExecuteCommand()
    if not partnerName then
        if lastMessageState ~= "no_partner" then
            DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: Set partner first!")
            lastMessageState = "no_partner"
        end
        return
    end
    
    if partnerCasting then
        if lastMessageState ~= "partner_casting" then
            DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: Partner is casting - waiting!")
            lastMessageState = "partner_casting"
        end
        return
    end
    
    if mySlashFunc then
        -- Notify partner we're starting to cast
        isCasting = true
        SendCastingNotification(true)
        
        -- Execute the command
        mySlashFunc()
        if lastMessageState ~= "executing" then
            DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: Executing command")
            lastMessageState = "executing"
        end
        
        -- Start timer to automatically end casting state
        StartCastTimer()
    else
        if lastMessageState ~= "no_command" then
            DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: No command configured!")
            lastMessageState = "no_command"
        end
    end
end

-- Slash command handler
SLASH_TURNBASEDMULTIBOX1 = "/tbm"

function SlashCmdList.TURNBASEDMULTIBOX(msg)
    local space = string.find(msg, " ") or 0
    local cmd = string.sub(msg, 1, space-1)
    local arg = string.sub(msg, space+1)
    
    if cmd == "setpartner" and arg ~= "" then
        partnerName = arg
        DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: Partner set to "..arg)
        lastMessageState = nil  -- Reset message state on new partner
    elseif cmd == "setcommand" and arg ~= "" then
        local cmdUpper = string.upper(arg)
        if SlashCmdList[cmdUpper] then
            mySlashCommand = cmdUpper
            mySlashFunc = SlashCmdList[cmdUpper]
            DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: Will execute /"..arg)
            lastMessageState = nil  -- Reset message state on new command
        else
            DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: Command /"..arg.." not found!")
        end
    elseif cmd == "go" then
        ExecuteCommand()
    elseif cmd == "endcast" then
        if isCasting then
            isCasting = false
            timerStart = 0  -- Cancel any pending timer
            timerFrame:Hide()
            SendCastingNotification(false)
            if lastMessageState ~= "cast_complete" then
                DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: Casting complete (manual)")
                lastMessageState = "cast_complete"
            end
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox Commands:")
        DEFAULT_CHAT_FRAME:AddMessage("/tbm setpartner Name - Set your partner")
        DEFAULT_CHAT_FRAME:AddMessage("/tbm setcommand CMD - Set command to execute")
        DEFAULT_CHAT_FRAME:AddMessage("/tbm go - Execute your command (1 sec cooldown)")
        DEFAULT_CHAT_FRAME:AddMessage("/tbm endcast - Manually end casting state")
    end
end

-- Event handling
f:SetScript("OnEvent", function()
    if event == "PLAYER_ENTERING_WORLD" then
        DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox loaded")
    elseif event == "CHAT_MSG_ADDON" then
        if arg1 == PREFIX and arg4 == partnerName then
            if arg2 == "CAST_START" then
                partnerCasting = true
                if lastMessageState ~= "partner_started" then
                    DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: Partner started casting")
                    lastMessageState = "partner_started"
                end
            elseif arg2 == "CAST_END" then
                partnerCasting = false
                if lastMessageState ~= "partner_finished" then
                    DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: Partner finished casting")
                    lastMessageState = "partner_finished"
                end
            end
        end
    elseif event == "CHAT_MSG_WHISPER" then
        if arg2 == partnerName then
            if arg1 == "TBM_CAST_START" then
                partnerCasting = true
                if lastMessageState ~= "partner_started" then
                    DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: Partner started casting (whisper)")
                    lastMessageState = "partner_started"
                end
            elseif arg1 == "TBM_CAST_END" then
                partnerCasting = false
                if lastMessageState ~= "partner_finished" then
                    DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: Partner finished casting (whisper)")
                    lastMessageState = "partner_finished"
                end
            end
        end
    end
end)

f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("CHAT_MSG_ADDON")
f:RegisterEvent("CHAT_MSG_WHISPER")