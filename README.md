TurnBasedMultibox
Coordinate spellcasting between two characters to prevent simultaneous casting

Description:
This addon helps multiboxers coordinate actions between two characters by enforcing turn-based casting. When one character casts, the other is automatically blocked until the cast completes (with a 1-second cooldown).

Usage:

    Set up partners:
    /tbm setpartner Name - Set your coordination partner

    Configure command:
    /tbm setcommand CMD - Set which slash command to execute (e.g., "cast Fireball")

    Execute:
    /tbm go - Run your configured command while blocking your partner

Features:

    Blocks partners automatically during your cast

    1-second cooldown after casting

Example Session:

/tbm setpartner MyAlt  
/tbm setcommand cast Frostbolt  
/tbm go  # Executes /cast Frostbolt and blocks MyAlt
