lang = {}

local MISC = {}
lang.MISC = MISC

MISC.class = "Класс"
MISC.said_persona = "Вы сказали своё имя"
MISC.heard_persona = " сказал своё имя"
MISC.unknown_person = "Неизвестный"
MISC.gruwrongtarget = "Неверная цель. Продолжайте поиски"
MISC.grubackup = "Подкрепление в пути"
MISC.shmobilized = "Цель обращена"
MISC.shnotmobilized = "Цель не может быть обращена"
MISC.converted = "Вы были обращены"

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
SETTINGS.fp_scp_upgrades_button = "Открыть улучшения SCP"

local KEYCARDS = {}
lang.KEYCARDS = KEYCARDS

KEYCARDS.janitor = "Уборщик"
KEYCARDS.medic = "Медик"
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

CLASSES.cbgsoldier = "Солдат ЦРБ"

CLASSES.SCP008 = "SCP-008-2"
CLASSES.SCP035 = "SCP-035-2"
CLASSES.SCP096 = "SCP-096"

local DESC = {}
lang.DESC = DESC

DESC.youre = "Вы"

DESC.spectator = "Вы можете наблюдать за игрой. Просто откиньтесь на спинку кресла и расслабьтесь."

DESC.classd = "Описание йоу"
DESC.gruamnesiac = "Описание йоу"

DESC.researcher = "Описание йоу"
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

DESC.cbgsoldier = "Описание йоу"

DESC.SCP008 = "Описание йоу"
DESC.SCP035 = "Описание йоу"

local ARMOR = {}
lang.ARMOR = ARMOR

ARMOR.test_vest = "Тестовый бронежилет"
ARMOR.security_light_vest = "Лёгкий жилет СБ"
ARMOR.security_medium_vest = "Средний жилет СБ"
ARMOR.security_heavy_vest = "Тяжёлый жилет СБ"
ARMOR.test_helmet = "Тестовый шлем"
ARMOR.security_cap = "Кепка охраны"
ARMOR.security_light_helmet = "Лёгкий шлем СБ"
ARMOR.security_heavy_helmet = "Тяжёлый шлем СБ"

local TASK = {}
lang.TASK = TASK

TASK.fail = "Провал"
TASK.body_check = "Осмотр тела"
TASK.armor_equip = "Экипировка брони"
TASK.weapon_equip = "Поднятие предмета"

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

ACTIONS.fp_box = {
	open = "Открыть",
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
	scp1 = "Ожидается восстановление условий содержания 1 SCP объекта.",
	scp2 = "Ожидается восстановление условий содержания 2 SCP объектов.",
	scp3 = "Ожидается восстановление условий содержания 3 SCP объектов.",
}

LANG.Register( "russian", lang )