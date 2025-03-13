;;; ox-typst.el --- Typst Back-End for Org Export Engine -*- lexical-binding: t; -*-

;; Copyright (C) 2023-2024 Jonas Meurer

;; Author: Jonas Meurer
;; Keywords: text, wp, org, typst
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

(require 'ox)
(require 'org-element)

;; Variables

(defcustom org-typst-process "typst c \"%s\""
  "Format string for the command to process a Typst file to a PDF file.

The string is formatted with the file path of the Typst file.  The resulting
string must be a valid shell command, including a program name or a valid file
path to a Typst binary.  It is recommended to put the file path in quotes,
like the default value does.

Check the documentation of your Typst version for supported arguments."
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
  "Function called to format a drawer in Typst code.

The function must accept two parameters:
  NAME      the drawer name, like \"LOGBOOK\"
  CONTENTS  the contents of the drawer.

The function should return the string to be exported.

The default function simply returns the value of CONTENTS."
  :type 'function
  :group 'org-export-typst)

(defcustom org-typst-format-inlinetask-function (lambda (_ contents) contents)
  "Function called to format an inlinetask in Typst code.

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

Note that the support for images is very limited within Typest.  See
<https://typst.app/docs/reference/visualize/image/> supported types."
  :group 'org-export-typst
  :type '(alist :key-type (string :tag "Type")
                :value-type (regexp :tag "Path")))

(defcustom org-typst-from-latex-fragment #'org-typst-from-latex-with-naive
  "Defines the way the Typst transforms LaTeX fragments into Typst code.

If nil, then the all LaTeX fragment will be ignored.  Otherwise, the provided
function is called with a single argument, the raw LaTeX fragment as a string."
  :type 'function
  :group 'org-export-typst)

(defcustom org-typst-from-latex-environment #'org-typst-from-latex-with-naive
  "Defines the way the Typst transforms LaTeX fragments into Typst code.

See `org-typst-latex-fragment' for documentation. Has the same behavior, except
it is used to translate LaTeX environments instead of fragments."
  :type 'function
  :group 'org-export-typst)

(defcustom org-typst-src-apply-theme-color nil
  "Specify the behavior for applying custom theme colors to src-bocks.

When providing a custom theme through `org-typst-src-themes', the foreground and
background colors are ignored by Typst.  According to the documentation, the
user has to apply these colors by them self.  Setting this variable accordingly,
will result in `ox-typst' to apply the colors to the code block."
  :type '(choice
          (const :tag "None" nil)
          (const :tag "Foreground only" foreground)
          (const :tag "Background only" background)
          (const :tag "Both" t))
  :group 'org-export-typst)

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
    (:typst-format-inlinetask-function nil
                                       nil
                                       org-typst-format-inlinetask-function)))

;; Transpile
(defun org-typst-bold (_bold contents _info)
  (format "#text(weight: \"bold\", [%s])" contents))

(defun org-typst-center-block (_center-block contents _info)
  (format "#align(center)[%s]" contents))

(defun org-typst-clock (_clock _contents _info)
  (message "// todo: org-typst-clock"))

(defun org-typst-code (code _contents info)
  (when-let* ((code-text (org-element-property :value code)))
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
   (seq-map (lambda (c) (format "\\u{%x}" c))
            (org-element-property :utf-8 entity))
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
          (org-typst--as-string
           (org-element-property :label footnote-definition))))

(defun org-typst-footnote-reference (footnote-reference contents _info)
  (let ((label (org-element-property :label footnote-reference)))
    (pcase (org-element-property :type footnote-reference)
      ('standard (format "#footnote(label(%s))" (org-typst--as-string label)))
      ('inline (if label
                   (format "#footnote[%s] #label(%s)"
                           contents
                           (org-typst--as-string label))
                 (format "#footnote[%s]" contents)))
      (_ nil))))

(defun org-typst-headline (headline contents info)
  (when-let* ((level (org-element-property :level headline))
              (title (org-export-data (org-element-property :title headline)
                                      info))
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
  (when-let* ((code (org-element-property :value inline-src-block))
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
  (when-let* ((parent (org-export-get-parent item))
              (trimmed (org-trim contents)))
    (pcase (org-element-property :type parent)
      ;; NOTE: unordered list items are all represented as single lists
      ('unordered trimmed)
      ('ordered (when-let* ((bullet-raw (org-element-property :bullet item)))
                  (when (string-match "\\([0-9]+\\)\." bullet-raw)
                    (format "enum.item(%s)[%s],"
                            (match-string 1 bullet-raw)
                            trimmed))))
      ('descriptive (when-let* ((raw-tag (org-element-property :tag item))
                                (tag (and raw-tag
                                          (org-export-data raw-tag info))))
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
               (level (if (not (and localp parent))
                          0
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
       ((string-match-p "\\<figures\\>" value)
        "#outline(title: none, target: figure.where(kind: image))")
       ((string-match-p "\\<tables\\>" value)
        "#outline(title: none, target: figure.where(kind: table))")
       ((string-match-p "\\<listings\\>" value)
        "#outline(title: none, target: figure.where(kind: raw))"))))))

(defun org-typst-line-break (_line-break _contents _info)
  "#linebreak")

(defun org-typst-link (link contents info)
  (let (;; NOTE: Typst is a bit picky about labels inside headlines. If we point
        ;; to an element inside a headline, we need to point to the headline
        ;; instead. Most of the time this is what you want, but it might not be
        ;; correct.
        (resolve-headline-friendly
         (lambda (target)
           (let ((parent (org-element-parent-element target)))
             (if (string= (org-element-type parent) "headline")
                 (org-export-get-reference parent info)
               (org-export-get-reference target info))))))
    (cond
     ((org-export-inline-image-p link org-typst-inline-image-rules)
      (org-typst--figure (format
                          "#image(%s)"
                          (org-typst--as-string
                           (org-element-property
                            :path (org-export-link-localise link))))
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
             (link-path (org-typst--as-string
                         (funcall resolve-headline-friendly target))))
        (if contents
            (format "#link(label(%s))[%s]" link-path (org-trim contents))
          (format "#ref(label(%s))" link-path))))
     ;; Other like HTTP (external)
     (t
      (let ((link-typst (org-typst--as-string (org-element-property :raw-link link))))
        (format "#link(%s)%s"
                link-typst
                (if contents
                    (format "[%s] #footnote(link(%s))"
                            (org-trim contents)
                            link-typst)
                  "")))))))

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
          (let ((marker (cdr (assoc (org-element-property :checkbox item)
                                    org-typst-checkbox-symbols)))
                (item-content (org-trim (org-export-data item info))))
            (if marker
                (format "#list(marker: [%s], list.item[%s])"
                        marker
                        item-content)
              (format "#list(list.item[%s])" item-content)))))
      (cdr plain-list)))
    ('ordered (format "#enum(%s)" contents))
    ('descriptive (format "#terms(%s)" contents))
    (_ nil)))

(defun org-typst-plain-text (contents _info)
  (org-typst--escape '("#" "$") contents))

(defun org-typst-planning (_planning _contents _info)
  (message "// todo: org-typst-planning"))

(defun org-typst-property-drawer (property-drawer contents info)
  (and (org-string-nw-p contents)
       (org-typst--raw contents property-drawer info)))

(defun org-typst-quote-block (quote-block contents info)
  (let ((attribution (org-export-read-attribute
                      :attr_typst
                      quote-block
                      :author)))
    (when contents
      (org-typst--figure
       (format "#quote(block: true%s, %s)"
               (if attribution
                   (format ", attribution: %s"
                           (org-typst--as-string attribution))
                 "")
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
  (when-let* ((code (org-element-property :value src-block))
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
  (when-let* ((columns (cdr (org-export-table-dimensions table info))))
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
     (format "#set heading(numbering: %s)\n"
             (org-typst--as-string org-typst-heading-numbering))
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

(defun org-typst-latex-environment (latex-environment _contents _info)
  (when org-typst-from-latex-environment
    (funcall
     org-typst-from-latex-environment
     (org-element-property :value latex-environment))))

(defun org-typst-latex-fragment (latex-fragment _contents _info)
  (when org-typst-from-latex-fragment
    (funcall
     org-typst-from-latex-fragment
     (org-element-property :value latex-fragment))))

;; Helper
(defun org-typst--collect-text-faces (text new-major-mode)
  "Collect the faces and its position of a TEXT in its NEW-MAJOR-MODE.

The return value is a list which contains the text as lines.  Each line consists
of one more elements which compose the text.  These elements have the form
`(START FACE END)'."
  (with-temp-buffer
    (funcall new-major-mode)
    (insert text)
    (goto-char (point-min))
    (when (not (equal major-mode new-major-mode))
      (error "Could not turn on major mode `%s', enabled major mode `%s'" new-major-mode major-mode))
    (font-lock-ensure)
    (let ((lines nil)
          (current-line nil)
          (line-number 1))
      (while (not (eobp))
        (let ((start (point))
              (face (plist-get (text-properties-at (point)) 'face))
              (end (goto-char (min (line-end-position)
                                   (or (next-property-change (point))
                                       (point-max))))))
          (push (list start face end) current-line)
          (when (equal end (line-end-position))
            (push (seq-reverse current-line) lines)
            (setq line-number (1+ line-number)
                  current-line nil)
            (when (not (eobp))
              (forward-char)))))
      lines)))

(defun org-typst--face-get-attr (face attribute)
  "Return the ATTRIBUTE of the corresponding FACE.

If an attribute is unspecified on and the face inherits from another face, then
the value of the inherit face is used.  This continues until a face does not
inherits from another face."
  (let* ((preferred-value (face-attribute face attribute))
         (fallback-value (when (equal preferred-value 'unspecified)
                           (let ((inherit (face-attribute face :inherit)))
                             (when (and inherit (not (equal inherit 'unspecified)))
                             (org-typst--face-get-attr inherit attribute))))))
    (if (equal preferred-value 'unspecified)
        (if (equal fallback-value 'unspecified)
            nil
          fallback-value)
      preferred-value)))

(defun org-typst--text-and-face-into-typst (text face)
  "Convert a TEXT with style of FACE into Typst code."
  (let* ((foreground (org-typst--face-get-attr face :foreground))
         (underline (org-typst--face-get-attr face :underline))
         (overline (org-typst--face-get-attr face :overline))
         (slant (org-typst--face-get-attr face :slant))
         (weight (org-typst--face-get-attr face :weight))
         (strike-through (org-typst--face-get-attr face :strike-through))
         (underline-fn (lambda (content) (if underline (concat "#underline[" content "]" ) content)))
         (overline-fn (lambda (content) (if overline (concat "#overline["  content "]") content)))
         (strike-through-fn (lambda (content) (if strike-through (concat "#strike[" content "]") content))))
    (seq-reduce
     (lambda (content fn) (funcall fn content))
     (list underline-fn overline-fn strike-through-fn)
     (concat
      "#text("
      (when foreground (concat "fill: " (org-typst--as-color foreground) ","))
      (when weight (concat "weight: " (org-typst--as-string weight) ","))
      (when slant (concat "style: "
                          (org-typst--as-string
                           ;; slant can be 'italic, 'oblique, or 'roman
                           (if (string-equal slant 'roman) "normal"
                             slant))
                          ","))
      (org-typst--as-string text)
      ")"))))

(defun org-typst--engrave-code (text new-major-mode)
  "Convert a TEXT with its NEW-MAJOR-MODE into a Typst code."
  (let* ((lines (seq-map (lambda (elements)
                           (seq-reduce (lambda (acc element)
                                         (concat acc
                                                 (let* ((start (car element))
                                                        (face (cadr element))
                                                        (end (caddr element))
                                                        (text (substring text (1- start) (1- end))))
                                                   (concat "\n"
                                                           (if face
                                                               (concat "[" (org-typst--text-and-face-into-typst text face) "]")
                                                             (org-typst--as-string text t))))))
                                       elements
                                       ""))
                         (org-typst--collect-text-faces text new-major-mode))))
    (format "show raw.line: it => { %s }"
            (apply
             #'concat
             (cl-loop for line in (seq-reverse lines)
                      for line-number from 1
                      collect (format "\nif it.number == %s { %s }" line-number line))))))


(defun org-typst--raw (content element info &optional raw-language block)
  "Wrap CONTENT in a raw Typst block.

If BLOCK is not nil, then content will additionally wrapped in a figure with the
arguments of ELEMENT and INFO.

RAW-LANGUAGE is the language of the code block and will be used as the
`language' argument in Typst."
  (when content
    (let* ((attributes (org-export-read-attribute :attr_typst element))
           (language (when raw-language (org-typst--language raw-language)))
           ;; TODO: maybe read the tab-size set by the mapped mode in Org?
           (tab-size (org-export-read-attribute :attr_typst element :tab-size))
           (engrave (org-export-read-attribute :attr_typst element :engrave))
           (theme (org-typst--attribute-file :theme attributes))
           (syntax (org-typst--attribute-file :syntaxes attributes))
           (theme-settings (when (and theme (not (equal theme 'none)))
                             (org-typst--xml-theme-global-settings (org-typst--xml-read-plist theme))))
           (raw (format "#raw(block: %s, %s)"
                        (if block "true" "false")
                        (concat
                         (when tab-size (concat "tab_size: " tab-size ", "))
                         (when language (concat "lang: "
                                                (org-typst--as-string language)
                                                ", "))
                         (when theme (concat "theme: " (org-typst--as-typst-value theme) ","))
                         (when syntax (concat "syntaxes: " (org-typst--as-typst-value syntax) ","))
                         (org-typst--as-string content)))))
      (if (and theme-settings org-typst-src-apply-theme-color)
          (let* ((fg (org-typst--xml-dict-get theme-settings "foreground"))
                 (bg (org-typst--xml-dict-get theme-settings "background"))
                 (bg-fmt (when bg (format "#block(fill: %s, inset: 4pt)" (org-typst--as-color (org-typst--xml-as-string bg)))))
                 (fg-fmt (when fg (format "#text(fill: %s)" (org-typst--as-color (org-typst--xml-as-string fg))))))
            (when fg (setq raw (concat fg-fmt "[" raw "]")))
            (when bg (setq raw (concat bg-fmt "[" raw "]")))))
      (let* ((major-mode-of-language (org-src-get-lang-mode language))
             (actual-code (if block
                              (org-typst--figure raw element info)
                            raw)))
        (if engrave
            (if (not major-mode-of-language)
                (error "Language `%s` does not map to any major mode, configure `org-src-lang-modes' accordingly" language)
              (format "#{ %s \n[%s] }" (org-typst--engrave-code content major-mode-of-language) actual-code))
          actual-code)))))

(defun org-typst--as-color (color)
  "Convert Emacs COLOR into Typst color."

  (seq-let (red green blue) (tty-color-standard-values color)
    (format "rgb(%d, %d, %d)"
            (/ red 256)
            (/ green 256)
            (/ blue 256))))

(defun org-typst--plist-find (plist pred)
  "Find a single element in PLIST which matches PRED.

PRED is a function which takes the plist key and value as arguments.  If PRED
returns t, then the key value pair is returned as a list."
  (let ((returns nil))
    (while (and (not returns) plist)
      (when (funcall pred (car plist) (cadr plist))
        (setq returns (list (car plist) (cadr plist))))
      (setq plist (cddr plist)))
    returns))

(defun org-typst--xml-type? (xml type)
  "Check that XML is of TYPE."
  (equal (car xml) type))

(defun org-typst--xml-dict-get (xml key)
  "Return the KEY of an XML dictionary.

The XML must be of type `dict', otherwise an error is signaled.  When the key is
found, then the value is returned.  Otherwise, `nil' is returned."
  (if (not (org-typst--xml-type? xml 'dict))
      (error "Element not an XML dict")
    (cadr (org-typst--plist-find (cddr xml) (lambda (k _)
                                              (and (equal (car k) 'key)
                                                   (equal (caddr k) key)))))))

(defun org-typst--xml-as-string (xml)
  "Get value for string type of XML."
  (if (not (org-typst--xml-type? xml 'string))
      (error "Element not an XML string")
    (caddr xml)))

(defun org-typst--xml-array-filter-type (xml type)
  "Filter an XML array for TYPE.

The resulting list only contains elements which are of type TYPE."
  (if (not (org-typst--xml-type? xml 'array))
      (error "Element not an XML array")
    (seq-filter
     (lambda (elm) (and (listp elm) (equal (car elm) type))) (cddr xml))))

(defun org-typst--xml-theme-global-settings (dict)
  "Get the global settings part of a Sublime theme stored in DICT."
  (if (not (org-typst--xml-type? dict 'dict))
      (error "Element not an XML dict")
    (let* ((dicts (seq-filter (lambda (elm)
                                (and (org-typst--xml-type? elm 'dict)
                                     (not (org-typst--xml-dict-get elm "scope"))))
                              (org-typst--xml-array-filter-type (org-typst--xml-dict-get dict "settings") 'dict))))
      (if (equal (length dicts) 1)
          (org-typst--xml-dict-get (car dicts) "settings")
        (error "Theme was more than one global config")))))

(defun org-typst--xml-read-plist (file)
  "Parse XML FILE which must be a valid plist structure.

Sublime use the plist structure to store their themes."
  (let* ((xml (with-temp-buffer
                (insert-file-contents file)
                (libxml-parse-html-region))))
    (caddr (caddr (caddr
                   (pcase (car xml)
                     ('html xml)
                     ('top (car (seq-filter (lambda (elm)
                                              (and (listp elm)
                                                   (equal (car elm) 'html)))
                                            xml)))))))))

(defun org-typst--as-typst-value (value)
  "Convert the Elisp VALUE into a valid Typst value."
  (cond
   ((equal 'none value) "none")
   ((stringp value) (org-typst--as-string value))))

(defun org-typst--attribute-file (key attributes)
  "Interpret the element KEY of the list ATTRIBUTES as a file path.

If the value is empty, then the string \"none\" is returned.  Otherwise, the
string with the relative file path.  Notice that Typst only supports relative
file paths, to the `TYPST_ROOT'.  Absolute paths are not supported and these
files paths must be in the same directory as Org file or in a sub directory."
  (when (plist-member attributes key)
    (let ((file (plist-get attributes key)))
      (if (string-empty-p file)
          'none
        file))))

(defun org-typst--label (content item info)
  "Wrap ITEM and its CONTENT in a Typst label.

If ITEM is inside a headline or Org has no reference to it, then CONTENT is
returned without being wrapped.  All elements inside the headline are referenced
through the headline.

INFO is required to determine the reference of ITEM."
  (let ((label (or (org-export-get-reference item info)
                   (org-export-get-reference (org-element-parent item) info))))
    (if (and label
             (or (string= (org-element-type item) "headline")
                 (not (string= (org-element-type
                                (org-element-parent-element item))
                               "headline"))))
        (format "%s #label(%s)" (or content "") (org-typst--as-string label))
      content)))

(defun org-typst--figure (content element info)
  "Wrap ELEMENT and its CONTENT in a Typst figure.

Retrieves the caption from the ELEMENT itself or its parent.

INFO is required to determine the reference of ITEM."
  (let* ((raw (or (org-export-get-caption element)
                  (org-export-get-caption (org-element-parent-element
                                           element))))
         (caption (when raw
                    (mapconcat (lambda (e) (if (stringp e)
                                               e
                                             (org-export-data e info)))
                               raw))))
    (org-typst--label
     (format "#figure([%s]%s)"
             content
             (if caption (format ", caption: [%s]" caption) ""))
     element
     info)))

(defun org-typst--escape (chars string)
  "Escape CHARS in STRING with corresponding Unicode.

The resulting string will contain a \\u{XXXX} for every char specified in CHARS."
  (seq-reduce (lambda (str char)
                (let ((code (string-to-char char)))
                  (replace-regexp-in-string (rx-to-string code)
                                            (format "\\\\u{%x}" code)
                                            str)))
              chars
              string))

(defun org-typst--as-string (string &optional no-trim)
  "Construct Typst string with content STRING.

The STRING will escape every occurrence of `\"'.  Normally the STRING is
trimmed, but can be disabled with NO-TRIM."
  (when string
    (let* ((actual-string (cond ((stringp string) string)
                                ((symbolp string) (symbol-name string))
                                (t (error "Unsupported type %s of %s" (type-of string) string))))
           (escaped (org-typst--escape '("\"") actual-string)))
      (concat "\""
              (if no-trim
                  escaped
                (org-trim escaped))
              "\""))))

(defun org-typst--language (language)
  "Map Org LANGUAGE to Typst language for source blocks.

The user can define the mapping `org-typst-language-mapping', to rename the
languages.  If the language is not defined in the mapping, then it is
returned.  Otherwise, the mapped language is returned."
  (or
   (cdr (seq-find (lambda (pl) (string-equal (car pl) language))
                  org-typst-language-mapping))
   language))

(defun org-typst--timestamp (timestamp end)
  "Construct Typst timestamp from TIMESTAMP.

Setting END to non-nil extracts the end range of the timestamp.  Otherwise, the
start range of the timestamp is extracted."
  (when-let* ((year (org-element-property
                     (when end :year-end :year-start)
                     timestamp))
              (month (org-element-property
                      (when end :month-end :month-start)
                      timestamp))
              (day (org-element-property
                    (when end :day-end :day-start)
                    timestamp)))
    (if (org-timestamp-has-time-p timestamp)
        (when-let* ((hour (org-element-property (when end :hour-end :hour-start)
                                                timestamp))
                    (minute (org-element-property (when end
                                                    :minute-end :minute-start)
                                                  timestamp)))
          (format "#datetime(year: %s, month: %s, day: %s, hour: %s, minute: %s, second: 0).display()"
                  year
                  month
                  day
                  hour
                  minute))
      (format "#datetime(year: %s, month: %s, day: %s).display()"
              year
              month
              day))))

(defun org-typst-from-latex-with-pandoc (latex-fragment)
  "Convert a LATEX-FRAGMENT into a Typst expression using Pandoc."
  (with-temp-buffer
    (insert latex-fragment)
    (call-shell-region
     (point-min)
     (point-max)
     "pandoc -f latex -t typst -"
     t
     (current-buffer))
    (string-trim-right
     (buffer-substring-no-properties (point-min) (point-max)))))

(defun org-typst-from-latex-with-naive (latex-fragment)
  "Convert a LATEX-FRAGMENT into Typst code.

This approach is very naive and assumes that the provided LaTeX fragment has the
same inner syntax as Typst.  For more complex fragments, use a different
converter.

The advantage of this convert is the availability in Emacs without additional
dependencies.  Other converts rely on external dependencies."
  (cond
   ((string-match-p "^[ \t]*\$.*\$[ \t]*$" latex-fragment) latex-fragment)
   ((string-match-p "^[ \t]*\\\\(.*\\\\)[ \t]*$" latex-fragment)
    (replace-regexp-in-string "\\\\)[ \t]*$" "$"
                              (replace-regexp-in-string "^[ \t]*\\\\("
                                                        "$"
                                                        latex-fragment)))
   ((string-match-p "^[ \t]*\\\\\\[.*\\\\\\][ \t]*$" latex-fragment)
    (replace-regexp-in-string
     "\\\\\\][ \t]*$" "$"
     (replace-regexp-in-string "^[ \t]*\\\\\\[" "$" latex-fragment)))))

;; Commands
(defun org-typst-export-as-typst
    (&optional async subtreep visible-only body-only ext-plist)
  "Export current buffer as a Typst buffer.

If narrowing is active in the current buffer, only export its
narrowed part.

If a region is active, export that region.

A non-nil optional argument ASYNC means the process should happen
asynchronously.  The resulting buffer should be accessible
through the `org-export-stack' interface.

When optional argument SUBTREEP is non-nil, export the sub-tree
at point, extracting information from the headline properties
first.

When optional argument VISIBLE-ONLY is non-nil, don't export
contents of hidden elements.

BODY-ONLY currently has no effect.  The entire buffer is always exported.

EXT-PLIST, when provided, is a property list with external
parameters overriding Org default settings, but still inferior to
file-local settings.

Export is done in a buffer named \"*Org Typst Export*\", which will be displayed
when `org-export-show-temporary-export-buffer' is non-nil.  The resulting buffer
will use the major mode specified by `org-typst-export-buffer-major-mode'."
  (interactive)
  (org-export-to-buffer 'typst org-typst-export-buffer-name
                        async subtreep visible-only body-only ext-plist
                        (when org-typst-export-buffer-major-mode
                          (if (fboundp 'major-mode-remap)
                              (major-mode-remap
                               org-typst-export-buffer-major-mode)
                            org-typst-export-buffer-major-mode))))

(defun org-typst-export-to-typst
    (&optional async subtreep visible-only body-only ext-plist)
  "Export Org-buffer to Typst.

If narrowing is active in the current buffer, only export its narrowed part.

If a region is active, export that region.

A non-nil optional argument ASYNC means the process should happen
asynchronously.  The resulting file should be accessible through the
`org-export-stack' interface.

When optional argument SUBTREEP is non-nil, export the sub-tree at point,
extracting information from the headline properties first.

When optional argument VISIBLE-ONLY is non-nil, don't export contents of hidden
elements.

BODY-ONLY currently has no effect.  The entire buffer is always exported.

EXT-PLIST, when provided, is a property list with external parameters overriding
Org default settings, but still inferior to file-local settings."
  (interactive)
  (let ((outfile (org-export-output-file-name ".typ" subtreep)))
    (org-export-to-file 'typst outfile
                        async subtreep visible-only body-only ext-plist)))

(defun org-typst-export-to-pdf
    (&optional async subtreep visible-only body-only ext-plist)
  "Export Org-buffer as PDF using Typst.

If narrowing is active in the current buffer, only export its narrowed part.

If a region is active, export that region.

A non-nil optional argument ASYNC means the process should happen
asynchronously.  The resulting file should be accessible through the
`org-export-stack' interface.

When optional argument SUBTREEP is non-nil, export the sub-tree at point,
extracting information from the headline properties first.

When optional argument VISIBLE-ONLY is non-nil, don't export contents of hidden
elements.

BODY-ONLY currently has no effect.  The entire buffer is always exported.

EXT-PLIST, when provided, is a property list with external parameters overriding
Org default settings, but still inferior to file-local settings.

Return PDF file's name."
  (interactive)
  (let ((outfile (org-export-output-file-name ".typ" subtreep)))
    (org-export-to-file 'typst outfile
                        async subtreep visible-only body-only ext-plist
                        #'org-typst-compile)))

(defun org-typst-compile (typfile)
  "Compile Typst file to PDF.

TYPFILE is the name of the file being compiled.  The Typst command for the
compilation is controlled by `org-typst-process'.  Output of the compilation
process is redirected to \"*Org PDF Typst Output*\" buffer.

Return PDF file name or raise an error if it couldn't be produced."
  (let* ((log-buf-name "*Org PDF Typst Output*")
         (log-buf (get-buffer-create log-buf-name))
         (process (format org-typst-process typfile))
         outfile)
    (with-current-buffer log-buf
      (erase-buffer))

    (setq outfile (org-compile-file typfile
                                    (list process)
                                    "pdf"
                                    (format "See %S for details" log-buf-name)
                                    log-buf
                                    nil))
    outfile))

;; Citation Exporter
(defun org-typst-export-bibliography (_keys files style properties _backend com)
  (let ((dir (file-name-parent-directory (plist-get com :input-file)))
        (title (plist-get properties :title)))
    (format "#bibliography(%s%s(%s))"
            (and style (format "style: \"%s\", " style))
            (if title (format "title: %s, " (org-typst--as-string title)) "")
            (mapconcat (lambda (f) (org-typst--as-string (file-relative-name f dir)))
                       files
                       ", "))))

(defun org-typst-export-citation (citation style _ _info)
  (let ((references (org-cite-get-references citation)))
    (format "#cite(label(%s)%s)"
            (mapconcat (lambda (r) (org-typst--as-string (org-element-property :key r)))
                       references
                       ", ")
            (or (and (car style) (format ", style: \"%s\"" (car style)))  ""))))

;; Register `typst' processor
(org-cite-register-processor 'typst
                             :export-bibliography #'org-typst-export-bibliography
                             :export-citation #'org-typst-export-citation)

(provide 'ox-typst)
;;; ox-typst.el ends here
