//! dear god burn this file with fire !//

/* Most medication reactions, and their precursors */

//Standard First Aid Medication

/datum/chemical_reaction/carthatoline
	//heals toxin
	name = "Carthatoline"
	id = "carthatoline"
	result = "carthatoline"
	required_reagents = list("anti_toxin" = 1, MAT_CARBON = 2, MAT_PHORON = 0.1)
	catalysts = list(MAT_PHORON = 1)
	result_amount = 2

/datum/chemical_reaction/bicaridine
	//heals brute
	name = "Bicaridine"
	id = "bicaridine"
	result = "bicaridine"
	required_reagents = list("inaprovaline" = 1, MAT_CARBON = 1)
	inhibitors = list("sugar" = 1) // Messes up with inaprovaline
	result_amount = 2

/datum/chemical_reaction/vermicetol
	//heals brute
	name = "Vermicetol"
	id = "vermicetol"
	result = "vermicetol"
	required_reagents = list("bicaridine" = 2, "shockchem" = 1, MAT_PHORON = 0.1)
	catalysts = list(MAT_PHORON = 5)
	result_amount = 3

/datum/chemical_reaction/kelotane
	//Heals burns
	name = "Kelotane"
	id = "kelotane"
	result = "kelotane"
	required_reagents = list("silicon" = 1, MAT_CARBON = 1)
	result_amount = 2

/datum/chemical_reaction/dermaline
	//Heals burns
	name = "Dermaline"
	id = "dermaline"
	result = "dermaline"
	required_reagents = list("oxygen" = 1, "phosphorus" = 1, "kelotane" = 1)
	result_amount = 3

/datum/chemical_reaction/dexalin
	//fixes oxyloss
	name = "Dexalin"
	id = "dexalin"
	result = "dexalin"
	required_reagents = list("oxygen" = 2, MAT_PHORON = 0.1)
	catalysts = list(MAT_PHORON = 1)
	inhibitors = list("water" = 1) // Messes with cryox
	result_amount = 1


/datum/chemical_reaction/dexalinp
	//fixes Oxyloss
	name = "Dexalin Plus"
	id = "dexalinp"
	result = "dexalinp"
	required_reagents = list("dexalin" = 1, MAT_CARBON = 1, MAT_IRON = 1)
	result_amount = 3

//Painkiller

/datum/chemical_reaction/paracetamol
	name = "Paracetamol"
	id = "paracetamol"
	result = "paracetamol"
	required_reagents = list("inaprovaline" = 1, "nitrogen" = 1, "water" = 1)
	result_amount = 2

/datum/chemical_reaction/tramadol
	name = "Tramadol"
	id = "tramadol"
	result = "tramadol"
	required_reagents = list("paracetamol" = 1, "ethanol" = 1, "oxygen" = 1)
	result_amount = 3

/datum/chemical_reaction/oxycodone
	name = "Oxycodone"
	id = "oxycodone"
	result = "oxycodone"
	required_reagents = list("ethanol" = 1, "tramadol" = 1)
	catalysts = list(MAT_PHORON = 5)
	result_amount = 1

//Radiation Treatment

/datum/chemical_reaction/hyronalin
	//Calm radiation treatment
	name = "Hyronalin"
	id = "hyronalin"
	result = "hyronalin"
	required_reagents = list("radium" = 1, "anti_toxin" = 1)
	result_amount = 2

/datum/chemical_reaction/arithrazine
	//Angry radiation treatment
	name = "Arithrazine"
	id = "arithrazine"
	result = "arithrazine"
	required_reagents = list("hyronalin" = 1, "hydrogen" = 1)
	result_amount = 2

//The Daxon Family

/datum/chemical_reaction/nanoperidaxon
	//Heals ALL organs
	name = "Nano-Peridaxon"
	id = "nanoperidaxon"
	result = "nanoperidaxon"
	priority = 100
	required_reagents = list("peridaxon" = 2, "nifrepairnanites" = 2)
	result_amount = 2

/datum/chemical_reaction/osteodaxon
	//Heals bone fractures
	name = "Osteodaxon"
	id = "osteodaxon"
	result = "osteodaxon"
	priority = 100
	required_reagents = list("bicaridine" = 2, MAT_PHORON = 0.1, "carpotoxin" = 1)
	catalysts = list(MAT_PHORON = 5)
	inhibitors = list("clonexadone" = 1) // Messes with cryox
	result_amount = 2

/datum/chemical_reaction/respirodaxon
	//heals lungs
	name = "Respirodaxon"
	id = "respirodaxon"
	result = "respirodaxon"
	priority = 100
	required_reagents = list("dexalinp" = 2, "biomass" = 2, MAT_PHORON = 1)
	catalysts = list(MAT_PHORON = 5)
	inhibitors = list("dexalin" = 1)
	result_amount = 2

/datum/chemical_reaction/gastirodaxon
	//Heals stomach
	name = "Gastirodaxon"
	id = "gastirodaxon"
	result = "gastirodaxon"
	priority = 100
	required_reagents = list("carthatoline" = 1, "biomass" = 2, "tungsten" = 2)
	catalysts = list(MAT_PHORON = 5)
	inhibitors = list("lithium" = 1)
	result_amount = 3

/datum/chemical_reaction/hepanephrodaxon
	//heals liver and kidneys(or species equivalent)
	name = "Hepanephrodaxon"
	id = "hepanephrodaxon"
	result = "hepanephrodaxon"
	priority = 100
	required_reagents = list("carthatoline" = 2, "biomass" = 2, "lithium" = 1)
	catalysts = list(MAT_PHORON = 5)
	inhibitors = list("tungsten" = 1)
	result_amount = 2

/datum/chemical_reaction/cordradaxon
	//Heals Heart(or species equilvalent)
	name = "Cordradaxon"
	id = "cordradaxon"
	result = "cordradaxon"
	priority = 100
	required_reagents = list("potassium_chlorophoride" = 1, "biomass" = 2, "bicaridine" = 2)
	catalysts = list(MAT_PHORON = 5)
	inhibitors = list("clonexadone" = 1)
	result_amount = 2

//Psych Drugs and hallucination Treatment

/datum/chemical_reaction/nicotine
	name = "Nicotine"
	id = "nicotine"
	result = "nicotine"
	required_reagents = list("carbon" = 1, "oxygen" = 1, "sulfur" = 1)
	result_amount = 3

/datum/chemical_reaction/synaptizine
	name = "Synaptizine"
	id = "synaptizine"
	result = "synaptizine"
	required_reagents = list("sugar" = 1, "lithium" = 1, "water" = 1)
	result_amount = 3

/datum/chemical_reaction/methylphenidate
	name = "Methylphenidate"
	id = "methylphenidate"
	result = "methylphenidate"
	required_reagents = list("mindbreaker" = 1, "hydrogen" = 1)
	result_amount = 3

/datum/chemical_reaction/citalopram
	name = "Citalopram"
	id = "citalopram"
	result = "citalopram"
	required_reagents = list("mindbreaker" = 1, MAT_CARBON = 1)
	result_amount = 3

/datum/chemical_reaction/paroxetine
	//Gives you the strength to fight on
	name = "Paroxetine"
	id = "paroxetine"
	result = "paroxetine"
	required_reagents = list("mindbreaker" = 1, "oxygen" = 1, "inaprovaline" = 1)
	result_amount = 3

//Advanced Healing

/datum/chemical_reaction/alkysine
	//Heals brain damage
	name = "Alkysine"
	id = "alkysine"
	result = "alkysine"
	required_reagents = list("chlorine" = 1, "nitrogen" = 1, "anti_toxin" = 1)
	result_amount = 2


/datum/chemical_reaction/myelamine
	//Heals internal bleeding
	name = "Myelamine"
	id = "myelamine"
	result = "myelamine"
	required_reagents = list("bicaridine" = 1, "calcium" = 2, "spidertoxin" = 1)
	result_amount = 2

/datum/chemical_reaction/imidazoline
	//Heals the eyes and fixes blindness
	name = "imidazoline"
	id = "imidazoline"
	result = "imidazoline"
	required_reagents = list(MAT_CARBON = 1, "hydrogen" = 1, "anti_toxin" = 1)
	result_amount = 2

/datum/chemical_reaction/rezadone
	//Heals clone(20), oxyloss(2), brute,burn&toxin(20) more than 3 units diefigure the patient
	name = "Rezadone"
	id = "rezadone"
	result = "rezadone"
	required_reagents = list("carpotoxin" = 1, "cryptobiolin" = 1, MAT_COPPER = 1)
	result_amount = 3

/datum/chemical_reaction/ryetalyn
	//Fixes disabilities(those caused by mutations)
	name = "Ryetalyn"
	id = "ryetalyn"
	result = "ryetalyn"
	required_reagents = list("arithrazine" = 1, MAT_CARBON = 1)
	result_amount = 2

//Immunsystem (Anti-)Boosters
/datum/chemical_reaction/spaceacillin
	//simple antibiotic, no mentionable side effects
	name = "Spaceacillin"
	id = "spaceacillin"
	result = "spaceacillin"
	required_reagents = list("cryptobiolin" = 1, "inaprovaline" = 1)
	result_amount = 2

/datum/chemical_reaction/corophizine
	//sehr potentes antibiotic, has a low chance to break bones
	name = "Corophizine"
	id = "corophizine"
	result = "corophizine"
	required_reagents = list("spaceacillin" = 1, MAT_CARBON = 1, MAT_PHORON = 0.1)
	catalysts = list(MAT_PHORON = 5)
	result_amount = 2

/datum/chemical_reaction/immunosuprizine
	//Very toxic substance that prevents Organ rejection after transplanation, not sure why we still need this //Adopted for CRS(Cyberpsychosis) meds.
	name = "Immunosuprizine"
	id = "immunosuprizine"
	result = "immunosuprizine"
	required_reagents = list("corophizine" = 1, "tungsten" = 1, "sacid" = 1)
	catalysts = list(MAT_PHORON = 5)
	result_amount = 2


//Cryo meds

/datum/chemical_reaction/cryoxadone
	//The starter Cryo med, heals all four standard Damages
	name = "Cryoxadone"
	id = "cryoxadone"
	result = "cryoxadone"
	required_reagents = list("dexalin" = 1, "water" = 1, "oxygen" = 1)
	result_amount = 3

/datum/chemical_reaction/clonexadone
	//The advanced Cryo med, same as Cryox but 3 times as potent
	name = "Clonexadone"
	id = "clonexadone"
	result = "clonexadone"
	required_reagents = list("cryoxadone" = 1, "sodium" = 1, MAT_PHORON = 0.1)
	catalysts = list(MAT_PHORON = 5)
	result_amount = 2

/datum/chemical_reaction/leporazine
	//not directly a Cryocell medication but help thawn the patient afterwards
	name = "Leporazine"
	id = "leporazine"
	result = "leporazine"
	required_reagents = list("silicon" = 1, MAT_COPPER = 1)
	catalysts = list(MAT_PHORON = 5)
	result_amount = 2

//Utility chems that are precursors, or have no direct healing properties of their own, but should be found in a medical environment
/datum/chemical_reaction/sterilizine
	name = "Sterilizine"
	id = "sterilizine"
	result = "sterilizine"
	required_reagents = list("ethanol" = 1, "anti_toxin" = 1, "chlorine" = 1)
	result_amount = 3

/datum/chemical_reaction/virus_food
	name = "Virus Food"
	id = "virusfood"
	result = "virusfood"
	required_reagents = list("water" = 1, "milk" = 1, "sugar" = 1)
	result_amount = 5

/datum/chemical_reaction/cryptobiolin
	//Precursor for spaceacillin
	name = "Cryptobiolin"
	id = "cryptobiolin"
	result = "cryptobiolin"
	required_reagents = list("potassium" = 1, "oxygen" = 1, "sugar" = 1)
	result_amount = 3

/datum/chemical_reaction/ethylredoxrazine
	//Helps with alcohol in the blood stream
	name = "Ethylredoxrazine"
	id = "ethylredoxrazine"
	result = "ethylredoxrazine"
	required_reagents = list("oxygen" = 1, "anti_toxin" = 1, MAT_CARBON = 1)
	result_amount = 3

/datum/chemical_reaction/calciumcarbonate
	//prevents people from throwing up
	name = "Calcium Carbonate"
	id = "calciumcarbonate"
	result = "calciumcarbonate"
	required_reagents = list("oxygen" = 3, "calcium" = 1, MAT_CARBON = 1)
	result_amount = 2

/datum/chemical_reaction/soporific
	//Sedative to make people sleepy and keep the sleeping
	name = "Soporific"
	id = "stoxin"
	result = "stoxin"
	required_reagents = list("chloralhydrate" = 1, "sugar" = 4)
	inhibitors = list("phosphorus") // Messes with the smoke
	result_amount = 5

/datum/chemical_reaction/chloralhydrate
	//OD is very toxic, otherwise sedative like soporific
	name = "Chloral Hydrate"
	id = "chloralhydrate"
	result = "chloralhydrate"
	required_reagents = list("ethanol" = 1, "chlorine" = 3, "water" = 1)
	result_amount = 1

/datum/chemical_reaction/lipozine
	//Reduces Nutrients in the patient
	name = "Lipozine"
	id = "Lipozine"
	result = "lipozine"
	required_reagents = list("sodiumchloride" = 1, "ethanol" = 1, "radium" = 1)
	result_amount = 3

/datum/chemical_reaction/adranol
	//Helps with blurry vision, jitters, and confusion
	name = "Adranol"
	id = "adranol"
	result = "adranol"
	required_reagents = list("milk" = 2, "hydrogen" = 1, "potassium" = 1)
	result_amount = 3

/datum/chemical_reaction/biomass
	// Biomass, for cloning and bioprinters
	name = "Biomass"
	id = "biomass"
	result = "biomass"
	required_reagents = list("protein" = 1, "sugar" = 1, MAT_PHORON = 1)
	result_amount = 6	// Roughly 120u per phoron sheet


//Boosters

/datum/chemical_reaction/hyperzine
	//the Proper booster, no direct damage caused by it
	name = "Hyperzine"
	id = "hyperzine"
	result = "hyperzine"
	required_reagents = list("sugar" = 1, "phosphorus" = 1, "sulfur" = 1)
	result_amount = 3

/datum/chemical_reaction/stimm
	//The makeshift booster, inherently toxic
	name = "Stimm"
	id = "stimm"
	result = "stimm"
	required_reagents = list("left4zed" = 1, "fuel" = 1)
	catalysts = list("fuel" = 5)
	result_amount = 2


//Skrellian meds, because we have so many skrells running around.

/datum/chemical_reaction/talum_quem
	name = "Talum-quem"
	id = "talum_quem"
	result = "talum_quem"
	required_reagents = list("space_drugs" = 2, "sugar" = 1, "amatoxin" = 1)
	result_amount = 4

/datum/chemical_reaction/qerr_quem
	name = "Qerr-quem"
	id = "qerr_quem"
	result = "qerr_quem"
	required_reagents = list("nicotine" = 1, MAT_CARBON = 1, "sugar" = 2)
	result_amount = 4

/datum/chemical_reaction/malish_qualem
	name = "Malish-Qualem"
	id = "malish-qualem"
	result = "malish-qualem"
	required_reagents = list("immunosuprizine" = 1, "qerr_quem" = 1, "inaprovaline" = 1)
	catalysts = list(MAT_PHORON = 5)
	result_amount = 2

//Vore - Medication
/datum/chemical_reaction/ickypak
	name = "Ickypak"
	id = "ickypak"
	result = "ickypak"
	required_reagents = list("hyperzine" = 4, "fluorosurfactant" = 1)
	result_amount = 5

/datum/chemical_reaction/unsorbitol
	name = "Unsorbitol"
	id = "unsorbitol"
	result = "unsorbitol"
	required_reagents = list("mutagen" = 3, "lipozine" = 2)
	result_amount = 5

/datum/chemical_reaction/neuratrextate
	name = "Neuratrextate"
	id = "neuratrextate"
	result = "neuratrextate"
	required_reagents = list("immunosuprizine" = 3, "synaptizine" = 2)
	result_amount = 5
