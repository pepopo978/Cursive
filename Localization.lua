local L = AceLibrary("AceLocale-2.2"):new("Cursive")

L:RegisterTranslations("enUS", function()
	return {
		["|cffffcc00Cursive:|cffffaaaa Commands:"] = true,
		["|cffffcc00Priority choices:"] = true,
		["|cffffcc00Options (separate with ,):"] = true,
		["Display text warnings when a curse fails to cast."] = true,
		["Play a sound when a curse is resisted."] = true,
		["Play a sound when a curse is about to expire."] = true,
		["Allow out of combat targets to be multicursed.  Would only consider using this solo to avoid potentially griefing raids/dungeons by pulling unintended mobs."] = true,
		["Minimum HP for a target to be considered.  Example usage minhp=10000. "] = true,
		["Time threshold at which to allow refreshing a curse.  Default is 0 seconds."] = true,
		["Ignore the current target when choosing target for multicurse.  Does not affect 'curse' command."] = true,
		["/cursive curse <spellName:str>|<guid?:str>|<options?:List<str>>: Casts spell if not already on target/guid"] = true,
		["/cursive multicurse <spellName:str>|<priority?:str>|<options?:List<str>>: Picks target based on priority and casts spell if not already on target"] = true,
		["Target with the highest HP."] = true,
		["Target with the highest raid mark."] = true,
		["Target with the highest raid mark with Cross set to -1 and Skull set to -2 (Square highest prio at 6)."] = true,
		["Target with the lowest raid mark."] = true,
		["Target with the highest HP and raid mark."] = true,
		["Same as HIGHEST_HP_RAID_MARK but with RAID_MARK_SQUARE mark prio."] = true,
		["Same as HIGHEST_HP_RAID_MARK but with INVERSE_RAID_MARK mark prio."] = true,
		["|cffffcc00Cursive:|cffffaaaa Couldn't find a target to curse."] = true,
		["curse_duration_format"] = ".*over ([%d.]+) sec.",

		-- curses
		["(.+) fades from (.+)"] = true,
		["Your (.+) was resisted by (.+)"] = true,

		-- global
		["|cffffcc00Cursive:|cffffaaaa Couldn't detect SuperWoW."] = true,
		["|cffffcc00Cursive:|cffffaaaa Loaded.  /cursive for commands and minimap icon for options."] = true,


		-- settings
		["Cursive"] = true,
		["Health Bar Width"] = true,
		["Health Bar Height"] = true,
		["Raid Icon Size"] = true,
		["Curse Icon Size"] = true,
		["Spacing"] = true,
		["Text Size"] = true,
		["Scale"] = true,
		["In Combat"] = true,
		["Hostile"] = true,
		["Attackable"] = true,
		["Within 28 Range"] = true,
		["Within 45 Range"] = true,
		["Has Raid Mark"] = true,
		["Has Curse"] = true,
		["Only show units you have cursed"] = true,
		["Enabled"] = true,
		["Enable/Disable Cursive"] = true,
		["Show Title"] = true,
		["Show the title of the frame"] = true,
		["Allow clickthrough"] = true,
		["This will allow you to click through the frame to target mobs behind it, but prevents dragging the frame."] = true,
		["Show Frame Background"] = true,
		["Toggle the frame background to help with positioning"] = true,
		["Reset Frame"] = true,
		["Move the frame back to the default position"] = true,
		["Bar Display Settings"] = true,
		["Mob filters"] = true,
		["Target and Raid Marks always shown"] = true,
		["Max Curses"] = true,
		["Max Rows"] = true,
		["Max Columns"] = true,


		-- spells
		["Rank 1"] = true,
		["Rank 2"] = true,
		["Rank 3"] = true,
		["Rank 4"] = true,

		-- druid
		["Entangling Roots"] = true,
		["Sleep"] = true,
		["Faerie Fire"] = true,
		["Faerie Fire (Bear)"] = true,
		["Faerie Fire (Feral)"] = true,
		["Hibernate"] = true,
		["Insect Swarm"] = true,
		["Mangle"] = true,
		["Moonfire"] = true,
		["Rake"] = true,
		["Rip"] = true,
		["Soothe Animal"] = true,
		["Bash"] = true,
		["Maim"] = true,
		["Demoralizing Roar"] = true,
		["Challenging Roar"] = true,

		-- hunter
		["Scorpid Sting"] = true,
		["Serpent Sting"] = true,
		["Viper Sting"] = true,
		["Wing Clip"] = true,
		["Concussive Shot"] = true,
		["Wyvern Sting"] = true,
		["Counterattack"] = true,
		["Hunter\'s Mark"] = true,
		["Freezing Trap"] = true,

		-- mage
		["Polymorph"] = true,
		["Polymorph: Cow"] = true,
		["Polymorph: Turtle"] = true,
		["Polymorph: Pig"] = true,

		-- priest
		["Shackle Undead"] = true,
		["Mind Soothe"] = true,
		["Mind Control"] = true,
		["Devouring Plague"] = true,
		["Hex of Weakness"] = true,
		["Shadow Word: Pain"] = true,
		["Vampiric Embrace"] = true,
		["Holy Fire"] = true,

		-- Paladin
		["Turn Undead"] = true,

		-- rogue
		["Blind"] = true,
		["Sap"] = true,
		["Gouge"] = true,

		-- warlock
		["Conflagrate"] = true,
		["Corruption"] = true,
		["Curse of Agony"] = true,
		["Curse of Doom"] = true,
		["Curse of Recklessness"] = true,
		["Curse of Shadow"] = true,
		["Curse of the Elements"] = true,
		["Curse of Tongues"] = true,
		["Curse of Weakness"] = true,
		["Curse of Exhaustion"] = true,
		["Immolate"] = true,
		["Death Coil"] = true,
		["Banish"] = true,
		["Siphon Life"] = true,
		["Fear"] = true,
	}
end)

L:RegisterTranslations("zhCN", function()
	return {
		["|cffffcc00Cursive:|cffffaaaa Commands:"] = "|cffffcc00Cursive:|cffffaaaa 命令:",
		["|cffffcc00Priority choices:"] = "|cffffcc00优先级选择:",
		["|cffffcc00Options (separate with ,):"] = "|cffffcc00选项 (用半角逗号分隔):",
		["Display text warnings when a curse fails to cast."] = "当诅咒施放失败时显示文本警告.",
		["Play a sound when a curse is resisted."] = "当诅咒被抵抗时播放声音.",
		["Play a sound when a curse is about to expire."] = "当诅咒即将到期时播放声音.\n 详细使用说明及示例请查看readme文件",
		["Allow out of combat targets to be multicursed.  Would only consider using this solo to avoid potentially griefing raids/dungeons by pulling unintended mobs."] = "允许战斗外目标被多重诅咒。只有在单人游戏中才会考虑使用这个选项，以避免在副本中意外拉到怪物而造成困扰.",
		["Minimum HP for a target to be considered.  Example usage minhp=10000. "] = "目标考虑的最小生命值。例如：minhp=10000.",
		["Time threshold at which to allow refreshing a curse.  Default is 0 seconds."] = "允许刷新诅咒的时间阈值。默认是0秒.例如：refreshtime=2",
		["Ignore the current target when choosing target for multicurse.  Does not affect 'curse' command."] = "选择多重诅咒目标时忽略当前目标。不影响‘诅咒’命令。",
		["/cursive curse <spellName:str>|<guid?:str>|<options?:List<str>>: Casts spell if not already on target/guid"] = "/cursive curse <法术名称>|<目标ID>|<选项列表,用半角逗号分隔>: 如果目标/ID身上没有此法术，目标ID可以是以下内容(mouseover), (player), (pet), (party)(%d), (partypet)(%d), (raid)(%d+), (raidpet)(%d+), (target), (targettarget)",
		["/cursive multicurse <spellName:str>|<priority?:str>|<options?:List<str>>: Picks target based on priority and casts spell if not already on target"] = "/cursive multicurse <法术名称>|<优先级>|<选项列表,用半角逗号分隔>: 根据优先级选择目标并施放法术，如果目标上没有",
		["Target with the highest HP."] = "选择生命值最高的目标.",
		["Target with the highest raid mark."] = "选择团队标记最高的目标.",
		["Target with the highest raid mark with Cross set to -1 and Skull set to -2 (Square highest prio at 6)."] = "选择团队标记最高的目标，但是将红叉设为-1，骷髅设为-2（方块标记最高优先级为6）.",
		["Target with the lowest raid mark."] = "选择团队标记优先级最低的目标.(与RAID_MARK顺序相反)",
		["Target with the highest HP and raid mark."] = "选择生命值和团队标记最高的目标.",
		["Same as HIGHEST_HP_RAID_MARK but with RAID_MARK_SQUARE mark prio."] = "与HIGHEST_HP_RAID_MARK相同，但是RAID_MARK_SQUARE标记优先.",
		["Same as HIGHEST_HP_RAID_MARK but with INVERSE_RAID_MARK mark prio."] = "与HIGHEST_HP_RAID_MARK相同，但是INVERSE_RAID_MARK标记优先.",
		["|cffffcc00Cursive:|cffffaaaa Couldn't find a target to curse."] = "|cffffcc00Cursive:|cffffaaaa 找不到要诅咒的目标.",
		["curse_duration_format"] = ".*持续([%d.]+)秒.", -- no idea if this is right

		-- curses
		["(.+) fades from (.+)"] = "(.+)效果从(.+)身上消失",
		["Your (.+) was resisted by (.+)"] = "你的(.+)被(.+)抵抗了",

		-- global
		["|cffffcc00Cursive:|cffffaaaa Couldn't detect SuperWoW."] = "|cffffcc00Cursive:|cffffaaaa 无法检测到SuperWoW.",
		["|cffffcc00Cursive:|cffffaaaa Loaded.  /cursive for commands and minimap icon for options."] = "|cffffcc00Cursive:|cffffaaaa 已加载。/cursive 用于查看帮助命令，小地图图标打开设置选项.",

		-- settings
		["Cursive"] = "Cursive",
		["Health Bar Width"] = "生命条宽度",
		["Health Bar Height"] = "生命条高度",
		["Raid Icon Size"] = "团队标记大小",
		["Curse Icon Size"] = "诅咒图标大小",
		["Spacing"] = "间距",
		["Text Size"] = "文本大小",
		["Scale"] = "缩放",
		["In Combat"] = "战斗中",
		["Hostile"] = "敌对",
		["Attackable"] = "可攻击",
		["Within 28 Range"] = "在28范围内",
		["Within 45 Range"] = "在45范围内",
		["Has Raid Mark"] = "有团队标记",
		["Has Curse"] = "有诅咒",
		["Only show units you have cursed"] = "只显示你诅咒过的单位",
		["Enabled"] = "启用",
		["Enable/Disable Cursive"] = "启用/禁用 Cursive",
		["Show Title"] = "显示标题",
		["Show the title of the frame"] = "显示框架的标题",
		["Allow clickthrough"] = "允许点击穿透",
		["This will allow you to click through the frame to target mobs behind it, but prevents dragging the frame."] = "这将允许你点击穿透框架选中其背后的怪物，但会禁用拖动框架.",
		["Show Frame Background"] = "显示框架背景",
		["Toggle the frame background to help with positioning"] = "切换框架背景以帮助定位",
		["Reset Frame"] = "重置框架",
		["Move the frame back to the default position"] = "将框架移回默认位置",
		["Bar Display Settings"] = "条形显示设置",
		["Mob filters"] = "怪物过滤器",
		["Target and Raid Marks always shown"] = "目标和团队标记始终显示",
		["Max Curses"] = "最大诅咒数",
		["Max Rows"] = "最大行数",
		["Max Columns"] = "最大列数",

		-- spells
		["Rank 1"] = "等级 1",
		["Rank 2"] = "等级 2",
		["Rank 3"] = "等级 3",
		["Rank 4"] = "等级 4",

		-- druid
		["Entangling Roots"] = "纠缠根须",
		["Sleep"] = "沉睡",
		["Faerie Fire"] = "精灵之火",
		["Faerie Fire (Bear)"] = "精灵之火（熊形态）",
		["Faerie Fire (Feral)"] = "精灵之火（野性形态）",
		["Hibernate"] = "休眠",
		["Insect Swarm"] = "虫群",
		["Mangle"] = "撕碎", -- no idea if right
		["Moonfire"] = "月火术",
		["Rake"] = "扫击",
		["Rip"] = "撕扯",
		["Soothe Animal"] = "安抚动物",
		["Bash"] = "重击",
		["Maim"] = "致残",
		["Demoralizing Roar"] = "挫志咆哮",
		["Challenging Roar"] = "挑战咆哮",

		-- hunter
		["Scorpid Sting"] = "毒蝎钉刺",
		["Serpent Sting"] = "毒蛇钉刺",
		["Viper Sting"] = "蝰蛇钉刺",
		["Wing Clip"] = "摔绊",
		["Concussive Shot"] = "震荡射击",
		["Wyvern Sting"] = "翼龙钉刺",
		["Counterattack"] = "反击",
		["Hunter's Mark"] = "猎人印记",
		["Freezing Trap"] = "冰冻陷阱",

		-- mage
		["Polymorph"] = "变形术",
		["Polymorph: Cow"] = "变形术：奶牛",
		["Polymorph: Turtle"] = "变形术：龟",
		["Polymorph: Pig"] = "变形术：猪",

		-- priest
		["Shackle Undead"] = "束缚亡灵",
		["Mind Soothe"] = "安抚心灵",
		["Mind Control"] = "心灵控制",
		["Devouring Plague"] = "吞噬瘟疫",
		["Hex of Weakness"] = "虚弱妖术",
		["Shadow Word: Pain"] = "暗言术：痛",
		["Vampiric Embrace"] = "吸血鬼的拥抱",
		["Holy Fire"] = "神圣之火",

		-- Paladin
		["Turn Undead"] = "超度亡灵",

		-- rogue
		["Blind"] = "致盲",
		["Sap"] = "闷棍",
		["Gouge"] = "凿击",

		-- warlock
		["Conflagrate"] = "引燃", -- no idea if right
		["Corruption"] = "腐蚀术",
		["Curse of Agony"] = "痛苦诅咒",
		["Curse of Doom"] = "末日诅咒",
		["Curse of Recklessness"] = "鲁莽诅咒",
		["Curse of Shadow"] = "暗影诅咒",
		["Curse of the Elements"] = "元素诅咒",
		["Curse of Tongues"] = "语言诅咒",
		["Curse of Weakness"] = "虚弱诅咒",
		["Curse of Exhaustion"] = "疲劳诅咒",
		["Immolate"] = "献祭",
		["Death Coil"] = "死亡缠绕",
		["Banish"] = "放逐",
		["Siphon Life"] = "生命虹吸",
		["Fear"] = "恐惧",
	}
end)
