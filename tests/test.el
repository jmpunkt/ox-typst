;; -*- lexical-binding: t -*-
(require 'vc-git)

(load (file-name-concat (vc-git-root default-directory) "ox-typst.el"))

;; Required by math tests
(setq org-export-allow-bind-keywords t)

(defvar org-typst-test--tests-failed 0)
(defvar org-typst-test--tests-skipped 0)
(defvar org-typst-test--tests-succeeded 0)
(defvar org-typst-test--report-buffer "*REPORT EXPORT*")

(defun org-export-deterministic-reference (references)
  (let ((new (length references)))
    (while (rassq new references) (setq new (+ new 1)))
    new))

(advice-add #'org-export-new-reference :override #'org-export-deterministic-reference)

(defun org-typst-test-generate ()
  (interactive)
  (let* ((base-dir (vc-git-root default-directory))
         (test-dir (concat base-dir "tests/")))
    (dolist (org-file (directory-files-recursively test-dir "\\.org$"))
      ;; Only generate Typst files if they already exist, adding new test cases
      ;; must be done manually
      (when (file-exists-p (format "%s.typ" (file-name-sans-extension org-file)))
        (with-current-buffer (find-file-noselect org-file)
          (org-typst-export-to-typst))))))

(defun org-typst-test--report-line (prefix status suffix &optional fn)
  (let ((status-text (concat "["
                             (cond ((eq status 'success) "PASS")
                                   ((eq status 'skip) "SKIP")
                                   ((eq status 'fail) "FAIL"))
                             "]"))
        (color (cond ((eq status 'success) "green")
                     ((eq status 'skip) "gray")
                     ((eq status 'fail) "red"))))
    (if (not noninteractive)
        (with-current-buffer (get-buffer-create org-typst-test--report-buffer)
          (let* ((start (point))
                 (map (make-sparse-keymap))
                 (end (progn
                        (insert prefix)
                        (insert status-text)
                        (insert suffix)
                        (point)))
                 (ov-line (make-overlay start (1+ end)))
                 (ov-prefix (make-overlay (+ start (length prefix))
                                          (+ start (length prefix) (length status-text))))
                 (action (lambda () (interactive) (funcall fn))))
            (when fn
              (define-key map (kbd "RET") action)
              (define-key map [mouse-2] action))
            (overlay-put ov-line 'keymap map)
            (overlay-put ov-prefix 'keymap map)
            (overlay-put ov-prefix 'face `(:background ,color)))
          (newline))
      (princ (concat prefix status-text suffix "\n" (when (and (eq status 'fail) fn)
                                                      (save-excursion
                                                        (funcall fn)
                                                        (buffer-string))))
                     #'external-debugging-output))))

(defun org-typst-test--report (test stages)
  (cl-assert (listp stages))
  (let* ((status (seq-reduce (lambda (acc stage)
                               (let ((status (nth 1 stage)))
                                 (cond ((eq acc 'fail) acc)
                                       ((eq acc 'skip) (if (eq status 'fail) status acc))
                                       ((eq acc 'success) status))))
                             stages 'success)))
    (cond ((eq status 'fail) (setq org-typst-test--tests-failed (1+ org-typst-test--tests-failed)))
          ((eq status 'skip) (setq org-typst-test--tests-skipped (1+ org-typst-test--tests-skipped)))
          ((eq status 'success) (setq org-typst-test--tests-succeeded (1+ org-typst-test--tests-succeeded))))
    (org-typst-test--report-line "" status (concat " " test) (lambda () (find-file test)))
    (dolist (stage stages)
      (let* ((test (nth 0 stage))
             (status (nth 1 stage))
             (fn (nth 2 stage)))
        (org-typst-test--report-line "+ " status (concat " " test) fn))))
  (if (not noninteractive)
      (with-current-buffer (get-buffer-create org-typst-test--report-buffer)
        (goto-char (point-max))
        (insert "\n"))
    (princ "\n" #'external-debugging-output)))

(defun org-typst-test-run ()
  (interactive)
  (let* ((base-dir (vc-git-root default-directory))
         (test-dir (concat base-dir "tests/")))
    (when (not base-dir)
      (error "Not in a git repository"))
    (setq org-typst-test--tests-failed 0)
    (setq org-typst-test--tests-skipped 0)
    (setq org-typst-test--tests-succeeded 0)
    (with-current-buffer (get-buffer-create org-typst-test--report-buffer)
      (read-only-mode -1)
      (erase-buffer))
    (dolist (org-file (directory-files-recursively test-dir "\\.org$"))
      (let* ((org-buffer (find-file-noselect org-file))
             (typst-file (format "%s.typ" (file-name-sans-extension org-file))))
        (let ((result-transpile
               (if (not (file-exists-p typst-file))
                   (list 'skip nil)
                 (let* ((typst-new-file (format "%s.new.typ" (file-name-sans-extension org-file)))
                        (typst-new-buffer (progn (when (get-buffer typst-new-file)
                                                   (kill-buffer typst-new-file))
                                                 (find-file typst-new-file)))
                        (typst-buffer (find-file-noselect typst-file))
                        (typst-buffer-content (with-current-buffer typst-buffer
                                                (buffer-substring-no-properties
                                                 (point-min)
                                                 (point-max)))))
                   (when (with-current-buffer typst-new-buffer)
                     (erase-buffer))
                   (with-current-buffer org-buffer
                     (org-typst-export-as-typst)
                     (with-current-buffer typst-new-buffer
                       (insert-buffer-substring org-typst-export-buffer-name)
                       (set-buffer-modified-p nil))
                     (list (if (string= typst-buffer-content
                                        (with-current-buffer org-typst-export-buffer-name
                                          (buffer-substring-no-properties (point-min) (point-max))))
                               'success
                             'fail)
                           (lambda () (diff-buffers typst-buffer typst-new-buffer)))))))

              (result-compile
               (if (not (file-exists-p typst-file))
                   (list 'skip nil)
                 (let* ((typst-output-buffer (format "*Output Typst %s*"
                                                     (file-name-sans-extension org-file)))
                        (exit-code (shell-command (format "typst c '%s'"
                                                          (expand-file-name typst-file))
                                                  (progn (when (get-buffer typst-output-buffer)
                                                           (kill-buffer typst-output-buffer))
                                                         typst-output-buffer))))
                   (list (if (zerop exit-code) 'success 'fail)
                         (lambda () (switch-to-buffer (get-buffer-create typst-output-buffer))))))))
          (org-typst-test--report org-file (list
                                            (cons "Transpile to Typst" result-transpile)
                                            (cons "Compile Typst File" result-compile))))))
    (switch-to-buffer org-typst-test--report-buffer)
    (goto-char (point-max))
    (insert (format "\nTests: %d\nSucceeded: %d\nSkipped: %d\nFailed: %d\n"
                    (+ org-typst-test--tests-succeeded
                       org-typst-test--tests-skipped
                       org-typst-test--tests-failed)
                    org-typst-test--tests-succeeded
                    org-typst-test--tests-skipped
                    org-typst-test--tests-failed))
    (delete-other-windows)
    (read-only-mode 1)
    (when (> org-typst-test--tests-failed 0)
      (error "Not all tests passed"))))
