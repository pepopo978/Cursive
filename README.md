# Cursive

> [!IMPORTANT]
>
> **This addon requires you to have [SuperWoW](https://github.com/balakethelock/SuperWoW) installed.**
>
> It won't work without it. Really.

![image](https://github.com/pepopo978/Cursive/assets/149287158/801511af-29c7-4baf-b1ac-5e8c52f0f846)


Cursive combines ShaguScan unit scanning with curse tracking similar to DotTimer and the ability to automatically curse targets similar to Decursive.

## Commands
`/cursive` for commands, minimap icon to edit options.

### Curse
`/cursive curse <spellName:str>|<guid?:str>|<noFailureWarning?:int[0,1]`: Casts spell if not already on target/guid

EXAMPLE: `/cursive curse Corruption|target|1` will attempt to cast Corruption on your target if it's not already on them and won't warn you if it does nothing.

### Multicurse
`/cursive multicurse <spellName:str>|<priority?:str>|<noFailureWarning?:int[0,1]`: Picks target based on priority and casts spell if not already on target.  
Priority options: HIGHEST_HP, RAID_MARK

EXAMPLE: `/cursive multicurse Corruption|HIGHEST_HP` will attempt to cast Corruption picking the target with the highest HP that doesn't already have it and will warn you if it does nothing.

## Command Options
All commands can take the following options separated by commas:
- ["warnings"] : "Display text warnings when a curse fails to cast.",
- ["resistsound"] : "Play a sound when a curse is resisted.",
- ["expiringsound"] : "Play a sound when a curse is about to expire.",

EXAMPLE: `/cursive multicurse Corruption|HIGHEST_HP|warnings,resistsound,expiringsound`

## Important info

All commands will prioritize targets within 28 yards of you first to have a better chance of being in range.

All commands will ignore targets with the following CCs on them:
- Sleep
- Entangling Roots
- Shackle Undead
- Polymorph
- Turn Undead
- Blind
- Sap
- Gouge
- Freezing Trap

Multicurse will only ever target enemies that are already in combat (except if you target a mob directly first) to prevent pulling things you didn't intend like marked patrols.

Raid mark priority is based on the following order:
- Skull = 8
- Cross = 7
- Square = 6
- Moon = 5
- Triangle = 4
- Circle = 3
- Star = 2
- Diamond = 1
- No mark = 0
