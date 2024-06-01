;;; editor/meow/config.el -*- lexical-binding: t; -*-

(use-package! meow

;;; Loading

  ;; Eager-load Meow, so that if there are errors later in our config, at least
  ;; we have Meow set up to fix them.
  :demand t

  ;; Enable after modules have loaded.
  :hook (doom-after-modules-config . meow-global-mode)

  :init

;;; `meow-motion-remap-prefix'

  ;; Rebind all keys shadowed by Meow's Motion state to 'C-<key>'.
  ;; Different from the Meow default 'H-<key>', because how many users actually
  ;; have that key on their keyboard?
  ;; 'C-j' and 'C-k' are unlikely to be rebound by any modes as they're basic
  ;; editing keys. 'C-]' can't be remapped under the 'C-' prefix, but it's
  ;; unlikely that any mode will shadow `abort-recursive-edit'.
  (setq meow-motion-remap-prefix "C-")

  :config

;;; Cursor configuration

  ;; In Emacs, unlike Evil, the cursor is /between/ two characters, not on top
  ;; of a character. Since this module will likely attract a lot of Evil users,
  ;; use the 'bar' cursor shape instead of the default 'block' to reflect this
  ;; fact.
  ;; In addition, blink the cursor in insert state.

  (defvar my/meow-want-blink-cursor-in-insert t
    "Whether `blink-cursor-mode' should be enabled in INSERT state.")

  (setq meow-cursor-type-normal 'bar
        meow-cursor-type-insert 'bar
        meow-cursor-type-beacon 'bar
        meow-cursor-type-default 'box
        blink-cursor-delay 0 ; start blinking immediately
        blink-cursor-blinks 0 ; blink forever
        blink-cursor-interval 0.15) ; blink time period

  ;; Toggle blink on entering/exiting insert mode
  (add-hook 'meow-insert-mode-hook #'+meow-maybe-toggle-cursor-blink)

  ;; When we switch windows, the window we switch to may be in a different state
  ;; than the previous one
  (advice-add #'meow--on-window-state-change
              :after #'+meow-maybe-toggle-cursor-blink)

;;; Continuing commented lines

  ;; Since `meow-open-below' just runs `newline-and-indent', it will perform
  ;; Doom's behavior of continuing commented lines (if
  ;; `+default-want-RET-continue-comments' is non-nil). Prevent this.
  (defvar my/meow-want-meow-open-below-continue-comments nil
    "If non-nil `meow-open-below' will continue commented lines.")

  (defadvice! my/meow--newline-indent-and-continue-comments-a (&rest _)
    "Support `my/meow-want-meow-open-below-continue-comments'.
Doom uses `+default--newline-indent-and-continue-comments-a' to continue
comments. Prevent that from running if necessary."
    :before-while #'+default--newline-indent-and-continue-comments-a
    (interactive "*")
    (if (eq real-this-command #'meow-open-below)
        my/meow-want-meow-open-below-continue-comments
      t))

;;; Alternate states

  ;; Use a consistent key for exiting EMACS state and `meow-temp-normal'.
  ;; We use 'C-]' as our binding to toggle this state, both in Motion and Emacs
  ;; states. This binding was chosen based on the notion that it is rare to use
  ;; its default binding `abort-recursive-edit'. It is rare to encounter
  ;; recursive editing levels outside the minibuffer, and that specific case is
  ;; handled by `doom/escape'.
  ;; If it is really needed, `abort-recursive-edit' is also bound to `C-x X a'.

  (defvar +meow-alternate-state-key "C-]"
    "Key to switch to an alternate state in Meow.
- Invoke `meow-temp-normal' in Motion state
- In EMACS state, return to previous/Motion state.")

  (meow-motion-overwrite-define-key
   (cons +meow-alternate-state-key #'meow-temp-normal))

;;; Emacs state
  ;; Meow's Motion state, as configured by the suggested bindings, is mainly
  ;; useful in modes where moving the cursor between lines is meaningful, and
  ;; the mode doesn't bind SPC. For anything else, it tends to get in the way.
  ;; In such cases, it's best to configure our own bindings for the mode rather
  ;; than relying on Motion state.
  ;; In Meow, every mode starts in a particular state, defaulting to Motion. So,
  ;; if we want a mode to not have any Meow bindings, it needs to start in a
  ;; state without any bindings.
  ;; To this end, we define a custom EMACS state to switch to. This state will
  ;; have no bindings except one to switch back to the previous state (or to
  ;; Motion state if the buffer started in Emacs state), and a binding to invoke
  ;; Keypad state (we use M-SPC as it's unlikely to be bound by other modes, and
  ;; the default binding of `cycle-spacing' probably won't be relevant in the
  ;; special modes we're using this state for).

  (defvar +meow-emacs-state--previous nil
    "Meow state before switching to EMACS state.")

  (defface meow-emacs-cursor
    `((t (:inherit unspecified
          :background ,(face-foreground 'warning))))
    "BEACON cursor face."
    :group 'meow)

  (defvar meow-emacs-state-keymap
    (let ((map (make-sparse-keymap)))
      (define-key map (kbd +meow-alternate-state-key) #'+meow-toggle-emacs-state)
      (define-key map (kbd "M-SPC") #'meow-keypad)
      map)
    "Keymap for EMACS state.
Should only contain `+meow-toggle-emacs-state'.")

  (meow-define-state emacs
    "Meow EMACS state minor mode.
This is a custom state having no bindings except `+meow-toggle-emacs-state' and
`meow-keypad'."
    :lighter " [E]"
    :keymap meow-emacs-state-keymap
    :face meow-emacs-cursor)

  (defun +meow-toggle-emacs-state ()
    "Toggle EMACS state.
If EMACS state was manually switched to via this command, switch back to the
previous state. Otherwise, assume that the buffer started in EMACS state, and
switch to MOTION state."
    (interactive)
    (if (meow-emacs-mode-p)
        (progn
          (meow--switch-state
           (or +meow-emacs-state--previous 'motion))
          (setq +meow-emacs-state--previous nil))
      (setq +meow-emacs-state--previous meow--current-state)
      (meow--switch-state 'emacs)))

;;; misc. settings

  ;; Wait for longer before removing the expansion hints. One second is too
  ;; short, especially for people using them for the first time.
  (setq meow-expand-hint-remove-delay 4.0)

  ;; Don't self-insert keypad-mode keys if they're undefined, in order to be
  ;; consistent with Emacs' standard behavior with undefined keys.
  (setq meow-keypad-self-insert-undefined nil)

;;; Bindings

;;;; Suggested bindings

  (cond ((modulep! +qwerty) (+meow--setup-qwerty))
        ((modulep! +qwertz) (+meow--setup-qwertz))
        ((modulep! +dvorak) (+meow--setup-dvorak))
        ((modulep! +dvp) (+meow--setup-dvp))
        ((modulep! +colemak) (+meow--setup-colemak))
        (t nil))

;;;; Doom leader/localleader

  ;; FIXME: When these are invoked via Keypad, the descriptions of prefixes are
  ;; not shown. This could be a Doom problem, a general.el problem, or a
  ;; `meow--which-key-describe-keymap' problem.
  (when (modulep! :config default +bindings)

    ;; Make Meow use `doom-leader-map' instead of `mode-specific-map' as the
    ;; fallback for Keypad state. This allows us to use SPC in almost the same
    ;; way as in :editor evil.
    (setcdr (assq 'leader meow-keymap-alist) doom-leader-map)

    ;; A minor tweak - 'SPC c' will translate to 'C-c' rather than invoking
    ;; `doom-leader-code-map'. So we must use another prefix key. 'k' was chosen
    ;; because it wasn't already in use, and because it makes
    ;; `+lookup/documentation', a very handy command, easy to invoke
    ;; ('SPC k k').
    ;; (We need a hook since this module is loaded before the bindings are, due to ':demand')
    (add-hook! 'doom-after-modules-config-hook
      (defun +meow-leader-move-code-map-h ()
        (when (boundp 'doom-leader-code-map)
          (define-key doom-leader-map "k" (cons "code" doom-leader-code-map)))))

    ;; Also note that the Git commands are now under 'SPC v', unlike in
    ;; :editor evil.

    ;; Next, the localleader. For non-Evil users, this is invoked by 'C-c l'.
    ;; Since 'l' isn't used as a prefix in `doom-leader-map', we can use it as
    ;; the prefix for localleader. ('SPC m' would translate to 'M-' in Keypad
    ;; state, so we can't use it.)
    ;; I do not understand how Doom accomplishes the localleader bindings and do
    ;; not want to tangle with general.el, so we'll accomplish this with a HACK.
    ;;
    ;; Doom binds `doom-leader-map' under 'C-c' (the default value of
    ;; `doom-leader-alt-key'. Ideally we want to bind locallleader under this
    ;; prefix as well. Since we just freed up the 'c' prefix in
    ;; `doom-leader-map', we use that -
    (add-hook! 'doom-after-modules-config-hook
      (defun +meow-set-localleader-alt-key-h ()
        (setq doom-localleader-alt-key "C-c c")))
    ;;
    ;; Then, we define a command that calls 'C-c c', and bind it to 'l':
    (define-key doom-leader-map "l"
                (cons "+localleader" (cmd! (meow--execute-kbd-macro "C-c c"))))
    ;; ...and now the localleader bindings are accessible with 'SPC l' (or with
    ;; 'SPC c SPC c', for that matter).
    )

;;;; Layout-independent Rebindings

;;;;; Keypad

;;;;;; SPC u -> C-u
  ;; Like in Doom's evil config.
  (add-to-list 'meow-keypad-start-keys '(?u . ?u))

;;;;; 'M-SPC'

  ;; As in our EMACS state, make 'M-SPC' trigger the leader-key bindings in
  ;; Insert state.
  (meow-define-keys 'insert '("M-SPC" . meow-keypad))

;;;;; `+meow-escape'

  ;; By default, ESC does nothing in Meow normal state (bound to `ignore'). But
  ;; we need to run `doom-escape-hook' for things like :ui popup to function as
  ;; expected. In addition, it makes sense to extend `doom/escape's incremental
  ;; behavior to Meow.
  ;; Hence, `+meow-escape' - a command that cancels the selection if it's
  ;; active, otherwise falling back to `doom/escape'.
  ;; This also has the nice effect of requiring one less normal-state
  ;; keybinding - `meow-cancel-selection' is no longer needed as this command
  ;; invokes it when necessary, so the user can rebind 'g' if they want.
  (meow-normal-define-key '("<escape>" . +meow-escape))

;;;;; Esc in Motion state

  ;; Popups will be in Motion state, and Doom's popup management relies on
  ;; `doom-escape-hook'. So we can't have <escape> bound to `ignore'.
  (meow-motion-overwrite-define-key '("<escape>" . doom/escape))

;;;; Emacs tutorial
  ;; It teaches the default bindings, so make it start in our Emacs state.
  (defadvice! +meow-emacs-tutorial-a (&rest _)
    :after #'help-with-tutorial
    (+meow-toggle-emacs-state)
    (insert
     (propertize
      "Meow: this Tutorial buffer has been started in Emacs state. Meow
bindings are not active.\n\n"
      'face 'warning))))
