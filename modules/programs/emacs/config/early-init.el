;; (setq native-comp-speed -1)

(setq exec-path (split-string (getenv "PATH") path-separator))

(menu-bar-mode -1)
(tool-bar-mode -1)

(setq user-emacs-directory
      (concat (file-name-as-directory
               (or (getenv "XDG_DATA_HOME") "~/.local/share"))
              "emacs"))
