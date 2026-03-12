#include "pacman.h"
#include <alpm.h>
#include <stddef.h>

int fetch_pacman(void) {
    alpm_handle_t *handle = alpm_initialize("/", "/var/lib/pacman", NULL);
    if (!handle) return -1;

    alpm_db_t *db = alpm_get_localdb(handle);
    int count = (int)alpm_list_count(alpm_db_get_pkgcache(db));

    alpm_release(handle);
    return count;
}
