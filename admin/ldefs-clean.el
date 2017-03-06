;; Copyright (C) 2016-2017 Free Software Foundation, Inc.

;; This file is part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This file takes the output from the "generate-ldefs-boot" make
;; target, takes the relevant autoload forms, removes everything else
;; and adds some comments.

(defun ldefs-clean-uniquify-region-lines (beg end)
  "Remove duplicate adjacent lines in region."
  (save-excursion
    (goto-char beg)
    (while (re-search-forward "^\\(.*\n\\)\\1+" end t)
      (replace-match "\\1"))))

(defun ldefs-clean-uniquify-buffer-lines ()
  "Remove duplicate adjacent lines in the current buffer."
  (interactive)
  (ldefs-clean-uniquify-region-lines (point-min) (point-max)))

(defun ldefs-clean-up ()
  "Clean up output from build and turn it into ldefs-boot-auto.el."
  (interactive)
  (goto-char (point-max))
  ;; We only need the autoloads up till loaddefs.el is
  ;; generated. After this, ldefs-boot.el is not needed
  (search-backward "  GEN      loaddefs.el")
  (delete-region (point) (point-max))
  (keep-lines "(autoload" (point-min) (point-max))
  (sort-lines nil (point-min) (point-max))
  (ldefs-clean-uniquify-buffer-lines)
  (goto-char (point-min))
  (insert
   ";; This file is autogenerated by admin/ldefs-clean.el
;; Do not edit
")
  (goto-char (point-max))
  (insert
   ";; Local Variables:
;; no-byte-compile: t
;; no-update-autoloads: t
;; End:"))


(defun ldefs-clean ()
  (find-file "../lisp/ldefs-boot-auto.temp")
  (ldefs-clean-up)
  (write-file "ldefs-boot-auto.el"))
