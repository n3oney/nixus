import Widget from "resource:///com/github/Aylur/ags/widget.js";
import Variable from "resource:///com/github/Aylur/ags/variable.js";
import { execAsync } from "resource:///com/github/Aylur/ags/utils.js";
import { readFile } from "resource:///com/github/Aylur/ags/utils.js";
import Soup from "gi://Soup?version=3.0";
import GLib from "gi://GLib";
import Gio from "gi://Gio";

const gitHubToken = readFile("/var/run/user/1000/agenix/gh_notifications_key");

const githubNotifications = Variable(0);

const refreshNotifs = async () => {
  const session = new Soup.Session();

  const message = new Soup.Message({
    method: "GET",
    uri: GLib.Uri.parse(
      "https://api.github.com/notifications",
      GLib.UriFlags.NONE,
    ),
  });

  message
    .get_request_headers()
    .append("Authorization", `Bearer ${gitHubToken}`);
  message.get_request_headers().append("User-Agent", `ags-bar 1.0.0`);

  const inputStream = await session.send_async(message, 0, null);

  const outputStream = Gio.MemoryOutputStream.new_resizable();

  await outputStream.splice_async(
    inputStream,
    Gio.OutputStreamSpliceFlags.CLOSE_TARGET |
      Gio.OutputStreamSpliceFlags.CLOSE_SOURCE,
    GLib.PRIORITY_DEFAULT,
    null,
  );

  const gBytes = outputStream.steal_as_bytes();

  const text = new TextDecoder().decode(gBytes.toArray());

  const json = await JSON.parse(text);

  githubNotifications.setValue(json.length);
};

setInterval(refreshNotifs, 60_000);

refreshNotifs();

export const GitHub = () =>
  Widget.Button({
    className: githubNotifications
      .bind("value")
      .transform((v) => `github ${v === 0 ? "" : "unread"}`),
    child: Widget.Overlay({
      child: Widget.Label({ label: "", className: "bell" }),
      overlays: [
        Widget.Label({ label: "0", className: "count", vpack: "center" }).bind(
          "label",
          githubNotifications,
          "value",
          (v) => v.toString(),
        ),
      ],
    }),

    onPrimaryClick: async () => {
      await execAsync(["xdg-open", "https://github.com/notifications"]);
    },
  });
