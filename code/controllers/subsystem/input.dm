SUBSYSTEM_DEF(input)
	name = "Input"
	wait = 0.25 // scale to 40 fps
	init_order = INIT_ORDER_INPUT
	init_stage = INIT_STAGE_EARLY
	priority = FIRE_PRIORITY_INPUT
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY

	/// Classic mode input focused macro set. Manually set because we can't define ANY or ANY+UP for classic.
	var/static/list/macroset_classic_input
	/// Classic mode map focused macro set. Manually set because it needs to be clientside and go to macroset_classic_input.
	var/static/list/macroset_classic_hotkey
	/// New hotkey mode macro set. All input goes into map, game keeps incessently setting your focus to map, we can use ANY all we want here; we don't care about the input bar, the user has to force the input bar every time they want to type.
	var/static/list/macroset_hotkey

	/// Macro set for hotkeys
	var/list/hotkey_mode_macros
	/// Macro set for classic.
	var/list/input_mode_macros

	/// currentrun list of clients
	var/list/client/currentrun

/datum/controller/subsystem/input/Initialize()
	setup_macrosets()
	refresh_client_macro_sets()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/input/Recover()
	setup_macrosets()
	refresh_client_macro_sets()
	initialized = SSinput.initialized

/// Sets up the key list for classic mode for when badmins screw up vv's.
/datum/controller/subsystem/input/proc/setup_macrosets()
	// First, let's do the snowflake keyset!
	macroset_classic_input = list()
	var/list/classic_mode_keys = list(
		"North", "East", "South", "West",
		"Northeast", "Southeast", "Northwest", "Southwest",
		"Insert", "Delete", "Ctrl", "Alt", "Shift",
		/* REMOVED - Keep these out unless control freak is enabled. "F1", "F2",*/ "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",
		)
	for(var/key in classic_mode_keys)
		macroset_classic_input[key] = "\"KeyDown [key]\""
		macroset_classic_input["[key]+UP"] = "\"KeyUp [key]\""
	// LET'S PLAY THE BIND EVERY KEY GAME!
	// oh except for Backspace and Enter; if you want to use those you shouldn't have used oldmode!
	var/list/classic_ctrl_override_keys = list(
	"\[", "\]", "\\\\", ";", "'", ",", ".", "/", "-", "=", "`"
	)
	// i'm lazy let's play the list iteration game of numbers
	for(var/i in 0 to 9)
		classic_ctrl_override_keys += "[i]"
	// let's play the ascii game of A to Z (UPPERCASE)
	for(var/i in 65 to 90)
		classic_ctrl_override_keys += ascii2text(i)
	// let's play the list iteration game x2
	for(var/key in classic_ctrl_override_keys)
		// make sure to double double quote to ensure things are treated as a key combo instead of addition/semicolon logic.
		macroset_classic_input["\"Ctrl+[key]\""] = "\"KeyDown [istext(classic_ctrl_override_keys[key])? classic_ctrl_override_keys[key] : key]\""
		macroset_classic_input["\"Ctrl+[key]+UP\""] = "\"KeyUp [istext(classic_ctrl_override_keys[key])? classic_ctrl_override_keys[key] : key]\""
	// Misc
	macroset_classic_input["Tab"] = "\".winset \\\"mainwindow.macro=[SKIN_MACROSET_CLASSIC_HOTKEYS] map.focus=true input.background-color=[COLOR_INPUT_DISABLED]\\\"\""
	macroset_classic_input["Escape"] = "\".winset \\\"input.text=\\\"\\\"\\\"\""
	// These are required unless control freak is enabled.
	macroset_classic_input["F1"] = "adminhelp"
	macroset_classic_input["F2"] = "ooc"

	// FINALLY, WE CAN DO SOMETHING MORE NORMAL FOR THE SNOWFLAKE-BUT-LESS KEYSET.

	// HAHA - SIKE. Because of BYOND weirdness (tl;dr not specifically binding this way results in potentially duplicate chatboxes when
	//  conflicts occur with something like say indicator vs say), we're going to snowflake this anyways
	var/list/hard_bind_anti_collision = list()
	var/list/anti_collision_modifiers = list("Ctrl", "Alt", "Shift", "Ctrl+Alt", "Ctrl+Shift", "Alt+Shift", "Ctrl+Alt+Shift")
	for(var/key in list("T", "O", "M"))
		for(var/modifier in anti_collision_modifiers)
			hard_bind_anti_collision["[modifier]+[key]"] = ".NONSENSICAL_VERB_THAT_DOES_NOTHING"

	macroset_classic_hotkey = list(
	"Any" = "\"KeyDown \[\[*\]\]\"",
	"Any+UP" = "\"KeyUp \[\[*\]\]\"",
	"Tab" = "\".winset \\\"mainwindow.macro=[SKIN_MACROSET_CLASSIC_INPUT] input.focus=true input.background-color=[COLOR_INPUT_ENABLED]\\\"\"",
	"Escape" = "\".winset \\\"input.text=\\\"\\\"\\\"\"",
	"Back" = "\".winset \\\"input.text=\\\"\\\"\\\"\"",
	"F1" = "adminhelp",
	"F2" = "ooc",
	)

	macroset_classic_hotkey |= hard_bind_anti_collision

	// And finally, the modern set.
	macroset_hotkey = list(
	"Any" = "\"KeyDown \[\[*\]\]\"",
	"Any+UP" = "\"KeyUp \[\[*\]\]\"",
	"Tab" = "\".winset \\\"input.focus=true?map.focus=true input.background-color=[COLOR_INPUT_DISABLED]:input.focus=true input.background-color=[COLOR_INPUT_ENABLED]\\\"\"",
	"Escape" = "\".winset \\\"input.text=\\\"\\\"\\\"\"",
	"Back" = "\".winset \\\"input.text=\\\"\\\"\\\"\"",
	"F1" = "adminhelp",
	"F2" = "ooc",
	)

	macroset_hotkey |= hard_bind_anti_collision

// Badmins just wanna have fun ♪
/datum/controller/subsystem/input/proc/refresh_client_macro_sets()
	for(var/client/user as anything in GLOB.clients)
		if(!user.initialized)
			continue
		user.set_macros()
		user.update_movement_keys()

/datum/controller/subsystem/input/fire(resumed)
	if(!resumed)
		currentrun = GLOB.clients.Copy()
	var/i
	for(i in length(currentrun) to 1 step -1)
		var/client/C = currentrun[i]
		if(!C.initialized)
			continue
		C.keyLoop()
		if(MC_TICK_CHECK)
			break
	currentrun.len -= length(currentrun) - i + 1

/// *sigh
/client/verb/NONSENSICAL_VERB_THAT_DOES_NOTHING()
	set name = ".NONSENSICAL_VERB_THAT_DOES_NOTHING"
	set hidden = TRUE
