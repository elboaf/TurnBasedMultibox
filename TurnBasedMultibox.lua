-- TurnBasedMultibox.lua for Vanilla WoW 1.12
local ADDON_NAME = "TurnBasedMultibox"
local PREFIX = "TBM"
local isMyTurn = false
local partnerName = nil
local isLeader = false
local WAIT_DELAY = 1.0
local timerStart = 0  -- Initialize as number
local mySlashCommand = nil
local mySlashFunc = nil

-- Create frames
local f = CreateFrame("Frame", "TurnBasedMultiboxFrame")
local timerFrame = CreateFrame("Frame")

-- Universal message sending
local function SendTurnMessage()
    if not partnerName then return end
    
    -- Try different methods
    if GetNumPartyMembers() > 0 then
        SendAddonMessage(PREFIX, "TURN_PASS", "PARTY")
    else
        SendChatMessage("TBM_TURN_PASS", "WHISPER", nil, partnerName)
    end
    DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: Turn passed")
end

-- Fixed timer implementation
timerFrame:SetScript("OnUpdate", function()
    if timerStart > 0 then  -- Check if timer is active
        local currentTime = GetTime()
        local elapsed = currentTime - timerStart
        if elapsed >= WAIT_DELAY then
            timerStart = 0  -- Reset timer
            this:Hide()
            SendTurnMessage()
        end
    end
end)
timerFrame:Hide()

local function PassTurnWithDelay()
    timerStart = GetTime()  -- Store numeric timestamp
    timerFrame:Show()
end

-- Execute command
local function ExecuteCommand()
    if mySlashFunc then
        mySlashFunc()
        DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: Executing command")
        isMyTurn = false
        PassTurnWithDelay()
    else
        DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: No command configured!")
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
    elseif cmd == "setleader" then
        isLeader = true
        isMyTurn = true
        DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: You are now the leader")
    elseif cmd == "setcommand" and arg ~= "" then
        local cmdUpper = string.upper(arg)
        if SlashCmdList[cmdUpper] then
            mySlashCommand = cmdUpper
            mySlashFunc = SlashCmdList[cmdUpper]
            DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: Will execute /"..arg)
        else
            DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: Command /"..arg.." not found!")
        end
    elseif cmd == "go" then
        if not partnerName then
            DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: Set partner first!")
            return
        end
        if not mySlashCommand then
            DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: Set command first!")
            return
        end
        if not isMyTurn then
            DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: Not your turn!")
            return
        end
        ExecuteCommand()
    else
        DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox Commands:")
        DEFAULT_CHAT_FRAME:AddMessage("/tbm setpartner Name - Set your partner")
        DEFAULT_CHAT_FRAME:AddMessage("/tbm setleader - Become the leader")
        DEFAULT_CHAT_FRAME:AddMessage("/tbm setcommand CMD - Set command to execute")
        DEFAULT_CHAT_FRAME:AddMessage("/tbm go - Execute your command")
    end
end

-- Event handling
f:SetScript("OnEvent", function()
    if event == "PLAYER_ENTERING_WORLD" then
        DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox loaded")
        if isLeader then
            isMyTurn = true
            DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: You have first turn!")
        end
    elseif event == "CHAT_MSG_ADDON" then
        if arg1 == PREFIX and arg2 == "TURN_PASS" and arg4 == partnerName then
            isMyTurn = true
            DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: Received turn")
        end
    elseif event == "CHAT_MSG_WHISPER" then
        if arg1 == "TBM_TURN_PASS" and arg2 == partnerName then
            isMyTurn = true
            DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: Received turn via whisper")
        end
    end
end)

f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("CHAT_MSG_ADDON")
f:RegisterEvent("CHAT_MSG_WHISPER")