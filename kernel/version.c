#define VERSION_MAJOR 0
#define VERSION_MINOR 0
#define VERSION_PATCH 2

#define _Q(s) #s
#define Q(s) _Q(s)

const char *osversion = Q(VERSION_MAJOR) "." Q(VERSION_MINOR) "." Q(VERSION_PATCH) "-" Q(VERSION_BUILD);

