import Widget from "resource:///com/github/Aylur/ags/widget.js";
import Utils from "resource:///com/github/Aylur/ags/utils.js";
import GLib from "gi://GLib";

// Use pactl/wpctl instead of AGS Audio service to avoid libgvc crash
// when Bluetooth state changes (gvc_mixer_stream_get_port assertion failure)

const getVolume = () => {
  try {
    const out = Utils.exec("wpctl get-volume @DEFAULT_AUDIO_SINK@");
    // Output format: "Volume: 0.36" or "Volume: 0.36 [MUTED]"
    const match = out.match(/Volume:\s*([\d.]+)(\s*\[MUTED\])?/);
    if (match) {
      const volume = Math.round(parseFloat(match[1]) * 100);
      const muted = !!match[2];
      return { volume, muted };
    }
  } catch (e) {
    // wpctl failed, return default
  }
  return { volume: 0, muted: false };
};

export const Volume = () =>
  Widget.Label({
    className: "volume",
    label: "0",
    setup: (self) => {
      let debounceId = null;

      const update = () => {
        const { volume, muted } = getVolume();
        self.label = volume.toString();
        self.className = muted ? "volume muted" : "volume";
      };

      const debouncedUpdate = () => {
        if (debounceId) {
          GLib.source_remove(debounceId);
        }
        // Small debounce to coalesce rapid events during device changes
        debounceId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 50, () => {
          debounceId = null;
          update();
          return GLib.SOURCE_REMOVE;
        });
      };

      // Initial update (with small delay to ensure PipeWire is ready)
      GLib.timeout_add(GLib.PRIORITY_DEFAULT, 100, () => {
        update();
        return GLib.SOURCE_REMOVE;
      });

      // Subscribe to PulseAudio events via pactl (avoids libgvc)
      const proc = Utils.subprocess(
        ["pactl", "subscribe"],
        (line) => {
          // Filter for sink events (volume/mute changes)
          if (line.includes("sink") || line.includes("server")) {
            debouncedUpdate();
          }
        },
        (err) => {
          // pactl subscribe failed, fall back to polling
          console.log("pactl subscribe failed, falling back to polling");
          self.poll(1000, update);
        },
      );

      // Cleanup on destroy
      self.connect("destroy", () => {
        proc.force_exit();
        if (debounceId) {
          GLib.source_remove(debounceId);
        }
      });
    },
  });
