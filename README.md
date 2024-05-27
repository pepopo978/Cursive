# Cursive

> [!IMPORTANT]
>
> **This addon requires you to have [SuperWoW](https://github.com/balakethelock/SuperWoW) installed.**
>
> It won't work without it. Really.

![image](https://github.com/pepopo978/Cursive/assets/149287158/801511af-29c7-4baf-b1ac-5e8c52f0f846)


Cursive combines ShaguScan unit scanning with curse tracking similar to DotTimer and the ability to automatically curse targets similar to Decursive.

`/cursive` for commands, minimap icon to edit options.

`/cursive curse <spellName:str>|<guid?:str>|<noFailureWarning?:int[0,1]`: Casts spell if not already on target/guid

EXAMPLE: `/cursive curse Corruption|target|1` will attempt to cast Corruption on your target if it's not already on them and won't warn you if it does nothing.

`/cursive multicurse <spellName:str>|<priority?:str>|<noFailureWarning?:int[0,1]`: Picks target based on priority and casts spell if not already on target.  
Priority options: HIGHEST_HP, RAID_MARK

EXAMPLE: `/cursive multicurse Corruption|HIGHEST_HP` will attempt to cast Corruption picking the target with the highest HP that doesn't already have it and will warn you if it does nothing.
