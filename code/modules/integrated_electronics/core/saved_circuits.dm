// Helpers for saving/loading integrated circuits.


// Saves type, modified name and modified inputs (if any) to a list
// The list is converted to JSON down the line.
//"Special" is not verified at any point except for by the circuit itself.
/obj/item/integrated_circuit/proc/save()
	var/list/component_params = list()
	var/init_name = initial(name)

	// Save initial name used for differentiating assemblies
	component_params["type"] = init_name

	// Save the modified name.
	if(init_name != displayed_name)
		component_params["name"] = displayed_name

	// Saving input values
	if(length(inputs))
		var/list/saved_inputs = list()

		for(var/index in 1 to inputs.len)
			var/datum/integrated_io/input = inputs[index]

			// Don't waste space saving the default values
			if(input.data == inputs_default["[index]"])
				continue
			if(input.data == initial(input.data))
				continue

			var/list/input_value = list(index, FALSE, input.data)
			// Index, Type, Value
			// FALSE is default type used for num/text/list/null
			// TODO: support for special input types, such as internal refs and maybe typepaths

			if(islist(input.data) || isnum(input.data) || istext(input.data) || isnull(input.data))
				saved_inputs.Add(list(input_value))

		if(saved_inputs.len)
			component_params["inputs"] = saved_inputs

	var/special = save_special()
	if(!isnull(special))
		component_params["special"] = special

	return component_params

/obj/item/integrated_circuit/proc/save_special()
	return

// Verifies a list of component parameters
// Returns null on success, error name on failure
/obj/item/integrated_circuit/proc/verify_save(list/component_params)
	var/init_name = initial(name)
	// Validate name
	if(component_params["name"] && component_params["name"] != sanitizeSafe(component_params["name"], MAX_MESSAGE_LEN, 0, 0))
		return "Bad component name at [init_name]."

	// Validate input values
	if(component_params["inputs"])
		var/list/loaded_inputs = component_params["inputs"]
		if(!islist(loaded_inputs))
			return "Malformed input values list at [init_name]."

		var/inputs_amt = length(inputs)

		// Too many inputs? Inputs for input-less component? This is not good.
		if(!inputs_amt || inputs_amt < length(loaded_inputs))
			return "Input values list out of bounds at [init_name]."

		for(var/list/input in loaded_inputs)
			if(input.len != 3)
				return "Malformed input data at [init_name]."

			var/input_id = input[1]
			var/input_type = input[2]
			//var/input_value = input[3]

			// No special type support yet.
			if(input_type)
				return "Unidentified input type at [init_name]!"
			// TODO: support for special input types, such as typepaths and internal refs

			// Input ID is a list index, make sure it's sane.
			if(!isnum(input_id) || input_id % 1 || input_id > inputs_amt || input_id < 1)
				return "Invalid input index at [init_name]."


// Loads component parameters from a list
// Doesn't verify any of the parameters it loads, this is the job of verify_save()
/obj/item/integrated_circuit/proc/load(list/component_params)
	// Load name
	if(component_params["name"])
		displayed_name = html_encode(component_params["name"])

	// Load input values
	if(component_params["inputs"])
		var/list/loaded_inputs = component_params["inputs"]

		for(var/list/input in loaded_inputs)
			var/index = input[1]
			//var/input_type = input[2]
			var/input_value = input[3]

			var/datum/integrated_io/pin = inputs[index]
			// The pins themselves validate the data.
			pin.write_data_to_pin(istext(input_value)? html_encode(input_value) : input_value)
			// TODO: support for special input types, such as internal refs and maybe typepaths

	if(!isnull(component_params["special"]))
		load_special(component_params["special"])

/obj/item/integrated_circuit/proc/load_special(special_data)
	return

// Saves type and modified name (if any) to a list
// The list is converted to JSON down the line.
/obj/item/electronic_assembly/proc/save()
	var/list/assembly_params = list()

	// Save initial name used for differentiating assemblies
	if(istype(src, /obj/item/electronic_assembly/clothing))
		var/obj/item/electronic_assembly/clothing/clothingCheck = src
		if(clothingCheck.clothing)
			assembly_params["container"] = initial(clothingCheck.clothing.name)

	assembly_params["type"] = initial(name)

	// Save modified name
	if(initial(name) != name)
		assembly_params["name"] = name

	// Save modified description
	if(initial(desc) != desc)
		assembly_params["desc"] = desc

	// Save modified color
	if(initial(detail_color) != detail_color)
		assembly_params["detail_color"] = detail_color

	return assembly_params


// Verifies a list of assembly parameters
// Returns null on success, error name on failure
/obj/item/electronic_assembly/proc/verify_save(list/assembly_params)
	// Validate name and color
	if(assembly_params["name"] && assembly_params["name"] != sanitizeSafe(assembly_params["name"], MAX_MESSAGE_LEN, 0, 0))
		return "Bad assembly name."
	if(assembly_params["desc"] && !reject_bad_text(assembly_params["desc"]))
		return "Bad assembly description."
	if(assembly_params["detail_color"] && !reject_bad_text(assembly_params["detail_color"], 7))
		return "Bad assembly color."

// Loads assembly parameters from a list
// Doesn't verify any of the parameters it loads, this is the job of verify_save()
/obj/item/electronic_assembly/proc/load(list/assembly_params)
	// Load modified name, if any.
	if(assembly_params["name"])
		name = html_encode(assembly_params["name"])

	// Load modified description, if any.
	if(assembly_params["desc"])
		desc = html_encode(assembly_params["desc"])

	if(assembly_params["detail_color"])
		detail_color = assembly_params["detail_color"]

	update_icon()

// Attempts to save an assembly into a save file format.
// Returns null if assembly is not complete enough to be saved.
/datum/controller/subsystem/processing/circuit/proc/save_electronic_assembly(obj/item/electronic_assembly/assembly)
	// No components? Don't even try to save it.
	if(!length(assembly.assembly_components))
		return


	var/list/blocks = list()

	// Block 1.  Assembly.
	blocks["assembly"] = assembly.save()
	// (implant assemblies are not yet supported)


	// Block 2.  Components.
	var/list/components = list()
	for(var/c in assembly.assembly_components)
		var/obj/item/integrated_circuit/component = c
		components.Add(list(component.save()))
	blocks["components"] = components


	// Block 3.  Wires.
	var/list/wires = list()
	var/list/saved_wires = list()

	for(var/c in assembly.assembly_components)
		var/obj/item/integrated_circuit/component = c
		var/list/all_pins = component.inputs + component.outputs + component.activators

		for(var/p in all_pins)
			var/datum/integrated_io/pin = p
			var/list/params = pin.get_pin_parameters()
			var/text_params = params.Join()

			for(var/p2 in pin.linked)
				var/datum/integrated_io/pin2 = p2
				var/list/params2 = pin2.get_pin_parameters()
				var/text_params2 = params2.Join()

				// Check if we already saved an opposite version of this wire
				// (do not save the same wire twice)
				if((text_params2 + "=" + text_params) in saved_wires)
					continue

				// If not, add a wire "hash" for future checks and save it
				saved_wires.Add(text_params + "=" + text_params2)
				wires.Add(list(list(params, params2)))

	if(wires.len)
		blocks["wires"] = wires

	return json_encode(blocks)



// Checks assembly save and calculates some of the parameters.
// Returns assembly (type: list) if the save is valid.
// Returns error code (type: text) if loading has failed.
// The following parameters area calculated during validation and added to the returned save list:
// "requires_upgrades", "unsupported_circuit", "metal_cost", "complexity", "max_complexity", "used_space", "max_space"
/datum/controller/subsystem/processing/circuit/proc/validate_electronic_assembly(program)
	var/list/blocks = json_decode(program)
	if(!blocks)
		return

	var/error


	// Block 1.  Assembly.
	var/list/assembly_params = blocks["assembly"]

	if(!islist(assembly_params) || !length(assembly_params))
		return "Invalid assembly data."	// No assembly, damaged assembly or empty assembly

	// Validate any possible container.
	// Minor note that the only other containers for assemblies are clothing at the moment; this type should be changed if that changes.
	var/obj/item/clothing/possible_container
	if(assembly_params["container"])
		var/container_path = all_assemblies[assembly_params["container"]]
		possible_container = cached_assemblies[container_path]
		if(!possible_container)
			return "Invalid container type."

	// Validate type, get a temporary component
	var/assembly_path = all_assemblies[assembly_params["type"]]
	var/obj/item/electronic_assembly/assembly = cached_assemblies[assembly_path]
	if(!assembly)
		return "Invalid assembly type: \"[assembly_params["type"]]\"."

	// Make sure the container is supposed to have that type of assembly.
	if(possible_container)
		if(possible_container.EA.type != assembly.type)
			return "Invalid assembly in container."

	// Check assembly save data for errors
	error = assembly.verify_save(assembly_params)
	if(error)
		return error


	// Read space & complexity limits and start keeping track of them
	blocks["complexity"] = 0
	blocks["max_complexity"] = assembly.max_complexity
	blocks["used_space"] = 0
	blocks["max_space"] = assembly.max_components

	// Start keeping track of total metal cost
	blocks["metal_cost"] = assembly.cost


	// Block 2.  Components.
	if(!islist(blocks["components"]) || !length(blocks["components"]))
		return "Invalid components list."	// No components or damaged components list

	var/list/assembly_components = list()
	for(var/C in blocks["components"])
		var/list/component_params = C

		if(!islist(component_params) || !length(component_params))
			return "Invalid component data."

		// Validate type, get a temporary component
		var/component_path = all_components[component_params["type"]]
		var/obj/item/integrated_circuit/component = cached_components[component_path]
		if(!component)
			return "Invalid component type: \"[component_params["type"]]\"."

		// Add temporary component to assembly_components list, to be used later when verifying the wires
		assembly_components.Add(component)

		// Check component save data for errors
		error = component.verify_save(component_params)
		if(error)
			return error

		// Update estimated assembly complexity, taken space and material cost
		blocks["complexity"] += component.complexity
		blocks["used_space"] += component.size
		blocks["metal_cost"] += component.w_class

		// Check if the assembly requires printer upgrades
		if(!(component.spawn_flags & IC_SPAWN_DEFAULT))
			// We don't actually care about built in components.
			if(component.removable)
				blocks["requires_upgrades"] = TRUE

		// Check if the assembly supports the circucit
		if((component.action_flags & assembly.allowed_circuit_action_flags) != component.action_flags)
			blocks["unsupported_circuit"] = TRUE


	// Check complexity and space limitations
	if(blocks["used_space"] > blocks["max_space"])
		return "Used space overflow."
	if(blocks["complexity"] > blocks["max_complexity"])
		return "Complexity overflow."


	// Block 3.  Wires.
	if(blocks["wires"])
		if(!islist(blocks["wires"]))
			return "Invalid wiring list."	// Damaged wires list

		for(var/w in blocks["wires"])
			var/list/wire = w

			if(!islist(wire) || wire.len != 2)
				return "Invalid wire data."

			var/datum/integrated_io/IO = assembly.get_pin_ref_list(wire[1], assembly_components)
			var/datum/integrated_io/IO2 = assembly.get_pin_ref_list(wire[2], assembly_components)
			if(!IO || !IO2)
				return "Invalid wire data."

			if(initial(IO.io_type) != initial(IO2.io_type))
				return "Wire type mismatch."

	return blocks


// Loads assembly (in form of list) into an object and returns it.
// No sanity checks are performed, save file is expected to be validated by validate_electronic_assembly
/datum/controller/subsystem/processing/circuit/proc/load_electronic_assembly(loc, list/blocks)

	// Block 1.  Assembly.
	var/list/assembly_params = blocks["assembly"]
	var/obj/item/electronic_assembly/assembly
	var/obj/item/clothing/clothing
	if(assembly_params["container"])
		var/obj/item/clothing/clothing_path = all_assemblies[assembly_params["container"]]
		clothing = new clothing_path(null)
		if(clothing.EA)
			assembly = clothing.EA
	else
		var/obj/item/electronic_assembly/assembly_path = all_assemblies[assembly_params["type"]]
		assembly = new assembly_path(null)
	assembly.load(assembly_params)



	// Block 2.  Components.
	for(var/component_params in blocks["components"])
		var/obj/item/integrated_circuit/component_path = all_components[component_params["type"]]
		if(!initial(component_path.removable))
			continue
		var/obj/item/integrated_circuit/component = new component_path(assembly)
		component.load(component_params)
		assembly.add_component(component)


	// Block 3.  Wires.
	if(blocks["wires"])
		for(var/w in blocks["wires"])
			var/list/wire = w
			var/datum/integrated_io/IO = assembly.get_pin_ref_list(wire[1])
			var/datum/integrated_io/IO2 = assembly.get_pin_ref_list(wire[2])
			IO.connect_pin(IO2)

	if(clothing)
		clothing.forceMove(loc)
	else
		assembly.forceMove(loc)
	return assembly
