#ifndef CPOSIX_SHIM_H
#define CPOSIX_SHIM_H

#if defined(__APPLE__) || defined(__linux__)

#include <dlfcn.h>

// Dynamic library loading sentinel values.
// RTLD_DEFAULT and RTLD_NEXT are macros that Swift cannot import directly,
// so we expose them as functions.

static inline void *swift_RTLD_DEFAULT(void) {
    return RTLD_DEFAULT;
}

static inline void *swift_RTLD_NEXT(void) {
    return RTLD_NEXT;
}

#endif /* __APPLE__ || __linux__ */

#endif /* CPOSIX_SHIM_H */
