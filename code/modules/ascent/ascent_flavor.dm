//// Some flavor things

/obj/item/disk/ascent
	name = "astronavigational data disk"
	desc = "A complex attomechanical data-storage solution used by the ascent, containing a wealth of information on this Seedship's origin point, stellar journey, and potential landing sites. Automatically updated from the vessel's central processing strata."
	color = COLOR_PURPLE

/obj/item/disk/ascent/queen
	name = "\improper N-dimensional artform disk"
	desc = "An advanced ascent storage pattern containing a replica of multiple well-known pieces of Control Mind datasculpting, taking advantage of the several additional dimensions of space within the Worldnet. Very popular among Gynes and Serpentid Queens. Warning: May cause existential dread, uncontrolled emotional responses, and spontaneous insanity in primitive lifeforms."

//// Natural translator implants

/obj/item/implant/translator/natural/ascent
	origin_tech = list(TECH_BIO = 10)
	learning_threshold = 1
	max_languages = 25

/obj/item/implantcase/ascent
	name = "glass case - 'operative translation device'"
	imp = /obj/item/implant/translator/natural/ascent

/obj/item/storage/box/ascentimplants
	name = "operative translators"
	desc = "Box of stuff used to implant translation software, designed to sync up with the Mantid physiology."
	icon_state = "implant"
	item_state = "syringe_kit"
	startswith = list(/obj/item/implanter/translator = 1,
	                  /obj/item/implantcase/ascent = 12)
