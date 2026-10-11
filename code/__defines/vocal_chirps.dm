// Tuning constants for vocal chirps -- the speech sounds defined in code/modules/mob/living/vocal_chirps.dm.
// They live here rather than beside the catalog because the preference files (preference_setup/general/
// 06_vocals.dm) and preferences_tgui.dm are included well before it, and DM resolves #defines in include order.

#define VOCAL_CHIRP_DEFAULT_MINPITCH 0.4
#define VOCAL_CHIRP_DEFAULT_MAXPITCH 2
#define VOCAL_CHIRP_DEFAULT_MINVARY 0.1
#define VOCAL_CHIRP_DEFAULT_MAXVARY 0.8
#define VOCAL_CHIRP_DEFAULT_MINSPEED 2
#define VOCAL_CHIRP_DEFAULT_MAXSPEED 16

/// "No chirp of my own" -- falls through to the species' own speech_sounds (Skrell warble etc). Default.
#define VOCAL_CHIRP_SPECIES_DEFAULT "Species Default"

/// Baseline for spacing chirps out. Speeds below this pack chirps tighter, above it spread them out.
#define VOCAL_CHIRP_SPEED_BASELINE 4
/// Hard cap on chirps per message, so a wall of text can't machine-gun.
#define VOCAL_CHIRP_MAX_PER_MESSAGE 24
/// Hard cap on how long one message's chirp train may run.
#define VOCAL_CHIRP_MAX_TIME (1.5 SECONDS)
/// Randomize one chirp's pitch within the player's chosen variance band.
#define VOCAL_CHIRP_DO_VARY(pitch, variance) (rand(((pitch * 100) - (variance * 50)), ((pitch * 100) + (variance * 50))) / 100)
/// Below 1 so whispers don't fall off jarringly at close range.
#define VOCAL_CHIRP_FALLOFF_EXPONENT 0.5
