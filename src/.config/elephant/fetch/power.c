#include "power.h"
#include <dbus/dbus.h>
#include <string.h>

void fetch_power(char *out, size_t out_len) {
    out[0] = '\0';

    DBusError err;
    dbus_error_init(&err);

    DBusConnection *conn = dbus_bus_get_private(DBUS_BUS_SYSTEM, &err);
    if (!conn || dbus_error_is_set(&err)) {
        dbus_error_free(&err);
        return;
    }

    DBusMessage *msg = dbus_message_new_method_call(
        "net.hadess.PowerProfiles",
        "/net/hadess/PowerProfiles",
        "org.freedesktop.DBus.Properties",
        "Get"
    );
    if (!msg) {
        dbus_connection_close(conn);
        dbus_connection_unref(conn);
        return;
    }

    const char *iface = "net.hadess.PowerProfiles";
    const char *prop = "ActiveProfile";
    dbus_message_append_args(msg,
        DBUS_TYPE_STRING, &iface,
        DBUS_TYPE_STRING, &prop,
        DBUS_TYPE_INVALID);

    DBusMessage *reply = dbus_connection_send_with_reply_and_block(
        conn, msg, 1000, &err);
    dbus_message_unref(msg);

    if (!reply || dbus_error_is_set(&err)) {
        dbus_error_free(&err);
        dbus_connection_close(conn);
        dbus_connection_unref(conn);
        return;
    }

    DBusMessageIter iter, variant;
    dbus_message_iter_init(reply, &iter);
    dbus_message_iter_recurse(&iter, &variant);

    const char *profile = NULL;
    dbus_message_iter_get_basic(&variant, &profile);

    if (profile) {
        strncpy(out, profile, out_len - 1);
        out[out_len - 1] = '\0';
    }

    dbus_message_unref(reply);
    dbus_connection_close(conn);
    dbus_connection_unref(conn);
}
