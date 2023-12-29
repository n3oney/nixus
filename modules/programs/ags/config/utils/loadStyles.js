import * as Utils from "resource:///com/github/Aylur/ags/utils.js";
import App from "resource:///com/github/Aylur/ags/app.js";

export const loadStyles = () => {
  const scss = `${App.configDir}/style/style.scss`;

  // target css file
  const css = `${App.configDir}/style.css`;

  Utils.exec(`sassc ${scss} ${css}`);

  Utils.monitorFile(
    // directory that contains the scss files
    `${App.configDir}/style`,

    // reload function
    function () {
      Utils.exec(`sassc ${scss} ${css}`);
      App.resetCss();
      App.applyCss(css);
    },

    // specify that its a directory
    "directory",
  );
};
