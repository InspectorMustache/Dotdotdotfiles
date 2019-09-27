;; sexier builtin help
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

;; tramp settings (so far not many)
(setq tramp-default-method "ssh")
(add-hook 'find-file-hook
          (lambda ()
            (when (file-remote-p default-directory)
              (my/source-ssh-env))))

(use-package all-the-icons
  :defer t)

(use-package f)

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

(use-package restart-emacs
  :commands restart-emacs)

(use-package visual-regexp-steroids
  :commands (vr/replace vr/query-replace vr/isearch-forward vr/isearch-backward)
  :after pcre2el
  :config
  (setq vr/engine 'pcre2el))

;; use locally installed package (from AUR) of emacs-vterm
(use-package vterm
  :straight nil
  :commands my/vterm
  :config
  (defun my/vterm ()
    "Hide or show vterm window.
Start terminal if it isn't running already."
    (interactive)
    (let* ((vterm-buf "vterm")
           (vterm-win (get-buffer-window vterm-buf)))
      (if vterm-win
          (progn
            (select-window vterm-win)
            (ignore-errors
              (delete-process vterm--process))
            (while (process-live-p vterm--process)
              (ignore))
            (kill-this-buffer)
            (delete-window))
        (if (get-buffer vterm-buf)
            (pop-to-buffer vterm-buf)
          (vterm-other-window))
        (evil-insert-state)))))


(provide 'init-emacs-extensions)