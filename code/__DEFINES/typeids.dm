//Byond type ids
#define TYPEID_NULL "0x0"
#define TYPEID_NORMAL_LIST "f"
#define TYPEID_APPEARANCE "3a"
#define TYPEID_ANONYMOUS_TYPEPATH "29"

//helper macros
#define GET_TYPEID(ref) ( ( (length(ref) <= 10) ? TYPEID_NULL : copytext(ref, 4, length(ref)-6) ) )
#define IS_NORMAL_LIST(V) (GET_TYPEID(!isnum(V) && ref(V)) == TYPEID_NORMAL_LIST)
#define IS_APPEARANCE(V) (GET_TYPEID(!isnum(V) && ref(V)) == TYPEID_APPEARANCE)
#define IS_ANONYMOUS_TYPEPATH(V) (GET_TYPEID(!isnum(V) && ref(V)) == TYPEID_ANONYMOUS_TYPEPATH)
