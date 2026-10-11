//Human
#define LANGUAGE_HUMAN_EURO      "Zurich Accord Common"
#define LANGUAGE_HUMAN_CHINESE   "Yangyu"
#define LANGUAGE_HUMAN_ARABIC    "Prototype Standard Arabic"
#define LANGUAGE_HUMAN_INDIAN    "New Dehlavi"
#define LANGUAGE_HUMAN_IBERIAN   "Iberian"
#define LANGUAGE_HUMAN_RUSSIAN   "Pan-Slavic"
#define LANGUAGE_HUMAN_SELENIAN  "Selenian"

//Human, surviving real-world languages. The languages above are the setting's own constructed descendants of
//Earth speech (Zurich Accord Common, Yangyu, Iberian and so on); these are the older tongues they grew out of,
//still spoken on Earth and in diaspora communities. Both sets coexist deliberately.
//Each of these is a group of regional variants rather than a single language -- see /datum/language/var/language_group.
//Variants within a group understand each other at LANGUAGE_GROUP_UNDERSTANDING and share one speech prefix.
#define LANGUAGE_HUMAN_ENGLISH   "English"
#define LANGUAGE_HUMAN_SPANISH   "Spanish"
#define LANGUAGE_HUMAN_MANDARIN  "Mandarin"

#define LANGUAGE_HUMAN_ENGLISH_GB  "English (Britain)"
#define LANGUAGE_HUMAN_ENGLISH_US  "English (America)"
#define LANGUAGE_HUMAN_SPANISH_ES  "Spanish (Spain)"
#define LANGUAGE_HUMAN_SPANISH_AR  "Spanish (Argentina)"
#define LANGUAGE_HUMAN_SPANISH_MX  "Spanish (Mexico)"

//Human misc
#define LANGUAGE_GUTTER         "Gutter"
#define LANGUAGE_SPACER         "Spacer"

//Alien
#define LANGUAGE_EAL               "Encoded Audio Language"
#define LANGUAGE_UNATHI_SINTA      "Sinta'unathi"
#define LANGUAGE_UNATHI_YEOSA      "Yeosa'unathi"
#define LANGUAGE_SKRELLIAN         "Skrellian"
#define LANGUAGE_ROOTLOCAL         "Local Rootspeak"
#define LANGUAGE_ROOTGLOBAL        "Global Rootspeak"
#define LANGUAGE_ADHERENT          "Protocol"
#define LANGUAGE_VOX               "Vox-pidgin"
#define LANGUAGE_NABBER            "Serpentid"

//Antag
#define LANGUAGE_CULT              "Cult"
#define LANGUAGE_CULT_GLOBAL       "Occult"
#define LANGUAGE_ALIUM             "Alium"

//Other
#define LANGUAGE_PRIMITIVE         "Primitive"
#define LANGUAGE_SIGN              "Sign Language"
#define LANGUAGE_ROBOT_GLOBAL      "Robot Talk"
#define LANGUAGE_DRONE_GLOBAL      "Drone Talk"
#define LANGUAGE_CHANGELING_GLOBAL "Changeling"
#define LANGUAGE_BORER_GLOBAL      "Cortical Link"
#define LANGUAGE_MANTID_NONVOCAL   "Ascent-Glow"
#define LANGUAGE_MANTID_VOCAL      "Ascent-Voc"
#define LANGUAGE_MANTID_BROADCAST  "Worldnet"
#define LANGUAGE_LEGION_GLOBAL     "Nexus Link"

// Language flags.
#define WHITELISTED  1   // Language is available if the speaker is whitelisted.
#define RESTRICTED   2   // Language can only be acquired by spawning or an admin.
#define NONVERBAL    4   // Language has a significant non-verbal component. Speech is garbled without line-of-sight.
#define SIGNLANG     8   // Language is completely non-verbal. Speech is displayed through emotes for those who can understand.
#define HIVEMIND     16  // Broadcast to all mobs with this language.
#define NONGLOBAL    32  // Do not add to general languages list.
#define INNATE       64  // All mobs can be assumed to speak and understand this language. (audible emotes)
#define NO_TALK_MSG  128 // Do not show the "\The [speaker] talks into \the [radio]" message
#define NO_STUTTER   256 // No stuttering, slurring, or other speech problems
#define ALT_TRANSMIT 512 // Language is not based on vision or sound (Todo: add this into the say code and use it for the rootspeak languages)

// Misc
#define MAX_LANGUAGES 3

// Proficiency levels, borrowing the CEFR scale. A character's entry in mob.languages maps the language datum to
// one of these. NONE is never stored -- not knowing a language means having no entry at all -- but it is what the
// accessors return for an unknown language, so it is defined for comparison.
#define LANGUAGE_LEVEL_NONE 0
#define LANGUAGE_LEVEL_A1   1
#define LANGUAGE_LEVEL_A2   2
#define LANGUAGE_LEVEL_B1   3
#define LANGUAGE_LEVEL_B2   4
#define LANGUAGE_LEVEL_C1   5
#define LANGUAGE_LEVEL_C2   6

#define LANGUAGE_LEVEL_MIN LANGUAGE_LEVEL_A1
#define LANGUAGE_LEVEL_MAX LANGUAGE_LEVEL_C2

/// Full comprehension. Speech at this value is passed through verbatim without a trip through scramble().
#define LANGUAGE_COMPREHENSION_FULL 100

/// Mutual intelligibility between regional variants of the same tongue (see /datum/language/var/language_group).
#define LANGUAGE_GROUP_UNDERSTANDING 95
