;;; ox-typst.el --- Typst Back-End for Org Export Engine -*- lexical-binding: t; -*-

;; Copyright (C) 2023 Jonas Meurer

;; Author: Jonas Meurer
;; Keywords: text, org, typst
;; URL: https://github.com/jmpunkt/ox-typst
;; Package-Version: 0.1.0
;; Package-Requires: ((emacs "29.1") (org "9.7"))

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Exports Org files to Typst.  Used with the `org-export-dispatch' command.

;;; Code:

(require 'org-macs)
(require 'ox)
(require 'org-element)


;; Variables

(defcustom org-typst-bin "typst"
  "Path or name of Typst binary."
  :type 'string
  :group 'org-typst-export)

;; TODO: Maybe use a different way to display checkboxes. Unicode most
;; likely wont work since there are no three checkbox like symbols
;; which share the same size.
(defcustom org-typst-checkbox-symbols
  '((on . "#box(stroke: 0.5pt + rgb(0,0,0), width: 8pt, height: 8pt, align(center, \"+\"))")
    (off . "#box(stroke: 0.5pt + rgb(0,0,0), width: 8pt, height: 8pt, align(center, \" \"))")
    (trans . "#box(stroke: 0.5pt + rgb(0,0,0), width: 8pt, height: 8pt, align(center, \"-\"))"))
  "Mapping for different checkbox types to Typst code.

Changing the properties results in a appearance change of all
checkboxes that kind across the document."
  :type '(alist :key-type (symbol :tag "Kind of checkbox")
                :value-type (string :tag "Typst representation of that checkbox"))
  :group 'org-export-typst)

(defcustom org-typst-language-mapping '(("elisp" . "lisp"))
  "Maps language tag from Org-Mode to another.

Typst might not understand the language tag provided by
Org-Mode.  Instead map the tag to an alternative tag."
  :type (list 'string)
  :group 'org-export-typst)

(defcustom org-typst-format-drawer-function (lambda (_ contents) contents)
  "Function called to format a drawer in LaTeX code.

The function must accept two parameters:
  NAME      the drawer name, like \"LOGBOOK\"
  CONTENTS  the contents of the drawer.

The function should return the string to be exported.

The default function simply returns the value of CONTENTS."
  :type 'function
  :group 'org-export-typst)

(defcustom org-typst-format-inlinetask-function (lambda (_ contents) contents)
  "Function called to format an inlinetask in LaTeX code.

The function must accept seven parameters:
  TODO      the todo keyword (string or nil)
  TODO-TYPE the todo type (symbol: `todo', `done', nil)
  PRIORITY  the inlinetask priority (integer or nil)
  NAME      the inlinetask name (string)
  TAGS      the inlinetask tags (list of strings or nil)
  CONTENTS  the contents of the inlinetask (string or nil)
  INFO      the export options (plist)

The function should return the string to be exported."
  :type 'function
  :group 'org-export-typst)

(defcustom org-typst-latex-fragment-behavior nil
  "Determines how to process LaTeX fragments."
  :type '(choice (const :tag "No processing" nil)
                 ;; TODO: how to implement translation of LaTeX fragments to Typst?
                 (const :tag "Translate" translate))
  :group 'org-export-typst)

(defcustom org-typst-export-buffer-major-mode nil
  "Set the major-mode for buffer created by Org export.

When an Org file is exported to a buffer, the specified major-mode is
automatically enabled.  This is required, if the name of the created buffer does
not have the correct suffix.  Emacs is not able to auto-load the correct
major-mode."
  :type 'symbol
  :group 'org-export-typst)

(defcustom org-typst-export-buffer-name "*Org Typst Export*"
  "Name of the output buffer for exporting."
  :type 'string
  :group 'org-export-typst)

(defcustom org-typst-heading-numbering "1."
  "Default numbering for headline used for the generated document."
  :type 'string
  :group 'org-export-typst)

(defcustom org-typst-inline-image-rules
  `(("file" . ,(rx "." (or "jpeg" "jpg" "png" "svg") eos))
    ("https" . ,(rx "." (or "jpeg" "jpg" "png" "svg") eos)))
  "Rules characterizing image files that can be inlined into Typst.

A rule consists in an association whose key is the type of link
to consider, and value is a regexp that will be matched against
link's path.

Note that the support for images is very limited within Typest. See
https://typst.app/docs/reference/visualize/image/ supprted types."
  :group 'org-export-typst
  :type '(alist :key-type (string :tag "Type")
		            :value-type (regexp :tag "Path")))

;; Export
(org-export-define-backend 'typst
  '((bold . org-typst-bold)
    (center-block . org-typst-center-block)
    (clock . org-typst-clock)
    (code . org-typst-code)
    (drawer . org-typst-drawer)
    (dynamic-block . org-typst-dynamic-block)
    (entity . org-typst-entity)
    (example-block . org-typst-example-block)
    (export-block . org-typst-export-block)
    (export-snippet . org-typst-export-snippet)
    (fixed-width . org-typst-fixed-width)
    (footnote-definition . org-typst-footnote-definition)
    (footnote-reference . org-typst-footnote-reference)
    (headline . org-typst-headline)
    (horizontal-rule . org-typst-horizontal-rule)
    (inline-src-block . org-typst-inline-src-block)
    (inlinetask . org-typst-inlinetask)
    (italic . org-typst-italic)
    (item . org-typst-item)
    (keyword . org-typst-keyword)
    (latex-environment . org-typst-latex-environment)
    (latex-fragment . org-typst-latex-fragment)
    (line-break . org-typst-line-break)
    (link . org-typst-link)
    (node-property . org-typst-node-property)
    (paragraph . org-typst-paragraph)
    (plain-list . org-typst-plain-list)
    (plain-text . org-typst-plain-text)
    (planning . org-typst-planning)
    (property-drawer . org-typst-property-drawer)
    (quote-block . org-typst-quote-block)
    (radio-target . org-typst-radio-target)
    (section . org-typst-section)
    (special-block . org-typst-special-block)
    (src-block . org-typst-src-block)
    (statistics-cookie . org-typst-statistics-cookie)
    (strike-through . org-typst-strike-through)
    (subscript . org-typst-subscript)
    (superscript . org-typst-superscript)
    (table . org-typst-table)
    (table-cell . org-typst-table-cell)
    (table-row . org-typst-table-row)
    (target . org-typst-target)
    (template . org-typst-template)
    (timestamp . org-typst-timestamp)
    (underline . org-typst-underline)
    (verbatim . org-typst-verbatim)
    (verse-block . org-typst-verse-block))
  :menu-entry
  '(?y "Export to Typst"
       ((?F "As Typst buffer" org-typst-export-as-typst)
	    (?f "As Typst file" org-typst-export-to-typst)
	    (?p "As PDF file" org-typst-export-to-pdf)))
  :options-alist
  '((:typst-format-drawer-function nil nil org-typst-format-drawer-function)
    (:typst-format-inlinetask-function nil nil org-typst-format-inlinetask-function)))

;; Transpile
(defun org-typst-bold (_bold contents _info)
  (format "#text(weight: \"bold\", [%s])" contents))

(defun org-typst-center-block (_center-block contents _info)
  (format "#align(center)[%s]" contents))

(defun org-typst-clock (_clock _contents _info)
  (message "// todo: org-typst-clock"))

(defun org-typst-code (code _contents info)
  (when-let ((code-text (org-element-property :value code)))
    (org-typst--raw code-text code info)))

(defun org-typst-drawer (drawer contents info)
  (let* ((name (org-element-property :drawer-name drawer))
	       (output (funcall (plist-get info :typst-format-drawer-function)
			                    name contents)))
    (org-typst--label output drawer info)))

(defun org-typst-dynamic-block (_dynamic-block contents _info)
  contents)

(defun org-typst-entity (entity _contents _info)
  (string-join
   (seq-map (lambda (c) (format "\\u{%x}" c)) (org-element-property :utf-8 entity))
   ""))

(defun org-typst-example-block (example-block contents info)
  (org-typst--raw contents example-block info nil t))

(defun org-typst-export-block (export-block _contents _info)
  (when (member (org-element-property :type export-block) '("TYPST" "TYP"))
    (org-remove-indentation (org-element-property :value export-block))))

(defun org-typst-export-snippet (export-snippet _contents _info)
  (when (eq (org-export-snippet-backend export-snippet) 'typst)
    (org-element-property :value export-snippet)))

(defun org-typst-fixed-width (fixed-width _contents info)
  (org-typst--raw (org-element-property :value fixed-width) fixed-width info))

(defun org-typst-footnote-definition (footnote-definition contents _info)
  (format "#hide[#footnote[%s] #label(%s)]"
          (org-trim contents)
          (org-typst--as-string (org-element-property :label footnote-definition))))

(defun org-typst-footnote-reference (footnote-reference contents _info)
  (let ((label (org-element-property :label footnote-reference)))
    (pcase (org-element-property :type footnote-reference)
      ('standard (format "#footnote(label(%s))" (org-typst--as-string label)))
      ('inline (if label
                   (format "#footnote[%s] #label(%s)" contents (org-typst--as-string label))
                 (format "#footnote[%s]" contents)))
      (_ nil))))

(defun org-typst-headline (headline contents info)
  (when-let* ((level (org-element-property :level headline))
              (title (org-export-data (org-element-property :title headline) info))
              (label (org-typst--label nil headline info)))
    (concat
     (format "#heading(level: %s%s)"
             level
             (if (or (org-export-excluded-from-toc-p headline info)
                     (not (org-export-numbered-headline-p headline info)))
                 ", outlined: false, numbering: none"
               ""))
     (format "[%s]" title)
     label
     "\n"
     contents)))

(defun org-typst-horizontal-rule (_horizontal-rule _contents _info)
  "#line(length: 100%)")

(defun org-typst-inline-src-block (inline-src-block _contents info)
  (when-let ((code (org-element-property :value inline-src-block))
             (lang (org-element-property :language inline-src-block)))
    (org-typst--raw code inline-src-block info lang)))

(defun org-typst-inlinetask (inlinetask contents info)
  (let ((title (org-export-data (org-element-property :title inlinetask) info))
	      (todo (and (plist-get info :with-todo-keywords)
		               (let ((todo (org-element-property :todo-keyword inlinetask)))
		                 (and todo (org-export-data todo info)))))
	      (todo-type (org-element-property :todo-type inlinetask))
	      (tags (and (plist-get info :with-tags)
		               (org-export-get-tags inlinetask info)))
	      (priority (and (plist-get info :with-priority)
		                   (org-element-property :priority inlinetask)))
	      (contents (org-typst--label contents inlinetask info)))
    (funcall (plist-get info :typst-format-inlinetask-function)
	           todo todo-type priority title tags contents info)))

(defun org-typst-italic (_italic contents _info)
  (format "#emph[%s]" contents))

(defun org-typst-item (item contents info)
  (when-let ((parent (org-export-get-parent item))
             (trimmed (org-trim contents)))
    (pcase (org-element-property :type parent)
      ;; NOTE: unordered list items are all represented as single lists
      ('unordered trimmed)
      ('ordered (when-let ((bullet-raw (org-element-property :bullet item)))
                  (when (string-match "\\([0-9]+\\)\." bullet-raw)
                    (format "enum.item(%s)[%s]," (match-string 1 bullet-raw) trimmed))))
      ('descriptive (when-let* ((raw-tag (org-element-property :tag item))
                                (tag (and raw-tag (org-export-data raw-tag info))))
                      (format "terms.item[%s][%s]," tag trimmed)))
      (_ nil))))

(defun org-typst-keyword (keyword _contents info)
  (let ((key (org-element-property :key keyword))
        (value (org-element-property :value keyword)))
    (cond
     ((string-equal key "TYPST") value)
     ((string-equal key "TYP") value)
     ((string-equal key "TOC")
      (cond
	     ((string-match-p "\\<headlines\\>" value)
	      (let* ((localp (string-match-p "\\<local\\>" value))
		           (parent (org-element-lineage keyword 'headline))
		           (level (if (not (and localp parent)) 0
			                  (org-export-get-relative-level parent info)))
		           (depth
		            (and (string-match "\\<[0-9]+\\>" value)
			               (+ (string-to-number (match-string 0 value)) level))))
	        (if (and localp parent)
              (format "#context {
  let before = query(
    selector(heading).before(here(), inclusive: true),
  )
  let elm = before.pop()
  let after_elements = query(
    heading.where(outlined: true).after(here(), inclusive: true),
  )
  let next_maybe = after_elements.find(it => it.level <= elm.level)
  let next = if next_maybe == none {
    after_elements.pop()
  } else {
    next_maybe
  }
  outline(
    title: none,
    depth: %s,
    target: heading.where(outlined: true).after(
      elm.location(),
      inclusive: false,
    ).and(
      heading.where(outlined: true).before(
        next.location(),
        inclusive: next_maybe == none,
      ),
    ),
  )
}" (if depth depth "none"))
            (if depth
                (format "#outline(title: none, depth: %s)" depth)
              "#outline(title: none)"))))
       ((string-match-p "\\<figures\\>" value) "#outline(title: none, target: figure.where(kind: image))")
	     ((string-match-p "\\<tables\\>" value) "#outline(title: none, target: figure.where(kind: table))")
	     ((string-match-p "\\<listings\\>" value) "#outline(title: none, target: figure.where(kind: raw))"))))))

(defun org-typst-line-break (_line-break _contents _info)
  "#linebreak")

(defun org-typst-link (link contents info)
  (let ((link-raw (org-typst--as-string (org-element-property :raw-link link)))
        ;; NOTE: Typst is a bit picky about labels inside headlines. If we point
        ;; to an element inside a headline, we need to point to the headline
        ;; instead. Most of the time this is what you want, but it might not be
        ;; correct.
        (resolve-headline-friendly (lambda (target) (let ((parent (org-element-parent-element target)))
                                                      (if (string= (org-element-type parent) "headline")
                                                          (org-export-get-reference parent info)
                                                        (org-export-get-reference target info))))))
    (cond
     ((org-export-inline-image-p link org-typst-inline-image-rules)
      (org-typst--figure (format "#image(%s)"
                                 (org-typst--as-string
                                  (org-element-property :path (org-export-link-localise link))))
                         link
                         info))
     ((equal (org-element-property :type link) "radio")
      (when-let* ((target (org-export-resolve-radio-link link info))
                  (ref (funcall resolve-headline-friendly target)))
        (format "#link(label(%s))[%s]"
                (org-typst--as-string ref)
                (org-trim contents))))
     ((member (org-element-property :type link) '("custom-id" "id" "fuzzy"))
      (let* ((target (org-export-resolve-link link info))
             (link-path (org-typst--as-string (funcall resolve-headline-friendly target))))
        (if contents
            (format "#link(label(%s))[%s]" link-path (org-trim contents))
          (format "#ref(label(%s))" link-path))))
     ;; Other like HTTP (external)
     (t
      (format "#link(%s)%s"
              (org-typst--as-string link-raw)
              (if contents
                  (format "[%s] #footnote(link(%s))"
                          (org-trim contents)
                          link-raw)
                ""))))))

(defun org-typst-node-property (_node-property _contents _info)
  (message "// todo: org-typst-node-property"))

(defun org-typst-paragraph (_paragraph contents _info)
  contents)

(defun org-typst-plain-list (plain-list contents info)
  (pcase (org-element-property :type plain-list)
    ;; NOTE: use a single list with a marker instead of a list with
    ;;       list items
    ('unordered
     (mapconcat
      (lambda (item)
        (when (eq (car item) 'item)
          (let ((marker (cdr (assoc (org-element-property :checkbox item) org-typst-checkbox-symbols)))
                (item-content (org-trim (org-export-data item info))))
            (if marker
                (format "#list(marker: [%s], list.item[%s])" marker item-content)
              (format "#list(list.item[%s])" item-content)))))
      (cdr plain-list)))
    ('ordered (format "#enum(%s)" contents))
    ('descriptive (format "#terms(%s)" contents))
    (_ nil)))

(defun org-typst-plain-text (contents _info)
  (org-typst--escape '("#") contents))

(defun org-typst-planning (_planning _contents _info)
  (message "// todo: org-typst-planning"))

(defun org-typst-property-drawer (property-drawer contents info)
  (and (org-string-nw-p contents)
       (org-typst--raw contents property-drawer info)))

(defun org-typst-quote-block (quote-block contents info)
  (let ((attribution (org-export-read-attribute :attr_typst quote-block :author)))
    (when contents
      (org-typst--figure
       (format "#quote(block: true%s, %s)"
               (if attribution (format ", attribution: %s" (org-typst--as-string attribution)) "")
               (org-typst--as-string contents))
       quote-block
       info))))

(defun org-typst-radio-target (radio-target text info)
  (org-typst--label text radio-target info))

(defun org-typst-section (_section contents _info)
  contents)

(defun org-typst-special-block (_special-block contents _info)
  contents)

(defun org-typst-src-block (src-block _contents info)
  (when-let ((code (org-element-property :value src-block))
             (lang (org-element-property :language src-block)))
    (when (org-string-nw-p code)
      (org-typst--raw code src-block info lang t))))

(defun org-typst-statistics-cookie (_statistics-cookie _contents _info))

(defun org-typst-strike-through (_strike-through contents _info)
  (format "#strike[%s]" contents))

(defun org-typst-subscript (_subscript contents _info)
  (format "#sub[%s]" contents))

(defun org-typst-superscript (_superscript contents _info)
  (format "#super[%s]" contents))

(defun org-typst-table (table contents info)
  (when-let ((columns (cdr (org-export-table-dimensions table info))))
    (if (eq (org-element-property :type table) 'org)
        ;;org
        (org-typst--figure
         (format "#table(columns: %s, %s)" columns contents)
         table
         info)
      ;; table.el
      (message "// todo: implement org-typst-table (table.el)"))))

(defun org-typst-table-cell (_table-cell contents _info)
  (format "[%s]," (or contents "")))

(defun org-typst-table-row (_table-row contents _info)
  contents)

(defun org-typst-target (target contents info)
  (org-typst--label contents target info))

(defun org-typst-template (contents info)
  (let ((title (plist-get info :title))
        (author (when (plist-get info :with-author)
			            (plist-get info :author)))
        (language (plist-get info :language))
        (email (when (plist-get info :with-email)
		             (plist-get info :email)))
        (toc (plist-get info :with-toc)))
    (concat
     (when (or (car title) author)
       (concat
        "#set document("
        (format "title: \"%s\"" (or (car title) ""))
        (when author
          (or (when email
                (format ", author: \"<%s> %s\"" (car author) email))
              (format ", author: \"%s\"" (car author))))
        ")\n"))
     (when language (format "#set text(lang: \"%s\")\n" language))
     (when toc "#outline()\n")
     (format "#set heading(numbering: %s)\n" (org-typst--as-string org-typst-heading-numbering))
     contents)))

(defun org-typst-timestamp (timestamp _contents _info)
  (let ((start (org-typst--timestamp timestamp nil))
        (end (org-typst--timestamp timestamp 1)))
    (if (and start end)
        (format "%s -- %s"  start end)
      (or start end))))

(defun org-typst-underline (_underline contents _info)
  (format "#underline[%s]" contents))

(defun org-typst-verbatim (verbatim _contents _info)
  (format "#raw(%s)"
          (org-typst--as-string (org-element-property :value verbatim))))

(defun org-typst-verse-block (verse-block contents info)
  (org-typst--raw contents verse-block info nil t))

(defun org-typst-latex-environment (_latex-environment _contents _info)
  (message "// todo: org-typst-latex-environment"))

(defun org-typst-latex-fragment (latex-fragment _contents _info)
  (cond
   ((eq org-typst-latex-fragment-behavior nil)
    (let ((fragment (org-element-property :value latex-fragment)))
      (cond
       ((string-match-p "^[ \t]*\$.*\$[ \t]*$" fragment) fragment)
       ((string-match-p "^[ \t]*\\\\(.*\\\\)[ \t]*$" fragment)
        (replace-regexp-in-string "\\\\)[ \t]*$" "$" (replace-regexp-in-string "^[ \t]*\\\\(" "$" fragment)))
       ((string-match-p "^[ \t]*\\\\\\[.*\\\\\\][ \t]*$" fragment)
        (replace-regexp-in-string "\\\\\\][ \t]*$" "$" (replace-regexp-in-string "^[ \t]*\\\\\\[" "$" fragment))))))
   ((eq org-typst-latex-fragment-behavior 'translate) (message "// todo: latex-fragment-translate"))))

;; Helper
(defun org-typst--raw (content element info &optional language block)
  (when content
    (let ((raw (format "#raw(block: %s, %s%s)"
                       (if block "true" "false")
                       (if language (concat "lang: "
                                            (org-typst--language language)
                                            ", ")
                         "")
                       (org-typst--as-string content))))
      (if block
          (org-typst--figure raw element info)
        raw))))

(defun org-typst--label (content item info)
  (let ((label (or (org-export-get-reference item info)
                   (org-export-get-reference (org-element-parent item) info))))
    (if (and label
             (or (string= (org-element-type item) "headline")
                 (not (string= (org-element-type (org-element-parent-element item)) "headline"))))
        (format "%s #label(%s)" (or content "") (org-typst--as-string label))
      content)))

(defun org-typst--figure (content element info)
  (let* ((raw (or (org-export-get-caption element)
                  (org-export-get-caption (org-element-parent-element element))))
         (caption (when raw (mapconcat (lambda (e) (if (stringp e) e (org-export-data e info))) raw))))
    (org-typst--label
     (format "#figure([%s]%s)"
             content
             (if caption (format ", caption: [%s]" caption) ""))
     element
     info)))

(defun org-typst--sections (level)
  (format "%s" (seq-reduce #'concat (mapcar (lambda (_elm) "=") (number-sequence 1 level)) "")))

(defun org-typst--escape (chars string)
  (seq-reduce (lambda (str char)
                (let ((code (string-to-char char)))
                  (replace-regexp-in-string (rx-to-string code) (format "\\\\u{%x}" code) str)))
              chars
              string))

(defun org-typst--as-string (string)
  (when string
    (concat "\""
            (org-trim (org-typst--escape '("\"") string))
            "\"")))

(defun org-typst--language (language)
  (org-typst--as-string
   (or
    (cdr (seq-find (lambda (pl) (string-equal (car pl) language)) org-typst-language-mapping))
    language)))

(defun org-typst--timestamp (timestamp end)
  (when-let ((year (org-element-property (when end :year-end :year-start) timestamp))
             (month (org-element-property (when end :month-end :month-start) timestamp))
             (day (org-element-property (when end :day-end :day-start) timestamp)))
    (if (org-timestamp-has-time-p timestamp)
        (when-let ((hour (org-element-property (when end :hour-end :hour-start) timestamp))
                   (minute (org-element-property (when end :minute-end :minute-start) timestamp)))
          (format "#datetime(year: %s, month: %s, day: %s, hour: %s, minute: %s, second: 0).display()" year month day hour minute))
      (format "#datetime(year: %s, month: %s, day: %s).display()" year month day))))

;; Commands
(defun org-typst-export-as-typst
    (&optional async subtreep visible-only body-only ext-plist)
  (interactive)
  (org-export-to-buffer 'typst org-typst-export-buffer-name
    async subtreep visible-only body-only ext-plist
    ;; TODO: use org-typst-export-buffer-major-mode
    (when org-typst-export-buffer-major-mode
      (if (fboundp 'major-mode-remap)
          (major-mode-remap org-typst-export-buffer-major-mode)
        org-typst-export-buffer-major-mode))))

(defun org-typst-export-to-typst
    (&optional async subtreep visible-only body-only ext-plist)
  (interactive)
  (let ((outfile (org-export-output-file-name ".typ" subtreep)))
    (org-export-to-file 'typst outfile
      async subtreep visible-only body-only ext-plist)))

(defun org-typst-export-to-pdf (&optional async subtreep visible-only body-only ext-plist)
  (interactive)
  (let ((outfile (org-export-output-file-name ".typ" subtreep)))
    (org-export-to-file 'typst outfile
      async subtreep visible-only body-only ext-plist
      #'org-typst-compile)))

(defun org-typst-compile (typfile &optional snippet)
  (let* ((log-buf-name "*Org PDF Typst Output*")
         (log-buf (and (not snippet) (get-buffer-create log-buf-name)))
         (process (format "%s c \"%s\"" org-typst-bin typfile))
         outfile)
    (with-current-buffer log-buf
      (erase-buffer))

    (setq outfile (org-compile-file typfile (list process) "pdf"
				                            (format "See %S for details" log-buf-name)
				                            log-buf nil))
    outfile))

(require 'oc-typst)

(provide 'ox-typst)
;;; ox-typst.el ends here
