import Widget from "resource:///com/github/Aylur/ags/widget.js";
import Variable from "resource:///com/github/Aylur/ags/variable.js";

const powerMenuHovered = Variable(false);

const ActionButton = ({ icon, className, command }) =>
  Widget.Button({
    child: Widget.Label(icon),
    className: className,
    onPrimaryClick: () => execAsync([command]),
  });

export const PowerMenu = () =>
  Widget.EventBox({
    onHover: () => powerMenuHovered.setValue(true),
    onHoverLost: () => powerMenuHovered.setValue(false),
    child: Widget.Box({
      className: "power",
      spacing: 8,
      children: [
        ActionButton({
          icon: "",
          command: "poweroff",
          className: "poweroff",
        }),
        Widget.Revealer({
          revealChild: false,
          transitionDuration: 550,
          transition: "slide_right",
          child: Widget.Box({
            children: [
              ActionButton({
                icon: "",
                className: "reboot",
                command: "reboot",
              }),
            ],
          }),
        }).bind("revealChild", powerMenuHovered, "value"),
      ],
    }),
  });
