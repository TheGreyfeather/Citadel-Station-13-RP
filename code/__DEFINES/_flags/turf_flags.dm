//* /turf_flags var on /turf
/// This is used in literally one place, turf.dm, to block ethwereal jaunt.
#define NO_JAUNT						(1<<0)
/// Unused reservation turf
#define TURF_FLAG_UNUSED_RESERVATION			(1<<2)
/// queued for planet turf addition
#define TURF_PLANET_QUEUED				(1<<3)
/// registered to a planet
#define TURF_PLANET_REGISTERED			(1<<4)
/// queued for ZAS rebuild
#define TURF_ZONE_REBUILD_QUEUED		(1<<5)
/// no making dirt overlays or similar overlays on this
#define TURF_SEMANTICALLY_BOTTOMLESS	(1<<6)
/// considered a volatile-changing area by persistence, which means things like trash and debris won't stay here
#define TURF_FLAG_ERODING				(1<<7)
/// The slowdown affects a physical person, even if they aren't walking on the tile the turf represents.
#define TURF_SLOWDOWN_INCLUDE_FLYING	(1<<8)

///CITMAIN TURF FLAGS - Completely unused
/*
/// If a turf can be made dirty at roundstart. This is also used in areas.
#define CAN_BE_DIRTY				(1<<3)
/// Should this tile be cleaned up and reinserted into an excited group?
#define EXCITED_CLEANUP				(1<<4)
/// Blocks lava rivers being generated on the turf
#define NO_LAVA_GEN					(1<<5)
/// Blocks ruins spawning on the turf
#define NO_RUINS					(1<<6)
*/

DEFINE_BITFIELD(turf_flags, list(
	BITFIELD(NO_JAUNT),
	BITFIELD(TURF_FLAG_UNUSED_RESERVATION),
	BITFIELD(TURF_PLANET_QUEUED),
	BITFIELD(TURF_PLANET_REGISTERED),
	BITFIELD(TURF_ZONE_REBUILD_QUEUED),
	BITFIELD(TURF_SEMANTICALLY_BOTTOMLESS),
	BITFIELD(TURF_FLAG_ERODING),
	BITFIELD(TURF_SLOWDOWN_INCLUDE_FLYING),
))

//* /turf_path_danger var on /turf
/// lava, fire, etc
#define TURF_PATH_DANGER_BURN (1<<0)
/// openspace, chasms, etc
#define TURF_PATH_DANGER_FALL (1<<1)
/// will just fucking obliterate you
#define TURF_PATH_DANGER_ANNIHILATION (1<<2)
/// this, is literally space.
#define TURF_PATH_DANGER_SPACE (1<<3)

DEFINE_SHARED_BITFIELD(turf_path_danger, list(
	"turf_path_danger",
	"turf_path_danger_ignore",
), list(
	BITFIELD(TURF_PATH_DANGER_BURN),
	BITFIELD(TURF_PATH_DANGER_FALL),
	BITFIELD(TURF_PATH_DANGER_ANNIHILATION),
	BITFIELD(TURF_PATH_DANGER_SPACE),
))
