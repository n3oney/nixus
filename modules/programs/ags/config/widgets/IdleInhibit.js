import Widget from "resource:///com/github/Aylur/ags/widget.js";
import Variable from "resource:///com/github/Aylur/ags/variable.js";
import { execAsync } from "resource:///com/github/Aylur/ags/utils.js";

const idleInhibited = Variable(false);

export const IdleInhibit = () =>
  Widget.Button({
    className: "idle-inhibit",
    child: Widget.Label("").bind("label", idleInhibited, "value", (v) =>
      v ? "" : "",
    ),
    onPrimaryClick: async () => {
      execAsync(
        idleInhibited.value
          ? ["bash", "-c", "pidof wlroots-idle-inhibit | xargs kill"]
          : [
              "bash",
              "-c",
              "hyprctl dispatch exec [workspace 69 silent] $(which wlroots-idle-inhibit)",
            ],
      );
      idleInhibited.setValue(!idleInhibited.value);
    },
  });
