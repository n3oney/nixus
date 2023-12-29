import Widget from "resource:///com/github/Aylur/ags/widget.js";
import { execAsync } from "resource:///com/github/Aylur/ags/utils.js";

export const Clock = () =>
  Widget.Box({
    vertical: true,
    children: [
      Widget.Label({
        className: "time",
        setup: (self) =>
          self.poll(1000, (self) =>
            execAsync(["date", "+%H:%M"]).then((date) => (self.label = date)),
          ),
      }),
      Widget.Label({
        className: "date",
        setup: (self) =>
          self.poll(1000, (self) =>
            execAsync(["date", "+%B %d"]).then((date) => (self.label = date)),
          ),
      }),
    ],
  });
