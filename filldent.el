;;; filldent.el --- fill or indent                  -*- lexical-binding: t; -*-

;; Copyright (C) 2021 Case Duckworth

;; Author: Case Duckworth <acdw@acdw.net>

;;; License:

;; Everyone is permitted to do whatever with this software, without
;; limitation.  This software comes without any warranty whatsoever,
;; but with two pieces of advice:

;; - Be kind to yourself.

;; - Make good choices.

;;; Commentary:

;; From a converstion in #emacs, where someone was confused about M-q
;; vs. C-M-\.  I realized that we rarely want to indent prose, or fill
;; programming, so let's do a dwim-style thing.  That's filldent.

;; Apparently `paredit' already has a binding like this, set to M-q.  Very
;; interesting.

;;; Code:

;;; Variables

(defgroup filldent nil
  "Fill or indent buffer text depending on mode."
  :prefix "filldent-"
  :group 'convenience)

(defcustom filldent-fill-modes '(tex-mode text-mode)
  "Modes in which `filldent-dwim' and friends will fill.
Recommended: text-ish modes."
  :type '(repeat function))

(defcustom filldent-indent-modes '(prog-mode)
  "Modes in which `filldent-dwim' and friends will indent.
Recommended: prog-ish modes."
  :type '(repeat function))

(defcustom filldent-default 'fill
  "What to do if confused.
If a mode doesn't derive from any of the modes in `filldent-fill-modes' or `filldent-indent-modes', this defines the default thing to do.

Possible values are `fill' and `indent'."
  :type '(choice (const :tag "Fill" 'fill)
                 (const :tag "Indent" 'indent)))

;;; Functions

(defun filldent--type (&optional buffer)
  "Determine what type of buffer we're in.
BUFFER can be the name of a buffer, a buffer object, but defaults
to the current buffer.  This function returns the symbol `fill'
or `indent'."
  (with-current-buffer (or buffer (current-buffer))
    (cond
     ((apply #'derived-mode-p filldent-fill-modes)
      'fill)
     ((apply #'derived-mode-p filldent-indent-modes)
      'indent)
     (t filldent-default))))

(defun filldent-region (beg end &optional arg)
  "Filldent region from BEG to END.
Optional prefix ARG determines whether to justify the text (when
filling) or the number of spaces to indent the text (when
indenting)."
  (interactive "*r\nP")
  (pcase (filldent--type)
    ('indent (indent-region beg end arg))
    ('fill (fill-paragraph arg t))))

(defun filldent-paragraph (&optional arg)
  "Filldent defun or paragraph at point.
Optional prefix ARG determines whether to justify the text (when
filling) or the number of spaces to indent the text (when
indenting)."
  (interactive "P")
  (pcase (filldent--type)
    ('indent (save-excursion
               (mark-defun)
               (indent-region (region-beginning) (region-end) arg)))
    ('fill (fill-paragraph arg nil))))

(defun filldent-dwim (&optional arg)
  "Filldent defun or paragraph at point, or region, if it's active.
Optional prefix ARG determines whether to justify the text (when
filling) or the number of spaces to indent the text (when
indenting)."
  (interactive "P")
  (if (region-active-p)
      (filldent-region (region-beginning) (region-end) arg)
    (filldent-paragraph arg)))

(provide 'filldent)
;;; filldent.el ends here
