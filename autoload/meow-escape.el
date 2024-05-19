;;; editor/meow/autoload/meow-escape.el -*- lexical-binding: t; -*-

;;;###autoload
(defun +meow-escape ()
  "Call `meow-cancel-selection', else fallback to `doom/escape'."
  (interactive)
  (if (region-active-p)
      (meow-cancel-selection)
    (call-interactively #'doom/escape)))
