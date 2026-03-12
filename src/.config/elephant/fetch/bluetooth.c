#include "bluetooth.h"
#include <dbus/dbus.h>

int fetch_bluetooth(void) {
    DBusError err;
    dbus_error_init(&err);

    DBusConnection *conn = dbus_bus_get_private(DBUS_BUS_SYSTEM, &err);
    if (!conn || dbus_error_is_set(&err)) {
        dbus_error_free(&err);
        return -1;
    }

    DBusMessage *msg = dbus_message_new_method_call(
        "org.bluez",
        "/org/bluez/hci0",
        "org.freedesktop.DBus.Properties",
        "Get"
    );
    if (!msg) {
        dbus_connection_close(conn);
        dbus_connection_unref(conn);
        return -1;
    }

    const char *iface = "org.bluez.Adapter1";
    const char *prop = "Powered";
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
        return -1;
    }

    DBusMessageIter iter, variant;
    dbus_message_iter_init(reply, &iter);
    dbus_message_iter_recurse(&iter, &variant);

    dbus_bool_t powered = 0;
    dbus_message_iter_get_basic(&variant, &powered);

    dbus_message_unref(reply);
    dbus_connection_close(conn);
    dbus_connection_unref(conn);

    return powered ? 1 : 0;
}
