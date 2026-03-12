#include "tailscale.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>

#define SOCK_PATH "/var/run/tailscale/tailscaled.sock"
#define BUF_SIZE (512 * 1024)

void fetch_tailscale(char *out, size_t out_len) {
    out[0] = '\0';

    int fd = socket(AF_UNIX, SOCK_STREAM, 0);
    if (fd < 0) return;

    struct sockaddr_un addr;
    memset(&addr, 0, sizeof(addr));
    addr.sun_family = AF_UNIX;
    strncpy(addr.sun_path, SOCK_PATH, sizeof(addr.sun_path) - 1);

    if (connect(fd, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
        close(fd);
        return;
    }

    const char *req =
        "GET /localapi/v0/status HTTP/1.0\r\n"
        "Host: local-tailscaled.sock\r\n\r\n";
    if (write(fd, req, strlen(req)) < 0) {
        close(fd);
        return;
    }

    char *buf = malloc(BUF_SIZE);
    if (!buf) { close(fd); return; }

    size_t total = 0;
    ssize_t n;
    while ((n = read(fd, buf + total, BUF_SIZE - total - 1)) > 0) {
        total += (size_t)n;
        if (total >= BUF_SIZE - 1) break;
    }
    buf[total] = '\0';
    close(fd);

    /* Navigate: "ExitNodeStatus" -> "TailscaleIPs" -> first element */
    char *p = strstr(buf, "\"ExitNodeStatus\"");
    if (p) {
        p = strstr(p, "\"TailscaleIPs\"");
        if (p) {
            p = strchr(p, '[');
            if (p) {
                p = strchr(p, '"');
                if (p) {
                    p++;
                    char *end = strchr(p, '"');
                    if (end) {
                        size_t len = (size_t)(end - p);
                        if (len < out_len) {
                            memcpy(out, p, len);
                            out[len] = '\0';
                        }
                    }
                }
            }
        }
    }

    free(buf);
}
