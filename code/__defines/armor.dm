// Armor will turn attacks into less dangerous (e.g. turning cut into bruise), so keep that in mind when decided what armor value to use.
// Some levels are marked with what they intend to block in such way.

// Thin kevlar lining. Not an actual armor type that exists anymore. Shouldn't degrade.
#define  ARMOR_BALLISTIC_I		5
// Stops up to .380
// Fails against .32 AP or .380 AP.

// IIA stops most pistol calibres at low velocities. Soft vests only. Concealed. Shouldn't degrade.
#define  ARMOR_BALLISTIC_IIA	15
// Stops up to 9mm, and 10mm HP.
// Fails at .45 AP, 9mm AP.

// II stops higher velocities than IIA. Soft vests only. Concealed. Shouldn't degrade.
#define  ARMOR_BALLISTIC_II     30
// Stops up to 10mm and all HPs, but it hurts.
// Fails at 9mm AP, 10mm AP.

// Even higher velocities than II, but still soft armor. Non-concealed soft armor. Shouldn't degrade.
#define  ARMOR_BALLISTIC_IIIA   45
// Stops up to 9mm AP and .50AE, but it really hurts.
// Fails at AP variants.

// Fictional. Stops intermediary rifle cartridges. Hard plates. Should degrade with repeated impacts.
#define  ARMOR_BALLISTIC_IIIAP   50
// Stops all pistol rounds except .50 AP and .44 AP. Hurts.
// Stops all non-AP intermediary rounds. Still hurts a lot depending on energy.
// Fails against full-length rounds.

// Level III is rated for all non-AP rifle ammo. Should degrade with repeated impacts.
#define  ARMOR_BALLISTIC_III    65
// Stops all HP and FMJ intermediaries, but they hurt.
// Stops all HP and FMJ full-length calibers, but they hurt a lot.
// All AP still goes through.

// Fictional. Blocks intermediary AP. Should degrade with repeated impacts.
#define  ARMOR_BALLISTIC_IIIP   70
// Stops all intermediary AP calibers, minus .458 SOCOM
// Fails at AP .458 SOCOM, and AP full-length calibers.

// Blocks full-length AP. Should degrade with repeated impacts.
#define  ARMOR_BALLISTIC_IV		80
// Fails only at 10.5x99mm, 12.7x99mm FMJ and 11.6x101mm FMJ.

// Fictional. Blocks 10.5x99mm, 12.7x99mm and 11.6x101mm. Should degrade with repeated impacts.
#define  ARMOR_BALLISTIC_IVP 90

// Fictional. Blocks AP variants of 10.5x99mm, 12.7x99mm and 11.6x101mm. Should degrade with repeated impacts.
#define  ARMOR_BALLISTIC_V 100

// Named aliases used by alien tech definitions
#define  ARMOR_BALLISTIC_PISTOL     ARMOR_BALLISTIC_IIIAP
#define  ARMOR_BALLISTIC_RESISTANT  ARMOR_BALLISTIC_III
#define  ARMOR_BALLISTIC_RIFLE      ARMOR_BALLISTIC_IV

// Pending a rework. Two types of laser armor should exist: Ablative and Capacitive.
// Capacitive heats and cooks you on multiple hits, but doesn't degrade.
// Ablative slowly degrades as the surface material ablates.

#define  ARMOR_LASER_MINOR			10
#define  ARMOR_LASER_SMALL			25	//Blocks small e-guns
#define  ARMOR_LASER_HANDGUNS		40	//Blocks normal e-guns
#define  ARMOR_LASER_MAJOR			50
#define  ARMOR_LASER_RIFLES			70	//Blocks laser rifles
#define  ARMOR_LASER_HEAVY			100

#define  ARMOR_MELEE_MINOR			5
#define  ARMOR_MELEE_SMALL			10
#define  ARMOR_MELEE_KNIVES			15	//Blocks most knives
#define  ARMOR_MELEE_RESISTANT		30	//Blocks large weapons like swords and toolboxes
#define  ARMOR_MELEE_MAJOR			50
#define  ARMOR_MELEE_VERY_HIGH		70
#define  ARMOR_MELEE_SHIELDED		100

#define  ARMOR_BIO_MINOR			10
#define  ARMOR_BIO_SMALL			25
#define  ARMOR_BIO_RESISTANT		50
#define  ARMOR_BIO_STRONG			75
#define  ARMOR_BIO_SHIELDED			100

#define  ARMOR_RAD_MINOR			10
#define  ARMOR_RAD_SMALL			25
#define  ARMOR_RAD_RESISTANT		40
#define  ARMOR_RAD_SHIELDED			100

#define  ARMOR_BOMB_MINOR			10
#define  ARMOR_BOMB_PADDED			30
#define  ARMOR_BOMB_RESISTANT		60
#define  ARMOR_BOMB_SHIELDED		100

#define  ARMOR_ENERGY_MINOR			10
#define  ARMOR_ENERGY_SMALL			25
#define  ARMOR_ENERGY_RESISTANT		40
#define  ARMOR_ENERGY_STRONG		75
#define  ARMOR_ENERGY_SHIELDED		100
