# Cursive

> [!IMPORTANT]
>
> **This addon requires you to have [SuperWoW](https://github.com/balakethelock/SuperWoW) installed.**
>
> It won't work without it. Really.

![image](https://github.com/pepopo978/Cursive/assets/149287158/801511af-29c7-4baf-b1ac-5e8c52f0f846)

Cursive combines ShaguScan unit scanning with curse tracking similar to DotTimer and the ability to automatically curse
targets similar to Decursive.

### Recommended setup

Move the Cursive label to the desired position on the screen. You can turn on 'Show Frame Background' in the settings to
help with this. Once you have it where you want it, turn off 'Show Frame Background' and turn on 'Allow clickthrough'
so that it doesn't block your clicks when it's not displaying mobs.

## Commands

`/cursive` for commands, minimap icon to edit options.

### Curse

`/cursive curse <spellName:str>|<guid?:str>|<options?:comma separated str>`: Casts spell if not already on target/guid

EXAMPLE: `/cursive curse Corruption|target` will attempt to cast Corruption on your target if it's not already on them
and they aren't cc'ed.

### Multicurse

`/cursive multicurse <spellName:str>|<priority?:str>|<options?:comma separated str>`: Picks target based on priority and
casts spell if not already on target and they aren't cc'ed.

EXAMPLE: `/cursive multicurse Corruption|HIGHEST_HP` will attempt to cast Corruption picking the target with the highest
HP that doesn't already have it and will warn you if it does nothing.

## Priority Options

- HIGHEST_HP - Target highest HP enemy without a curse first.
- RAID_MARK - Target largest raid mark enemy without a curse first. Priority is as follows:
    - Skull = 8 (1st priority)
    - Cross = 7
    - Square = 6
    - Moon = 5
    - Triangle = 4
    - Circle = 3
    - Star = 2
    - Diamond = 1 (8th priority)
    - No mark = 0
- RAID_MARK_SQUARE - Target largest raid mark but ignore Skull and Cross. Priority is as follows:
    - Square = 6 (1st priority)
    - Moon = 5
    - Triangle = 4
    - Circle = 3
    - Star = 2
    - Diamond = 1
    - No mark = 0
    - Cross = -1
    - Skull = -2 (9th priority)
- INVERSE_RAID_MARK - Target lowest raid mark enemy without a curse first. (reverse of RAID_MARK)

- HIGHEST_HP_RAID_MARK - Target highest HP enemy with a raid (use raid mark priorities for identical hp), then highest
  HP enemy without a mark.
- HIGHEST_HP_RAID_MARK_SQUARE - Same as HIGHEST_HP_RAID_MARK but with RAID_MARK_SQUARE priority for marked enemies.
- HIGHEST_HP_INVERSE_RAID_MARK - Same as HIGHEST_HP_RAID_MARK but with INVERSE_RAID_MARK priority for marked enemies.

## Command Options

All commands can take the following options separated by commas:

- `warnings` : "Display text warnings when a curse fails to cast.",
- `resistsound` : "Play a sound when a curse is resisted.",
- `expiringsound` : "Play a sound when a curse is about to expire.",
- `allowooc` : "Allow out of combat targets to be multicursed. Would only consider using this solo to avoid potentially
  griefing raids/dungeons by pulling unintended mobs.",
- `ignoretarget` : "Ignore the current target when choosing target for multicurse.  Does not affect 'curse' command.",
- `playeronly` : "Only choose players and ignore npcs when choosing target for multicurse.  Does not affect 'curse' command.",
- `minhp=<number>` : "Minimum HP for a target to be considered.",
- `refreshtime=<number>` : "Time threshold at which to allow refreshing a curse. Default is 0 seconds.",
- `name=<str>` : "Filter targets by name. Can be a partial match.  If no match is found, the command will do nothing.",
- `ignorespellid=<number>` : "Ignore targets with the specified spell id already on them. Useful for ignoring targets that already have a shared debuff.",
- `ignorespelltexture=<number>` : "Ignore targets with the specified spell texture already on them. Useful for ignoring targets that already have a shared debuff.",

EXAMPLE: `/cursive multicurse Corruption|HIGHEST_HP|warnings,resistsound,expiringsound,minhp=10000,refreshtime=2`

EXAMPLE: `/cursive multicurse Curse of Recklessness|RAID_MARK|name=Touched Warrior,ignorespelltexture=Spell_Shadow_UnholyStrength,resistsound,expiringsound`

## Important info

If you have my latest nampower, it will use the SpellInRange function from that to provide improved range checking.

Otherwise, all commands will prioritize targets within 28 yards of you first to have a better chance of being in range.

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
- Banish

Multicurse will only ever target enemies that are already in combat (except if you target a mob directly first) to
prevent pulling things you didn't intend like marked patrols.
