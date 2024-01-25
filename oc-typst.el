;;; oc-typst.el --- Typst bibliography -*- lexical-binding: t; -*-

;; Copyright (C) 2023 Jonas Meurer

;; Author: Jonas Meurer

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
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;; Code:

(require 'oc)

;;; Export capability
(defun org-cite-typst-export-bibliography (keys files style properties backend com)
  (let ((dir (file-name-parent-directory (plist-get com :input-file)))
        (title (plist-get properties :title)))
    (format "#bibliography(%s%s%s)"
            (and style (format "style: \"%s\", " style))
            (if title (format "title: %s, " (org-typst--as-string title) ""))
            (mapconcat (lambda (f) (org-typst--as-string (file-relative-name f dir)))
                       files
                       ", "))))

(defun org-cite-typst-export-citation (citation style _ info)
  (let ((references (org-cite-get-references citation)))
    (format "#cite(label(%s)%s)"
            (mapconcat (lambda (r) (org-typst--as-string (org-element-property :key r)))
                       references
                       ", ")
            (or (and (car style) (format ", style: \"%s\"" (car style)))  ""))))

;;; Register `typst' processor
(org-cite-register-processor 'typst
  :export-bibliography #'org-cite-typst-export-bibliography
  :export-citation #'org-cite-typst-export-citation)

(provide 'oc-typst)
;;; oc-typst.el ends here
