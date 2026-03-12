#include <alpm.h>
#include <stdio.h>

int main() {
    alpm_handle_t *handle = alpm_initialize("/", "/var/lib/pacman", NULL);
    if (handle == NULL) return 1;
    alpm_db_t *db_local = alpm_get_localdb(handle);
    size_t pkg_count = alpm_list_count(alpm_db_get_pkgcache(db_local));
    printf("Packages: %zu\n", pkg_count);
    alpm_release(handle);
    return 0;
}