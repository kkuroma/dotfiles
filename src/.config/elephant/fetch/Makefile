CC      = gcc
CFLAGS  = -O2 -Wall -Wextra $(shell pkg-config --cflags dbus-1)
LDFLAGS = -lalpm -lpthread $(shell pkg-config --libs dbus-1)

SRCS = main.c pacman.c tailscale.c hypridle.c bluetooth.c power.c
OBJS = $(SRCS:.c=.o)

fetch: $(OBJS)
	$(CC) -o $@ $^ $(LDFLAGS)
	rm -f $(OBJS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) fetch

.PHONY: clean
