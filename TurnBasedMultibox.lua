-- TurnBasedMultibox.lua for Vanilla WoW 1.12
local ADDON_NAME = "TurnBasedMultibox"
local PREFIX = "TBM" -- Addon message prefix
local isMyTurn = false
local partnerName = nil
local myClass = nil
local isLeader = false
local WAIT_DELAY = 1.0 -- 2 second delay
local timerStart = nil

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

-- Execute class-specific slash commands
local function ExecuteClassCommand()
    if myClass == "ROGUE" then
        if SlashCmdList["SWOOSH"] then
            SlashCmdList["SWOOSH"]() -- Execute /swoosh
            DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: Executing /swoosh")
        else
            DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: SWOOSH addon not loaded!")
        end
    elseif myClass == "DRUID" then
        if SlashCmdList["DRIBBLE"] then
            SlashCmdList["DRIBBLE"]() -- Execute /dribble
            DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: Executing /dribble")
        else
            DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: DRIBBLE addon not loaded!")
        end
    end
    
    -- Pass turn after executing command
    isMyTurn = false
    PassTurnWithDelay()
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
    elseif cmd == "status" then
        DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: "..(isMyTurn and "It's YOUR turn" or "Waiting for partner"))
        DEFAULT_CHAT_FRAME:AddMessage("Status: "..(isLeader and "Leader" or "Follower"))
        DEFAULT_CHAT_FRAME:AddMessage("Class: "..(myClass or "unknown"))
    elseif cmd == "go" then
        if not partnerName then
            DEFAULT_CHAT_FRAME:AddMessage("TurnBasedMultibox: Set partner first with /tbm setpartner Name")
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
        DEFAULT_CHAT_FRAME:AddMessage("/tbm go - Execute class command (with "..WAIT_DELAY.."s delay)")
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