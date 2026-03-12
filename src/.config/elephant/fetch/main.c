#include <pthread.h>
#include <stdio.h>
#include <string.h>
#include <dbus/dbus.h>

#include "pacman.h"
#include "tailscale.h"
#include "hypridle.h"
#include "bluetooth.h"
#include "power.h"

static int      s_packages;
static char     s_tailscale[64];
static int      s_hypridle;
static int      s_bluetooth;
static char     s_power[32];

static void *t_pacman(void *arg)    { (void)arg; s_packages  = fetch_pacman();                            return NULL; }
static void *t_tailscale(void *arg) { (void)arg; fetch_tailscale(s_tailscale, sizeof(s_tailscale));       return NULL; }
static void *t_hypridle(void *arg)  { (void)arg; s_hypridle   = fetch_hypridle();                         return NULL; }
static void *t_bluetooth(void *arg) { (void)arg; s_bluetooth  = fetch_bluetooth();                        return NULL; }
static void *t_power(void *arg)     { (void)arg; fetch_power(s_power, sizeof(s_power));                   return NULL; }

int main(void) {
    dbus_threads_init_default();

    memset(s_tailscale, 0, sizeof(s_tailscale));
    memset(s_power, 0, sizeof(s_power));

    pthread_t threads[5];
    pthread_create(&threads[0], NULL, t_pacman,    NULL);
    pthread_create(&threads[1], NULL, t_tailscale, NULL);
    pthread_create(&threads[2], NULL, t_hypridle,  NULL);
    pthread_create(&threads[3], NULL, t_bluetooth, NULL);
    pthread_create(&threads[4], NULL, t_power,     NULL);

    for (int i = 0; i < 5; i++)
        pthread_join(threads[i], NULL);

    printf("packages=%d\n",  s_packages);
    printf("tailscale=%s\n", s_tailscale);
    printf("hypridle=%d\n",  s_hypridle);
    printf("bluetooth=%d\n", s_bluetooth);
    printf("power=%s\n",     s_power);

    return 0;
}
