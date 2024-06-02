;;; editor/meow/autoload/meow-cursor.el -*- lexical-binding: t; -*-

;;;###autoload
(defun +meow-maybe-toggle-cursor-blink (&rest _)
  "Turn cursor blink on if in insert state, off otherwise."
  (when +meow-want-blink-cursor-in-insert
    (if (meow-insert-mode-p)
        (blink-cursor-mode +1)
      (blink-cursor-mode -1))))
