//* This file is explicitly licensed under the MIT license. *//
//* Copyright (c) 2024 Citadel Station Developers           *//

/mob/verb/horizontal_invert_self()
	set name = "Invert Yourself (Horizontal)"
	set desc = "Mirror your sprite across the N-S axis."
	set category = VERB_CATEGORY_IC

	// todo: remote control? mobs that don't allow it?

	if(TIMER_COOLDOWN_CHECK(src, CD_INDEX_MOB_VERB_INVERT_SELF))
		// todo: don't usr lol
		to_chat(usr, SPAN_WARNING("You can't do that yet!"))
		return
	TIMER_COOLDOWN_START(src, CD_INDEX_MOB_VERB_INVERT_SELF, 0.5 SECONDS)

	log_game("[key_name(usr)] invoked horizontal_invert_self on [key_name(src)].")

	var/datum/component/mob_self_horizontal_inversion/inversion = GetComponent(/datum/component/mob_self_horizontal_inversion)
	if(inversion)
		qdel(inversion)
	else
		AddComponent(/datum/component/mob_self_horizontal_inversion)