;;; editor/meow/autoload/emacs-state.el -*- lexical-binding: t; -*-
;; Meow's Motion state, as configured by the suggested bindings, is mainly
;; useful in modes where moving the cursor between lines is meaningful, and
;; the mode doesn't bind SPC. For anything else, it tends to get in the way.
;; In such cases, it's best to configure our own bindings for the mode rather
;; than relying on Motion state.
;; In Meow, every mode starts in a particular state, defaulting to Motion. So,
;; if we want a mode to not have any Meow bindings, it needs to start in a state
;; without any bindings.
;; To this end, we define a custom EMACS state to switch to. This state will
;; have no bindings except one to switch back to the previous state (or to
;; Motion state if the buffer started in Emacs state).

(defvar +meow-emacs-state--previous nil
  "Meow state before switching to EMACS state.")

(defface meow-emacs-cursor
  `((t (:inherit unspecified
        :background ,(face-foreground 'warning))))
  "BEACON cursor face."
  :group 'meow)


(defvar-keymap meow-emacs-state-keymap
  :doc "Keymap for EMACS state.
Should only contain `+meow-toggle-emacs-state'."
  ;; We use 'C-]' as our binding to toggle this state, both in Motion and Emacs
  ;; states. This binding was chosen based on the notion that it is rare to use
  ;; its default binding `abort-recursive-edit'. It is rare to encounter
  ;; recursive editing levels outside the minibuffer, and that specific case is
  ;; handled by `doom/escape'.
  ;; If it is really needed, `abort-recursive-edit' is also bound to `C-x X a'.
  +meow-alternate-state-key #'+meow-toggle-emacs-state)

(meow-define-state emacs
  "Meow EMACS state minor mode.
This is a custom state having no bindings except `+meow-toggle-emacs-state'."
  :lighter " [E]"
  :keymap meow-emacs-state-keymap
  :face meow-emacs-cursor)

;;;###autoload
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
