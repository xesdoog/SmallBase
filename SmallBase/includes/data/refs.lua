---@diagnostic disable

t_ObjectiveBlips = {
    1,
    9,
    143,
    144,
    145,
    146,
    306,
    535,
    536,
    537,
    538,
    539,
    540,
    541,
    542,
}

t_AppScriptNames = {
    "apparcadebusiness",
    "apparcadebusinesshub",
    "appavengeroperations",
    "appbailoffice",
    "appbikerbusiness",
    "appbroadcast",
    "appbunkerbusiness",
    "appbusinesshub",
    "appcamera",
    "appchecklist",
    "appcontacts",
    "appcovertops",
    "appemail",
    "appextraction",
    "appfixersecurity",
    "apphackertruck",
    "apphackerden",
    "apphs_sleep",
    "appimportexport",
    "appinternet",
    "appjipmp",
    "appmedia",
    "appmpbossagency",
    "appmpemail",
    "appmpjoblistnew",
    "apporganiser",
    "appprogresshub",
    "apprepeatplay",
    "appsecurohack",
    "appsecuroserv",
    "appsettings",
    "appsidetask",
    "appsmuggler",
    "apptextmessage",
    "apptrackify",
    "appvinewoodmenu",
    "appvlsi",
    "appzit",
    -- "debug_app_select_screen",
}

t_ModshopScriptNames = {
    "arena_carmod",
    "armory_aircraft_carmod",
    "base_carmod",
    "business_hub_carmod",
    "car_meet_carmod",
    "carmod_shop",
    "fixer_hq_carmod",
    "hacker_truck_carmod",
    "hangar_carmod",
    "juggalo_hideout_carmod",
    "personal_carmod_shop",
    "tuner_property_carmod",
    -- "vinewood_premium_garage_carmod",
}

t_Langs = {
    { name = "English", iso = "en-US" },
    { name = "Français", iso = "fr-FR" },
    { name = "Deütsch", iso = "de-DE" },
    { name = "Español", iso = "es-ES" },
    { name = "Italiano", iso = "it-IT" },
    { name = "Português (Brasil)", iso = "pt-BR" },
    { name = "Русский (Russian)", iso = "ru-RU" },
    { name = "Chinese (Traditional)", iso = "zh-TW" },
    { name = "Chinese (Simplified)", iso = "zh-CN" },
    { name = "Japanese", iso = "ja-JP" },
    { name = "Polish", iso = "pl-PL" },
    { name = "Korean", iso = "ko-KR" },
}

t_GamepadControls = {
    { ctrl = 7,   gpad = "R3" },
    { ctrl = 10,  gpad = "LT" },
    { ctrl = 11,  gpad = "RT" },
    { ctrl = 14,  gpad = "DPAD RIGHT" },
    { ctrl = 15,  gpad = "DPAD LEFT" },
    { ctrl = 19,  gpad = "DPAD DOWN" },
    { ctrl = 20,  gpad = "DPAD DOWN" },
    { ctrl = 21,  gpad = "A" },
    { ctrl = 22,  gpad = "X" },
    { ctrl = 23,  gpad = "Y" },
    { ctrl = 27,  gpad = "DPAD UP" },
    { ctrl = 29,  gpad = "R3" },
    { ctrl = 30,  gpad = "LEFT STICK" },
    { ctrl = 34,  gpad = "LEFT STICK" },
    { ctrl = 36,  gpad = "L3" },
    { ctrl = 37,  gpad = "LB" },
    { ctrl = 38,  gpad = "LB" },
    { ctrl = 42,  gpad = "DPAD UP" },
    { ctrl = 43,  gpad = "DPAD DOWN" },
    { ctrl = 44,  gpad = "RB" },
    { ctrl = 45,  gpad = "B" },
    { ctrl = 46,  gpad = "DPAD RIGHT" },
    { ctrl = 47,  gpad = "DPAD LEFT" },
    { ctrl = 56,  gpad = "Y" },
    { ctrl = 57,  gpad = "B" },
    { ctrl = 70,  gpad = "A" },
    { ctrl = 71,  gpad = "RT" },
    { ctrl = 72,  gpad = "LT" },
    { ctrl = 73,  gpad = "A" },
    { ctrl = 74,  gpad = "DPAD RIGHT" },
    { ctrl = 75,  gpad = "Y" },
    { ctrl = 76,  gpad = "RB" },
    { ctrl = 79,  gpad = "R3" },
    { ctrl = 81,  gpad = "(NONE)" },
    { ctrl = 82,  gpad = "(NONE)" },
    { ctrl = 83,  gpad = "(NONE)" },
    { ctrl = 84,  gpad = "(NONE)" },
    { ctrl = 84,  gpad = "DPAD LEFT" },
    { ctrl = 96,  gpad = "(NONE)" },
    { ctrl = 97,  gpad = "(NONE)" },
    { ctrl = 124, gpad = "LEFT STICK" },
    { ctrl = 125, gpad = "LEFT STICK" },
    { ctrl = 112, gpad = "LEFT STICK" },
    { ctrl = 127, gpad = "LEFT STICK" },
    { ctrl = 117, gpad = "LB" },
    { ctrl = 118, gpad = "RB" },
    { ctrl = 167, gpad = "(NONE)" },
    { ctrl = 168, gpad = "(NONE)" },
    { ctrl = 169, gpad = "(NONE)" },
    { ctrl = 170, gpad = "B" },
    { ctrl = 172, gpad = "DPAD UP" },
    { ctrl = 173, gpad = "DPAD DOWN" },
    { ctrl = 174, gpad = "DPAD LEFT" },
    { ctrl = 175, gpad = "DPAD RIGHT" },
    { ctrl = 178, gpad = "Y" },
    { ctrl = 194, gpad = "B" },
    { ctrl = 243, gpad = "(NONE)" },
    { ctrl = 244, gpad = "BACK" },
    { ctrl = 249, gpad = "(NONE)" },
    { ctrl = 288, gpad = "A" },
    { ctrl = 289, gpad = "X" },
    { ctrl = 303, gpad = "DPAD UP" },
    { ctrl = 307, gpad = "DPAD RIGHT" },
    { ctrl = 308, gpad = "DPAD LEFT" },
    { ctrl = 311, gpad = "DPAD DOWN" },
    { ctrl = 318, gpad = "START" },
    { ctrl = 322, gpad = "(NONE)" },
    { ctrl = 344, gpad = "DPAD RIGHT" },
}

t_UISounds = {
    ["Radar"] = {
        soundName = "RADAR_ACTIVATE",
        soundRef = "DLC_BTL_SECURITY_VANS_RADAR_PING_SOUNDS"
    },
    ["Select"] = {
        soundName = "SELECT",
        soundRef = "HUD_FRONTEND_DEFAULT_SOUNDSET"
    },
    ["Pickup"] = {
        soundName = "PICK_UP",
        soundRef = "HUD_FRONTEND_DEFAULT_SOUNDSET"
    },
    ["W_Pickup"] = {
        soundName = "PICK_UP_WEAPON",
        soundRef = "HUD_FRONTEND_CUSTOM_SOUNDSET"
    },
    ["Fail"] = {
        soundName = "CLICK_FAIL",
        soundRef = "WEB_NAVIGATION_SOUNDS_PHONE"
    },
    ["Click"] = {
        soundName = "CLICK_LINK",
        soundRef = "DLC_H3_ARCADE_LAPTOP_SOUNDS"
    },
    ["Notif"] = {
        soundName = "LOSE_1ST",
        soundRef = "GTAO_FM_EVENTS_SOUNDSET"
    },
    ["Delete"] = {
        soundName = "DELETE",
        soundRef = "HUD_DEATHMATCH_SOUNDSET"
    },
    ["Cancel"] = {
        soundName = "CANCEL",
        soundRef = "HUD_FREEMODE_SOUNDSET"
    },
    ["Error"] = {
        soundName = "ERROR",
        soundRef = "HUD_FREEMODE_SOUNDSET"
    },
    ["Nav"] = {
        soundName = "NAV_LEFT_RIGHT",
        soundRef = "HUD_FREEMODE_SOUNDSET"
    },
    ["Nav2"] = {
        soundName = "NAV_UP_DOWN",
        soundRef = "HUD_FREEMODE_SOUNDSET"
    },
    ["Select2"] = {
        soundName = "CHANGE_STATION_LOUD",
        soundRef = "RADIO_SOUNDSET"
    },
    ["Focus_In"] = {
        soundName = "FOCUSIN",
        soundRef = "HINTCAMSOUNDS"
    },
    ["Focus_Out"] = {
        soundName = "FOCUSOUT",
        soundRef = "HINTCAMSOUNDS"
    },
}

t_ReservedKeys = {
    kb   = {
        0x01,
        0x07,
        0x0A,
        0x0B,
        0x1B,
        0x24,
        0x2C,
        0x2D,
        0x46,
        0x5B,
        0x5C,
        0x5E,
    },
    gpad = {
        23,
        24,
        25,
        71,
        75,
    }
}

t_Locales = {
    { name = "English",             id = 0,  iso = "en-US" },
    { name = "French",              id = 1,  iso = "fr-FR" },
    { name = "German",              id = 2,  iso = "de-DE" },
    { name = "Italian",             id = 3,  iso = "it-IT" },
    { name = "Spanish, Spain",      id = 4,  iso = "es-ES" },
    { name = "Portugese",           id = 5,  iso = "pt-BR" },
    { name = "Polish",              id = 6,  iso = "pl-PL" },
    { name = "Russian",             id = 7,  iso = "ru-RU" },
    { name = "Korean",              id = 8,  iso = "ko-KR" },
    { name = "Chinese Traditional", id = 9,  iso = "zh-TW" },
    { name = "Japanese",            id = 10, iso = "ja-JP" },
    { name = "Spanish, Mexico",     id = 11, iso = "es-MX" },
    { name = "Chinese Simplified",  id = 12, iso = "zh-CN" },
}
