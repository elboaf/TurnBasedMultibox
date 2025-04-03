TurnBasedMultibox Addon - Usage Guide

(For Vanilla WoW 1.12)

This addon allows two characters to take turns executing slash commands (e.g., /swoosh for Rogues, /dribble for Druids) in a synchronized manner, using hidden addon messages to avoid chat spam.
📌 Setup Instructions
1. Install the Addon

    Place the TurnBasedMultibox folder in World of Warcraft\Interface\AddOns\

    Ensure both characters have the addon enabled

2. Configure Each Character
On Character 1 (Leader - Starts First)
lua
Copy

/tbm setpartner Character2Name  -- Set your partner's name
/tbm setslash SWOOSH           -- (or DRIBBLE, etc.)
/tbm setleader                 -- Designate as the starter

On Character 2 (Follower - Waits for Turn)
lua
Copy

/tbm setpartner Character1Name  -- Set your partner's name
/tbm setslash DRIBBLE           -- (or SWOOSH, etc.)

🎮 How to Use
Basic Commands
Command	Description
/tbm setpartner Name	Sets the other character’s name
/tbm setslash COMMAND	Sets which slash command to execute (e.g., SWOOSH, DRIBBLE)
/tbm setleader	Marks this character as the one who starts first
/tbm go	Executes your slash command when it’s your turn
/tbm status	Shows current turn, role, and slash command
How Turns Work

    Leader (who ran /tbm setleader) goes first.

    After using /tbm go, the turn automatically passes to the partner after 2 seconds.

    The other character can then use /tbm go when prompted.

    Turns continue alternating until stopped.

🔧 Troubleshooting
Common Issues & Fixes
Issue	Solution
"Not your turn yet!"	Wait for the other character to finish their turn.
"Command not found"	Ensure the target addon (e.g., SWOOSH/DRIBBLE) is loaded.
Messages not sending	Both characters must be online and in the same zone.
Addon not working	Reload UI (/reload) and reconfigure.
💡 Tips

✅ Works with any slash command – Not just SWOOSH/DRIBBLE!
✅ No chat spam – Uses hidden addon messages.
✅ Flexible timing – Adjust WAIT_DELAY in the code if needed.
Example Workflow

    Rogue (Leader):

        /tbm setpartner MyDruid

        /tbm setslash SWOOSH

        /tbm setleader

        /tbm go (casts first, then passes turn)

    Druid (Follower):

        /tbm setpartner MyRogue

        /tbm setslash DRIBBLE

        Waits for turn notification, then /tbm go
