/mob/living/carbon/brain/handle_breathing()
	return

/mob/living/carbon/brain/handle_mutations_and_radiation(seconds)
	// todo; deal with this
	// removed for now because why do we even tick brains this way??

	// if (radiation)
	// 	if (radiation > 100)
	// 		radiation = 100
	// 		if(!container)//If it's not in an MMI
	// 			to_chat(src, "<font color='red'>You feel weak.</font>")
	// 		else//Fluff-wise, since the brain can't detect anything itself, the MMI handles thing like that
	// 			to_chat(src, "<font color='red'>STATUS: CRITICAL AMOUNTS OF RADIATION DETECTED.</font>")

	// 	switch(radiation)
	// 		if(1 to 49)
	// 			radiation--
	// 			if(prob(25))
	// 				adjustToxLoss(1)
	// 				update_health()

	// 		if(50 to 74)
	// 			radiation -= 2
	// 			adjustToxLoss(1)
	// 			if(prob(5))
	// 				radiation -= 5
	// 				if(!container)
	// 					to_chat(src, "<font color='red'>You feel weak.</font>")
	// 				else
	// 					to_chat(src, "<font color='red'>STATUS: DANGEROUS LEVELS OF RADIATION DETECTED.</font>")
	// 			update_health()

	// 		if(75 to 100)
	// 			radiation -= 3
	// 			adjustToxLoss(3)
	// 			update_health()


/mob/living/carbon/brain/handle_environment(datum/gas_mixture/environment)
	if(!environment)
		return
	var/environment_heat_capacity = environment.heat_capacity()
	if(istype(get_turf(src), /turf/space))
		var/turf/heat_turf = get_turf(src)
		environment_heat_capacity = heat_turf.heat_capacity

	if((environment.temperature > (T0C + 50)) || (environment.temperature < (T0C + 10)))
		var/transfer_coefficient = 1

		handle_temperature_damage(HEAD, environment.temperature, environment_heat_capacity*transfer_coefficient)

	if(stat==2)
		bodytemperature += 0.1*(environment.temperature - bodytemperature)*environment_heat_capacity/(environment_heat_capacity + 270000)

	//Account for massive pressure differences

	return //TODO: DEFERRED

/mob/living/carbon/brain/proc/handle_temperature_damage(body_part, exposed_temperature, exposed_intensity)
	if(status_flags & STATUS_GODMODE) return

	if(exposed_temperature > bodytemperature)
		var/discomfort = min( abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1.0)
		//adjustFireLoss(2.5*discomfort)
		//adjustFireLoss(5.0*discomfort)
		adjustFireLoss(20.0*discomfort)

	else
		var/discomfort = min( abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1.0)
		//adjustFireLoss(2.5*discomfort)
		adjustFireLoss(5.0*discomfort)


/mob/living/carbon/brain/handle_chemicals_in_body()
	chem_effects.Cut()

	if(touching) touching.metabolize()
	if(ingested) ingested.metabolize()
	if(bloodstr) bloodstr.metabolize()

	// decrement dizziness counter, clamped to 0
	if(resting)
		dizziness = max(0, dizziness - 5)
	else
		dizziness = max(0, dizziness - 1)

	update_health()

	return //TODO: DEFERRED

/mob/living/carbon/brain/handle_regular_UI_updates()	//TODO: comment out the unused bits >_>
	update_health()

	if(stat == DEAD)	//DEAD. BROWN BREAD. SWIMMING WITH THE SPESS CARP
		src.apply_status_effect(/datum/status_effect/sight/blindness, 5 SECONDS)//60 seconds is just a randomly picked number, the modifier does not expire as long as the holder is dead
		silent = 0
	else				//ALIVE. LIGHTS ARE ON
		if( !container && (health < getMinHealth() || ((world.time - timeofhostdeath) > config_legacy.revival_brain_life)) )
			death()
			src.apply_status_effect(/datum/status_effect/sight/blindness, 5 SECONDS)
			silent = 0
			return 1

		//Handling EMP effect in the Life(), it's made VERY simply, and has some additional effects handled elsewhere
		if(emp_damage)			//This is pretty much a damage type only used by MMIs, dished out by the emp_act
			if(!(container && istype(container, /obj/item/mmi)))
				emp_damage = 0
			else
				emp_damage = round(emp_damage,1)//Let's have some nice numbers to work with
			switch(emp_damage)
				if(31 to INFINITY)
					emp_damage = 30//Let's not overdo it
				if(21 to 30)//High level of EMP damage, unable to see, hear, or speak
					src.apply_status_effect(/datum/status_effect/sight/blindness, 5 SECONDS)
					ear_deaf = 1
					silent = 1
					if(!alert)//Sounds an alarm, but only once per 'level'
						emote("alarm")
						to_chat(src, "<font color='red'>Major electrical distruption detected: System rebooting.</font>")
						alert = 1
					if(prob(75))
						emp_damage -= 1
				if(20)
					alert = 0
					ear_deaf = 0
					silent = 0
					emp_damage -= 1
				if(11 to 19)//Moderate level of EMP damage, resulting in nearsightedness and ear damage
					eye_blurry = 1
					ear_damage = 1
					if(!alert)
						emote("alert")
						to_chat(src, "<font color='red'>Primary systems are now online.</font>")
						alert = 1
					if(prob(50))
						emp_damage -= 1
				if(10)
					alert = 0
					eye_blurry = 0
					ear_damage = 0
					emp_damage -= 1
				if(2 to 9)//Low level of EMP damage, has few effects(handled elsewhere)
					if(!alert)
						emote("notice")
						to_chat(src, "<font color='red'>System reboot nearly complete.</font>")
						alert = 1
					if(prob(25))
						emp_damage -= 1
				if(1)
					alert = 0
					to_chat(src, "<font color='red'>All systems restored.</font>")
					emp_damage -= 1

	return 1

/mob/living/carbon/brain/handle_regular_hud_updates()
	if (healths)
		if (stat != DEAD)
			switch(health)
				if(100 to INFINITY)
					healths.icon_state = "health0"
				if(80 to 100)
					healths.icon_state = "health1"
				if(60 to 80)
					healths.icon_state = "health2"
				if(40 to 60)
					healths.icon_state = "health3"
				if(20 to 40)
					healths.icon_state = "health4"
				if(0 to 20)
					healths.icon_state = "health5"
				else
					healths.icon_state = "health6"
		else
			healths.icon_state = "health7"

	if (stat == DEAD || (MUTATION_XRAY in src.mutations))
		AddSightSelf(SEE_TURFS | SEE_MOBS | SEE_OBJS)
		self_perspective?.legacy_force_set_hard_darkvision(0)
		SetSeeInvisibleSelf(SEE_INVISIBLE_LEVEL_ONE)
	else if (stat != DEAD)
		RemoveSightSelf(SEE_TURFS | SEE_MOBS | SEE_OBJS)
		self_perspective?.legacy_force_set_hard_darkvision(null)
		SetSeeInvisibleSelf(SEE_INVISIBLE_LIVING)

	if (stat != DEAD)
		//Blindness is handled by the modifier
		if(disabilities & DISABILITY_NEARSIGHTED)
			overlay_fullscreen("impaired", /atom/movable/screen/fullscreen/scaled/impaired, 1)
		else
			clear_fullscreen("impaired")
		if(eye_blurry)
			overlay_fullscreen("blurry", /atom/movable/screen/fullscreen/tiled/blurry)
		else
			clear_fullscreen("blurry")
		if(druggy)
			overlay_fullscreen("high", /atom/movable/screen/fullscreen/tiled/high)
		else
			clear_fullscreen("high")

		if(IsRemoteViewing())
			if(machine && machine.check_eye(src) < 0)
				reset_perspective()

	return 1
