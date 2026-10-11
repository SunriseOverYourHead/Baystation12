// For use with pipe rotate verb
#define PIPE_ROTATE_STANDARD 0 // usual rotate
#define PIPE_ROTATE_TWODIR   1 // Sanitizes cardinal directions to just two, leaves corner directions alone
#define PIPE_ROTATE_ONEDIR   2 // Only has one dir, south

#define PIPE_PLACEMENT_SIMPLE     1
#define PIPE_PLACEMENT_ORTHOGONAL 2
#define PIPE_PLACEMENT_DIAGONAL   3

//Connection Type Definitions
#define CONNECT_TYPE_REGULAR        1
#define CONNECT_TYPE_SUPPLY         2
#define CONNECT_TYPE_SCRUBBER       4
#define CONNECT_TYPE_HE				8
#define CONNECT_TYPE_FUEL           16

// Piping layer - independent of connect_types. Two pipes of the SAME connect_types can now coexist on the same
// tile/direction as long as they're on different layers (whereas connect_types alone already lets DIFFERENT
// categories, e.g. regular vs supply, share a tile). Defaults to the middle layer so every pre-existing/mapped
// pipe (which never sets this) only ever matches other default-layer pipes - zero behavior change on old maps.
#define PIPING_LAYER_MIN            1
#define PIPING_LAYER_MAX            5
#define PIPING_LAYER_DEFAULT        3
// Pixel offset per layer step (perpendicular to the pipe's own direction - a N/S pipe shifts sideways in X, an
// E/W pipe shifts vertically in Y) and the tiny layer(z-order) nudge per step, both copied verbatim from
// NovaSector's code/__DEFINES/atmospherics/atmos_piping.dm ("IF YOU EVER CHANGE THESE CHANGE SPRITES TO MATCH").
#define PIPING_LAYER_P_X            5
#define PIPING_LAYER_P_Y            5
#define PIPING_LAYER_LCHANGE        0.005

// Bitmask pipe-shape defines (auto-shaping "smart" pipe) - copied from NovaSector's atmos_piping.dm. A pipe's
// icon_state is a computed "[bitfield]_[piping_layer]" key into icons/atmos/pipes_bitmask.dmi (copied from
// NovaSector's icons/obj/pipes_n_cables/!pipes_bitmask.dmi): FULLPIPE bits mark directions with an actual
// connected neighbor (rendered as a stub reaching the tile edge), SHORTPIPE bits mark directions that are
// allowed (per initialize_directions) but not currently connected (rendered as a short capped stub).
#define NORTH_FULLPIPE (1<<0) //also just NORTH
#define SOUTH_FULLPIPE (1<<1) //also just SOUTH
#define EAST_FULLPIPE (1<<2) //also just EAST
#define WEST_FULLPIPE (1<<3) //also just WEST
#define NORTH_SHORTPIPE (1<<4)
#define SOUTH_SHORTPIPE (1<<5)
#define EAST_SHORTPIPE (1<<6)
#define WEST_SHORTPIPE (1<<7)
#define CARDINAL_TO_FULLPIPES(cardinals) (cardinals)
#define CARDINAL_TO_SHORTPIPES(cardinals) ((cardinals) << 4)
// A pipe is a "stub" if it has zero or one connectable direction - there's no sprite for that, so the smart
// pipe always pads a stub out to at least two directions (using SHORTPIPE bits) before picking an icon_state.
#define ISSTUB(bits) (!((bits) & ((bits) - 1)))
#define REVERSE_DIR(dir) ((((dir) & 85) << 1) | (((dir) & 170) >> 1))

#define DISPOSAL_FLIP_NONE          0
#define DISPOSAL_FLIP_FLIP          1
#define DISPOSAL_FLIP_LEFT          2
#define DISPOSAL_FLIP_RIGHT         4

//Pipe classifications
#define PIPE_CLASS_OTHER            0
#define PIPE_CLASS_UNARY            1
#define PIPE_CLASS_BINARY           2
#define PIPE_CLASS_TRINARY          3
#define PIPE_CLASS_QUATERNARY       4
#define PIPE_CLASS_OMNI             5

#define ADIABATIC_EXPONENT          0.667 //Actually adiabatic exponent - 1.
