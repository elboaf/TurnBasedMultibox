TurnBasedMultibox    
Coordinate spellcasting between two characters to prevent simultaneous casting

This addon was created specifically for Turtle Wow. 

Multiboxing is the act of controlling multiple WoW clients simultaneously. This can entail having multiple clients open on a single machine or utilizing multiple machines to control the actions of both accounts at the same time for combat or moving. Source:  https://turtle-wow.org/rules

With clever usage of macros/addons, keyboard inputs to the focused window or PC, and mouse button (scroll wheel) inputs to the non-focused window or PC, multiboxing can often appear as if you are using 3rd party software to broadcast inputs, when you are not. This addon aims to prevent the appearance of this phenomenon. Despite sending simultaneous inputs to each window in a manner that is technically not violating any of the currently stated rules, if your characters are observed, by other players or staff, casting spells/abilities at the exact same frame or within a very small window of time of one another, then it's very likely you will be reported by players, investigated by staff, and banned for usage of 3rd party software.

This addon serves as an abstraction layer between actual user inputs, and the execution of the main loop function for the other multiboxing addons found in my repository, which prevents simultaneous casts between multiboxed characters -- When one character casts, the other is automatically blocked for 1000 ms.

Usage:

    Set up partners:
    /tbm setpartner Name - Set your coordination partner

    Configure command:
    /tbm setcommand CMD - Set which slash command to execute (e.g., "DRIBBLE"), where DRIBBLE is the slash command that executes the main loop function from another addon, eg: https://github.com/elboaf/Dribble

    Execute:
    /tbm go - Run your configured command while blocking your partner

Features:

    Blocks partners automatically during your cast

    1-second cooldown after casting

Example Session:

/tbm setpartner Myalt  
/tbm setcommand SLASHCOMMAND    
/tbm go
