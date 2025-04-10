//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/obj/machinery/containment_field
	name = "Containment Field"
	desc = "An energy field."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "Contain_F"
	anchored = TRUE
	density = FALSE
	integrity_flags = INTEGRITY_ACIDPROOF | INTEGRITY_FIREPROOF | INTEGRITY_LAVAPROOF
	use_power = USE_POWER_OFF
	light_range = 4
	var/obj/machinery/field_generator/FG1 = null
	var/obj/machinery/field_generator/FG2 = null
	var/hasShocked = 0 //Used to add a delay between shocks. In some cases this used to crash servers by spawning hundreds of sparks every second.

/obj/machinery/containment_field/Destroy()
	if(FG1 && !FG1.clean_up)
		FG1.cleanup()
	if(FG2 && !FG2.clean_up)
		FG2.cleanup()
	. = ..()

/obj/machinery/containment_field/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	if(get_dist(src, user) > 1)
		return 0
	else
		shock(user)
		return 1

/obj/machinery/containment_field/CanAllowThrough(atom/movable/mover, turf/target)
	if(isliving(mover))
		return FALSE
	return ..()

/obj/machinery/containment_field/Bumped(atom/movable/bumped_atom)
	. = ..()
	if(isliving(bumped_atom))
		shock(bumped_atom)

/obj/machinery/containment_field/legacy_ex_act(severity)
	return 0

/obj/machinery/containment_field/shock(mob/living/user as mob)
	if(hasShocked)
		return 0
	if(!FG1 || !FG2)
		qdel(src)
		return 0
	if(isliving(user))
		hasShocked = 1
		var/shock_damage = min(rand(30,40),rand(30,40))
		user.electrocute(0, shock_damage, 0, NONE, BP_TORSO, src)

		var/atom/target = get_edge_target_turf(user, get_dir(src, get_step_away(user, src)))
		user.throw_at_old(target, 200, 4)

		sleep(20)

		hasShocked = 0

/obj/machinery/containment_field/proc/set_master(var/master1,var/master2)
	if(!master1 || !master2)
		return 0
	FG1 = master1
	FG2 = master2
	return 1
