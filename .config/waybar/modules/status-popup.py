#!/usr/bin/env python3

import atexit
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import time

import gi

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
gi.require_version("GtkLayerShell", "0.1")

from gi.repository import Gdk, GLib, Gtk, GtkLayerShell  # noqa: E402


MODE = sys.argv[1] if len(sys.argv) == 2 else ""
if MODE not in {"notifications", "power"}:
    raise SystemExit("usage: status-popup.py notifications|power")

RUNTIME_DIR = Path(os.environ.get("XDG_RUNTIME_DIR", "/tmp"))
STATE_PATH = RUNTIME_DIR / "waybar-status-popup.json"

CSS = b"""
window#status-popup {
  background: transparent;
}

.popup {
  background: rgba(24, 24, 37, 0.97);
  border: 1px solid #45475a;
  border-radius: 2px;
  padding: 14px;
  color: #cdd6f4;
  font-family: "JetBrainsMono Nerd Font";
  font-size: 11px;
}

.popup-title {
  color: #f5e0dc;
  font-size: 14px;
  font-weight: 800;
}

.popup-subtle {
  color: #a6adc8;
  font-size: 10px;
}

.popup-close,
.popup-button {
  background: #313244;
  border: 0;
  border-radius: 2px;
  color: #cdd6f4;
  padding: 7px 10px;
}

.popup-close:hover,
.popup-button:hover {
  background: #45475a;
}

.popup-close {
  padding: 4px 9px;
}

.notification-card {
  background: #1e1e2e;
  border: 1px solid #313244;
  border-radius: 2px;
  padding: 10px;
}

.notification-app {
  color: #89b4fa;
  font-size: 10px;
  font-weight: 700;
}

.notification-summary {
  color: #cdd6f4;
  font-size: 11px;
  font-weight: 800;
}

.notification-body {
  color: #bac2de;
  font-size: 10px;
}

.notification-state {
  background: #313244;
  border-radius: 2px;
  color: #a6adc8;
  font-size: 9px;
  padding: 2px 6px;
}

.power-button {
  font-size: 12px;
  padding: 12px;
}

.power-danger,
.confirm-button {
  color: #f38ba8;
}

.confirm-title {
  color: #f38ba8;
  font-size: 12px;
  font-weight: 800;
}

scrollbar slider {
  background: #585b70;
  border-radius: 2px;
  min-width: 5px;
}
"""


def add_class(widget, name):
    widget.get_style_context().add_class(name)
    return widget


def label(text, style=None, xalign=0):
    widget = Gtk.Label(label=text, xalign=xalign)
    if style:
        add_class(widget, style)
    return widget


def popup_process(pid):
    try:
        command = Path(f"/proc/{pid}/cmdline").read_bytes()
    except (FileNotFoundError, PermissionError, ProcessLookupError):
        return False
    return b"status-popup.py" in command


def read_state():
    try:
        state = json.loads(STATE_PATH.read_text())
        return int(state["pid"]), state["mode"]
    except (FileNotFoundError, KeyError, TypeError, ValueError, json.JSONDecodeError):
        return None


def claim_popup():
    state = read_state()
    if state and popup_process(state[0]):
        pid, existing_mode = state
        try:
            os.kill(pid, signal.SIGTERM)
        except ProcessLookupError:
            pass
        if existing_mode == MODE:
            return False
        for _ in range(20):
            if not popup_process(pid):
                break
            time.sleep(0.02)

    temporary = STATE_PATH.with_suffix(".tmp")
    temporary.write_text(json.dumps({"pid": os.getpid(), "mode": MODE}))
    temporary.replace(STATE_PATH)
    return True


def cleanup_state():
    state = read_state()
    if state and state[0] == os.getpid():
        STATE_PATH.unlink(missing_ok=True)


def run_json(command):
    try:
        result = subprocess.run(
            command, check=True, capture_output=True, text=True, timeout=2
        )
        data = json.loads(result.stdout)
        return data if isinstance(data, list) else []
    except (FileNotFoundError, subprocess.SubprocessError, json.JSONDecodeError):
        return []


class StatusPopup:
    def __init__(self):
        self.closing = False
        self.window = Gtk.Window()
        self.window.set_name("status-popup")
        self.window.set_decorated(False)
        self.window.set_resizable(False)
        self.window.set_size_request(430 if MODE == "notifications" else 360, -1)
        self.window.connect("delete-event", self.on_delete)
        self.window.connect("destroy", self.on_destroy)
        self.window.connect("focus-out-event", self.on_focus_out)
        self.window.connect("key-press-event", self.on_key_press)

        GtkLayerShell.init_for_window(self.window)
        GtkLayerShell.set_namespace(self.window, "waybar-status-popup")
        GtkLayerShell.set_layer(self.window, GtkLayerShell.Layer.OVERLAY)
        GtkLayerShell.set_anchor(self.window, GtkLayerShell.Edge.TOP, True)
        GtkLayerShell.set_anchor(self.window, GtkLayerShell.Edge.RIGHT, True)
        GtkLayerShell.set_margin(self.window, GtkLayerShell.Edge.TOP, 6)
        GtkLayerShell.set_margin(self.window, GtkLayerShell.Edge.RIGHT, 6)
        GtkLayerShell.set_keyboard_mode(
            self.window, GtkLayerShell.KeyboardMode.ON_DEMAND
        )

        display = Gdk.Display.get_default()
        monitors = [
            display.get_monitor(index) for index in range(display.get_n_monitors())
        ]
        if monitors:
            monitor = max(monitors, key=lambda item: item.get_geometry().x)
            GtkLayerShell.set_monitor(self.window, monitor)

        provider = Gtk.CssProvider()
        provider.load_from_data(CSS)
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        self.revealer = Gtk.Revealer()
        self.revealer.set_transition_type(Gtk.RevealerTransitionType.SLIDE_DOWN)
        self.revealer.set_transition_duration(160)
        self.revealer.add(self.build_panel())
        self.revealer.set_reveal_child(True)
        self.window.add(self.revealer)
        self.window.set_opacity(0)
        self.window.show_all()
        GLib.timeout_add(16, self.fade_in)

    def build_panel(self):
        panel = add_class(
            Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12), "popup"
        )

        header = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        title = "Notifications" if MODE == "notifications" else "Power"
        header.pack_start(label(title, "popup-title"), True, True, 0)
        close = add_class(Gtk.Button(label="Close"), "popup-close")
        close.connect("clicked", self.request_close)
        header.pack_end(close, False, False, 0)
        panel.pack_start(header, False, False, 0)

        self.body = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        panel.pack_start(self.body, True, True, 0)
        if MODE == "notifications":
            self.build_notifications()
        else:
            self.build_power_actions()
        return panel

    def replace_body(self, widget):
        for child in self.body.get_children():
            self.body.remove(child)
        self.body.pack_start(widget, True, True, 0)
        self.body.show_all()

    def build_notifications(self):
        active = run_json(["makoctl", "list", "-j"])
        history = run_json(["makoctl", "history", "-j"])
        active_ids = {item.get("id") for item in active}
        notifications = {
            item.get("id"): item for item in history if item.get("id") is not None
        }
        notifications.update(
            {item.get("id"): item for item in active if item.get("id") is not None}
        )
        items = sorted(
            notifications.values(), key=lambda item: item.get("id", 0), reverse=True
        )

        content = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        if not items:
            empty = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
            empty.set_border_width(18)
            empty.pack_start(
                label("No recent notifications", "notification-summary", 0.5),
                False,
                False,
                0,
            )
            empty.pack_start(
                label("New notifications will appear here.", "popup-subtle", 0.5),
                False,
                False,
                0,
            )
            content.pack_start(empty, False, False, 0)
        else:
            for item in items[:12]:
                content.pack_start(
                    self.notification_card(item, item.get("id") in active_ids),
                    False,
                    False,
                    0,
                )

        scroller = Gtk.ScrolledWindow()
        scroller.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        scroller.set_propagate_natural_height(True)
        scroller.set_max_content_height(540)
        scroller.add(content)

        wrapper = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        wrapper.pack_start(scroller, True, True, 0)
        if history or items:
            footer = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        if history:
            restore = add_class(Gtk.Button(label="Restore latest"), "popup-button")
            restore.connect("clicked", self.restore_latest)
            footer.pack_start(restore, True, True, 0)
        if items:
            clear = add_class(Gtk.Button(label="Clear all"), "popup-button")
            add_class(clear, "confirm-button")
            clear.connect("clicked", self.clear_all)
            footer.pack_start(clear, True, True, 0)
        if history or items:
            wrapper.pack_start(footer, False, False, 0)
        self.replace_body(wrapper)

    def notification_card(self, item, active):
        card = add_class(
            Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5),
            "notification-card",
        )
        top = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        app_name = str(item.get("app_name") or "Notification")
        top.pack_start(label(app_name, "notification-app"), True, True, 0)
        top.pack_end(
            label("Now" if active else "Recent", "notification-state"), False, False, 0
        )
        card.pack_start(top, False, False, 0)

        summary = str(item.get("summary") or "(No summary)")
        summary_label = label(summary, "notification-summary")
        summary_label.set_line_wrap(True)
        summary_label.set_max_width_chars(52)
        card.pack_start(summary_label, False, False, 0)

        body = " ".join(str(item.get("body") or "").split())
        if len(body) > 320:
            body = body[:317].rstrip() + "..."
        if body:
            body_label = label(body, "notification-body")
            body_label.set_line_wrap(True)
            body_label.set_max_width_chars(58)
            card.pack_start(body_label, False, False, 0)
        return card

    def build_power_actions(self):
        actions = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        for title, command, danger in (
            ("Suspend", ["systemctl", "suspend"], False),
            ("Reboot", ["systemctl", "reboot"], True),
            ("Power off", ["systemctl", "poweroff"], True),
        ):
            button = add_class(Gtk.Button(label=title), "popup-button")
            add_class(button, "power-button")
            if danger:
                add_class(button, "power-danger")
                button.connect("clicked", self.confirm_action, title, command)
            else:
                button.connect("clicked", self.run_action, command)
            actions.pack_start(button, False, False, 0)
        self.replace_body(actions)

    def confirm_action(self, _button, title, command):
        confirmation = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        confirmation.pack_start(
            label(f"{title}?", "confirm-title", 0.5), False, False, 0
        )
        confirmation.pack_start(
            label("This action affects the entire session.", "popup-subtle", 0.5),
            False,
            False,
            0,
        )

        buttons = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        cancel = add_class(Gtk.Button(label="Cancel"), "popup-button")
        cancel.connect("clicked", lambda _button: self.build_power_actions())
        confirm = add_class(Gtk.Button(label=title), "popup-button")
        add_class(confirm, "confirm-button")
        confirm.connect("clicked", self.run_action, command)
        buttons.pack_start(cancel, True, True, 0)
        buttons.pack_start(confirm, True, True, 0)
        confirmation.pack_start(buttons, False, False, 0)
        self.replace_body(confirmation)

    def restore_latest(self, _button):
        subprocess.run(["makoctl", "restore"], check=False)
        self.request_close()

    def clear_all(self, _button):
        subprocess.run(["makoctl", "dismiss", "--all", "--no-history"], check=False)
        for _ in range(100):
            if not run_json(["makoctl", "history", "-j"]):
                break
            if subprocess.run(["makoctl", "restore"], check=False).returncode != 0:
                break
            subprocess.run(["makoctl", "dismiss", "--no-history"], check=False)
        self.build_notifications()

    def run_action(self, _button, command):
        subprocess.Popen(command)
        self.request_close()

    def fade_in(self):
        opacity = min(1, self.window.get_opacity() + 0.14)
        self.window.set_opacity(opacity)
        return opacity < 1

    def fade_out(self):
        opacity = max(0, self.window.get_opacity() - 0.16)
        self.window.set_opacity(opacity)
        if opacity == 0:
            self.window.destroy()
            return False
        return True

    def request_close(self, *_args):
        if self.closing:
            return False
        self.closing = True
        GLib.timeout_add(16, self.fade_out)
        return False

    def on_delete(self, *_args):
        self.request_close()
        return True

    def on_destroy(self, *_args):
        cleanup_state()
        Gtk.main_quit()

    def on_focus_out(self, *_args):
        GLib.timeout_add(80, self.close_if_inactive)
        return False

    def close_if_inactive(self):
        if not self.window.is_active():
            self.request_close()
        return False

    def on_key_press(self, _window, event):
        if event.keyval == Gdk.KEY_Escape:
            self.request_close()
            return True
        return False


if not claim_popup():
    raise SystemExit(0)

atexit.register(cleanup_state)
popup = StatusPopup()
signal.signal(signal.SIGTERM, lambda *_args: GLib.idle_add(popup.request_close))
Gtk.main()
