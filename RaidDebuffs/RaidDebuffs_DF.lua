--[[
-- File: RaidDebuffs_DF.lua
-- Author: enderneko (enderneko-dev@outlook.com)
-- File Created: 2022/12/05 17:28:20 +0800
-- Last Modified: 2022/12/26 08:41:54 +0800
--]]

local _, Cell = ...
local F = Cell.funcs

local debuffs = {
    [1205] = { -- 巨龙群岛
    ["general"] = {
    },
    [2515] = { -- 斯图恩兰，苍天苦难
    },
    [2506] = { -- 巴斯律孔，页岩之翼
    },
    [2517] = { -- 巴祖阿尔，惊恐烈焰
    },
    [2518] = { -- 利斯卡诺兹，未来灾劫
    },
    },

    [1200] = { -- 化身巨龙牢窟
        ["general"] = {
        },
        [2480] = { -- 艾拉诺格
            394917, -- 飞扑烈焰（M）
            397115, -- 烧尽
            370597, -- 杀戮指令
            396094, -- 大型火焰裂隙
            390715, -- 火焰裂隙
            394906, -- 灼烧之伤（T）
            370648, -- 熔岩涌流（岩浆）
            -396023, -- 焚火咆哮
        },
        [2500] = { -- 泰洛斯
            386352, -- 岩石冲击
            "381253", -- 觉醒之土
            391592, -- 注能爆尘
            376276, -- 震荡猛击（T）
            382458, -- 共鸣余震
            "-382776", -- 觉醒之土
            -381595, -- 撼地突袭
        },
        [2486] = { -- 原始议会
            "374039", -- 流星之斧
            "371624", -- 传导印记
            371591, -- 冰霜之墓
            372056, -- 碾压（T）
            372027, -- 劈砍烈焰（T）
            371836, -- 原始暴风雪
            371514, -- 灼烧之地
            -386661, -- 冰川之召
            "-375091", -- 流星之斧（易伤）
        },
        [2482] = { -- 瑟娜尔丝，冰冷之息
            374104, -- 困在网中
            373048, -- 窒息之网
            372082, -- 包围之网
            372030, -- 粘性蛛网
            385083, -- 蛛网冲击（T）
            388016, -- 溶解防御（T）
            371976, -- 冰冷冲击
            372055, -- 冰封地面
            372736, -- 永冻
            -372648, -- 渗流之寒
        },
        [2502] = { -- 晋升者达瑟雅
            375580, -- 西风猛击（T）
            "391686", -- 传导印记
            390449, -- 雷霆之箭
            -391717, -- 静电释放
            -388290, -- 旋风
        },
        [2491] = { -- 库洛格·恐怖图腾
            372458, -- 绝对零度
            390920, -- 震撼爆裂
            391696, -- 致命电流
            391056, -- 大地笼罩
            391022, -- 冷冽洪流
            391419, -- 冻结
            "373535", -- 闪电崩裂（被电）
            "373494", -- 闪电崩裂（电）
            372158, -- 破甲一击（T）
            393431, -- 风暴惩击
            374427, -- 碎地
            382564, -- 岩浆爆裂
            393297, -- 冰霜惩击
            -374864, -- 原始破碎（易伤）
            -372514, -- 霜寒噬咬
            -374623, -- 冰霜束缚
            -374023, -- 灼热屠戮
            -374554, -- 岩浆之池
            -373681, -- 酷寒
            -396085, -- 大地统御
            -396106, -- 炽燃统御
            -396109, -- 冰霜统御
            -396113, -- 风暴统御
        },
        [2493] = { -- 巢穴守护者迪乌尔娜
            396264, -- 爆震石斫
            388920, -- 冷凝笼罩
            388717, -- 寒冰包裹
            376260, -- 震动
            378782, -- 致死之伤（T）
            376266, -- 潜地打击（T）
            375475, -- 撕裂噬咬（T）
            375716, -- 寒冰弹幕
            375620, -- 电离充能
            375578, -- 烈焰哨卫
            375889, -- 巨杖之怒
            380483, -- 强化巨杖之怒
            -375873, -- 野火
            -375458, -- 寒冰怒气
        },
        [2499] = { -- 莱萨杰丝，噬雷之龙
            381615, -- 静电充能
            399713, -- 磁力充能
            377467, -- 积雷充能
            381442, -- 闪电打击
            385073, -- 球状闪电
            388115, -- 闪电毁灭
            396037, -- 澎湃冲击
            397382, -- 碎裂幔罩
            394584, -- 反转
            391990, -- 正能量电荷
            391991, -- 负能量电荷
            390763, -- 雷鸣能量（T）
            391285, -- 蚀雷护甲（T）
            395906, -- 电化之颌（T）
            388635, -- 爆裂
            381251, -- 电能鞭笞
            390911, -- 残留能量
            389698, -- 爆裂电流
            377662, -- 静电力场
            392921, -- 局部风暴
            395929, -- 风暴之怨
            -399054, -- 风暴喷涌
            -388659, -- 风暴之翼
            -377612, -- 飓风龙翼
        },
    },

    [1201] = { -- 艾杰斯亚学院
        ["general"] = {
            390918, -- 爆炸之种
            378011, -- 致命狂风
            388392, -- 乏味的讲课
            377344, -- 啄击
            388866, -- 法力虚空
            388984, -- 邪恶伏击
            388912, -- 断体猛击
            387843, -- 星界炸弹
            387932, -- 星界旋风
        },
        [2509] = { -- 维克萨姆斯
            386181, -- 法力炸弹
            391977, -- 涌动超载
            386201, -- 腐化法力
        },
        [2512] = { -- 茂林古树
            388544, -- 裂树击
            389033, -- 鞭笞者毒素
            396716, -- 皲皮
        },
        [2495] = { -- 克罗兹
            376449, -- 火焰风暴
            376997, -- 狂野啄击
            377008, -- 震耳尖啸
            397210, -- 音速易伤
        },
        [2514] = { -- 多拉苟萨的回响
            374350, -- 能量炸弹
            389007, -- 野蛮能量
            389011, -- 势不可挡
        },
    },

    [1196] = { -- 蕨皮山谷
        ["general"] = {
            385185, -- 迷惑
            367500, -- 狰狞蔑笑
            384970, -- 香味肉块
            367481, -- 血腥啃噬
            367484, -- 恶毒爪击
            367521, -- 白骨箭
            368081, -- 枯萎
            368091, -- 感染撕咬
            373595, -- 枯萎感染
            373872, -- 喷薄污泥
            373899, -- 腐朽根须
            374245, -- 腐烂之溪
            385058, -- 枯萎毒药
            385834, -- 嗜血冲锋
            375416, -- 流血
            385361, -- 腐烂疫病
            385303, -- 带齿陷阱
            387796, -- 网
            383399, -- 腐烂激涌
            368299, -- 剧毒陷阱
            -382787, -- 腐朽利爪
            -382723, -- 毁灭猛击
        },
        [2471] = { -- 劈爪的战团
            381461, -- 野蛮冲撞
            381379, -- 腐朽感官
            378229, -- 屠戮标记
            378020, -- 狂伤
            377844, -- 剑刃风暴
        },
        [2473] = { -- 树口
            377222, -- 吞噬
            377864, -- 感染喷吐
            383875, -- 消化了一半
            -376933, -- 缠绕之藤
        },
        [2472] = { -- 肠击
            385356, -- 诱捕陷阱
            384425, -- 闻着像肉
        },
        [2474] = { -- 腐朽主母怒眼
            383087, -- 枯萎传染
            387210, -- 腐朽之力
            373896, -- 枯萎腐烂
            376149, -- 窒息腐云
            -373912, -- 腐朽打击
        },
    },

    [1204] = { -- 注能大厅
        ["general"] = {
            391610, -- 联结之风
            374563, -- 眩晕
            374615, -- 偷袭
            374020, -- 密闭射线
            393444, -- 龟裂创伤
            374706, -- 积热爆裂
            375384, -- 滚石
            385168, -- 雷霆风暴
            391613, -- 慢性毒菌
            -391634, -- 极寒冰冻
            -374339, -- 挫志怒吼
        },
        [2504] = { -- 看护者伊里度斯
            384524, -- 泰坦之拳
            389179, -- 能量过载
            389443, -- 净化冲击波
            383935, -- 火花齐射
            389446, -- 废灵脉冲
            389181, -- 能量场
        },
        [2507] = { -- 吞喉巨蛙
            374389, -- 巨口蛙毒
        },
        [2510] = { -- 不屈者卡金
            385963, -- 冰霜震击
            -386743, -- 极地之风
        },
        [2511] = { -- 原始海啸
            387571, -- 汇流洪水
            396971, -- 威慑冲击
            387359, -- 浸水
        },
    },

    [1199] = { -- 奈萨鲁斯
        ["general"] = {
            372208, -- 贾拉丁熔岩
            372224, -- 龙骨之斧
            372461, -- 灌魔岩浆
            372570, -- 果敢伏击
            372971, -- 回荡猛击
            374451, -- 燃烧锁链
            382005, -- 滚烫噬咬
            384161, -- 燃烧微粒
            378818, -- 岩浆焚火
            373540, -- 束缚之矛
            373089, -- 灼热齐射
            378221, -- 熔火易伤
            -372459, -- 燃烧
        },
        [2490] = { -- 查尔加斯，龙鳞之灾
            374482, -- 束地之链
            373735, -- 巨龙打击
            396332, -- 炽燃聚焦
            373756, -- 岩浆波
            374854, -- 迸发之地
            -389059, -- 炉渣喷发
        },
        [2489] = { -- 熔炉主管戈雷克
            372971, -- 回荡猛击
            374842, -- 炽焰护盾
            -374534, -- 炽热挥舞
        },
        [2494] = { -- 岩浆之牙
            375204, -- 热液岩浆
            -375890, -- 岩浆喷发
        },
        [2501] = { -- 督军莎尔佳
            377018, -- 熔火真金
            377522, -- 爆燃追击
            377542, -- 爆燃之地
            376784, -- 火焰易伤
        },
    },

    [1202] = { -- 红玉新生法池
        ["general"] = {
            385313, -- 霉运打击
            372047, -- 钢铁弹幕
            372796, -- 炽焰冲刺
            392641, -- 滚雷
            373693, -- 活动炸弹
            391130, -- 暴风骤雨之盾
            392924, -- 震爆
            395292, -- 火焰之喉
            392451, -- 闪火
            385536, -- 烈焰之舞
            373869, -- 燃烧之触
            372697, -- 锯齿土地
            -373692, -- 地狱烈火
            -392406, -- 雷霆一击
        },
        [2488] = { -- 梅莉杜莎·寒妆
            372963, -- 霜风
            "372682", -- 原始酷寒 -- TODO: 冻结
        },
        [2485] = { -- 柯姬雅·焰蹄
            372811, -- 熔火巨石
            372860, -- 灼热伤口
            373869, -- 燃烧之触
            384823, -- 地狱烈火
            372820, -- 焦灼之土
            -372858, -- 灼热打击
        },
        [2503] = { -- 基拉卡与厄克哈特·风脉
            381526, -- 怒吼火息
            381862, -- 地狱火之核
            384773, -- 烈焰余烬
            -381518, -- 变迁之风
        },
    },

    [1203] = { -- 碧蓝魔馆
        ["general"] = {
            371352, -- 禁断知识
            375602, -- 古怪生长
            386549, -- 清醒的克星
            370764, -- 穿刺碎片
            371007, -- 裂生碎片
            375591, -- 树脂爆发
            386640, -- 撕扯血肉
            387564, -- 秘法蒸汽
            375649, -- 注能之地
            377488, -- 寒冰束缚
            370766, -- 晶化裂口
        },
        [2492] = { -- 莱魔
            374567, -- 爆裂法印
            374789, -- 注能打击
            374523, -- 刺痛树液
            375591, -- 树脂爆发
        },
        [2505] = { -- 青刃
        },
        [2483] = { -- 泰拉什·灰翼
            396722, -- 绝对零度
            387151, -- 寒冰灭绝者
            386881, -- 冰霜炸弹
            387150, -- 冰霜之地
        },
        [2508] = { -- 安布雷斯库
            385267, -- 爆裂旋涡
            384978, -- 巨龙打击
            -385331, -- 破裂
            -388777, -- 压制瘴气
        },
    },

    [1198] = { -- 诺库德阻击战
        ["general"] = {
            373395, -- 恐怖威吓
            395035, -- 粉碎灵魂
            384336, -- 战争践踏
            397394, -- 致命雷霆
            381530, -- 风暴震击
            381692, -- 迅捷刺击
            384134, -- 穿刺
            388801, -- 致死打击
            387629, -- 腐烂之风
            386912, -- 风暴喷涌之云
            386025, -- 风暴
            384492, -- 猎人印记
            -382628, -- 能量湍流
        },
        [2498] = { -- 格拉尼斯
        },
        [2497] = { -- 狂怒风暴
            386916, -- 狂怒风暴
            384185, -- 闪电打击
            383944, -- 飑风
        },
        [2478] = { -- 提拉和马鲁克
            386063, -- 恐怖怒吼
            392151, -- 强风箭
        },
        [2477] = { -- 巴拉卡可汗
            376634, -- 钢铁之矛
            376864, -- 静电之矛
            375937, -- 撕裂猛击
            376827, -- 传导打击
            376899, -- 鸣裂之云
            376894, -- 鸣裂颠覆
            -376730, -- 暴风
        },
    },

    [1197] = { -- 奥达曼：提尔的遗产
        ["general"] = {
            369811, -- 残暴猛击
            369366, -- 困于岩石
            369411, -- 音速爆裂
            369337, -- 困难地形
            369408, -- 撕裂猛击
            369419, -- 剧毒之牙
            369828, -- 噬咬
            372718, -- 大地碎片
            377732, -- 锯齿撕咬
            377486, -- 时光利刃
            377510, -- 窃取时间
            382576, -- 提尔的蔑视
            369818, -- 疾病之咬
        },
        [2475] = { -- 失落的矮人
            369792, -- 碎颅者
            375286, -- 灼热炮火
            369828, -- 噬咬
            377825, -- 燃烧的沥青
        },
        [2487] = { -- 布罗马奇
        },
        [2484] = { -- 哨兵塔隆达丝
            372652, -- 共鸣宝珠
            382071, -- 共鸣宝珠
            372718, -- 大地碎片
        },
        [2476] = { -- 艾博隆
            368996, -- 净化烈焰
            369110, -- 不稳定的灰烬
            369006, -- 灼烧酷热
        },
        [2479] = { -- 时空领主戴欧斯
            377405, -- 时光渗陷
            376325, -- 永恒领域
        },
    },
}

F:LoadBuiltInDebuffs(debuffs)