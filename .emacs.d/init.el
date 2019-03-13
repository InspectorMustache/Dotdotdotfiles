;; get rid of the custom blabla by using custom-file
(defconst custom-file (expand-file-name "custom.el" user-emacs-directory))
(unless (file-exists-p custom-file)
  (write-region "" "" custom-file))

;; set up default browser
(setq browse-url-generic-program "qutebrowser")
(setq browse-url-browser-function 'browse-url-generic)

;; use more conservative sentence definition
(setq sentence-end-double-space nil)

;; set up a separate location for backup and temp files
(defconst emacs-tmp-dir (expand-file-name "auto-save" user-emacs-directory))
(setq backup-directory-alist
      `((".*" . ,emacs-tmp-dir)))
(setq auto-save-file-name-transforms
      `((".*" ,(concat emacs-tmp-dir "/\\1") t)))
    (setq auto-save-list-file-prefix
      emacs-tmp-dir)

;; enable sourcing from init scripts in emacs.d/subinits
(add-to-list 'load-path (expand-file-name "subinits" user-emacs-directory))

;; source custom functions early
(require 'init-my-functions)

;; setup package management with straight.el and use-package
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)
(setq straight-use-package-by-default t)

(require 'init-gui-setup)

;; Indentation settings (no TABs)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

;; load up org-mode with workarounds
(require 'init-org-mode)

;; tramp settings (so far not many)
(setq tramp-default-method "ssh")
(add-hook 'find-file-hook
          (lambda ()
            (when (file-remote-p default-directory)
              (my/source-ssh-env))))

;; various mode setting options
(add-to-list 'auto-mode-alist '(".gitignore" . prog-mode))

;; eshell settings
(setq eshell-banner-message "")
(add-hook 'eshell-exit-hook (lambda ()
                              (when
                                  (string= (buffer-name (window-buffer (selected-window)))
                                           "*eshell*")
                                (delete-window))))

;; spellchecking settings
(setq ispell-program-name "hunspell")
(setq ispell-local-dictionary "de_DE")
(setq ispell-local-dictionary-alist
      '(("German (Germany)" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil ("-d" "de_DE"))
        ("English (US)" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil ("-d" "en_US") nil utf-8)
        ("English (Australia)" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil ("-d" "en_AU") nil utf-8)))

;; delimiter highlighting and matching
(setq electric-pair-open-newline-between-pairs t)
(my/add-hooks 'electric-pair-mode '(prog-mode-hook text-mode-hook))
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; sexier builtin help
(use-package helpful
  :defer t
  :config
  (setq helpful-switch-buffer-function 'my/helpful-buffer-other-window)
  (setq helpful-max-buffers 2)


  ;; helpful related functions
  (defun my/helpful-buffer-other-window (buf)
    "Display helpful buffer BUF the way I want it, ie:
Replace buffer/window if in helpful-mode, lazy-open otherwise."
    (let (sw)
      (if (eq major-mode 'helpful-mode)
          (progn
            (quit-window)
            (pop-to-buffer buf))
        (progn (setq sw (selected-window))
               (switch-to-buffer-other-window buf)))
      (helpful-update)
      (when sw (select-window sw)))))

;; vimperator-style link-hints
(use-package link-hint
  :commands link-hint-open-link)

(use-package magit
  :commands magit-status
  :hook ((magit-mode . my/source-ssh-env)
         (with-editor-mode . evil-insert-state)))

(use-package pcre2el
  :defer t)

(use-package quickrun
  :commands quickrun
  :config
  (setq quickrun-focus-p nil))

(use-package shackle
  :config
  (shackle-mode 1)
  (setq shackle-rules
        '(("*eshell*"
           :regexp t :select t :popup t :align below :size 0.2)
          ("^\\*ansi-term.*"
           :regexp t :select t :popup t :align below :size 0.2)
          ('inferior-python-mode
           :select t :popup t :align below :size 0.2))))

(use-package visual-regexp-steroids
  :commands (vr/replace vr/query-replace vr/isearch-forward vr/isearch-backward)
  :after pcre2el
  :config
  (setq vr/engine 'pcre2el))

(require 'init-ivy)

(require 'init-evil)

(require 'init-language-specific)

(require 'init-keybinds)

;; open todo.org on startup
(add-hook 'after-init-hook (lambda ()
                             (find-file (expand-file-name "~/Sync/Diverses/todo.org" (getenv "HOME")))
                             (org-cycle)))
