import Audio from "resource:///com/github/Aylur/ags/service/audio.js";
import Widget from "resource:///com/github/Aylur/ags/widget.js";

export const Volume = () =>
  Widget.Label({
    className: "volume",
    label: "0",
    setup: (self) => {
      self.hook(
        Audio,
        () => {
          self.label = (100 * (Audio.speaker?.volume ?? 0)).toFixed(0);

          self.className = Audio.speaker?.stream.isMuted
            ? "volume muted"
            : "volume";
        },
        "speaker-changed",
      );
    },
  });
