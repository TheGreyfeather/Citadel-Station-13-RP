/datum/prototype/language/binary
	id = LANGUAGE_ID_SILICON_BINARY
	name = "Robot Talk"
	desc = "Most human stations support free-use communications protocols and routing hubs for synthetic use."
	colour = "say_quote"
	speech_verb = "states"
	ask_verb = "queries"
	exclaim_verb = "declares"
	key = "b"
	language_flags = LANGUAGE_RESTRICTED | LANGUAGE_HIVEMIND
	var/drone_only

/datum/prototype/language/binary/broadcast(var/mob/living/speaker,var/message,var/speaker_mask)

	if(!speaker.binarycheck())
		return

	if (!message)
		return

	message = say_emphasis(message)

	var/message_start = "<i><span class='game say'>[name], <span class='name'>[speaker.name]</span>"
	var/message_body = "<span class='message'>[speaker.say_quote(message)], \"[message]\"</span></span></i>"

	for (var/mob/M in dead_mob_list)
		if(!istype(M,/mob/new_player) && !istype(M,/mob/living/carbon/brain)) //No meta-evesdropping
			var/message_to_send = "[message_start] ([ghost_follow_link(speaker, M)]) [message_body]"
			if(M.check_mentioned(message) && M.get_preference_toggle(/datum/game_preference_toggle/game/legacy_name_highlight))
				message_to_send = "<font size='3'><b>[message_to_send]</b></font>"
			M.show_message(message_to_send, 2)

	for (var/mob/living/S in living_mob_list)
		if(drone_only && !istype(S,/mob/living/silicon/robot/drone))
			continue
		else if(istype(S , /mob/living/silicon/ai))
			message_start = "<i><span class='game say'>[name], <a href='byond://?src=\ref[S];track2=\ref[S];track=\ref[speaker];trackname=[html_encode(speaker.name)]'><span class='name'>[speaker.name]</span></a></span></i>"
		else if (!S.binarycheck())
			continue

		var/message_to_send = "[message_start] [message_body]"
		if(S.check_mentioned(message) && S.get_preference_toggle(/datum/game_preference_toggle/game/legacy_name_highlight))
			message_to_send = "<font size='3'><b>[message_to_send]</b></font>"
		S.show_message(message_to_send, 2)

	var/list/listening = hearers(1, src)
	listening -= src

	for (var/mob/living/M in listening)
		if(istype(M, /mob/living/silicon) || M.binarycheck())
			continue
		M.show_message("<i><span class='game say'><span class='name'>synthesised voice</span> <span class='message'>beeps, \"beep beep beep\"</span></span></i>",2)

	//robot binary xmitter component power usage
	if (isrobot(speaker))
		var/mob/living/silicon/robot/R = speaker
		var/datum/robot_component/C = R.components["comms"]
		R.cell_use_power(C.active_usage)

/datum/prototype/language/binary/drone
	id = LANGUAGE_ID_DRONE_BINARY
	name = "Drone Talk"
	desc = "A heavily encoded damage control coordination stream."
	speech_verb = "transmits"
	ask_verb = "transmits"
	exclaim_verb = "transmits"
	colour = "say_quote"
	key = "d"
	language_flags = LANGUAGE_RESTRICTED | LANGUAGE_HIVEMIND
	drone_only = 1
