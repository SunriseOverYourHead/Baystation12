// Constants for the sexcon (arousal/sex-action) engine, ported from Ratwood-2.0-main's own
// code/__DEFINES/sexcon_defines.dm as closely as this codebase's own primitives allow. See
// baystation12soyh_ratwood_sexcon_port memory for the full research/porting-decisions log.

GLOBAL_LIST_AS(sex_actions, build_sex_actions())

#define SEX_ACTION(sex_action_type) GLOB.sex_actions[sex_action_type]

#define MAX_AROUSAL 150
#define PASSIVE_EJAC_THRESHOLD 108
#define ACTIVE_EJAC_THRESHOLD 100
#define SEX_MAX_CHARGE 300
#define CHARGE_FOR_CLIMAX 100
#define AROUSAL_HARD_ON_THRESHOLD 20
#define CHARGE_RECHARGE_RATE (CHARGE_FOR_CLIMAX / (5 MINUTES))
#define AROUSAL_TIME_TO_UNHORNY (3 SECONDS)
#define SPENT_AROUSAL_RATE (3 / (1 SECONDS))
#define IMPOTENT_AROUSAL_LOSS_RATE (3 / (1 SECONDS))

// Retuned from Ratwood's own values (1.5/0.4/0.2 per second) after live feedback that arousal took far too long to
// fade on its own -- ~150 (MAX_AROUSAL) to 0 now takes roughly a minute (50/5 + 50/3 + 50/1.5 ~= 60s) rather than
// several minutes.
#define AROUSAL_HIGH_UNHORNY_RATE (5 / (1 SECONDS))
#define AROUSAL_MID_UNHORNY_RATE (3 / (1 SECONDS))
#define AROUSAL_LOW_UNHORNY_RATE (1.5 / (1 SECONDS))

#define MOAN_COOLDOWN 3 SECONDS
#define PAIN_COOLDOWN 6 SECONDS

#define SEX_SPEED_LOW 1
#define SEX_SPEED_MID 2
#define SEX_SPEED_HIGH 3
#define SEX_SPEED_EXTREME 4
#define SEX_SPEED_LUDICROUS 5

#define SEX_SPEED_MIN 1
#define SEX_SPEED_MAX 5

#define SEX_FORCE_LOW 1
#define SEX_FORCE_MID 2
#define SEX_FORCE_HIGH 3
#define SEX_FORCE_EXTREME 4
#define SEX_FORCE_LUDICROUS 5

#define SEX_FORCE_MIN 1
#define SEX_FORCE_MAX 5

#define SEX_MANUAL_AROUSAL_DEFAULT 1
#define SEX_MANUAL_AROUSAL_UNAROUSED 2
#define SEX_MANUAL_AROUSAL_PARTIAL 3
#define SEX_MANUAL_AROUSAL_FULL 4

#define SEX_MANUAL_AROUSAL_MIN 1
#define SEX_MANUAL_AROUSAL_MAX 4

#define PAIN_MILD_EFFECT 10
#define PAIN_MED_EFFECT 20
#define PAIN_HIGH_EFFECT 30
#define PAIN_MINIMUM_FOR_DAMAGE PAIN_MED_EFFECT
#define PAIN_DAMAGE_DIVISOR 50
// CORRECTED (was wrong in an earlier pass): this codebase's HUMANS have a real, separate, per-organ "pain" stat --
// confirmed by reading /mob/living/carbon/human/adjustHalLoss() (human_damage.dm), which routes into each organ's
// own add_pain()/remove_pain() (_external_damage.dm), capped per-organ at that organ's own max_damage and NOT
// touching brute_dam/burn_dam at all. (The earlier, wrong claim came from reading only the base /mob/living stub,
// which humans override -- a real research mistake, corrected after the user directly pointed out tasers/stun
// weapons don't deal part damage, which is what sent me back to re-check.) /mob/living/carbon/human/get_shock()
// (human_damage.dm) sums this across all organs (minus painkillers) as "traumatic_shock" -- once that reaches
// species.total_health (normally 100), life.dm Paralyse()s the mob for 10 seconds EVERY Life() tick for as long as
// shock stays at/above that line, which is the actual mechanism behind "unconscious for way too long": pain has no
// fast passive decay (only ~1-3/tick per organ, _external.dm), so if this port kept adding pain faster than that
// organ-tick can drain it, total shock could get pinned above the paralysis line indefinitely. This define is the
// safety margin this port enforces: never add pain once current shock is already at/above it, keeping a healthy
// buffer under the real 100 paralysis threshold rather than sitting right next to it.
#define PAIN_SAFETY_SHOCK_CAP 60

#define SEX_CATEGORY_NULL 0
#define SEX_CATEGORY_MISC (1<<0)
#define SEX_CATEGORY_HANDS (1<<1)
#define SEX_CATEGORY_PENETRATE (1<<2)

// Ratwood's SEX_ZONE_* are a per-zone GRAB/non-GRAB bitflag pair against its own ~14-entry precise body-zone system
// (BODY_ZONE_PRECISE_GROIN etc). This codebase's own body model is the coarser 9-limb BP_* set (__defines/mobs.dm),
// so a single flag per zone is enough -- whether a given sex_action additionally requires a grab is already a
// separate per-action var (/datum/sex_action/var/require_grab), not baked into the zone bitfield itself.
#define SEX_ZONE_NULL 0
#define SEX_ZONE_GROIN (1<<0)
#define SEX_ZONE_CHEST (1<<1)
#define SEX_ZONE_MOUTH (1<<2)
#define SEX_ZONE_L_FOOT (1<<3)
#define SEX_ZONE_R_FOOT (1<<4)

// Ratwood's SEX_PART_* map onto this codebase's own BP_PENIS/BP_PUSSY/BP_TESTICLES/BP_BREASTS organ tags
// (strings, not bitflags, in this codebase) for organ lookups -- these bitflags are kept only for the
// user_sex_part/target_sex_part menu-visibility bitfield sex_action itself uses, matching Ratwood's own shape.
#define SEX_PART_NULL 0
#define SEX_PART_COCK (1<<0)
#define SEX_PART_CUNT (1<<1)
#define SEX_PART_ANUS (1<<2)
#define SEX_PART_JAWS (1<<3)
#define SEX_PART_CHEST (1<<4)

#define KNOTTED_NULL 0
#define KNOTTED_AS_TOP 1
#define KNOTTED_AS_BTM 2

/proc/build_sex_actions()
	. = list()
	for(var/path in typesof(/datum/sex_action))
		if(is_abstract(path))
			continue
		.[path] = new path()
	return .
