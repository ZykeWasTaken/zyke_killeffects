Config = Config or {}

-- Ranked based on what type of rarety they could have, bottom is most rare
-- Set `unlocked = true` to unlock the effect for everyone
-- Preferably set the unlocked ones at the top so that the script can choose it automatically in case it needs to
-- https://vespura.com/fivem/particle-list/
Config.Effects = {
    {label = "Blood Mist", dict = "core", particle = "blood_mist", size = 1.5, amount = 1, unlocked = true},

    {label = "Zap", dict = "core", particle = "ent_ray_prologue_elec_crackle_sp", size = 1.0, amount = 1},

    {label = "Pyromaniac", dict = "core", particle = "ent_ray_meth_fires", size = 1.0, amount = 1},
    {label = "Tactical Smoke", dict = "core", particle = "ent_ray_heli_aprtmnt_exp", size = 1.0, amount = 1},
    {label = "Blinding Lights", dict = "core", particle = "veh_exhaust_spacecraft", size = 1.0, amount = 1},
    {label = "EMP", dict = "scr_xs_dr", particle = "scr_xs_dr_emp", size = 1.0, amount = 1},

    {label = "Fireworks", dict = "scr_rcpaparazzo1", particle = "scr_mich4_firework_starburst", size = 2.0, amount = 1},
    {label = "Flare", dict = "scr_sm", particle = "scr_sm_hl_package_flare", size = 1.0, amount = 1},
    {label = "The Last Water Bender", dict = "scr_xm_submarine", particle = "scr_xm_submarine_surface_explosion", size = 0.5, amount = 1},

    {label = "Blown To Bits", dict = "scr_trevor3", particle = "scr_trev3_trailer_expolsion", size = 0.5, amount = 1},
    {label = "Landmine", dict = "scr_xm_submarine", particle = "exp_underwater_mine", size = 0.8, amount = 1, zOffset = 1.0},
    {label = "Extra Terrestrial", dict = "scr_xs_props", particle = "scr_xs_exp_mine_sf", size = 0.5, amount = 1, zOffset = 0.5},

    {label = "Stars Of Death", dict = "scr_rcpaparazzo1", particle = "scr_mich4_firework_burst_spawn", size = 1.0, amount = 3, zOffset = 1.0},
    {label = "C4", dict = "scr_trevor3", particle = "scr_trev3_c4_explosion", size = 1.0, amount = 1, zOffset = 0.6},

    {label = "Fiery Spirit", dict = "core", particle = "exp_grd_boat_sp", size = 1.0, amount = 1},
    {label = "Abra Kadabra", dict = "scr_rcbarry2", particle = "muz_clown", size = 2.0, amount = 10},

    {label = "Clown & Stars", dict = "scr_rcbarry2", particle = "scr_exp_clown", size = 0.8, amount = 1},

    {label = "Deadly Flowers", dict = "scr_rcbarry2", particle = "scr_clown_bul", size = 1.5, amount = 3},
    {label = "Clown Appears", dict = "scr_rcbarry2", particle = "scr_clown_appears", size = 1.3, amount = 1, zOffset = 0.5},

    {label = "Orbital Blast", dict = "scr_xm_orbital", particle = "scr_xm_orbital_blast", size = 0.6, amount = 1},
    {label = "Make It Rain", dict = "scr_xs_celebration", particle = "scr_xs_money_rain", size = 2.5, amount = 20},

    {label = "Balloon Pop", dict = "scr_sm", particle = "scr_dst_inflatable", size = 0.5, amount = 1}, -- 10
}