/obj/item/projectile/bullet
	name = "bullet"
	icon_state = "bullet"
	fire_sound = null
	damage = 50
	damage_type = DAMAGE_BRUTE
	damage_flags = DAMAGE_FLAG_BULLET | DAMAGE_FLAG_SHARP
	embed = TRUE
	penetration_modifier = 1.0
	space_knockback = 1
	var/mob_passthrough_check = 0
	var/is_pellet = FALSE

	muzzle_type = /obj/projectile/bullet
	miss_sounds = list('sound/weapons/guns/miss1.ogg','sound/weapons/guns/miss2.ogg','sound/weapons/guns/miss3.ogg','sound/weapons/guns/miss4.ogg')
	ricochet_sounds = list('sound/weapons/guns/ricochet1.ogg', 'sound/weapons/guns/ricochet2.ogg',
							'sound/weapons/guns/ricochet3.ogg', 'sound/weapons/guns/ricochet4.ogg')
	impact_sounds = list(BULLET_IMPACT_MEAT = SOUNDS_BULLET_MEAT, BULLET_IMPACT_METAL = SOUNDS_BULLET_METAL)

/obj/item/projectile/bullet/on_hit(atom/target, blocked = 0)
	if (..(target, blocked))
		var/mob/living/L = target
		shake_camera(L, 3, 2)

/obj/item/projectile/bullet/attack_mob(mob/living/target_mob, distance, miss_modifier)
	if(penetrating > 0 && damage > 20 && prob(damage))
		mob_passthrough_check = 1
	else
		mob_passthrough_check = 0
	. = ..()

	if(. == 1 && iscarbon(target_mob) && !is_pellet)
		damage *= 0.7 //squishy mobs absorb KE

/obj/item/projectile/bullet/can_embed()
	//prevent embedding if the projectile is passing through the mob
	if(mob_passthrough_check)
		return 0
	return ..()

/obj/item/projectile/bullet/check_penetrate(atom/A)
	if(QDELETED(A) || !A.density) return 1 //if whatever it was got destroyed when we hit it, then I guess we can just keep going

	if(ismob(A))
		if(!mob_passthrough_check)
			return 0
		return 1

	var/chance = damage
	if(has_extension(A, /datum/extension/penetration))
		var/datum/extension/penetration/P = get_extension(A, /datum/extension/penetration)
		chance = P.PenetrationProbability(chance, damage, damage_type)

	if(prob(chance))
		if(A.opacity)
			//display a message so that people on the other side aren't so confused
			A.visible_message(SPAN_WARNING("\The [src] pierces through \the [A]!"))
		return 1

	return 0

//For projectiles that actually represent clouds of projectiles
/obj/item/projectile/bullet/pellet
	name = "shrapnel" //'shrapnel' sounds more dangerous (i.e. cooler) than 'pellet'
	damage = 37.5
	//icon_state = "bullet" //TODO: would be nice to have it's own icon state
	var/pellets = 4			//number of pellets
	var/range_step = 2		//projectile will lose a fragment each time it travels this distance. Can be a non-integer.
	var/base_spread = 90	//lower means the pellets spread more across body parts. If zero then this is considered a shrapnel explosion instead of a shrapnel cone
	var/spread_step = 10	//higher means the pellets spread more across body parts with distance
	is_pellet = TRUE

/obj/item/projectile/bullet/pellet/Bumped()
	. = ..()
	bumped = 0 //can hit all mobs in a tile. pellets is decremented inside attack_mob so this should be fine.

/obj/item/projectile/bullet/pellet/proc/get_pellets(distance)
	/// pellets lost due to distance
	var/pellet_loss = round(max(distance - 1, 0)/range_step)
	return max(pellets - pellet_loss, 1)

/obj/item/projectile/bullet/pellet/attack_mob(mob/living/target_mob, distance, miss_modifier)
	if (pellets < 0) return 1

	var/total_pellets = get_pellets(distance)
	var/spread = max(base_spread - (spread_step*distance), 0)

	//shrapnel explosions miss prone mobs with a chance that increases with distance
	var/prone_chance = 0
	if(!base_spread)
		prone_chance = max(spread_step*(distance - 2), 0)

	var/hits = 0
	for (var/i in 1 to total_pellets)
		if(target_mob.lying && target_mob != original && prob(prone_chance))
			continue

		//pellet hits spread out across different zones, but 'aim at' the targeted zone with higher probability
		//whether the pellet actually hits the def_zone or a different zone should still be determined by the parent using get_zone_with_miss_chance().
		var/old_zone = def_zone
		def_zone = ran_zone(def_zone, spread)
		if (..())
			hits++
		def_zone = old_zone //restore the original zone the projectile was aimed at

	pellets -= hits //each hit reduces the number of pellets left
	if (hits >= total_pellets || pellets <= 0)
		return 1
	return 0

/obj/item/projectile/bullet/pellet/get_structure_damage()
	var/distance = get_dist(loc, starting)
	return ..() * get_pellets(distance)

/obj/item/projectile/bullet/pellet/Move()
	. = ..()

	//If this is a shrapnel explosion, allow mobs that are prone to get hit, too
	if(. && !base_spread && isturf(loc))
		for(var/mob/living/M in loc)
			if(M.lying || !M.CanPass(src, loc, 0.5, 0)) //Bump if lying or if we would normally Bump.
				if(Bump(M, TRUE)) //Bump will make sure we don't hit a mob multiple times
					return

// PISTOL and SMG calibers


// .45
/obj/item/projectile/bullet/pistol/antique
	energy = 7
	penetration_modifier = 0.6
	distance_falloff = 5

// .32
/obj/item/projectile/bullet/pistol/tiny
	damage = 70 // Even a small caliber kills you very, very easily unprotected.
	energy = 2
	armor_penetration = 2
	penetration_modifier = 0.3
	agony = 10
	distance_falloff = 5

/obj/item/projectile/bullet/pistol/rubber/tiny
	damage = 10
	energy = 1
	agony = 20

// .380
/obj/item/projectile/bullet/pistol/small
	damage = 80
	energy = 4
	armor_penetration = 4
	penetration_modifier = 0.4
	agony = 15
	distance_falloff = 4

// 9x19mm
/obj/item/projectile/bullet/pistol
	damage = 80
	energy = 10
	armor_penetration = 10
	penetration_modifier = 0.5 // Bullets without a lot of power that often don't go very deep.
	agony = 20
	distance_falloff = 3

/obj/item/projectile/bullet/pistol/rubber //"rubber" bullets
	name = "rubber bullet"
	damage_flags = 0
	armor_penetration = 0
	damage = 15
	energy = 4
	agony = 40
	embed = FALSE

/obj/item/projectile/bullet/pistol/practice
	damage = 5
	energy = 0
	armor_penetration = 0
	penetration_modifier = 0.1
	agony = 5


// 10mm
/obj/item/projectile/bullet/pistol/big
	damage = 85
	energy = 15
	armor_penetration = 20
	penetration_modifier = 0.6
	agony = 25
	distance_falloff = 3

// .44
/obj/item/projectile/bullet/pistol/huge
	damage = 85
	energy = 25
	armor_penetration = 35
	penetration_modifier = 0.7
	distance_falloff = 2
	agony = 30

// .50
/obj/item/projectile/bullet/pistol/massive
	damage = 90
	energy = 30
	armor_penetration = 40
	penetration_modifier = 0.8
	distance_falloff = 1
	agony = 35

// 20mm
/obj/item/projectile/bullet/pistol/cannon
	damage = 110
	energy = 60
	armor_penetration = 47
	penetration_modifier = 1
	distance_falloff = 3
	agony = 80

//4mm. Tiny, very low damage, does not embed, but has very high penetration. Only to be used for the experimental SMG.
/obj/item/projectile/bullet/flechette
	damage = 23
	penetrating = 1
	armor_penetration = 40
	embed = FALSE
	distance_falloff = 2

// SHOTGUNS

// Not nearly as much AP as rifles, but tons of damage and energy.
/obj/item/projectile/bullet/shotgun
	name = "slug"
	damage = 90
	energy = 55
	armor_penetration = 40
	penetration_modifier = 1
	distance_falloff = 1
	agony = 30

/obj/item/projectile/bullet/shotgun/beanbag		//because beanbags are not bullets
	name = "beanbag"
	damage = 20
	energy = 5
	damage_flags = 0
	agony = 70
	embed = FALSE
	armor_penetration = 10
	distance_falloff = 3

//Overall less damage than slugs in exchange for more damage at very close range and more embedding
/obj/item/projectile/bullet/pellet/shotgun
	name = "shrapnel"
	icon_state = "pellet"
	damage = 60
	energy = 5
	pellets = 6
	range_step = 1
	spread_step = 50
	agony = 5
	armor_penetration = 10
	penetration_modifier = 0.5

// Ineffective against hard armor
/obj/item/projectile/bullet/pellet/shotgun/flechette
	name = "flechette"
	icon_state = "flechette"
	damage = 50
	energy = 8
	armor_penetration = 40
	pellets = 3
	range_step = 3
	base_spread = 99
	spread_step = 2
	agony = 10
	penetration_modifier = 0.3
	hitchance_mod = 5

// Base rifle round.
/obj/item/projectile/bullet/rifle
	damage = 80
	energy = 35
	armor_penetration = 46
	penetrating = 1
	distance_falloff = 1
	agony = 10
	penetration_modifier = 0.2

// Intermediate RIFLE rounds
//.223 Remington
/obj/item/projectile/bullet/rifle/intermediate/small/antique
	damage = 70
	energy = 25
	distance_falloff = 1

// 6.02x41mm, ICCG service
/obj/item/projectile/bullet/rifle/intermediate/small
	damage = 75
	energy = 40
	distance_falloff = 0.2

// 6.5x39mm	Grendel, SCG service
/obj/item/projectile/bullet/rifle/intermediate
	damage = 80
	energy = 35
	armor_penetration = 46
	distance_falloff = 0.4

// 8.6x43mm Blackout, SCG Special
/obj/item/projectile/bullet/rifle/intermediate/big
	damage = 85
	energy = 45
	agony = 20
	armor_penetration = 48
	penetration_modifier = 0.5

// 7.62x39mm
/obj/item/projectile/bullet/rifle/intermediate/big/antique
	damage = 70
	energy = 30
	agony = 15
	armor_penetration = 45

// 9x39mm, ICCG Special
/obj/item/projectile/bullet/rifle/intermediate/massive
	damage = 70
	energy = 50
	agony = 30
	armor_penetration = 48
	distance_falloff = 2
	penetration_modifier = 0.7

// 11.6x57mm. SOL Exotic
/obj/item/projectile/bullet/rifle/intermediate/huge
	damage = 110
	energy = 50
	agony = 35
	armor_penetration = 47
	distance_falloff = 2
	penetration_modifier = 1


// Full Length RIFLE rounds

// 5.56x56mm
/obj/item/projectile/bullet/rifle/full/small/antique
	damage = 90
	energy = 45
	agony = 20
	armor_penetration = 60
	distance_falloff = 0.3

// 7.62x51mm
/obj/item/projectile/bullet/rifle/full/big/antique
	damage = 90
	energy = 45
	agony = 20
	armor_penetration = 60
	distance_falloff = 0.3

// 12.7x99mm
/obj/item/projectile/bullet/rifle/full/huge/antique
	damage = 120
	energy = 70
	agony = 35
	armor_penetration = 85
	distance_falloff = 0.3

// 6.5x59mm Sol Service
/obj/item/projectile/bullet/rifle/full/small
	damage = 85
	energy = 40
	agony = 20
	armor_penetration = 60
	penetration_modifier = 0.2
	distance_falloff = 0.1

// 8.6x66mm ICCG Service
/obj/item/projectile/bullet/rifle/full
	damage = 90
	energy = 45
	agony = 20
	armor_penetration = 60
	penetration_modifier = 0.3
	distance_falloff = 01

// 10.5x99mm ICCG Special
/obj/item/projectile/bullet/rifle/full/big
	damage = 120
	energy = 70
	agony = 40
	penetrating = 5
	armor_penetration = 87
	penetration_modifier = 0.9
	distance_falloff = 0

// 11.6x101mm SOL Special
/obj/item/projectile/bullet/rifle/full/huge
	damage = 125
	energy = 75
	agony = 45
	penetrating = 5
	armor_penetration = 88
	penetration_modifier = 1
	distance_falloff = 0

// Autocannon

/obj/item/projectile/bullet/autocannon
	damage = 180
	energy = 120
	agony = 80
	armor_penetration = 110
	penetration_modifier = 2
	distance_falloff = 0

// Rockets

// 88mm
/obj/item/projectile/bullet/rocket
	damage = 300
	energy = 200
	agony = 100
	armor_penetration = 150
	penetration_modifier = 2
	distance_falloff = 0
	var/explosion_radius = 3
	var/explosion_max_power = EX_ACT_LIGHT

// 66mm
/obj/item/projectile/bullet/rocket/light
	damage = 250
	energy = 180
	agony = 90
	armor_penetration = 130
	explosion_radius = 2
	explosion_max_power = EX_ACT_LIGHT


/obj/item/projectile/bullet/rocket/on_hit(atom/target, blocked = 0)
	if(isturf(target))
		explosion(target, explosion_radius, explosion_max_power)
	..()


/* Miscellaneous */
/obj/item/projectile/bullet/gyro
	name = "minirocket"
	fire_sound = 'sound/effects/Explosion1.ogg'
	var/explosion_radius = 2
	var/explosion_max_power = EX_ACT_LIGHT

/obj/item/projectile/bullet/gyro/on_hit(atom/target, blocked = 0)
	if(isturf(target))
		explosion(target, explosion_radius, explosion_max_power)
	..()

/obj/item/projectile/bullet/blank
	invisibility = INVISIBILITY_ABSTRACT
	damage = 1
	embed = FALSE

/obj/item/projectile/bullet/rifle/practice
	damage = 5

/obj/item/projectile/bullet/rifle/military/practice
	damage = 5

/obj/item/projectile/bullet/shotgun/practice
	name = "practice"
	damage = 5

/obj/item/projectile/bullet/pistol/cap
	name = "cap"
	invisibility = INVISIBILITY_ABSTRACT
	fire_sound = null
	damage_type = DAMAGE_PAIN
	damage_flags = 0
	damage = 0
	nodamage = TRUE
	embed = FALSE

/obj/item/projectile/bullet/pistol/cap/Process()
	qdel(src)
	return PROCESS_KILL

/obj/item/projectile/bullet/rock //spess dust
	name = "micrometeor"
	icon_state = "rock"
	damage = 40
	armor_penetration = 25
	life_span = 255
	distance_falloff = 0

/obj/item/projectile/bullet/rock/New()
	icon_state = "rock[rand(1,3)]"
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)
	..()
