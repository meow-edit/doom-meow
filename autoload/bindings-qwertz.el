;;; editor/meow/autoload/bindings-qwertz.el -*- lexical-binding: t; -*-

;;;###autoload
(defun +meow--setup-qwertz ()
  (setq meow-cheatsheet-physical-layout meow-cheatsheet-physical-layout-iso)
  (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwertz)

  (meow-thing-register 'angle
                       '(pair (";") (":"))
                       '(pair (";") (":")))

  (setq meow-char-thing-table
        '((?f . round)
          (?d . square)
          (?s . curly)
          (?a . angle)
          (?r . string)
          (?v . paragraph)
          (?c . line)
          (?x . buffer)))

  (meow-leader-define-key
   ;; Use SPC (0-9) for digit arguments.
   '("1" . meow-digit-argument)
   '("2" . meow-digit-argument)
   '("3" . meow-digit-argument)
   '("4" . meow-digit-argument)
   '("5" . meow-digit-argument)
   '("6" . meow-digit-argument)
   '("7" . meow-digit-argument)
   '("8" . meow-digit-argument)
   '("9" . meow-digit-argument)
   '("0" . meow-digit-argument)
   '("-" . meow-keypad-describe-key)
   '("_" . meow-cheatsheet))

  (meow-normal-define-key
   ;; expansion
   '("0" . meow-expand-0)
   '("1" . meow-expand-1)
   '("2" . meow-expand-2)
   '("3" . meow-expand-3)
   '("4" . meow-expand-4)
   '("5" . meow-expand-5)
   '("6" . meow-expand-6)
   '("7" . meow-expand-7)
   '("8" . meow-expand-8)
   '("9" . meow-expand-9)
   '("ä" . meow-reverse)

   ;; movement
   '("i" . meow-prev)
   '("k" . meow-next)
   '("j" . meow-left)
   '("l" . meow-right)

   '("z" . meow-search)
   '("-" . meow-visit)

   ;; expansion
   '("I" . meow-prev-expand)
   '("K" . meow-next-expand)
   '("J" . meow-left-expand)
   '("L" . meow-right-expand)

   '("u" . meow-back-word)
   '("U" . meow-back-symbol)
   '("o" . meow-next-word)
   '("O" . meow-next-symbol)

   '("a" . meow-mark-word)
   '("A" . meow-mark-symbol)
   '("s" . meow-line)
   '("S" . meow-goto-line)
   '("w" . meow-block)
   '("q" . meow-join)
   '("g" . meow-grab)
   '("G" . meow-pop-grab)
   '("m" . meow-swap-grab)
   '("M" . meow-sync-grab)
   '("p" . meow-cancel-selection)
   '("P" . meow-pop-selection)

   '("x" . meow-till)
   '("y" . meow-find)

   '("," . meow-beginning-of-thing)
   '("." . meow-end-of-thing)
   '(";" . meow-inner-of-thing)
   '(":" . meow-bounds-of-thing)

   ;; editing
   '("d" . meow-kill)
   '("f" . meow-change)
   '("t" . meow-delete)
   '("c" . meow-save)
   '("v" . meow-yank)
   '("V" . meow-yank-pop)

   '("e" . meow-insert)
   '("E" . meow-open-above)
   '("r" . meow-append)
   '("R" . meow-open-below)

   '("h" . undo-only)
   '("H" . undo-redo)

   '("b" . open-line)
   '("B" . split-line)

   '("ü" . indent-rigidly-left-to-tab-stop)
   '("+" . indent-rigidly-right-to-tab-stop)

   ;; ignore escape
   '("<escape>" . ignore)))
