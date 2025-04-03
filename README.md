TurnBasedMultibox Addon
Perfect for synchronized multiboxing in Vanilla WoW 1.12
🚀 Quick Start Guide
1. Installation

    Download the TurnBasedMultibox folder

    Place it in World of Warcraft\Interface\AddOns\

    Ensure both characters have the addon enabled

🎮 Setup & Commands
First Character (Leader)
/tbm setpartner DruidName    -- Set your partner's name
/tbm setcommand SWOOSH      -- Configure your slash command
/tbm setleader             -- Designate as the starter

Second Character (Follower)
/tbm setpartner RogueName   -- Set your partner's name  
/tbm setcommand DRIBBLE    -- Configure your slash command  

Core Commands
Command	Description	Example
/tbm setpartner NAME	Links to your multibox partner	/tbm setpartner MyDruid
/tbm setcommand CMD	Sets which slash command to execute	/tbm setcommand SWOOSH
/tbm setleader	Makes this character start first	(Run once on main char)
/tbm go	Executes your command when it's your turn	(Alternates automatically)
/tbm status	Shows current turn/command status	
🔄 How Turns Work

    Leader casts first with /tbm go

    After 1 seconds, turn automatically passes to partner

    Follower can then use /tbm go

    Continues alternating until stopped


✅ Works with ANY slash command - Not just SWOOSH/DRIBBLE!
✅ No chat spam - Uses hidden addon messaging
✅ Flexible timing - Edit WAIT_DELAY in code if needed
