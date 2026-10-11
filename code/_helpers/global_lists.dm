//Since it didn't really belong in any other category, I'm putting this here
//This is for procs to replace all the goddamn 'in world's that are chilling around the code

/// All /obj/structure/cable, managed by instances
GLOBAL_LIST_EMPTY(cable_list)

/// All medical side effects
GLOBAL_LIST_EMPTY(side_effects)

/// All character setup mannequins
GLOBAL_LIST_EMPTY(mannequins)

var/global/list/landmarks_list = list()				//list of all landmarks created

#define all_genders_define_list list(MALE,FEMALE,PLURAL,NEUTER)
#define all_genders_text_list list("Male","Female","Plural","Neuter")

//Languages/species/whitelist.

var/global/list/datum/language/all_languages = list()
var/global/list/language_keys = list()					// Table of say codes for all languages

GLOBAL_LIST_EMPTY(all_particles)

// Grabs
var/global/list/all_grabstates = list()
var/global/list/all_grabobjects = list()

// Uplinks
var/global/list/obj/item/device/uplink/world_uplinks = list()

//Preferences stuff
//Hairstyles
GLOBAL_LIST_EMPTY(hair_styles_list)        //stores /datum/sprite_accessory/hair indexed by name
GLOBAL_LIST_EMPTY(facial_hair_styles_list) //stores /datum/sprite_accessory/facial_hair indexed by name

var/global/list/skin_styles_female_list = list()		//unused
GLOBAL_LIST_EMPTY(body_marking_styles_list)		//stores /datum/sprite_accessory/marking indexed by name
GLOBAL_LIST_EMPTY(mutant_tail_styles_list)		//stores /datum/sprite_accessory/mutant/tail indexed by name
GLOBAL_LIST_EMPTY(mutant_horn_styles_list)		//stores /datum/sprite_accessory/mutant/horns indexed by name
GLOBAL_LIST_EMPTY(mutant_frill_styles_list)		//stores /datum/sprite_accessory/mutant/frills indexed by name
GLOBAL_LIST_EMPTY(mutant_spine_styles_list)		//stores /datum/sprite_accessory/mutant/spines indexed by name
GLOBAL_LIST_EMPTY(mutant_ear_styles_list)		//stores /datum/sprite_accessory/mutant/ears indexed by name
GLOBAL_LIST_EMPTY(mutant_xenodorsal_styles_list)		//stores /datum/sprite_accessory/mutant/xenodorsal indexed by name
GLOBAL_LIST_EMPTY(mutant_xenohead_styles_list)		//stores /datum/sprite_accessory/mutant/xenohead indexed by name
GLOBAL_LIST_EMPTY(mutant_wing_styles_list)		//stores /datum/sprite_accessory/mutant/wings indexed by name
GLOBAL_LIST_EMPTY(mutant_snout_styles_list)		//stores /datum/sprite_accessory/mutant/snout indexed by name
GLOBAL_LIST_EMPTY(mutant_moth_antennae_styles_list)		//stores /datum/sprite_accessory/mutant/moth_antennae indexed by name
GLOBAL_LIST_EMPTY(mutant_fluff_styles_list)		//stores /datum/sprite_accessory/mutant/fluff indexed by name
GLOBAL_LIST_EMPTY(mutant_breast_styles_list)		//stores /datum/sprite_accessory/mutant/breasts indexed by name
GLOBAL_LIST_EMPTY(mutant_penis_styles_list)		//stores /datum/sprite_accessory/mutant/penis indexed by name
GLOBAL_LIST_EMPTY(mutant_testicles_styles_list)		//stores /datum/sprite_accessory/mutant/testicles indexed by name
GLOBAL_LIST_EMPTY(mutant_vagina_styles_list)		//stores /datum/sprite_accessory/mutant/vagina indexed by name
GLOBAL_LIST_AS(marking_limb_slots, list(BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG, BP_L_HAND, BP_R_HAND, BP_L_FOOT, BP_R_FOOT, BP_CHEST, BP_HEAD, BP_GROIN))

GLOBAL_TYPED_NEW(underwear, /datum/category_collection/underwear)

// Visual nets
var/global/list/datum/visualnet/visual_nets = list()
var/global/datum/visualnet/camera/cameranet = new()

// Runes
var/global/list/rune_list = new()
var/global/list/endgame_exits = list()
var/global/list/endgame_safespawns = list()

var/global/list/syndicate_access = list(access_maint_tunnels, access_syndicate, access_external_airlocks)

// Strings which corraspond to bodypart covering flags, useful for outputting what something covers.
var/global/list/string_part_flags = list(
	"head" = HEAD,
	"face" = FACE,
	"eyes" = EYES,
	"upper body" = UPPER_TORSO,
	"lower body" = LOWER_TORSO,
	"legs" = LEGS,
	"feet" = FEET,
	"arms" = ARMS,
	"hands" = HANDS
)

// Strings which corraspond to slot flags, useful for outputting what slot something is.
var/global/list/string_slot_flags = list(
	"back" = SLOT_BACK,
	"face" = SLOT_MASK,
	"waist" = SLOT_BELT,
	"ID slot" = SLOT_ID,
	"ears" = SLOT_EARS,
	"eyes" = SLOT_EYES,
	"hands" = SLOT_GLOVES,
	"head" = SLOT_HEAD,
	"feet" = SLOT_FEET,
	"exo slot" = SLOT_OCLOTHING,
	"body" = SLOT_ICLOTHING,
	"uniform" = SLOT_TIE,
	"holster" = SLOT_HOLSTER
)

//////////////////////////
/////Initial Building/////
//////////////////////////

/proc/get_mannequin(ckey)
	RETURN_TYPE(/mob/living/carbon/human/dummy/mannequin)
	if (!GLOB.mannequins[ckey])
		GLOB.mannequins[ckey] = new /mob/living/carbon/human/dummy/mannequin
	return GLOB.mannequins[ckey]


/hook/global_init/proc/makeDatumRefLists()
	var/list/paths

	//Hair - Initialise all /datum/sprite_accessory/hair into an list indexed by hair-style name
	paths = typesof(/datum/sprite_accessory/hair) - /datum/sprite_accessory/hair
	for(var/path in paths)
		var/datum/sprite_accessory/hair/H = path
		if (is_abstract(H) || !initial(H.name))
			continue
		H = new path()
		GLOB.hair_styles_list[H.name] = H

	//Facial Hair - Initialise all /datum/sprite_accessory/facial_hair into an list indexed by facialhair-style name
	paths = typesof(/datum/sprite_accessory/facial_hair) - /datum/sprite_accessory/facial_hair
	for(var/path in paths)
		var/datum/sprite_accessory/facial_hair/H = path
		if (is_abstract(H) || !initial(H.name))
			continue
		H = new path()
		GLOB.facial_hair_styles_list[H.name] = H

	//Body markings - Initialise all /datum/sprite_accessory/marking into an list indexed by marking name
	paths = typesof(/datum/sprite_accessory/marking) - /datum/sprite_accessory/marking
	for(var/path in paths)
		var/datum/sprite_accessory/marking/M = path
		if (!initial(M.name))
			continue
		M = new path()
		GLOB.body_marking_styles_list[M.name] = M

	//Mutant organ styles - Initialise all /datum/sprite_accessory/mutant/tail into a list indexed by style name
	paths = typesof(/datum/sprite_accessory/mutant/tail) - /datum/sprite_accessory/mutant/tail
	for(var/path in paths)
		var/datum/sprite_accessory/mutant/tail/T = path
		if (!initial(T.name))
			continue
		T = new path()
		GLOB.mutant_tail_styles_list[T.name] = T

	//Mutant organ styles - Initialise all /datum/sprite_accessory/mutant/horns into a list indexed by style name
	paths = typesof(/datum/sprite_accessory/mutant/horns) - /datum/sprite_accessory/mutant/horns
	for(var/path in paths)
		var/datum/sprite_accessory/mutant/horns/HN = path
		if (!initial(HN.name))
			continue
		HN = new path()
		GLOB.mutant_horn_styles_list[HN.name] = HN

	//Mutant organ styles - Initialise all /datum/sprite_accessory/mutant/frills into a list indexed by style name
	paths = typesof(/datum/sprite_accessory/mutant/frills) - /datum/sprite_accessory/mutant/frills
	for(var/path in paths)
		var/datum/sprite_accessory/mutant/frills/FR = path
		if (!initial(FR.name))
			continue
		FR = new path()
		GLOB.mutant_frill_styles_list[FR.name] = FR

	//Mutant organ styles - Initialise all /datum/sprite_accessory/mutant/spines into a list indexed by style name
	paths = typesof(/datum/sprite_accessory/mutant/spines) - /datum/sprite_accessory/mutant/spines
	for(var/path in paths)
		var/datum/sprite_accessory/mutant/spines/SP = path
		if (!initial(SP.name))
			continue
		SP = new path()
		GLOB.mutant_spine_styles_list[SP.name] = SP

	//Mutant organ styles - Initialise all /datum/sprite_accessory/mutant/ears into a list indexed by style name
	paths = typesof(/datum/sprite_accessory/mutant/ears) - /datum/sprite_accessory/mutant/ears
	for(var/path in paths)
		var/datum/sprite_accessory/mutant/ears/EA = path
		if (!initial(EA.name))
			continue
		EA = new path()
		GLOB.mutant_ear_styles_list[EA.name] = EA

	//Mutant organ styles - Initialise all /datum/sprite_accessory/mutant/xenodorsal into a list indexed by style name
	paths = typesof(/datum/sprite_accessory/mutant/xenodorsal) - /datum/sprite_accessory/mutant/xenodorsal
	for(var/path in paths)
		var/datum/sprite_accessory/mutant/xenodorsal/XD = path
		if (!initial(XD.name))
			continue
		XD = new path()
		GLOB.mutant_xenodorsal_styles_list[XD.name] = XD

	//Mutant organ styles - Initialise all /datum/sprite_accessory/mutant/xenohead into a list indexed by style name
	paths = typesof(/datum/sprite_accessory/mutant/xenohead) - /datum/sprite_accessory/mutant/xenohead
	for(var/path in paths)
		var/datum/sprite_accessory/mutant/xenohead/XH = path
		if (!initial(XH.name))
			continue
		XH = new path()
		GLOB.mutant_xenohead_styles_list[XH.name] = XH

	//Mutant organ styles - Initialise all /datum/sprite_accessory/mutant/wings into a list indexed by style name
	paths = typesof(/datum/sprite_accessory/mutant/wings) - /datum/sprite_accessory/mutant/wings
	for(var/path in paths)
		var/datum/sprite_accessory/mutant/wings/WI = path
		if (!initial(WI.name))
			continue
		WI = new path()
		GLOB.mutant_wing_styles_list[WI.name] = WI

	//Mutant organ styles - Initialise all /datum/sprite_accessory/mutant/snout into a list indexed by style name
	paths = typesof(/datum/sprite_accessory/mutant/snout) - /datum/sprite_accessory/mutant/snout
	for(var/path in paths)
		var/datum/sprite_accessory/mutant/snout/SN = path
		if (!initial(SN.name))
			continue
		SN = new path()
		GLOB.mutant_snout_styles_list[SN.name] = SN

	//Mutant organ styles - Initialise all /datum/sprite_accessory/mutant/moth_antennae into a list indexed by style name
	paths = typesof(/datum/sprite_accessory/mutant/moth_antennae) - /datum/sprite_accessory/mutant/moth_antennae
	for(var/path in paths)
		var/datum/sprite_accessory/mutant/moth_antennae/MA = path
		if (!initial(MA.name))
			continue
		MA = new path()
		GLOB.mutant_moth_antennae_styles_list[MA.name] = MA

	//Mutant organ styles - Initialise all /datum/sprite_accessory/mutant/fluff into a list indexed by style name
	paths = typesof(/datum/sprite_accessory/mutant/fluff) - /datum/sprite_accessory/mutant/fluff
	for(var/path in paths)
		var/datum/sprite_accessory/mutant/fluff/FL = path
		if (!initial(FL.name))
			continue
		FL = new path()
		GLOB.mutant_fluff_styles_list[FL.name] = FL

	//Mutant organ styles - Initialise all /datum/sprite_accessory/mutant/breasts into a list indexed by style name
	paths = typesof(/datum/sprite_accessory/mutant/breasts) - /datum/sprite_accessory/mutant/breasts
	for(var/path in paths)
		var/datum/sprite_accessory/mutant/breasts/BR = path
		if (!initial(BR.name))
			continue
		BR = new path()
		GLOB.mutant_breast_styles_list[BR.name] = BR

	//Mutant organ styles - Initialise all /datum/sprite_accessory/mutant/penis into a list indexed by style name
	paths = typesof(/datum/sprite_accessory/mutant/penis) - /datum/sprite_accessory/mutant/penis
	for(var/path in paths)
		var/datum/sprite_accessory/mutant/penis/PE = path
		if (!initial(PE.name))
			continue
		PE = new path()
		GLOB.mutant_penis_styles_list[PE.name] = PE

	//Mutant organ styles - Initialise all /datum/sprite_accessory/mutant/testicles into a list indexed by style name
	paths = typesof(/datum/sprite_accessory/mutant/testicles) - /datum/sprite_accessory/mutant/testicles
	for(var/path in paths)
		var/datum/sprite_accessory/mutant/testicles/TE = path
		if (!initial(TE.name))
			continue
		TE = new path()
		GLOB.mutant_testicles_styles_list[TE.name] = TE

	//Mutant organ styles - Initialise all /datum/sprite_accessory/mutant/vagina into a list indexed by style name
	paths = typesof(/datum/sprite_accessory/mutant/vagina) - /datum/sprite_accessory/mutant/vagina
	for(var/path in paths)
		var/datum/sprite_accessory/mutant/vagina/VA = path
		if (!initial(VA.name))
			continue
		VA = new path()
		GLOB.mutant_vagina_styles_list[VA.name] = VA

	//Languages and species.
	paths = typesof(/datum/language)-/datum/language
	for(var/T in paths)
		var/datum/language/L = new T
		all_languages[L.name] = L

	for (var/language_name in all_languages)
		var/datum/language/L = all_languages[language_name]
		if(L.flags & NONGLOBAL)
			continue
		// Regional variants of one tongue share a prefix, so the group registers its key once, against its primary
		// variant; resolve_spoken_variant() then swaps in whichever variant the speaker actually knows. Without
		// this, whichever variant happened to be instantiated last would silently win the key.
		if(L.language_group && !L.is_group_primary)
			continue
		language_keys[lowertext(L.key)] = L

	wire_language_groups()

	//Grabs
	paths = typesof(/datum/grab) - /datum/grab
	for(var/T in paths)
		var/datum/grab/G = new T
		if(G.state_name)
			all_grabstates[G.state_name] = G

	paths = typesof(/obj/item/grab) - /obj/item/grab
	for(var/T in paths)
		var/obj/item/grab/G = T
		all_grabobjects[initial(G.type_name)] = T

	for(var/grabstate_name in all_grabstates)
		var/datum/grab/G = all_grabstates[grabstate_name]
		G.refresh_updown()

	paths = typesof(/particles)
	for (var/path in paths)
		var/particles/P = new path()
		GLOB.all_particles[P.name] = P

	return TRUE

//*** params cache
var/global/list/paramslist_cache = list()

#define cached_key_number_decode(key_number_data) cached_params_decode(key_number_data, GLOBAL_PROC_REF(key_number_decode))
#define cached_number_list_decode(number_list_data) cached_params_decode(number_list_data, GLOBAL_PROC_REF(number_list_decode))

/proc/cached_params_decode(params_data, decode_proc)
	. = paramslist_cache[params_data]
	if(!.)
		. = call(decode_proc)(params_data)
		paramslist_cache[params_data] = .

/proc/key_number_decode(key_number_data)
	RETURN_TYPE(/list)
	var/list/L = params2list(key_number_data)
	for(var/key in L)
		L[key] = text2num(L[key])
	return L

/proc/number_list_decode(number_list_data)
	RETURN_TYPE(/list)
	var/list/L = params2list(number_list_data)
	for(var/i in 1 to length(L))
		L[i] = text2num(L[i])
	return L
