/obj/item/storage/belt
	name = "belt"
	desc = "Can hold various things."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "utility"
	max_items = 7
	max_combined_volume = WEIGHT_VOLUME_NORMAL * 7 //This should ensure belts always have enough room to store whatever.
	max_single_weight_class = WEIGHT_CLASS_NORMAL
	ui_force_slot_mode = TRUE
	slot_flags = SLOT_BELT
	attack_verb = list("whipped", "lashed", "disciplined")
	equip_sound = 'sound/items/toolbelt_equip.ogg'
	drop_sound = 'sound/items/drop/toolbelt.ogg'
	pickup_sound = 'sound/items/pickup/toolbelt.ogg'
	worth_intrinsic = 50
	var/show_above_suit = 0

/obj/item/storage/belt/verb/toggle_layer()
	set name = "Switch Belt Layer"
	set category = VERB_CATEGORY_OBJECT

	if(show_above_suit == -1)
		to_chat(usr, SPAN_NOTICE("\The [src] cannot be worn above your suit!"))
		return
	show_above_suit = !show_above_suit
	update_icon()

// todo: this bad lol
/obj/item/storage/belt/render_apply_overlays(mutable_appearance/MA, bodytype, inhands, datum/inventory_slot/slot_meta, icon_used)
	. = ..()
	var/static/icon/funny_belt_icon = 'icons/mob/clothing/belt.dmi'
	for(var/obj/item/I in contents)
		var/state = resolve_belt_state(I, funny_belt_icon)
		if(!state)
			continue
		MA.add_overlay(image(icon = funny_belt_icon, icon_state = state))

// todo: this bad lol x2
/obj/item/storage/belt/proc/resolve_belt_state(obj/item/I, icon/ifile)
	return I.belt_state || I.item_state || I.icon_state

/obj/item/storage/update_icon()
	. = ..()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_belt()

/obj/item/storage/belt/utility
	name = "tool-belt" //Carn: utility belt is nicer, but it bamboozles the text parsing.
	desc = "Can hold various tools."
	icon_state = "utility"
	item_state = "utility"
	insertion_whitelist = list(
		///obj/item/combitool,
		/obj/item/tool/crowbar,
		/obj/item/tool/screwdriver,
		/obj/item/weldingtool,
		/obj/item/tool/wirecutters,
		/obj/item/tool/wrench,
		/obj/item/multitool,
		/obj/item/flashlight,
		/obj/item/cell/device,
		/obj/item/stack/cable_coil,
		/obj/item/t_scanner,
		/obj/item/atmos_analyzer,
		/obj/item/clothing/glasses,
		/obj/item/clothing/gloves,
		/obj/item/pda,
		/obj/item/megaphone,
		/obj/item/barrier_tape_roll,
		/obj/item/radio/headset,
		/obj/item/robotanalyzer,
		/obj/item/material/minihoe,
		/obj/item/material/knife/machete/hatchet,
		/obj/item/plant_analyzer,
		/obj/item/extinguisher/mini,
		/obj/item/duct_tape_roll,
		/obj/item/switchtool,
		/obj/item/integrated_electronics/wirer,
		/obj/item/integrated_electronics/debugger,
		)

/obj/item/storage/belt/utility/full
	starts_with = list(
		/obj/item/tool/screwdriver,
		/obj/item/tool/wrench,
		/obj/item/weldingtool,
		/obj/item/tool/crowbar,
		/obj/item/tool/wirecutters,
		/obj/item/stack/cable_coil/random_belt
	)

/obj/item/storage/belt/utility/atmostech
	starts_with = list(
		/obj/item/tool/screwdriver,
		/obj/item/tool/wrench,
		/obj/item/weldingtool,
		/obj/item/tool/crowbar,
		/obj/item/tool/wirecutters,
	)

/obj/item/storage/belt/utility/chief
	name = "chief engineer's toolbelt"
	desc = "Holds tools, looks snazzy."
	icon_state = "utilitybelt_ce"
	item_state = "utility_ce"

/obj/item/storage/belt/utility/chief/full
	starts_with = list(
		/obj/item/tool/screwdriver/power,
		/obj/item/tool/crowbar/power,
		/obj/item/weldingtool/experimental,
		/obj/item/multitool,
		/obj/item/stack/cable_coil/random_belt,
		/obj/item/extinguisher/mini,
		/obj/item/atmos_analyzer/longrange
	)

/obj/item/storage/belt/medical
	name = "medical belt"
	desc = "Can hold various medical equipment."
	icon_state = "medical"
	insertion_whitelist = list(
		/obj/item/healthanalyzer,
		/obj/item/dnainjector,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/storage/quickdraw/syringe_case,
		/obj/item/flame/lighter/zippo,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/pill_bottle,
		/obj/item/stack/medical,
		/obj/item/radio/headset,
		/obj/item/pda,
		/obj/item/barrier_tape_roll,
		/obj/item/megaphone,
		/obj/item/clothing/mask/surgical,
		/obj/item/clothing/head/surgery,
		/obj/item/clothing/gloves,
		/obj/item/reagent_containers/hypospray,
		/obj/item/hypospray,
		/obj/item/reagent_containers/glass/hypovial,
		/obj/item/clothing/glasses,
		/obj/item/tool/crowbar,
		/obj/item/flashlight,
		/obj/item/cell/device,
		/obj/item/extinguisher/mini,
		/obj/item/switchtool/surgery,
		/obj/item/storage/quickdraw/syringe_case
		)

/obj/item/storage/belt/medical/emt
	name = "EMT utility belt"
	desc = "A sturdy black webbing belt with attached pouches."
	icon_state = "ems"

/obj/item/storage/belt/detective
	name = "forensic utility belt"
	desc = "A belt for holding forensics equipment."
	icon_state = "security"
	max_items = 7
	max_single_weight_class = WEIGHT_CLASS_NORMAL
	insertion_whitelist = list(
		/obj/item/tape_recorder,
		/obj/item/barrier_tape_roll,
		/obj/item/clothing/glasses,
		/obj/item/flashlight,
		/obj/item/cell/device,
		/obj/item/reagent_containers/spray/luminol,
		/obj/item/sample,
		/obj/item/forensics/sample_kit/powder,
		/obj/item/forensics/swab,
		/obj/item/uv_light,
		/obj/item/forensics/sample_kit,
		/obj/item/photo,
		/obj/item/camera_film,
		/obj/item/camera,
		/obj/item/autopsy_scanner,
		/obj/item/mass_spectrometer,
		/obj/item/clothing/accessory/badge,
		/obj/item/reagent_scanner,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/syringe,
		/obj/item/pda,
		/obj/item/hailer,
		/obj/item/megaphone,
		/obj/item/radio/headset,
		/obj/item/clothing/gloves,
		/obj/item/barrier_tape_roll,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/handcuffs,
		/obj/item/flash,
		/obj/item/flame/lighter,
		/obj/item/reagent_containers/food/snacks/donut/,
		/obj/item/ammo_magazine,
		/obj/item/gun/projectile/ballistic/colt/detective,
		/obj/item/holowarrant
		)

/obj/item/storage/belt/explorer
	name = "pathfinder's bandolier"
	desc = "A versatile bandolier fitted with eight pouches that can hold a wide variety of items such as tools, small melee weapons, batteries, ammunition, and more; ideal for any pathfinder who has too much stuff and not enough pockets."
	icon_state = "bandolier"
	max_items = 7
	max_combined_volume = WEIGHT_VOLUME_NORMAL * 7
	show_above_suit = 1
	insertion_whitelist = list(
		/obj/item/grenade,
		/obj/item/tool/crowbar,
		/obj/item/tool/screwdriver,
		/obj/item/weldingtool,
		/obj/item/tool/wirecutters,
		/obj/item/tool/wrench,
		/obj/item/pickaxe/,
		/obj/item/multitool,
		/obj/item/stack/cable_coil,
		/obj/item/t_scanner,
		/obj/item/atmos_analyzer,
		/obj/item/flashlight,
		/obj/item/cell/device,
		/obj/item/cell/device/weapon,
		/obj/item/material/butterfly,
		/obj/item/material/knife,
		/obj/item/melee/transforming/energy/sword,
		/obj/item/shield/transforming/energy,
		/obj/item/ammo_casing/,
		/obj/item/ammo_magazine/,
		/obj/item/storage/box/beanbags,
		/obj/item/storage/box/shotgunammo,
		/obj/item/storage/box/shotgunshells,
		/obj/item/healthanalyzer,
		/obj/item/robotanalyzer,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/hypospray,
		/obj/item/hypospray,
		/obj/item/storage/pill_bottle,
		/obj/item/stack/medical,
		/obj/item/stack/marker_beacon,
		/obj/item/flashlight,
		/obj/item/extinguisher/mini,
		/obj/item/storage/quickdraw/syringe_case,
		/obj/item/photo,
		/obj/item/camera_film,
		/obj/item/camera,
		/obj/item/tape_recorder,
		/obj/item/barrier_tape_roll,
		/obj/item/healthanalyzer,
		/obj/item/geiger_counter,
		/obj/item/gps,
		/obj/item/switchtool,
		/obj/item/ano_scanner
		)

/obj/item/storage/belt/soulstone
	name = "soul stone belt"
	desc = "Designed for ease of access to the shards during a fight, as to not let a single enemy spirit slip away"
	icon_state = "soulstone"
	max_items = 6
	insertion_whitelist = list(
		/obj/item/soulstone
		)

/obj/item/storage/belt/soulstone/full
	starts_with = list(/obj/item/soulstone = 6)

/obj/item/storage/belt/utility/alien
	name = "alien belt"
	desc = "A belt(?) that can hold things."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "belt"
	item_state = "security"

/obj/item/storage/belt/utility/alien/full
	starts_with = list(
		/obj/item/tool/screwdriver/alien,
		/obj/item/tool/wrench/alien,
		/obj/item/weldingtool/alien,
		/obj/item/tool/crowbar/alien,
		/obj/item/tool/wirecutters/alien,
		/obj/item/multitool/alien,
		/obj/item/stack/cable_coil/alien
	)

/obj/item/storage/belt/medical/alien
	name = "alien belt"
	desc = "A belt(?) that can hold things."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "belt"
	item_state = "security"
	max_items = 8
	insertion_whitelist = list(
		/obj/item/healthanalyzer,
		/obj/item/dnainjector,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/flame/lighter/zippo,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/pill_bottle,
		/obj/item/stack/medical,
		/obj/item/radio/headset,
		/obj/item/pda,
		/obj/item/barrier_tape_roll,
		/obj/item/megaphone,
		/obj/item/clothing/mask/surgical,
		/obj/item/clothing/head/surgery,
		/obj/item/clothing/gloves,
		/obj/item/reagent_containers/hypospray,
		/obj/item/hypospray,
		/obj/item/clothing/glasses,
		/obj/item/tool/crowbar,
		/obj/item/flashlight,
		/obj/item/cell/device,
		/obj/item/extinguisher/mini,
		/obj/item/surgical
		)

/obj/item/storage/belt/medical/alien
	starts_with = list(
		/obj/item/surgical/scalpel/alien,
		/obj/item/surgical/hemostat/alien,
		/obj/item/surgical/retractor/alien,
		/obj/item/surgical/circular_saw/alien,
		/obj/item/surgical/FixOVein/alien,
		/obj/item/surgical/bone_clamp/alien,
		/obj/item/surgical/cautery/alien,
		/obj/item/surgical/surgicaldrill/alien
	)

/obj/item/storage/belt/champion
	name = "championship belt"
	desc = "Proves to the world that you are the strongest!"
	icon_state = "champion"
	max_items = 1
	insertion_whitelist = list(
		"/obj/item/clothing/mask/luchador"
		)

/obj/item/storage/belt/security/tactical
	name = "combat belt"
	desc = "Can hold security gear like handcuffs and flashes, with more pouches for more storage."
	icon_state = "swat"
	max_items = 9
	max_single_weight_class = WEIGHT_CLASS_NORMAL
	max_combined_volume = WEIGHT_VOLUME_NORMAL * 7

/obj/item/storage/belt/security/tactical/bandolier
	name = "combat belt"
	desc = "Can hold security gear like handcuffs and flashes, with more pouches for more storage."
	icon_state = "bandolier"

/obj/item/storage/belt/spike_bandolier
	name = "spike bandolier"
	desc = "A bandolier used to hold spikes, and only spikes."
	icon_state = "bandolier"
	max_items = 14
	max_single_weight_class = WEIGHT_CLASS_SMALL
	max_combined_volume = WEIGHT_VOLUME_SMALL * 14
	insertion_whitelist = list(/obj/item/melee/spike)
	starts_with = list(/obj/item/melee/spike = 14)

/obj/item/storage/belt/janitor
	name = "janitorial belt"
	desc = "A belt used to hold most janitorial supplies."
	icon_state = "janitor"
	max_items = 7
	max_single_weight_class = WEIGHT_CLASS_NORMAL
	worth_intrinsic = 35
	insertion_whitelist = list(
		/obj/item/clothing/glasses,
		/obj/item/flashlight,
		/obj/item/cell/device,
		/obj/item/grenade,
		/obj/item/pda,
		/obj/item/radio/headset,
		/obj/item/clothing/gloves,
		/obj/item/clothing/mask/surgical, //sterile mask,
		/obj/item/assembly/mousetrap,
		/obj/item/light/bulb,
		/obj/item/light/tube,
		/obj/item/flame/lighter,
		/obj/item/megaphone,
		/obj/item/barrier_tape_roll,
		/obj/item/reagent_containers/spray,
		/obj/item/soap
		)

/obj/item/storage/belt/archaeology
	name = "excavation gear-belt"
	desc = "Can hold various excavation gear."
	icon_state = "gear"
	worth_intrinsic = 65
	insertion_whitelist = list(
		/obj/item/storage/box/samplebags,
		/obj/item/core_sampler,
		/obj/item/beacon_locator,
		/obj/item/radio/beacon,
		/obj/item/gps,
		/obj/item/measuring_tape,
		/obj/item/flashlight,
		/obj/item/cell/device,
		/obj/item/pickaxe,
		/obj/item/depth_scanner,
		/obj/item/camera,
		/obj/item/paper,
		/obj/item/photo,
		/obj/item/folder,
		/obj/item/pen,
		/obj/item/folder,
		/obj/item/clipboard,
		/obj/item/anodevice,
		/obj/item/clothing/glasses,
		/obj/item/tool/wrench,
		/obj/item/storage/excavation,
		/obj/item/anobattery,
		/obj/item/ano_scanner,
		/obj/item/pickaxe/hand,
		/obj/item/hand_labeler,
		/obj/item/xenoarch_multi_tool,
		/obj/item/pickaxe/excavationdrill
		)

/obj/item/storage/belt/fannypack
	name = "leather fannypack"
	desc = "A dorky fannypack for keeping small items in."
	icon_state = "fannypack_leather"
	item_state = "fannypack_leather"
	max_single_weight_class = WEIGHT_CLASS_SMALL
	max_items = null
	max_combined_volume = WEIGHT_VOLUME_NORMAL * 2

/obj/item/storage/belt/fannypack/black
 	name = "black fannypack"
 	icon_state = "fannypack_black"
 	item_state = "fannypack_black"

/obj/item/storage/belt/fannypack/blue
 	name = "blue fannypack"
 	icon_state = "fannypack_blue"
 	item_state = "fannypack_blue"

/obj/item/storage/belt/fannypack/cyan
 	name = "cyan fannypack"
 	icon_state = "fannypack_cyan"
 	item_state = "fannypack_cyan"

/obj/item/storage/belt/fannypack/green
 	name = "green fannypack"
 	icon_state = "fannypack_green"
 	item_state = "fannypack_green"

/obj/item/storage/belt/fannypack/orange
 	name = "orange fannypack"
 	icon_state = "fannypack_orange"
 	item_state = "fannypack_orange"

/obj/item/storage/belt/fannypack/purple
 	name = "purple fannypack"
 	icon_state = "fannypack_purple"
 	item_state = "fannypack_purple"

/obj/item/storage/belt/fannypack/red
 	name = "red fannypack"
 	icon_state = "fannypack_red"
 	item_state = "fannypack_red"

/obj/item/storage/belt/fannypack/white
 	name = "white fannypack"
 	icon_state = "fannypack_white"
 	item_state = "fannypack_white"

/obj/item/storage/belt/fannypack/yellow
 	name = "yellow fannypack"
 	icon_state = "fannypack_yellow"
 	item_state = "fannypack_yellow"

/obj/item/storage/belt/sheath
	name = "sabre sheath"
	desc = "An ornate sheath designed to hold an officer's blade."
	icon_state = "sheath-sabre"
	max_items = 1
	insertion_whitelist = list(
		/obj/item/material/sword/sabre,
		/obj/item/melee/baton/stunsword,
		)
	starts_with = list(
		/obj/item/material/sword/sabre,
		)

/obj/item/storage/belt/sheath/initialize_storage()
	. = ..()
	obj_storage.update_icon_on_item_change = TRUE

/obj/item/storage/belt/sheath/update_icon()
	icon_state = "sheath"
	item_state = "sheath"
	if(contents.len)
		icon_state += "-sabre"
		item_state += "-sabre"
	if(loc && isliving(loc))
		var/mob/living/L = loc
		L.regenerate_icons()
	..()

/obj/item/storage/belt/ranger
	name = "ranger belt"
	desc = "The fancy utility-belt holding the tools, cuffs and gadgets of the Go Go ERT-Rangers. The belt buckle is not real phoron, but it is still surprisingly comfortable to wear."
	icon = 'icons/obj/clothing/ranger.dmi'
	icon_state = "ranger_belt"

/obj/item/storage/belt/dualholster
	name = "dual holster gunbelt"
	desc = "Belts like these were popular on old Earth, but were largely supplanted by modular holsters. This gunbelt is too bulky to be comfortably anchored to clothes without support."
	icon_state = "dual_holster"
	max_items = 2
	max_single_weight_class = WEIGHT_CLASS_NORMAL
	insertion_whitelist = list(
		/obj/item/gun/projectile/energy/alien,
		/obj/item/gun/projectile/energy/captain,
		/obj/item/gun/projectile/energy/crossbow,
		/obj/item/gun/projectile/energy/decloner,
		/obj/item/gun/projectile/energy/floragun,
		/obj/item/gun/projectile/energy/gun,
		/obj/item/gun/projectile/energy/gun/nuclear,
		/obj/item/gun/projectile/energy/ionrifle/pistol,
		/obj/item/gun/projectile/energy/lasertag,
		/obj/item/gun/projectile/energy/netgun,
		/obj/item/gun/projectile/energy/phasegun/pistol,
		/obj/item/gun/projectile/energy/nt_pulse/carbine,
		/obj/item/gun/projectile/energy/retro,
		/obj/item/gun/projectile/energy/nt_pmd/service_revolver,
		/obj/item/gun/projectile/energy/stunrevolver,
		/obj/item/gun/projectile/energy/taser,
		/obj/item/gun/projectile/energy/toxgun,
		/obj/item/gun/projectile/energy/zip,
		/obj/item/gun/projectile/ballistic/colt,
		/obj/item/gun/projectile/ballistic/contender,
		/obj/item/gun/projectile/ballistic/dartgun,
		/obj/item/gun/projectile/ballistic/deagle,
		/obj/item/gun/projectile/ballistic/derringer,
		/obj/item/gun/projectile/ballistic/gyropistol,
		/obj/item/gun/projectile/ballistic/luger,
		/obj/item/gun/projectile/ballistic/r9,
		/obj/item/gun/projectile/ballistic/revolver,
		/obj/item/gun/projectile/ballistic/sec,
		/obj/item/gun/projectile/ballistic/shotgun/doublebarrel/sawn,
		/obj/item/gun/projectile/ballistic/shotgun/flare,
		/obj/item/gun/projectile/ballistic/silenced,
		/obj/item/gun/projectile/ballistic/p92x,
		/obj/item/gun/projectile/ballistic/pistol,
		/obj/item/gun/projectile/ballistic/pirate
		)

/obj/item/storage/belt/quiver
	name = "leather quiver"
	desc = "A quiver made from the hide of some animal. Used to hold arrows."
	icon_state = "quiver"
	max_items = 15
	max_single_weight_class = WEIGHT_CLASS_NORMAL
	insertion_whitelist = list(
		/obj/item/ammo_casing/arrow
		)

/obj/item/storage/belt/quiver/full
	name = "leather quiver"
	desc = "A quiver made from the hide of some animal. Used to hold arrows."
	icon_state = "quiver"
	max_items = 15
	max_single_weight_class = WEIGHT_CLASS_NORMAL
	insertion_whitelist = list(
		/obj/item/ammo_casing/arrow
		)
	starts_with = list(
		/obj/item/ammo_casing/arrow = 15
		)

/obj/item/storage/belt/quiver/full/ash
	name = "leather quiver"
	desc = "A quiver made from the hide of some animal. Used to hold arrows."
	icon_state = "quiver"
	max_items = 15
	max_single_weight_class = WEIGHT_CLASS_NORMAL
	insertion_whitelist = list(
		/obj/item/ammo_casing/arrow
		)
	starts_with = list(
		/obj/item/ammo_casing/arrow/bone = 15
		)

/obj/item/storage/belt/utility/crystal
	name = "crystalline tool harness"
	desc = "A segmented belt of strange crystalline material."
	icon_state = "utilitybelt_crystal"
	item_state = "utilitybelt_crystal"

/obj/item/storage/belt/utility/crystal/Initialize()
	new /obj/item/multitool/crystal(src)
	new /obj/item/tool/wrench/crystal(src)
	new /obj/item/tool/crowbar/crystal(src)
	new /obj/item/tool/screwdriver/crystal(src)
	new /obj/item/tool/wirecutters/crystal(src)
	new /obj/item/weldingtool/electric/crystal(src)
	update_icon()
	. = ..()
