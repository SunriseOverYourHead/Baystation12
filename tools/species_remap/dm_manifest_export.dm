// Part of the species-remap bulk generation pipeline (see tools/species_remap/README.md). NOT part of the normal
// build -- to re-run this (eg after adding new clothing items, or to target a different species), temporarily:
//   1. Copy or symlink this file to code/_debug_export_remap_manifest.dm
//   2. Add "#include "code\_debug_export_remap_manifest.dm"" to baystation12.dme, right after
//      #include "code\game\world.dm"
//   3. Add a call to debug_export_remap_manifest() in /world/New() right after Master.Initialize(10, FALSE)
//      (wrap in spawn(50) so subsystems are ready)
//   4. Build, boot (check `ss -tnp | grep 5000` first -- never touch a live client session), let it run, then
//      copy data/logs/remap_manifest.json out, undo steps 1-3, and rebuild clean.
// This lives outside code/ specifically so it's never accidentally left wired into a real build.
//
// One-time introspection dump: every clothing/backpack item with a leg_remap_category set, its REAL (human
// baseline, no spritesheet/remap applied) on-mob icon+state for the slot it's worn in, and the list of species
// (bodytype strings, ie sprite_sheets' own keys) that ACTUALLY have this item's specific state covered -- not
// just species with a sprite_sheets ENTRY. Several base classes (/obj/item/clothing/suit, /obj/item/clothing/
// head, ...) set a sprite_sheets default globally for every subtype "since get_mob_overlay()'s own re-check
// already falls through to the pixel-remap for any state that sheet doesn't actually have" (see items.dm's
// get_mob_overlay() and the comment on /obj/item/clothing/suit's leg_remap_category) -- so an item can have a
// species KEY in sprite_sheets while that species' sheet is missing this exact state entirely (eg every SCGA/
// marine suit inherits SPECIES_NABBER from /obj/item/clothing/suit, but icons/mob/species/nabber/onmob_suit_gas
// .dmi only has 25 hand-drawn states, none of them SCGA's). Replicating the runtime's own "does this sheet
// actually have this state" check here (2026-09-04 fix -- the first version of this exporter didn't, and it
// silently excluded every such item from bulk generation, thinking they already had coverage) is what makes
// existing_species trustworthy. Written to JSON so a Python script can bulk-generate species variants without
// having to reimplement get_mob_overlay()'s resolution logic itself.
/world/proc/debug_export_remap_manifest()
	var/mob/living/carbon/human/dummy/mannequin/dummy = new(locate(1, 1, 1))
	// SPECIES_HUMAN has no sprite_sheets/remap entries anywhere -- get_mob_overlay() against it always resolves
	// to the item's own plain baseline art (item_icons or GLOB.default_onmob_icons), exactly what we want to
	// treat as "the real source sprite" for remapping.

	var/list/category_slots = list(
		"[CLOTHING_LEG_CATEGORY_PANTS]" = slot_w_uniform_str,
		"[CLOTHING_LEG_CATEGORY_SHORTS]" = slot_w_uniform_str,
		"[CLOTHING_LEG_CATEGORY_SKIRT]" = slot_w_uniform_str,
		"[CLOTHING_LEG_CATEGORY_BOOTS]" = slot_shoes_str,
		"[CLOTHING_LEG_CATEGORY_SUIT]" = slot_wear_suit_str,
		"[CLOTHING_LEG_CATEGORY_HELMET]" = slot_head_str,
		"[CLOTHING_LEG_CATEGORY_BACKPACK]" = slot_back_str,
		"[CLOTHING_LEG_CATEGORY_RUCKSACK]" = slot_back_str,
		"[CLOTHING_LEG_CATEGORY_SATCHEL]" = slot_back_str,
		"[CLOTHING_LEG_CATEGORY_MESSENGERBAG]" = slot_back_str,
		"[CLOTHING_LEG_CATEGORY_POCKETBOOK]" = slot_back_str,
		"[CLOTHING_LEG_CATEGORY_DUFFLEBAG]" = slot_back_str,
	)

	var/list/manifest = list()
	var/list/errors = list()
	var/total_checked = 0
	var/total_matched = 0

	var/list/all_types = typesof(/obj/item/clothing) + typesof(/obj/item/storage/backpack)
	for(var/T in all_types)
		total_checked++
		var/obj/item/it
		try
			it = new T()
		catch(var/exception/e)
			errors += "[T]: instantiate failed: [e]"
			continue
		if(!it)
			continue

		var/cat = it.leg_remap_category
		if(!cat || !(cat in category_slots))
			qdel(it)
			continue

		var/slot = category_slots[cat]

		var/image/rendered
		try
			rendered = it.get_mob_overlay(dummy, slot)
		catch(var/exception/e2)
			errors += "[T]: get_mob_overlay failed: [e2]"
			qdel(it)
			continue

		if(!rendered || !rendered.icon || !rendered.icon_state)
			errors += "[T]: get_mob_overlay returned no usable icon/icon_state"
			qdel(it)
			continue

		// A species key existing in sprite_sheets doesn't mean THIS state is in that sheet -- see header comment.
		var/list/existing_species = list()
		if(islist(it.sprite_sheets))
			for(var/sp in it.sprite_sheets)
				var/sheet_icon = it.sprite_sheets[sp]
				if(sheet_icon && (rendered.icon_state in icon_states(sheet_icon)))
					existing_species += sp

		total_matched++
		if(!manifest[cat])
			manifest[cat] = list()
		manifest[cat] += list(list(
			"type" = "[T]",
			"real_icon" = "[rendered.icon]",
			"real_icon_state" = "[rendered.icon_state]",
			"existing_species" = existing_species,
		))
		qdel(it)

	qdel(dummy)

	var/list/output = list("manifest" = manifest, "errors" = errors, "total_checked" = total_checked, "total_matched" = total_matched)
	var/f = file("data/logs/remap_manifest.json")
	fdel(f)
	text2file(json_encode(output), f)

	world.log << "debug_export_remap_manifest DONE: checked=[total_checked] matched=[total_matched] errors=[length(errors)]"
