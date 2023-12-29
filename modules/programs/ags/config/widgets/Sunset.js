import Widget from "resource:///com/github/Aylur/ags/widget.js";
import Variable from "resource:///com/github/Aylur/ags/variable.js";
import { execAsync } from "resource:///com/github/Aylur/ags/utils.js";

const sunsetState = Variable("auto");

export const Sunset = () =>
  Widget.Button({
    className: sunsetState.bind("value").transform((v) => `wlsunset ${v}`),
    child: Widget.Label("").bind("label", sunsetState, "value", (value) =>
      value === "auto" ? "" : value === "force_high" ? "" : "",
    ),
    onPrimaryClick: async () => {
      execAsync(["pkill", "-SIGUSR1", "wlsunset"]);
      sunsetState.setValue(
        sunsetState.value === "auto"
          ? "force_high"
          : sunsetState.value === "force_high"
          ? "force_low"
          : "auto",
      );
    },
  });
