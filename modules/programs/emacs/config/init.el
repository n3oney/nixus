;; Use spaces instead of tabs for indentation
(setq-default indent-tabs-mode nil)

;; Set the default indentation width
(setq-default tab-width 2)

;; Set standard indent to the same value as tab-width
(setq-default standard-indent 2)

(require 'use-package)

;; Vim Emulation
(use-package evil
  :init
  (setq evil-want-C-u-scroll t
        evil-mode-beyond-eol t
	evil-mode-fine-undo t
	evil-undo-system 'undo-redo
	evil-want-keybinding nil)
  :config
  (evil-mode 1)
  )

;; Allow config reload with a keybind  
(defun reload-init-file ()
  (interactive)
  (load-file "~/.config/emacs/init.el"))

(define-key evil-normal-state-map (kbd "SPC c r") 'reload-init-file)

;; Catppuccin :3
(use-package catppuccin-theme
  :init
  (setq catppuccin-flavor 'macchiato)
  :config
  (load-theme 'catppuccin :no-confirm))

;; Keybind help
(use-package which-key
  :init
  (setq which-key-idle-delay 0.01)
  :config
  (which-key-mode))

;; Load environment from direnv
(use-package direnv
  :config (direnv-mode))

(use-package nix-mode
  :mode "\\.nix\\'"
  :hook (nix-mode . disable-tabs))

(use-package rust-mode
  :mode "\\.rs\\'"
  :hook (rust-mode . disable-tabs))

(use-package lsp-mode
  ;; :init
  ;; (setq lsp-nix-nil-server-path (executable-find "nil"))
  :hook (nix-mode . lsp-deferred)
  :hook (rust-mode . lsp-deferred)
  :commands (lsp lsp-deferred)
  :config
  (define-key evil-normal-state-map (kbd "SPC r") #'lsp-rename)
  (define-key evil-normal-state-map (kbd "SPC a") #'lsp-execute-code-action))
