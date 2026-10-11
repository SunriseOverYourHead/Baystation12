/datum/sprite_accessory/hair
	icon = 'icons/mob/human_races/species/human/hair.dmi'
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO) // hair/facial hair only makes sense for these two (explicit user decision, 2026-09-02) -- GAS/Gyne/Vox/etc don't get hair options
	var/flags

/datum/sprite_accessory/hair/bald
	name = "Bald"
	icon_state = "bald"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN, SPECIES_ANTHRO, SPECIES_TESHARI) // explicit user decision -- Teshari can go bald
	flags = VERY_SHORT | HAIR_BALD

/datum/sprite_accessory/hair/short
	name = "Short Hair"	  // try to capatilize the names please~
	icon_state = "hair_a" // you do not need to define _s or _l sub-states, game automatically does this for you
	blend = ICON_MULTIPLY
	flags = VERY_SHORT

/datum/sprite_accessory/hair/twintail
	name = "Twintail"
	icon_state = "hair_twintail"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/short2
	name = "Short Hair 2"
	icon_state = "hair_shorthair3"
	blend = ICON_MULTIPLY

/datum/sprite_accessory/hair/cut
	name = "Cut Hair"
	icon_state = "hair_c"
	blend = ICON_MULTIPLY
	flags = VERY_SHORT

/datum/sprite_accessory/hair/flair
	name = "Flaired Hair"
	icon_state = "hair_flair"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/long
	name = "Shoulder-length Hair"
	icon_state = "hair_b"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/longer
	name = "Long Hair"
	icon_state = "hair_vlong"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/longest
	name = "Very Long Hair"
	icon_state = "hair_longest"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/longfringe
	name = "Long Fringe"
	icon_state = "hair_longfringe"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/longestalt
	name = "Longer Fringe"
	icon_state = "hair_vlongfringe"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/halfbang
	name = "Half-banged Hair"
	icon_state = "hair_halfbang"
	blend = ICON_MULTIPLY

/datum/sprite_accessory/hair/halfbangalt
	name = "Half-banged Hair Alt"
	icon_state = "hair_halfbang_alt"

/datum/sprite_accessory/hair/ponytail1
	name = "Ponytail 1"
	icon_state = "hair_ponytail"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/ponytail3
	name = "Ponytail 3"
	icon_state = "hair_ponytail3"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/ponytail4
	name = "Ponytail 4"
	icon_state = "hair_ponytail4"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/ponytail5
	name = "Ponytail 5"
	icon_state = "hair_ponytail5"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/ponytail6
	name = "Ponytail 6"
	icon_state = "hair_ponytail6"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/sideponytail
	name = "Side Ponytail"
	icon_state = "hair_stail"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/parted
	name = "Parted"
	icon_state = "hair_parted"
	blend = ICON_MULTIPLY

/datum/sprite_accessory/hair/pompadour
	name = "Pompadour"
	icon_state = "hair_pompadour"
	blend = ICON_MULTIPLY

/datum/sprite_accessory/hair/quiff
	name = "Quiff"
	icon_state = "hair_quiff"
	blend = ICON_MULTIPLY

/datum/sprite_accessory/hair/bedhead
	name = "Bedhead"
	icon_state = "hair_bedhead"
	blend = ICON_MULTIPLY

/datum/sprite_accessory/hair/bedhead2
	name = "Bedhead 2"
	icon_state = "hair_bedheadv2"
	blend = ICON_MULTIPLY

/datum/sprite_accessory/hair/bedhead3
	name = "Bedhead 3"
	icon_state = "hair_bedheadv3"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/beehive
	name = "Beehive"
	icon_state = "hair_beehive"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/bobcurl
	name = "Bobcurl"
	icon_state = "hair_bobcurl"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/bob
	name = "Bob"
	icon_state = "hair_bobcut"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/bowl
	name = "Bowl"
	icon_state = "hair_bowlcut"
	blend = ICON_MULTIPLY
	gender = MALE

/datum/sprite_accessory/hair/buzz
	name = "Buzzcut"
	icon_state = "hair_buzzcut"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)
	flags = VERY_SHORT

/datum/sprite_accessory/hair/crew
	name = "Crewcut"
	icon_state = "hair_crewcut"
	blend = ICON_MULTIPLY
	flags = VERY_SHORT

/datum/sprite_accessory/hair/combover
	name = "Combover"
	icon_state = "hair_combover"
	blend = ICON_MULTIPLY

/datum/sprite_accessory/hair/father
	name = "Father"
	icon_state = "hair_father"
	blend = ICON_MULTIPLY

/datum/sprite_accessory/hair/reversemohawk
	name = "Reverse Mohawk"
	icon_state = "hair_reversemohawk"
	blend = ICON_MULTIPLY

/datum/sprite_accessory/hair/devillock
	name = "Devil Lock"
	icon_state = "hair_devilock"
	blend = ICON_MULTIPLY

/datum/sprite_accessory/hair/dreadlocks
	name = "Dreadlocks"
	icon_state = "hair_dreads"
	blend = ICON_MULTIPLY

/datum/sprite_accessory/hair/curls
	name = "Curls"
	icon_state = "hair_curls"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/afro
	name = "Afro"
	icon_state = "hair_afro"
	blend = ICON_MULTIPLY

/datum/sprite_accessory/hair/afro2
	name = "Afro 2"
	icon_state = "hair_afro2"
	blend = ICON_MULTIPLY

/datum/sprite_accessory/hair/afro_large
	name = "Big Afro"
	icon_state = "hair_bigafro"
	blend = ICON_MULTIPLY

/datum/sprite_accessory/hair/rows
	name = "Rows"
	icon_state = "hair_rows1"
	species_allowed = list("_deprecated_no_species_")
	flags = VERY_SHORT

/datum/sprite_accessory/hair/rows2
	name = "Rows 2"
	icon_state = "hair_rows2"
	species_allowed = list("_deprecated_no_species_")
	flags = VERY_SHORT | HAIR_TIEABLE

/datum/sprite_accessory/hair/sargeant
	name = "Flat Top"
	icon_state = "hair_sargeant"
	blend = ICON_MULTIPLY
	flags = VERY_SHORT

/datum/sprite_accessory/hair/emo
	name = "Emo"
	icon_state = "hair_emo"
	blend = ICON_MULTIPLY

/datum/sprite_accessory/hair/emo2
	name = "Emo Alt"
	icon_state = "hair_emo2"
	blend = ICON_MULTIPLY

/datum/sprite_accessory/hair/shorteye
	name = "Overeye Short"
	icon_state = "hair_shortovereye"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/longovereye
	name = "Overeye Long"
	icon_state = "hair_longovereye"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/flow
	name = "Flow Hair"
	icon_state = "hair_f"
	blend = ICON_MULTIPLY

/datum/sprite_accessory/hair/feather
	name = "Feather"
	icon_state = "hair_feather"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/hitop
	name = "Hitop"
	icon_state = "hair_hitop"
	blend = ICON_MULTIPLY

/datum/sprite_accessory/hair/mohawk
	name = "Mohawk"
	icon_state = "hair_d"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/jensen
	name = "Adam Jensen Hair"
	icon_state = "hair_jensen"
	blend = ICON_MULTIPLY

/datum/sprite_accessory/hair/gelled
	name = "Gelled Back"
	icon_state = "hair_gelled"
	blend = ICON_MULTIPLY

/datum/sprite_accessory/hair/gentle
	name = "Gentle"
	icon_state = "hair_gentle"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/spiky
	name = "Spiky"
	icon_state = "hair_spikey"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/kusangi
	name = "Kusanagi Hair"
	icon_state = "hair_kusanagi"
	blend = ICON_MULTIPLY

/datum/sprite_accessory/hair/kagami
	name = "Pigtails"
	icon_state = "hair_kagami"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/himecut
	name = "Hime Cut"
	icon_state = "hair_himecut"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/shorthime
	name = "Short Hime Cut"
	icon_state = "hair_shorthime"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/mbraid
	name = "Medium Braid"
	icon_state = "hair_shortbraid"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/braid2
	name = "Long Braid"
	icon_state = "hair_hbraid"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/odango
	name = "Odango"
	icon_state = "hair_odango"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/ombre
	name = "Ombre"
	icon_state = "hair_ombre"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/updo
	name = "Updo"
	icon_state = "hair_updo"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/skinhead
	name = "Skinhead"
	icon_state = "hair_skinhead"
	blend = ICON_MULTIPLY
	flags = VERY_SHORT

/datum/sprite_accessory/hair/balding
	name = "Balding Hair"
	icon_state = "hair_e"
	blend = ICON_MULTIPLY
	flags = VERY_SHORT

/datum/sprite_accessory/hair/mahdrills
	name = "Drillruru"
	icon_state = "hair_drillruru"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/fringetail
	name = "Fringetail"
	icon_state = "hair_fringetail"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/dandypomp
	name = "Dandy Pompadour"
	icon_state = "hair_dandypompadour"
	blend = ICON_MULTIPLY

/datum/sprite_accessory/hair/cia
	name = "CIA"
	icon_state = "hair_cia"
	blend = ICON_MULTIPLY

/datum/sprite_accessory/hair/mulder
	name = "Mulder"
	icon_state = "hair_mulder"
	blend = ICON_MULTIPLY

/datum/sprite_accessory/hair/nitori
	name = "Nitori"
	icon_state = "hair_nitori"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/volaju
	name = "Volaju"
	icon_state = "hair_volaju"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/shortbangs
	name = "Short Bangs"
	icon_state = "hair_shortbangs"
	blend = ICON_MULTIPLY

/datum/sprite_accessory/hair/shavedbun
	name = "Shaved Bun"
	icon_state = "hair_shavedbun"
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/shavedbunalt
	name = "Shaved Bun Alt"
	icon_state = "hair_shavedbun_alt"
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/halfshaved
	name = "Half-Shaved"
	icon_state = "hair_halfshaved"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/halfshavedalt
	name = "Half-Shaved Alt"
	icon_state = "hair_halfshaved_alt"
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/softmohawk
	name = "Soft Mohawk"
	icon_state = "hair_softmohawk"
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/bun
	name = "Low Bun"
	icon_state = "hair_bun"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/doublebun
	name = "Double-Bun"
	icon_state = "hair_doublebun"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/lowfade
	name = "Low Fade"
	icon_state = "hair_lowfade"
	blend = ICON_MULTIPLY
	flags = VERY_SHORT

/datum/sprite_accessory/hair/medfade
	name = "Medium Fade"
	icon_state = "hair_medfade"
	blend = ICON_MULTIPLY
	flags = VERY_SHORT

/datum/sprite_accessory/hair/highfade
	name = "High Fade"
	icon_state = "hair_highfade"
	blend = ICON_MULTIPLY
	flags = VERY_SHORT

/datum/sprite_accessory/hair/baldfade
	name = "Balding Fade"
	icon_state = "hair_baldfade"
	blend = ICON_MULTIPLY
	flags = VERY_SHORT

/datum/sprite_accessory/hair/nofade
	name = "Regulation Cut"
	icon_state = "hair_nofade"
	blend = ICON_MULTIPLY
	flags = VERY_SHORT

/datum/sprite_accessory/hair/trimflat
	name = "Trimmed Flat Top"
	icon_state = "hair_trimflat"
	blend = ICON_MULTIPLY
	flags = VERY_SHORT

/datum/sprite_accessory/hair/shaved
	name = "Shaved"
	icon_state = "hair_shaved"
	blend = ICON_MULTIPLY
	flags = VERY_SHORT

/datum/sprite_accessory/hair/trimmed
	name = "Trimmed"
	icon_state = "hair_trimmed"
	blend = ICON_MULTIPLY
	flags = VERY_SHORT

/datum/sprite_accessory/hair/tightbun
	name = "Tight Bun"
	icon_state = "hair_tightbun"
	blend = ICON_MULTIPLY
	flags = VERY_SHORT | HAIR_TIEABLE

/datum/sprite_accessory/hair/coffeehouse
	name = "Coffee House Cut"
	icon_state = "hair_coffeehouse"
	blend = ICON_MULTIPLY
	flags = VERY_SHORT

/datum/sprite_accessory/hair/undercut
	name = "Undercut"
	icon_state = "hair_undercut"
	blend = ICON_MULTIPLY
	flags = VERY_SHORT

/datum/sprite_accessory/hair/partfade
	name = "Parted Fade"
	icon_state = "hair_shavedpart"
	blend = ICON_MULTIPLY
	flags = VERY_SHORT

/datum/sprite_accessory/hair/rowbun
	name = "Row Bun"
	icon_state = "hair_rowbun"
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/rowdualbraid
	name = "Row Dual Braid"
	icon_state = "hair_rowdualtail"
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/rowbraid
	name = "Row Braid"
	icon_state = "hair_rowbraid"
	species_allowed = list("_deprecated_no_species_")
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/regulationmohawk
	name = "Regulation Mohawk"
	icon_state = "hair_shavedmohawk"
	blend = ICON_MULTIPLY
	flags = VERY_SHORT

/datum/sprite_accessory/hair/topknot
	name = "Topknot"
	icon_state = "hair_topknot"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/ronin
	name = "Ronin"
	icon_state = "hair_ronin"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/bowlcut2
	name = "Bowl2"
	icon_state = "hair_bowlcut2"
	blend = ICON_MULTIPLY

/datum/sprite_accessory/hair/thinning
	name = "Thinning"
	icon_state = "hair_thinning"
	blend = ICON_MULTIPLY
	flags = VERY_SHORT

/datum/sprite_accessory/hair/thinningfront
	name = "Thinning Front"
	icon_state = "hair_thinningfront"
	blend = ICON_MULTIPLY
	flags = VERY_SHORT

/datum/sprite_accessory/hair/thinningback
	name = "Thinning Back"
	icon_state = "hair_thinningrear"
	blend = ICON_MULTIPLY
	flags = VERY_SHORT

/datum/sprite_accessory/hair/manbun
	name = "Manbun"
	icon_state = "hair_manbun"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/leftsidecut
	name = "Left Sidecut"
	icon_state = "hair_leftside"

/datum/sprite_accessory/hair/rightsidecut
	name = "Right Sidecut"
	icon_state = "hair_rightside"

/datum/sprite_accessory/hair/slick
	name = "Slick"
	icon_state = "hair_slick"

/datum/sprite_accessory/hair/messyhair
	name = "Messy"
	icon_state = "hair_messyhair"
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/averagejoe
	name = "Average Joe"
	icon_state = "hair_averagejoe"

/datum/sprite_accessory/hair/mohawkshaved
	name = "Shaved Mohawk"
	icon_state = "hair_mohawkshaved"

/datum/sprite_accessory/hair/mohawkshavednaomi
	name = "Naomi Mohawk"
	icon_state = "hair_mohawkshavednaomi"

/datum/sprite_accessory/hair/straightlong
	name = "Straight Long"
	icon_state = "hair_straightlong"
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/marysue
	name = "Mary Sue"
	icon_state = "hair_marysue"
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/messyhair2
	name = "Messy Hair 2"
	icon_state = "hair_messyhair2"

/datum/sprite_accessory/hair/buzzcut2
	name = "Buzzcut 2"
	icon_state = "hair_buzzcut2"

/datum/sprite_accessory/hair/donutbun
	name = "Donut Bun"
	icon_state = "hair_donutbun"
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/gentle2
	name = "Gentle 2"
	icon_state = "hair_gentle2"
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/trimrsidecut
	name = "Trimmed Right Sidecut"
	icon_state = "hair_rightside_trim"
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/belenkotied
	name = "Belenkotied"
	icon_state = "hair_belenkotied"

/datum/sprite_accessory/hair/bobshoulder
	name = "Shoulder Bob"
	icon_state = "hair_bob_shoulder"

/datum/sprite_accessory/hair/bobshoulder2
	name = "Shoulder Bob 2"
	icon_state = "hair_bob_shoulder2"

/datum/sprite_accessory/hair/bigbun
	name = "Big Bun"
	icon_state = "hair_bunbig"

/datum/sprite_accessory/hair/emofringe
	name = "Emo Fringe"
	icon_state = "hair_emofringe"
	blend = ICON_MULTIPLY

/datum/sprite_accessory/hair/himecutlong
	name = "Himecut Long"
	icon_state = "hair_himecut_long_ponytail"
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/himecutponytail
	name = "Himecut Ponytail"
	icon_state = "hair_himecut_ponytail"
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/modern
	name = "Modern"
	icon_state = "hair_modern"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/mohawkshaved3
	name = "Low and Long Mohawk"
	icon_state = "hair_mohawk_shavedlong"

/datum/sprite_accessory/hair/regmohawk2
	name = "Regulation Mohawk 2"
	icon_state = "hair_mohawk_shavedback"

/datum/sprite_accessory/hair/mohawkshaved4
	name = "Low Mohawk"
	icon_state = "hair_mohawk_shavedbacklong"

/datum/sprite_accessory/hair/oneshoulder
	name = "One Shoulder"
	icon_state = "hair_oneshoulder"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/ponytail7
	name = "Ponytail 7"
	icon_state = "hair_ponytail7"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/ponytailtied
	name = "Ponytail Tied"
	icon_state = "hair_ponytail_tied"
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/ponytaildinky1
	name = "Ponytail Dinky"
	icon_state = "hair_ponytail_dinky1"
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/ponytaildinky2
	name = "Ponytail Dinky 2"
	icon_state = "hair_ponytail_dinky2"
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/ponytaildinky3
	name = "Ponytail Dinky 3"
	icon_state = "hair_ponytail_dinky3"
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/tressshoulder
	name = "Tress Shoulder"
	icon_state = "hair_tressshoulder"
	blend = ICON_MULTIPLY
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/librarianbun
	name = "Librarian Bun"
	icon_state = "hair_bun_librarian"

/datum/sprite_accessory/hair/bununiter
	name = "Bun Uniter"
	icon_state = "hair_bun_uniter"
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/business
	name = "Business"
	icon_state = "hair_business"
	blend = ICON_MULTIPLY

/datum/sprite_accessory/hair/business2
	name = "Business 2"
	icon_state = "hair_business2"
	blend = ICON_MULTIPLY

/datum/sprite_accessory/hair/fadeg
	name = "Fade Grown"
	icon_state = "hair_fade_grown"

/datum/sprite_accessory/hair/pigtails
	name = "Simple Pigtails"
	icon_state = "hair_pigtails_simple"
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/shortspiked
	name = "Short Spiked"
	icon_state = "hair_short_spiked"

/datum/sprite_accessory/hair/sweptshort
	name = "Swept Short"
	icon_state = "hair_swept_short"

/datum/sprite_accessory/hair/sweptback
	name = "Swept Back"
	icon_state = "hair_swept_back"

/datum/sprite_accessory/hair/wavyshoulder
	name = "Shoulder-length Wavy"
	icon_state = "hair_wavyshoulder_down"
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/wavyup
	name = "Ponytail Wavy"
	icon_state = "hair_wavyshoulder_up"
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/wheeler
	name = "Wheeler"
	icon_state = "hair_wheeler"

/datum/sprite_accessory/hair/mullethawk
	name = "Mullet-Hawk"
	icon_state = "hair_mullethawk"

/datum/sprite_accessory/hair/maneshort
	name = "Mane Short"
	icon_state = "hair_mane_short"
	flags = HAIR_TIEABLE

/datum/sprite_accessory/hair/manelong
	name = "Mane Long"
	icon_state = "hair_mane_long"
	flags = HAIR_TIEABLE

// Ported from the shared /tg/-lineage vanilla hair pool via NovaSector / Bubberstation / S.P.L.U.R.T-tg-master
// (2026-09-02 hair sweep) -- these are additions to the existing native hair.dmi pool above, not replacements.
/datum/sprite_accessory/hair/h_80s
	name = "Short Hair 80s"
	icon_state = "hair_80s"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/afro_three_quarters
	name = "Afro (Three Quarters)"
	icon_state = "hair_afro_three_quarters"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/allthefuzz
	name = "All The Fuzz"
	icon_state = "hair_allthefuzz"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/anime_protag
	name = "Anime Protagonist"
	icon_state = "hair_anime_protag"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/antenna
	name = "Ahoge"
	icon_state = "hair_antenna"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/bedheadv4
	name = "Bedhead 4x"
	icon_state = "hair_bedheadv4"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/bigflattop
	name = "Flat Top (Big)"
	icon_state = "hair_bigflattop"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/bob_v2
	name = "Bob Hair"
	icon_state = "hair_bob"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/bob2
	name = "Bob Hair 2"
	icon_state = "hair_bob2"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/bob4
	name = "Bob Hair 4"
	icon_state = "hair_bob4"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/boddicker
	name = "Boddicker"
	icon_state = "hair_boddicker"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/braid
	name = "Braid (Floorlength)"
	icon_state = "hair_braid"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/braid2_v2
	name = "Braid (High)"
	icon_state = "hair_braid2"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/braided
	name = "Braided"
	icon_state = "hair_braided"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/braidfront
	name = "Braided Front"
	icon_state = "hair_braidfront"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/braidtail
	name = "Braided Tail"
	icon_state = "hair_braidtail"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/bun3
	name = "Bun Head 3"
	icon_state = "hair_bun3"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/bunhead2
	name = "Bun Head 2"
	icon_state = "hair_bunhead2"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/chinbob
	name = "Chin-Length Bob Cut"
	icon_state = "hair_chinbob"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/coily
	name = "Coily"
	icon_state = "hair_coily"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/comet
	name = "Comet"
	icon_state = "hair_comet"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/cornrowbraid
	name = "Cornrow Braid"
	icon_state = "hair_cornrowbraid"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/cornrowbun
	name = "Cornrow Bun"
	icon_state = "hair_cornrowbun"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/cornrows
	name = "Cornrows"
	icon_state = "hair_cornrows"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/cornrows2
	name = "Cornrows 2"
	icon_state = "hair_cornrows2"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/cornrowtail
	name = "Cornrow Tail"
	icon_state = "hair_cornrowtail"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/country
	name = "Ponytail (Country)"
	icon_state = "hair_country"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/curtains
	name = "Curtains"
	icon_state = "hair_curtains"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/double_drills
	name = "Double Drills"
	icon_state = "hair_double_drills"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/drillhairextended
	name = "Drill Hair (Extended)"
	icon_state = "hair_drillhairextended"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/floorlength_bedhead
	name = "Floorlength Bedhead"
	icon_state = "hair_floorlength_bedhead"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/frizzy_sidecut
	name = "Frizzy Sidecut"
	icon_state = "hair_frizzy_sidecut"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/hedgehog
	name = "Hedgehog Hair"
	icon_state = "hair_hedgehog"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/highponytail
	name = "Ponytail (High)"
	icon_state = "hair_highponytail"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/hightop_slant
	name = "Hightop Slant"
	icon_state = "hair_hightop_slant"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/himecut2
	name = "Hime Cut 2"
	icon_state = "hair_himecut2"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/himeup
	name = "Hime Updo"
	icon_state = "hair_himeup"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/hugeafro
	name = "Afro (Huge)"
	icon_state = "hair_hugeafro"
	blend = ICON_MULTIPLY
	species_allowed = list("_deprecated_no_species_")

/datum/sprite_accessory/hair/jade
	name = "Jade"
	icon_state = "hair_jade"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/keanu
	name = "Keanu Hair"
	icon_state = "hair_keanu"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/killmonger
	name = "Killmonger"
	icon_state = "hair_killmonger"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/largebun
	name = "Bun (Large)"
	icon_state = "hair_largebun"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/lbangs
	name = "Long Bangs"
	icon_state = "hair_lbangs"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/long_v2
	name = "Long Hair 1"
	icon_state = "hair_long"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/long2
	name = "Long Hair 2"
	icon_state = "hair_long2"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/long3
	name = "Long Hair 3"
	icon_state = "hair_long3"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/long_bedhead
	name = "Long Bedhead"
	icon_state = "hair_long_bedhead"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/long_dreads
	name = "Long Dreadlocks"
	icon_state = "hair_long_dreads"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/long_dreads_up
	name = "Long Dreads Up"
	icon_state = "hair_long_dreads_up"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/long_sidecut
	name = "Long Sidecut"
	icon_state = "hair_long_sidecut"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/long_wavy
	name = "Long Wavy"
	icon_state = "hair_long_wavy"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/longest2
	name = "Very Long Over Eye"
	icon_state = "hair_longest2"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/longsidepart
	name = "Long Side Part"
	icon_state = "hair_longsidepart"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/longstraightponytail
	name = "Ponytail (Long)"
	icon_state = "hair_longstraightponytail"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/messy
	name = "Messy"
	icon_state = "hair_messy"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/money_piece
	name = "Money Piece"
	icon_state = "hair_money_piece"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/mullet
	name = "Mullet"
	icon_state = "hair_mullet"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/mullet_with_rat_tail
	name = "Mullet with Rat Tail"
	icon_state = "hair_mullet_with_rat_tail"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/overeyetwo
	name = "Over Eye 2"
	icon_state = "hair_overeyetwo"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/oxton
	name = "Oxton"
	icon_state = "hair_oxton"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/part
	name = "Parted (Side)"
	icon_state = "hair_part"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/pigtails_v2
	name = "Pigtails 2"
	icon_state = "hair_pigtails"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/pigtails2
	name = "Pigtails 3"
	icon_state = "hair_pigtails2"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/pigtails_4
	name = "Pigtails 4"
	icon_state = "hair_pigtails_4"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/pigtails_5
	name = "Pigtails 5"
	icon_state = "hair_pigtails_5"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/pigtails_antenna
	name = "Pigtails (Antenna)"
	icon_state = "hair_pigtails_antenna"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/pigtails_cupid
	name = "Pigtails (Cupid)"
	icon_state = "hair_pigtails_cupid"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/pixie
	name = "Pixie Cut"
	icon_state = "hair_pixie"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/ponytail2_v2
	name = "Ponytail 2"
	icon_state = "hair_ponytail2"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/ponytail_fro
	name = "Ponytail (Fro)"
	icon_state = "hair_ponytail_fro"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/ponytail_wavy
	name = "Ponytail (Wavy)"
	icon_state = "hair_ponytail_wavy"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/protagonist
	name = "Slightly Long Hair"
	icon_state = "hair_protagonist"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/rosa
	name = "Short Hair Rosa"
	icon_state = "hair_rosa"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/sadako
	name = "Sadako"
	icon_state = "hair_sadako"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/short_wavy
	name = "Short Wavy"
	icon_state = "hair_short_wavy"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/shortbangs2
	name = "Short Bangs 2"
	icon_state = "hair_shortbangs2"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/shorter_bangs
	name = "Shorter Bangs"
	icon_state = "hair_shorter_bangs"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/shorthair2
	name = "Short Hair 2"
	icon_state = "hair_shorthair2"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/shorthairg
	name = "Short Hair 7"
	icon_state = "hair_shorthairg"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/sidecut
	name = "Sidecut"
	icon_state = "hair_sidecut"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/sidecut_bang
	name = "Sidecut Bang"
	icon_state = "hair_sidecut_bang"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/sidetail
	name = "Ponytail (Side)"
	icon_state = "hair_sidetail"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/sidetail2
	name = "Ponytail (Side) 2"
	icon_state = "hair_sidetail2"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/sidetail3
	name = "Ponytail (Side) 3"
	icon_state = "hair_sidetail3"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/sidetail4
	name = "Ponytail (Side) 4"
	icon_state = "hair_sidetail4"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/singed_blown_back
	name = "Singed Blown Back"
	icon_state = "hair_singed_blown_back"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/singed_pigtails
	name = "Singed Pigtails"
	icon_state = "hair_singed_pigtails"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/spiky2
	name = "Spiky 3"
	icon_state = "hair_spiky2"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/spikyponytail
	name = "Ponytail (Spiky)"
	icon_state = "hair_spikyponytail"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/swept
	name = "Swept Back Hair"
	icon_state = "hair_swept"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/swept2
	name = "Joestar"
	icon_state = "hair_swept2"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/swirly_curls
	name = "Swirly Curls"
	icon_state = "hair_swirly_curls"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/swirly_curls_alt
	name = "Swirl Curls Alt"
	icon_state = "hair_swirly_curls_alt"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/tall_mohawk
	name = "Mohawk (Tall)"
	icon_state = "hair_tall_mohawk"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/twintails_wavy
	name = "Twintails (Wavy)"
	icon_state = "hair_twintails_wavy"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/undercutleft
	name = "Undercut Left"
	icon_state = "hair_undercutleft"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/undercutright
	name = "Undercut Right"
	icon_state = "hair_undercutright"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/unkept
	name = "Unkept"
	icon_state = "hair_unkept"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/unshaven_mohawk
	name = "Mohawk (Unshaven)"
	icon_state = "hair_unshaven_mohawk"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/verybadlycut
	name = "Shorter Long Bedhead"
	icon_state = "hair_verybadlycut"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/veryshortovereyealternate
	name = "Very Short Over Eye"
	icon_state = "hair_veryshortovereyealternate"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/wisp
	name = "Wisp"
	icon_state = "hair_wisp"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/wolfcut
	name = "Wolfcut"
	icon_state = "hair_wolfcut"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)

/datum/sprite_accessory/hair/ziegler
	name = "Ziegler"
	icon_state = "hair_ziegler"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_HUMAN,SPECIES_ANTHRO)


// Restored 2026-09-02 -- these were auto-deleted as white-white duplicates but the user wants to
// visually re-check them (silhouette-only matching missed color/shading differences for some).