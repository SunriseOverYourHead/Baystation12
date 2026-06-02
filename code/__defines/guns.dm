// Outdated might be found in the hands of collectors, the desperate and Civilians.
// Civilian projectiles might be found in the hands of PMCs, contractors, etc.
// Service projectiles are the bread and butter used by armed forces
// Special projectiles are used by special forces, sniper teams, shock troops, etc. More limited in avaliability.

#define PROJECTILE_PISTOL_ANTIQUE	"11.5x23mm" 	//.45	// Civilian.
#define PROJECTILE_PISTOL_TINY		"7.65x15mm"		//.32 	// Civilian.
#define PROJECTILE_PISTOL_SMALL 	"9x17mm" 		//.380	// Civilian.
#define PROJECTILE_PISTOL 			"9x19mm" 		// 9mm	// Civilian/Service. SOL & ICCG
#define PROJECTILE_PISTOL_BIG 		"10x25mm"		//.40   // Service. SOL
#define PROJECTILE_PISTOL_HUGE 		"10.9x33mm"		//.44	// Service. ICCG
#define PROJECTILE_PISTOL_MASSIVE 	"12.7x32mm"		//.50	// Special. SOL
#define PROJECTILE_PISTOL_CANNON 	"20x32mm"		// 20mm // Special. ICCG
#define PROJECTILE_PISTOL_FLECHETTE "4x60mm"

#define PROJECTILE_RIFLE_INTERMEDIATE_ANTIQUE_SMALL			"5.56x45mm"		//.223	    // Civilian.
#define PROJECTILE_RIFLE_INTERMEDIATE_ANTIQUE_BIG			"7.62x39mm"		// 7.62     // Civilian.
#define PROJECTILE_RIFLE_INTERMEDIATE_SMALL					"6.02x41mm"		// 6.02	    // Service. ICCG
#define PROJECTILE_RIFLE_INTERMEDIATE						"6.5x39mm"		// Grendel  // Service. SOL
#define PROJECTILE_RIFLE_INTERMEDIATE_BIG					"8.6x43mm"		// Blackout // Special. SOL
#define PROJECTILE_RIFLE_INTERMEDIATE_MASSIVE				"9x39mm"		// SP-6     // Special. ICCG
#define PROJECTILE_RIFLE_INTERMEDIATE_HUGE					"11.6x57mm"		//.458 	    // Special. SOL

#define PROJECTILE_RIFLE_FULL_ANTIQUE_SMALL			"5.56x56mm"		//.220			// Civ.
#define PROJECTILE_RIFLE_FULL_ANTIQUE_BIG			"7.62x51mm"		//.308			// Civ.
#define PROJECTILE_RIFLE_FULL_ANTIQUE_HUGE			"12.7x99mm"		//.50			// Civ.
#define PROJECTILE_RIFLE_FULL_SMALL					"6.5x59mm"		// Creedmoor	// Service. SOL
#define PROJECTILE_RIFLE_FULL						"8.6x66mm"		// XLR			// Service. ICCG
#define PROJECTILE_RIFLE_FULL_BIG					"10.5x99mm"		// 10.5mm			// Service. ICCG
#define PROJECTILE_RIFLE_FULL_HUGE					"11.6x101mm"	// .458			// Service. SOL

#define PROJECTILE_AUTOCANNON		"20x102mm"

#define PROJECTILE_ROCKET			"88x755mm" // Non-expendable RL. Sol/ICCG Service
#define PROJECTILE_ROCKET_SMALL		"66x508mm" // Disposable RL. Sol/ICCG Service

#define PROJECTILE_SHOTGUN			"12g"
#define PROJECTILE_GYROJET			"20mmG"
#define PROJECTILE_CAPS			"caps"
#define PROJECTILE_DART			"darts"
#define CALIBER_SKRELL_SHOTGUN	"skrell_qx2"	// QX-2 miniaturized railgun. Skrell SDTF.

#define HOLD_CASINGS	0 //do not do anything after firing. Manual action, like pump shotguns, or guns that want to define custom behaviour
#define CLEAR_CASINGS	1 //clear chambered so that the next round will be automatically loaded and fired, but don't drop anything on the floor
#define EJECT_CASINGS	2 //drop spent casings on the ground after firing
#define CYCLE_CASINGS	3 //cycle casings, like a revolver. Also works for multibarrelled guns

//Gun loading types
#define SINGLE_CASING 	1	//The gun only accepts ammo_casings. ammo_magazines should never have this as their mag_type.
#define SPEEDLOADER 	2	//Transfers casings from the mag to the gun when used.
#define MAGAZINE 		4	//The magazine item itself goes inside the gun


#define GUN_BULK_LIGHT_RIFLE 4
#define GUN_BULK_RIFLE  5
#define GUN_BULK_HEAVY_RIFLE 6

#define BULLET_IMPACT_NONE  "none"
#define BULLET_IMPACT_METAL "metal"
#define BULLET_IMPACT_MEAT  "meat"

#define SOUNDS_BULLET_MEAT  list('sound/effects/projectile_impact/bullet_meat1.ogg', 'sound/effects/projectile_impact/bullet_meat2.ogg', 'sound/effects/projectile_impact/bullet_meat3.ogg', 'sound/effects/projectile_impact/bullet_meat4.ogg')
#define SOUNDS_BULLET_METAL  list('sound/effects/projectile_impact/bullet_metal1.ogg', 'sound/effects/projectile_impact/bullet_metal2.ogg', 'sound/effects/projectile_impact/bullet_metal3.ogg')
#define SOUNDS_LASER_MEAT  list('sound/effects/projectile_impact/energy_meat1.ogg','sound/effects/projectile_impact/energy_meat2.ogg')
#define SOUNDS_LASER_METAL  list('sound/effects/projectile_impact/energy_metal1.ogg','sound/effects/projectile_impact/energy_metal2.ogg')
