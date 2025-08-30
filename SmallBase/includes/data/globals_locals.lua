return {
    freemode_business_global = {
        description = "Biker Business Global",
        file = "freemode.c",
        LEGACY = {
            value = 1667996,
            pattern = [[if \(\((Global_.......?)\[\w+0\] != 0 && func_.....?\(\w+0\)\) && \w+2\)]],
            capture_group = 1
        },
        ENHANCED = {}
    },
    personal_vehicle_global = {
        description = "Personal Vehicle Global",
        file = "freemode.c",
        LEGACY = {
            value = 1572092,
            pattern = [[if \(VEHICLE::GET_IS_VEHICLE_ENGINE_RUNNING\((Global_.......?)\)\)]],
            capture_group = 1
        },
        ENHANCED = {}
    },
    gb_contraband_sell_local = {
        description = "Contraband Sell Local",
        file = "gb_contraband_sell.c",
        LEGACY = {
            value = 563,
            pattern = [[MISC::CLEAR_BIT\(.*?(Local_...?)\.f_1\), .*?Param0]],
            capture_group = 1
        },
        ENHANCED = {}
    },
    gb_biker_contraband_sell_local = {
        description = "Biker Contraband Sell Local",
        file = "gb_biker_contraband_sell.c",
        LEGACY = {
            value = 725,
            pattern = [[else if \(.*?!func_.*?\(1\) && .*?(Local_...?)(\.f_...?) > 0\)]],
            capture_group = 1,
            offsets = {
                {
                    value = 122,
                    capture_group = 2
                },
            }
        },
        ENHANCED = {}
    }
}
