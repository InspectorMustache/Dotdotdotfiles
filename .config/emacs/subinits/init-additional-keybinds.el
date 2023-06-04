;; -*- lexical-binding: t -*-

;; any additional keybindings that are not defined in any package declarations
;; go into this file

;; evil-collection loads for packages without use-package declarations
(with-eval-after-load 'xref (evil-collection-xref-setup))

;; use these EVERYWHERE
(general-def
  :keymaps          'override
  :states           '(motion emacs)
  "M-o"             'delete-other-windows
  "M-i"             '°restore-window-layout
  "M-O"             '°window-clear-side)

;; global F-key binds
(general-def
  :keymaps          'override
  "<f12>"           '°straight-update)

;; window navigation
(general-def
  :keymaps         'override
  :states          '(motion emacs)
  "M-c"            'evil-window-delete
  "M-h"            'evil-window-left
  "M-j"            'evil-window-down
  "M-k"            'evil-window-up
  "M-l"            'evil-window-right
  "M-H"            'evil-window-move-far-left
  "M-J"            'evil-window-move-very-bottom
  "M-K"            'evil-window-move-very-top
  "M-L"            'evil-window-move-far-right)

(general-leader
  :keymaps        'override
  :states         'motion
  "<tab>"         'evil-switch-to-windows-last-buffer)

(general-goleader
  :states         'motion
  :keymaps        'Info-mode-map
  "g"             'evil-goto-first-line)

;; normal state keybinds
(general-def
  :keymaps          'normal
  "<escape>"       (general-l
                     (evil-ex-nohighlight)
                     (evil-force-normal-state))
  "ö"              '°evil-dry-open-below
  "Ö"              '°evil-dry-open-above

  "_"               'goto-last-change
  "-"               'goto-last-change-reverse)

(general-goleader
  :keymaps          'normal
  "I"               'imenu)

(general-goleader
  :keymaps          'motion
  "s"               '°toggle-scratch-buffer
  "S"               (general-l
                      (°split-window-and-do
                       (°toggle-scratch-buffer)))
  "I"               'imenu)

(general-leader
  :states         'normal
  "P"             '°evil-paste-with-newline-above
  "p"             '°evil-paste-with-newline-below)

;; motion state bindings
(general-def
  :keymaps         'motion
  "("              'evil-backward-paragraph
  ")"              'evil-forward-paragraph
  "C-u"            'evil-scroll-up
  "<escape>"       (general-l
                     (evil-ex-nohighlight)
                     (evil-force-normal-state))
  "{"              'evil-backward-sentence-begin
  "}"              'evil-forward-sentence-begin)

(general-leader
  :keymaps          'motion
  "rc"              (general-l
                      (find-file (expand-file-name "init.el" user-emacs-directory)))
  "hg"              (general-l
                      (°split-window-and-do
                       (info "elisp")))
  "hG"              (general-l
                      (°split-window-and-do
                       (info-emacs-manual)))
  "hb"              'describe-bindings
  "hm"              'describe-mode
  "b"               (general-l
                      (let ((completion-regexp-list '("^[^*]")))
                        (call-interactively 'switch-to-buffer)))
  "k"               'kill-this-buffer
  "K"               'kill-buffer-and-window
  "q"               'find-file
  "v"             'evil-window-split
  "s"             'evil-window-vsplit
  "S"             (general-l
                    (evil-window-vsplit) (evil-window-right 1))
  "V"             (general-l
                    (evil-window-split) (evil-window-down 1)))

;; insert state keybinds
(general-def
  :keymaps          'insert
  "C-n"             nil
  "C-p"             nil
  "C-a"             'move-beginning-of-line
  "C-e"             'move-end-of-line
  "C-S-f"           'forward-word
  "C-S-b"           'backward-word
  "<backtab>"       'indent-relative
  "C-j"             'newline)

;; visual state keybinds
(general-def
  :keymaps         'visual
  "*"              (lambda (count)
                     (interactive "P")
                     (°evil-search-visual-selection 'forward count))
  "#"              (lambda (count)
                     (interactive "P")
                     (°evil-search-visual-selection 'backward count)))

;; isearch keybinds
(general-def
  :keymaps          'isearch-mode-map
  "C-S-s"           'isearch-repeat-backward)

;;  evil-ex and minibuffer keybinds
(general-def
  :keymaps          '(evil-ex-completion-map evil-ex-search-keymap read-expression-map
                                             minibuffer-local-map)
  "C-a"             'move-beginning-of-line
  "C-e"             'move-end-of-line
  "C-f"             'forward-char
  "C-b"             'backward-char
  "C-S-f"           'forward-word
  "C-S-b"           'backward-word
  "C-d"             'delete-char
  "C-S-d"           'kill-word
  "M-k"             'previous-line-or-history-element
  "M-j"             'next-line-or-history-element
  "C-v"             'yank
  "C-M-v"           'yank-pop
  "<escape>"        'abort-recursive-edit)

(general-def
  :states           'normal
  :keymaps          'view-mode-map
  "q"               'View-quit)
;; i don't know why this is necessary...?
(add-hook 'view-mode-hook (general-l (use-local-map view-mode-map)))

;; dired keybinds
(general-def
  :keymaps          'dired-mode-map
  "SPC"             nil
  "t"               '°dired-mark-toggle
  "T"               'dired-toggle-marks)

;; Info-mode keybinds
(general-def
  :states           'motion
  :keymaps          'Info-mode-map
  "p"               'Info-prev
  "n"               'Info-next
  "m"               'Info-menu
  "K"               'Info-up
  "q"               'kill-buffer-and-window)

(general-goleader
  :states           'motion
  :keymaps          'Info-mode-map
  "n"               'Info-goto-node)

;; (emacs-)lisp keybindings
(general-leader
  :states           'motion
  :keymaps          'lisp-mode-shared-map
  "e"               '°eval-at-point
  "E"               '°eval-line
  "M-e"             'eval-buffer
  "C-e"             'eval-defun)

;; python keybinds
(general-leader
  :states           'normal
  :keymaps          'python-mode-map
  "C-$"             'run-python
  "cB"              '°python-remove-breakpoints
  "S-<return>"      (general-l
                      (if (string-match-p "^test_" (buffer-file-name))
                          '°python-test
                        'quickrun)))

(general-def
  :states           'insert
  :keymaps          'inferior-python-mode-map
  "<return>"        'comint-send-input)

(general-leader
  :states           'visual
  :keymaps          'lisp-mode-shared-map
  "e"               '°eval-visual-region)

(provide 'init-additional-keybinds)
