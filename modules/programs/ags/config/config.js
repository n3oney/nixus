import SystemTray from "resource:///com/github/Aylur/ags/service/systemtray.js";
import Widget from "resource:///com/github/Aylur/ags/widget.js";
import App from "resource:///com/github/Aylur/ags/app.js";
import { PowerMenu } from "./widgets/PowerMenu.js";
import { IdleInhibit } from "./widgets/IdleInhibit.js";
import { Clock } from "./widgets/Clock.js";
import { loadStyles } from "./utils/loadStyles.js";
import { Volume } from "./widgets/Volume.js";
import { BatteryState } from "./widgets/Battery.js";
import { Sunset } from "./widgets/Sunset.js";
import { GitHub } from "./widgets/GitHub.js";

loadStyles();

const SysTray = () =>
  Widget.Box({
    spacing: 8,
    children: SystemTray.bind("items").transform((items) => {
      return items.map((item) =>
        Widget.Button({
          child: Widget.Icon({ binds: [["icon", item, "icon"]] }),
          onPrimaryClick: (_, event) => item.openMenu(event),
          onSecondaryClick: (_, event) => item.openMenu(event),
          binds: [["tooltip-markup", item, "tooltip-markup"]],
        }),
      );
    }),
  });

const Left = () =>
  Widget.Box({
    hpack: "start",
    spacing: 8,
    children: [PowerMenu(), IdleInhibit()],
  });

const Center = () =>
  Widget.Box({
    spacing: 8,
    children: [Clock()],
  });

const Right = () =>
  Widget.Box({
    hpack: "end",
    spacing: 8,
    children: [SysTray(), GitHub(), Sunset(), BatteryState(), Volume()],
  });

const Bar = (monitor = 0) =>
  Widget.Window({
    name: `bar-${monitor}`,
    className: "bar-window",
    monitor,
    anchor: ["top", "left", "right"],
    exclusivity: "exclusive",
    child: Widget.CenterBox({
      className: "bar",
      startWidget: Left(),
      centerWidget: Center(),
      endWidget: Right(),
    }),
  });

export default {
  style: App.configDir + "/style.css",
  windows: [Bar()],
};
