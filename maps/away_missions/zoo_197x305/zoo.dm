//TODO: This map is a relic of a bygone age (Vorecode). It has a few broken mobs and is too big for our current map system. But it'd be really cool to have.

/datum/map/gateway/zoo_197x305
	id = "zoo_197x305"
	name = "Gateway - Zoo"
	width = 197
	height = 305
	levels = list(
		/datum/map_level/gateway/zoo_197x305,
	)

/datum/map_level/gateway/zoo_197x305
	id = "Zoo197x305"
	name = "Gateway - Zoo"
	display_name = "Zoo"
	path = "maps/away_missions/zoo_197x305/levels/zoo.dmm"
	base_turf = /turf/space
	base_area = /area/space


// -- Areas -- //

/area/awaymission/zoo
	icon_state = "green"
	requires_power = 0
	dynamic_lighting = 0
	ambience = list('sound/ambience/ambispace.ogg','sound/music/title2.ogg','sound/music/space.ogg','sound/music/main.ogg','sound/music/traitor.ogg')

/area/awaymission/zoo/solars
	icon_state = "yellow"

/area/awaymission/zoo/tradeship
	icon_state = "purple"

/area/awaymission/zoo/syndieship
	icon_state = "red"

/area/awaymission/zoo/pirateship
	icon_state = "bluenew"

/obj/item/paper/zoo
	name = "\improper Quarterly Report"
	info = {"<i>There's nothing but spreadsheets and budget reports on this document, apparently regarding a zoo owned by Nanotrasen.</i>"}

/obj/item/paper/zoo/pirate
	name = "odd note"

/obj/item/paper/zoo/pirate/volk
	info = {"Lady Nebula,<br><br>We can't keep these animals here permanently. We're running out of food and they're getting hungry.
			Ma'isi went missing last night when we sent her to clean up the petting zoo. This morning, we found Tajaran hair in the
			horse shit. I can't speak for everyone, but I'm out. If these animals break loose, we're all fucking dead. Please get
			some extra rations of meat before the carnivores realize the electrified grilles don't work right now.<br><br>-Volk"}

/obj/item/paper/zoo/pirate/nebula
	info = {"Volk,<br><br>Throw some prisoners into the cages, then. The client took too long to pay up anyway.<br><br>-Lady Nebula"}

/obj/item/paper/zoo/pirate/haveyouseen
	info = {"Has anyone seen Za'med? I sent him to get something out of the tool shed and he hasn't come back.<br><br>-Meesei"}

/obj/item/paper/zoo/pirate/warning
	info = {"Attention crew,<br><br>Since apparently you fucking idiots didn't notice, that bulltaur who delivered the bears was
			Jarome Rognvaldr. I'm sorry, maybe you scabs forgot? Does the name Jarome the Bottomless ring any fucking bells? If he's
			seen again without a laser bolt hole through his fucking skull, I'm shoving anyone on guard duty up Zed's arse. Are we
			clear?<br><br>-Lady Nebula"}

// Fluff for exotic Z-levels that need power.

/obj/machinery/power/fractal_reactor/fluff/smes
	name = "power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit. The controls are locked."
	icon_state = "smes"

/obj/machinery/power/fractal_reactor/fluff/converter
	name = "power converter"
	desc = "A heavy duty power converter which allows the ship's engines to generate its power supply."
	icon_state = "bbox_on"
