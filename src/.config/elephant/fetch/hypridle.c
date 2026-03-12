#include "hypridle.h"
#include <dirent.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

int fetch_hypridle(void) {
    DIR *proc = opendir("/proc");
    if (!proc) return 0;

    struct dirent *ent;
    while ((ent = readdir(proc))) {
        if (ent->d_name[0] < '0' || ent->d_name[0] > '9')
            continue;

        char path[32];
        int n = snprintf(path, sizeof(path), "/proc/%s/comm", ent->d_name);
        if (n < 0 || (size_t)n >= sizeof(path)) continue;

        int fd = open(path, O_RDONLY);
        if (fd < 0) continue;

        char buf[9];
        ssize_t r = read(fd, buf, 8);
        close(fd);

        if (r == 8) {
            buf[8] = '\0';
            if (strcmp(buf, "hypridle") == 0) {
                closedir(proc);
                return 1;
            }
        }
    }

    closedir(proc);
    return 0;
}
