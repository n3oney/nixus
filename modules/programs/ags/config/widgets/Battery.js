import Widget from "resource:///com/github/Aylur/ags/widget.js";
import Battery from "resource:///com/github/Aylur/ags/service/battery.js";

export const BatteryState = () =>
  Widget.Label({
    className: "battery",
    label: Battery.bind("percent").transform((v) => v.toFixed(0)),
    visible: Battery.bind("available"),
    setup: (self) => {
      self.hook(Battery, () => {
        self.className = `battery ${
          Battery.charged ? "full" : Battery.charging ? "charging" : ""
        }`;
      });
    },
  });
