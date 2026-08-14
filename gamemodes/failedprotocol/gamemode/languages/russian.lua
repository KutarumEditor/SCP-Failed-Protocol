lang = {}

local MISC = {}
lang.MISC = MISC

MISC.class = "Класс"
MISC.persona = "Личность"
MISC.said_persona = "Вы сказали своё имя"
MISC.heard_persona = " сказал своё имя"
MISC.unknown_person = "Неизвестный"
MISC.gruwrongtarget = "Неверная цель. Продолжайте поиски"
MISC.grubackup = "Подкрепление в пути"
MISC.grufailed = "Цель потеряна. Эвакуируйтесь с территории комплекса"
MISC.shmobilized = "Цель обращена"
MISC.shnotmobilized = "Цель не может быть обращена"
MISC.converted = "Вы были обращены"
MISC.falseconverted = "Вы замаскировались под Длань Змея"
MISC.cuffed = "Вы связаны"
MISC.escaping = "Вы сбежите через"
MISC.inventory = "Инвентарь"

local MENU = {}
lang.MENU = MENU

MENU.start = "Старт"
MENU.join = "Вступить в игру"
MENU.credits = "Благодарность"
MENU.leave = "Отключиться"

local SETTINGS = {}
lang.SETTINGS = SETTINGS

SETTINGS.title = "Настройки"
SETTINGS.fp_disable_postfx = "Отключить постобработку"
SETTINGS.fp_disable_vignette = "Отключить виньетку"
SETTINGS.fp_disable_support = "Отключить спавн за поддержку"
SETTINGS.fp_disable_scp = "Отключить спавн за SCP"
SETTINGS.fp_inventory_button = "Открыть инвентарь"
SETTINGS.fp_settings_button = "Открыть настройки"
SETTINGS.fp_drop_weapon = "Выбросить оружие из рук"
SETTINGS.fp_scp_upgrades_button = "Открыть улучшения SCP"

local KEYCARDS = {}
lang.KEYCARDS = KEYCARDS

KEYCARDS.janitor = "Уборщик"
KEYCARDS.medic = "Медик"
KEYCARDS.logist = "Логист"
KEYCARDS.zone_manager = "Менеджер Зоны"
KEYCARDS.it_spec = "Специалист IT"
KEYCARDS.engineer = "Инженер"
KEYCARDS.cont_spec = "Спец. по Содержанию"
KEYCARDS.lab = "Лаборант"
KEYCARDS.jr_res = "Мл. Исследователь"
KEYCARDS.res = "Исследователь"
KEYCARDS.sr_res = "Ст. Исследователь"
KEYCARDS.head_res = "Глава Научного Отдела"
KEYCARDS.jr_sec = "Мл. Сотрудник СБ"
KEYCARDS.sec = "Сотрудник СБ"
KEYCARDS.sr_sec = "Ст. Сотрудник СБ"
KEYCARDS.int_sec = "Сотрудник ВБ"
KEYCARDS.director = "Директор"
KEYCARDS.mtf = "МОГ"
KEYCARDS.mtf_com = "Командир МОГ"
KEYCARDS.o5 = "О5"
KEYCARDS.goc = "ГОК"

local CLASSES = {}
lang.CLASSES = CLASSES

CLASSES.spectator = "Наблюдатель"

CLASSES.classd = "Класс-Д"
CLASSES.gruagent = "Агент ГРУ"

CLASSES.researcher = "Исследователь"
CLASSES.researcher_head = "Глава Научного Отдела"
CLASSES.medic = "Медик"
CLASSES.gruspy = "Шпион ГРУ"

CLASSES.guard_pacificator = "Усмиритель СБ"
CLASSES.guard = "Сотрудник СБ"
CLASSES.guard_storm = "Штурмовик СБ"
CLASSES.cispy = "Шпион ПХ"

CLASSES.ntfsoldier = "Солдат Эпсилон-11"

CLASSES.gocsoldier = "Солдат ГОК"

CLASSES.grusoldier = "Солдат ГРУ"

CLASSES.spearsoldier = "Солдат SPEAR"

CLASSES.cisoldier = "Солдат ПХ"

CLASSES.shsoldier = "Солдат ДЗ"
CLASSES.shcom = "Командир ДЗ"

CLASSES.cbgsoldier = "Солдат ЦРБ"

CLASSES.SCP008 = "SCP-008-2"
CLASSES.SCP035 = "SCP-035-2"
CLASSES.SCP096 = "SCP-096"
CLASSES.SCP457 = "SCP-457"

local DESC = {}
lang.DESC = DESC

DESC.youre = "Вы"

DESC.spectator = "Вы можете наблюдать за игрой. Просто откиньтесь на спинку кресла и расслабьтесь."

DESC.classd = "Описание йоу"
DESC.gruamnesiac = "Описание йоу"

DESC.researcher = "Описание йоу"
DESC.researcher_head = "Описание йоу"
DESC.medic = "Описание йоу"
DESC.gruspy = "Описание йоу"

DESC.guard_pacificator = "Описание йоу"
DESC.guard = "Описание йоу"
DESC.guard_storm = "Описание йоу"
DESC.cispy = "Описание йоу"

DESC.ntfsoldier = "Описание йоу"

DESC.gocsoldier = "Описание йоу"

DESC.grusoldier = "Описание йоу"

DESC.spearsoldier = "Описание йоу"

DESC.cisoldier = "Описание йоу"

DESC.shsoldier = "Описание йоу"
DESC.shcom = "Описание йоу"

DESC.cbgsoldier = "Описание йоу"

DESC.SCP008 = "Описание йоу"
DESC.SCP035 = "Описание йоу"
DESC.SCP096 = "Описание йоу"
DESC.SCP457 = "Описание йоу"

local LOOT = {}
lang.LOOT = LOOT

LOOT.locker_lcz = "Шкаф"

local EXITS = {}
lang.EXITS = EXITS

EXITS.main = "Основной выход"

local ARMOR = {}
lang.ARMOR = ARMOR

ARMOR.security_light_vest = "Лёгкий жилет СБ"
ARMOR.security_medium_vest = "Средний жилет СБ"
ARMOR.security_heavy_vest = "Тяжёлый жилет СБ"
ARMOR.ntf_vest = "Бронежилет Э-11"
ARMOR.goc_vest = "Бронежилет ГОК"
ARMOR.gru_vest = "Бронежилет ГРУ"
ARMOR.gru_heavy_vest = "Тяжёлый бронежилет ГРУ"
ARMOR.ci_vest = "Бронежилет ПХ"
ARMOR.sh_vest = "Бронежилет ДЗ"
ARMOR.cbg_plate_holder = "Плитник ЦРБ"
ARMOR.security_cap = "Кепка охраны"
ARMOR.security_light_helmet = "Лёгкий шлем СБ"
ARMOR.security_heavy_helmet = "Тяжёлый шлем СБ"
ARMOR.ntf_helmet = "Шлем Э-11"
ARMOR.goc_helmet = "Шлем ГОК"
ARMOR.gru_helmet = "Шлем ГРУ"
ARMOR.spear_helmet = "Шлем SPEAR"
ARMOR.ci_helmet = "Шлем ПХ"
ARMOR.cbg_mask = "Маска ЦРБ"

local TASK = {}
lang.TASK = TASK

TASK.fail = "Провал"
TASK.body_check = "Осмотр тела"
TASK.armor_equip = "Экипировка брони"
TASK.weapon_equip = "Поднятие предмета"
TASK.detaining = "Связывание цели"
TASK.undetaining = "Развязывание цели"
TASK.sh_conversion = "Обращение персоны"

local BODY = {}
lang.BODY = BODY

BODY.persona = "Личность"
BODY.unknown = "Неизвестно"
BODY.reason = "Причина смерти"
BODY.time = "Время смерти"
BODY.items = "Предметы"

local ROUNDENDINFO = {}
lang.ROUNDENDINFO = ROUNDENDINFO

ROUNDENDINFO.result = "Результат раунда:"

ROUNDENDINFO.mvps = "Лучшие игроки:"
ROUNDENDINFO.frags = "очков"

ROUNDENDINFO.audit = "Аудит:"

ROUNDENDINFO.foundation = "Фонд восстановил контроль"
ROUNDENDINFO.scp = "Аномалии высвободились"
ROUNDENDINFO.captured = "Комплекс захвачен"
ROUNDENDINFO.warheads = "Боеголовки взорваны"

local WEP = {}
lang.WEP = WEP

WEP.fp_hands = {
	name = "Руки"
}
WEP.fp_keycard = {
	name = "Ключ-карта"
}
WEP.fp_knife = {
	name = "Нож"
}
WEP.fp_bandage = {
	name = "Бинт"
}

local ENT = {}
lang.ENT = ENT

ENT.prop_ragdoll = "Тело"
ENT.fp_box = "Коробка"

local ACTIONS = {}
lang.ACTIONS = ACTIONS

ACTIONS.prop_ragdoll = {
	check = "Осмотреть",
}

ACTIONS.player = {
	detain = "Связать",
	undetain = "Развязать",
}

local KILLFEED = {}
lang.KILLFEED = KILLFEED

KILLFEED.suicide = "%v умер."
KILLFEED.default = "%a убил %v с помощью %i."

local DEATHQUOTES = {}
lang.DEATHQUOTES = DEATHQUOTES

DEATHQUOTES[TEAM_CLASSD] = {
	"Полёг последний заключённый.",
	"Мечты о свободе были разрушены.",
	"Уголовники обрели вечный покой.",
	"Их исправила смерть.",
}

DEATHQUOTES[TEAM_SCI] = {
	"Эксперимент обернулся катастрофой.",
	"Они отдали жизнь за должность.",
	"Лабораторные крысы и доктора поменялись местами.",
}

DEATHQUOTES[TEAM_SD] = {
	"Безопасность поставлена под вопрос.",
	"Защитники порядка пали.",
	"Щит зоны был проломлен.",
	"Ситуация дестабилизирована.",
}

DEATHQUOTES[TEAM_MTF] = {
	"Они столкнулись лицом к лицу со смертью... и проиграли.",
	"На этот раз тьма поглотила их.",
	"Последний оперативник Фонда пал.",
}

DEATHQUOTES[TEAM_GOC] = {
	"Творить мир больше некому.",
	"Миротворческая миссия провалена.",
}

DEATHQUOTES[TEAM_SPEAR] = {
	"Джони не замарширует домой.",
	"Последний орёл пал.",
	"Американские профессионалы полегли.",
	"PENTAGRAM потеряли свой отряд.",
}

DEATHQUOTES[TEAM_GRU] = {
	"Они не бросили своих.",
	"Последний медведь пал.",
	"Российские профессионалы полегли.",
	"ГРУ потеряли свой отряд.",
}

DEATHQUOTES[TEAM_CI] = {
	"Охота за аномалиями окончена.",
	"Главная оппозиция Фонду пала.",
	"Террор окончен.",
}

DEATHQUOTES[TEAM_CBG] = {
	"Киберпсихоз окончен.",
	"'Гуделки' полегли.",
}

DEATHQUOTES[TEAM_MCD] = {
	"Наёмники пали.",
	"Деньги в могилу забрать не получится.",
}

DEATHQUOTES[TEAM_SH] = {
	"Защитники аномалий пали.",
	"Паранормальный альтруизм был пресечён.",
}

DEATHQUOTES[TEAM_SCP] = {
	"Коробка открылась. Кот вышел из суперпозиции.",
	"Условия содержания были восстановлены.",
	"Объекты были ликвидированы.",
}

local PHRASES = {}
lang.PHRASES = PHRASES

PHRASES.gocsniper_name = "Снайпер ГОК"
PHRASES.gocsniper = {
	scp = "Аномалия замечена...",
	fire1 = "Мы готовы открыть огонь...",
	fire2 = "Вы назначены на устранение...",
	warning1 = "Убирайтесь или будете расстреляны!",
	warning2 = "Это ваш последний шанс!",
}

PHRASES.gruspy_name = "Вы"
PHRASES.gruspy = {
	found1 = "Приём. Цель обнаружена, сопровождаю...",
	found2 = "Приём. Объект обнаружен...",
	found3 = "Приём. Цель найдена...",
}

PHRASES.pa_name = "Система оповещений"
PHRASES.pa = {
	malfunction = "Мы получили сведения о множественных неполадках в работе электричества и дверей. \nПожалуйста сохраняйте спокойствие и...",
	breach = "Произошли множественные нарушения условий содержания по всему комплексу. \nВсему военному персоналу приказано пройти в зоны лёгкого, органического и тяжёлого содержаний для локализации угрозы. \nОстальному персоналу советуется оставаться в безопасных местах до стабилизации ситуации в комплексе.",
	epsilon11 = "Мобильная Оперативная Группа Эпсилон-11, обозначенная как 'Девятихвостая Лиса' вошла в комплекс. \nВсему персоналу следует соблюдать стандартные процедуры эвакуации.",
	goi = "Неопознанные субъекты вошли на территорию комплекса. \nВсему персоналу следует оставаться в убежищах или любом другом безопасном месте до момента нейтрелизации угрозы..",
	scp1 = "Ожидается восстановление условий содержания 1 SCP объекта.",
	scp2 = "Ожидается восстановление условий содержания 2 SCP объектов.",
	scp3 = "Ожидается восстановление условий содержания 3 SCP объектов.",
}

LANG.Register( "russian", lang )