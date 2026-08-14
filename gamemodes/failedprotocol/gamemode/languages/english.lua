lang = {}

local MISC = {}
lang.MISC = MISC

MISC.class = "Class"
MISC.persona = "Persona"
MISC.said_persona = "You said your name"
MISC.heard_persona = " said their name"
MISC.unknown_person = "Unknown"
MISC.gruwrongtarget = "Invalid target. Continue searching"
MISC.grubackup = "Backup is on the way"
MISC.grufailed = "Target lost. Withdraw from the facility"
MISC.shmobilized = "Target converted"
MISC.shnotmobilized = "Target can't be converted"
MISC.converted = "You were converted"
MISC.falseconverted = "You disguised yourself as the Serpent's Hand"
MISC.cuffed = "You are detained"
MISC.escaping = "You are escaping through"
MISC.inventory = "Inventory"

local MENU = {}
lang.MENU = MENU

MENU.start = "Start"
MENU.join = "Join the game"
MENU.credits = "Credits"
MENU.leave = "Disconnect"

local SETTINGS = {}
lang.SETTINGS = SETTINGS

SETTINGS.title = "Settings"
SETTINGS.fp_disable_postfx = "Disable post-processing"
SETTINGS.fp_disable_vignette = "Disable vignette"
SETTINGS.fp_disable_support = "Disable spawning as support"
SETTINGS.fp_disable_scp = "Disable spawning as SCP"
SETTINGS.fp_inventory_button = "Open inventory"
SETTINGS.fp_settings_button = "Open settings"
SETTINGS.fp_drop_weapon = "Drop current weapon"
SETTINGS.fp_scp_upgrades_button = "Open SCP upgrades"

local KEYCARDS = {}
lang.KEYCARDS = KEYCARDS

KEYCARDS.janitor = "Janitor"
KEYCARDS.medic = "Medic"
KEYCARDS.logist = "Logist"
KEYCARDS.zone_manager = "Zone Manager"
KEYCARDS.it_spec = "IT Specialist"
KEYCARDS.engineer = "Engineer"
KEYCARDS.cont_spec = "Containment Spec."
KEYCARDS.lab = "Lab. Assistant"
KEYCARDS.jr_res = "Jr. Researcher"
KEYCARDS.res = "Researcher"
KEYCARDS.sr_res = "Sr. Researcher"
KEYCARDS.head_res = "Head of Research Department"
KEYCARDS.jr_sec = "Jr. SD Officer"
KEYCARDS.sec = "SD Officer"
KEYCARDS.sr_sec = "Sr. SD Officer"
KEYCARDS.int_sec = "IS Agent"
KEYCARDS.director = "Director"
KEYCARDS.mtf = "MTF"
KEYCARDS.mtf_com = "MTF Commander"
KEYCARDS.o5 = "O5"
KEYCARDS.goc = "GOC"

local CLASSES = {}
lang.CLASSES = CLASSES

CLASSES.spectator = "Spectator"

CLASSES.classd = "Class-D"
CLASSES.gruagent = "GRU Agent"

CLASSES.researcher = "Researcher"
CLASSES.researcher_head = "Head of Research Department"
CLASSES.medic = "Medic"
CLASSES.gruspy = "GRU Spy"

CLASSES.guard_pacificator = "SD Pacificator"
CLASSES.guard = "SD Officer"
CLASSES.guard_storm = "SD Stormtrooper"
CLASSES.cispy = "CI Spy"

CLASSES.ntfsoldier = "Epsilon-11 Soldier"

CLASSES.gocsoldier = "GOC Soldier"

CLASSES.grusoldier = "GRU Soldier"

CLASSES.spearsoldier = "SPEAR Soldier"

CLASSES.cisoldier = "CI Soldier"

CLASSES.shsoldier = "SH Soldier"
CLASSES.shcom = "SH Commander"

CLASSES.cbgsoldier = "CBG Soldier"

CLASSES.SCP008 = "SCP-008-2"
CLASSES.SCP035 = "SCP-035-2"
CLASSES.SCP096 = "SCP-096"
CLASSES.SCP457 = "SCP-457"

local DESC = {}
lang.DESC = DESC

DESC.youre = "You are"

DESC.spectator = "You can spectate the game. Just sit back and relax."

DESC.classd = "Deez nuts"
DESC.gruamnesiac = "Deez nuts"

DESC.researcher = "Deez nuts"
DESC.researcher_head = "Deez nuts"
DESC.medic = "Deez nuts"
DESC.gruspy = "Deez nuts"

DESC.guard_pacificator = "Deez nuts"
DESC.guard = "Deez nuts"
DESC.guard_storm = "Deez nuts"
DESC.cispy = "Deez nuts"

DESC.ntfsoldier = "Deez nuts"

DESC.gocsoldier = "Deez nuts"

DESC.grusoldier = "Deez nuts"

DESC.spearsoldier = "Deez nuts"

DESC.cisoldier = "Deez nuts"

DESC.shsoldier = "Deez nuts"
DESC.shcom = "Deez nuts"

DESC.cbgsoldier = "Deez nuts"

DESC.SCP008 = "Deez nuts"
DESC.SCP035 = "Deez nuts"

local LOOT = {}
lang.LOOT = LOOT

LOOT.locker_lcz = "Locker"

local EXITS = {}
lang.EXITS = EXITS

EXITS.main = "Main exit"

local ARMOR = {}
lang.ARMOR = ARMOR

ARMOR.security_light_vest = "Light SD vest"
ARMOR.security_medium_vest = "Medium SD vest"
ARMOR.security_heavy_vest = "Heavy SD vest"
ARMOR.ntf_vest = "E-11 vest"
ARMOR.goc_vest = "GOC vest"
ARMOR.gru_vest = "GRU vest"
ARMOR.gru_heavy_vest = "GRU heavy vest"
ARMOR.spear_vest = "SPEAR vest"
ARMOR.ci_vest = "CI vest"
ARMOR.sh_vest = "SH vest"
ARMOR.cbg_plate_holder = "CBG plate holder"
ARMOR.security_cap = "SD cap"
ARMOR.security_light_helmet = "Light SD helmet"
ARMOR.security_heavy_helmet = "Heavy SD helmet"
ARMOR.ntf_helmet = "E-11 helmet"
ARMOR.goc_helmet = "GOC helmet"
ARMOR.gru_helmet = "GRU helmet"
ARMOR.spear_helmet = "SPEAR helmet"
ARMOR.ci_helmet = "CI helmet"
ARMOR.sh_helmet = "SH helmet"
ARMOR.sh_heavy_helmet = "SH heavy helmet"
ARMOR.cbg_mask = "CBG mask"

local TASK = {}
lang.TASK = TASK

TASK.fail = "Failure"
TASK.body_check = "Checking body"
TASK.armor_equip = "Equipping armor"
TASK.weapon_equip = "Picking item up"
TASK.detaining = "Detaining"
TASK.undetaining = "Undetaining"
TASK.sh_conversion = "Converting person"

local BODY = {}
lang.BODY = BODY

BODY.persona = "Persona"
BODY.unknown = "Unknown"
BODY.reason = "Death reason"
BODY.time = "Death time"
BODY.items = "Items"

local ROUNDENDINFO = {}
lang.ROUNDENDINFO = ROUNDENDINFO

ROUNDENDINFO.result = "Round result:"

ROUNDENDINFO.mvps = "Best players:"
ROUNDENDINFO.frags = "points"

ROUNDENDINFO.audit = "Audit:"

ROUNDENDINFO.foundation = "Foundation regained control"
ROUNDENDINFO.scp = "Anomalies outbroke"
ROUNDENDINFO.captured = "Facility was captured"
ROUNDENDINFO.warheads = "Warheads detonated"

local WEP = {}
lang.WEP = WEP

WEP.fp_hands = {
	name = "Hands"
}
WEP.fp_keycard = {
	name = "Keycard"
}
WEP.fp_knife = {
	name = "Knife"
}
WEP.fp_bandage = {
	name = "Bandage"
}

local ENT = {}
lang.ENT = ENT

ENT.prop_ragdoll = "Body"
ENT.fp_box = "Box"

local ACTIONS = {}
lang.ACTIONS = ACTIONS

ACTIONS.prop_ragdoll = {
	check = "Check",
}

ACTIONS.player = {
	detain = "Detain",
	undetain = "Undetain",
}

local KILLFEED = {}
lang.KILLFEED = KILLFEED

KILLFEED.suicide = "%v died."
KILLFEED.default = "%a killed %v with %i."

local DEATHQUOTES = {}
lang.DEATHQUOTES = DEATHQUOTES

DEATHQUOTES[TEAM_CLASSD] = {
	"The last prisoner has fallen.",
	"Dreams about freedom were shattered.",
	"Convicts have found eternal rest.",
	"Their punishment was death.",
}

DEATHQUOTES[TEAM_SCI] = {
	"Experiment turned into a catastrophe.",
	"They sacrificed their lives for their position.",
	"Lab rats and doctors switched places.",
}

DEATHQUOTES[TEAM_SD] = {
	"Security is put at risk.",
	"Order is disrupted.",
	"Zone shield has been compromised.",
	"Situation is unstable.",
}

DEATHQUOTES[TEAM_MTF] = {
	"They met with death... and lost.",
	"Darkness swallowed them.",
	"The last Foundation operative has fallen.",
}

DEATHQUOTES[TEAM_GOC] = {
	"No peaceleepers left.",
	"Peacekeeping mission failed.",
}

DEATHQUOTES[TEAM_SPEAR] = {
	"Johny won't be coming home.",
	"Last eagle has fallen.",
	"American professionals have fallen.",
	"PENTAGRAM lost their squad.",
}

DEATHQUOTES[TEAM_GRU] = {
	"They didn't abandon their own.",
	"The last bear has fallen.",
	"Russian professionals have fallen.",
	"GRU lost their squad.",
}

DEATHQUOTES[TEAM_CI] = {
	"Anomalous rush ended.",
	"Foundation main opposers have fallen.",
	"Terror ended.",
}

DEATHQUOTES[TEAM_CBG] = {
	"Cyberpsychosis ended.",
	"'Hummers' have fallen.",
}

DEATHQUOTES[TEAM_MCD] = {
	"Mercenaries have fallen.",
	"Money won't be able to get into the grave.",
}

DEATHQUOTES[TEAM_SH] = {
	"Defenders of anomalies have fallen.",
	"Paranormal altruism was crushed.",
}

DEATHQUOTES[TEAM_SCP] = {
	"The box has opened. The cat has left superposition.",
	"Containment conditions have been restored.",
	"Objects have been neutralized.",
}

local PHRASES = {}
lang.PHRASES = PHRASES

PHRASES.gocsniper_name = "GOC Sniper"
PHRASES.gocsniper = {
	scp = "Anomaly spotted...",
	fire1 = "We are free to open fire...",
	fire2 = "You are ordered to be terminated...",
	warning1 = "Stay away or you'll be shot!",
	warning2 = "This is your last chance!",
}

PHRASES.gruspy_name = "You"
PHRASES.gruspy = {
	found1 = "Copy. Target found, escorting...",
	found2 = "Copy. Object found...",
	found3 = "Copy. Target found...",
}

PHRASES.unkoper_name = "Unknown Operator"
PHRASES.unkoper = {
	first = "This is CH-1 to OH-6, have you located the target, over?",
	second = "CH-1 to OH-6, do you copy?",
}

PHRASES.pa_name = " Announcements system"
PHRASES.pa = {
	malfunction = "We've received reports of multiple electrical and door control issues. \nPlease remain calm and...",
	breach = "We've got multiple site-wide containment breaches. \nAll military personnel are ordered to head to the light, organic and heavy containment zones to localize the threat. \nOther staff are advised to stay in any safe area until site is secured.",
	epsilon11 = "Mobile Task Force unit Epsilon-11 designated 'Nine-Tailed Fox' has entered the facility. \nAll remaining personnel are advised to proceed with standart evacuation protocols.",
	goi = "Unknown subjects have entered the facility. \nAll remaining personnel are advised to stay in one of many shelters or any other safe area until threat is neutralized.",
	scp1 = "Awaiting recontainment of 1 SCP subject.",
	scp2 = "Awaiting recontainment of 2 SCP subjects.",
	scp3 = "Awaiting recontainment of 3 SCP subjects.",
}

LANG.Register( "english", lang )