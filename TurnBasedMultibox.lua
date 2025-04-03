-- TurnBasedMultibox.lua for Vanilla WoW 1.12
local ADDON_NAME = "TurnBasedMultibox"
local PREFIX = "TBM" -- Addon message prefix
local isMyTurn = false
local partnerName = nil
local myClass = nil
local isLeader = false
local WAIT_DELAY = 2.0 -- 2 second delay
local timerStart = nil
local mySlashCommand = nil -- Stores which slash command to use

-- Create frames
local f = CreateFrame("Frame", "TurnBasedMultiboxFrame")
local timerFrame = CreateFrame("Frame") -- For delay handling

-- Safe message sending function
local function SendTurnMessage()
    if not partnerName then return end
    
    -- Try PARTY channel first (works even if not in party)
    if GetNumPartyMembers() > 0 then
        SendAddonMessage(PREFIX, "TURN_PASS", "PARTY")
    else
        -- Fall back to WHISPER if not in party
        SendAddonMessage(PREFIX, "TURN_PASS", "WHISPER", partnerName)
    end
    DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: Turn passed to partner")
end

-- Timer implementation for Vanilla
timerFrame:SetScript("OnUpdate", function()
    if timerStart and (GetTime() - timerStart) >= WAIT_DELAY then
        timerStart = nil
        this:Hide()
        SendTurnMessage()
    end
end)
timerFrame:Hide()

local function PassTurnWithDelay()
    timerStart = GetTime()
    timerFrame:Show()
end

-- Execute the configured slash command
local function ExecuteClassCommand()
    if mySlashCommand and SlashCmdList[mySlashCommand] then
        SlashCmdList[mySlashCommand]()
        DEFAULT_CHAT_FRAME:AddMessage(format("TurnBasedMultibox: Executing /%s", mySlashCommand))
    else
        DEFAULT_CHAT_FRAME:AddMessage(format("TurnBasedMultibox: Error! Command '%s' not found", mySlashCommand or "nil"))
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
        DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: You are now the leader (start first)")
    elseif cmd == "setslash" and arg ~= "" then
        mySlashCommand = string.upper(arg)
        DEFAULT_CHAT_FRAME:AddMessage(format("TurnBasedMultibox: Will execute /%s when it's your turn", arg))
    elseif cmd == "status" then
        DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: "..(isMyTurn and "It's YOUR turn" or "Waiting for partner"))
        DEFAULT_CHAT_FRAME:AddMessage("Status: "..(isLeader and "Leader" or "Follower"))
        DEFAULT_CHAT_FRAME:AddMessage("Class: "..(myClass or "unknown"))
        DEFAULT_CHAT_FRAME:AddMessage("Slash Command: "..(mySlashCommand or "not set"))
    elseif cmd == "go" then
        if not partnerName then
            DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: Set partner first with /tbm setpartner Name")
            return
        end
        
        if not mySlashCommand then
            DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: Set slash command first with /tbm setslash COMMAND")
            return
        end
        
        if not isMyTurn then
            DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: Not your turn yet!")
            return
        end
        
        ExecuteClassCommand()
    else
        DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox Commands:")
        DEFAULT_CHAT_FRAME:AddMessage("/tbm setpartner Name - Set your partner")
        DEFAULT_CHAT_FRAME:AddMessage("/tbm setleader - Designate yourself as starter")
        DEFAULT_CHAT_FRAME:AddMessage("/tbm setslash COMMAND - Set which slash command to execute (e.g. SWOOSH)")
        DEFAULT_CHAT_FRAME:AddMessage("/tbm go - Execute your slash command")
        DEFAULT_CHAT_FRAME:AddMessage("/tbm status - Show current status")
    end
end

-- Event handling
f:SetScript("OnEvent", function()
    if event == "PLAYER_ENTERING_WORLD" then
        -- Get player class
        _, myClass = UnitClass("player")
        DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: Loaded - /tbm for help")
        
        -- If leader, announce first turn
        if isLeader then
            isMyTurn = true
            DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: You have first turn!")
        end
        
    elseif event == "CHAT_MSG_ADDON" then
        -- Only handle our own addon messages
        if arg1 == PREFIX then
            if arg2 == "TURN_PASS" and arg4 == partnerName then
                isMyTurn = true
                DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: Received turn from "..arg4)
            end
        end
    end
end)

-- Register events
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("CHAT_MSG_ADDON") -- For addon messages

DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox loaded. Type /tbm for help")