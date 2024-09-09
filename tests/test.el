;; -*- lexical-binding: t -*-
(require 'vc-git)

(load (file-name-concat (vc-git-root default-directory) "ox-typst.el"))

(defvar test-failed nil)
(defvar report-buffer "REPORT")

(defun org-export-deterministic-reference (references)
  (let ((new (length references)))
    (while (rassq new references) (setq new (+ new 1)))
    new))

(advice-add #'org-export-new-reference :override #'org-export-deterministic-reference)

(defun test/generate ()
  (interactive)
  (let* ((base-dir (vc-git-root default-directory))
         (test-dir (concat base-dir "tests/")))
    (dolist (org-file (directory-files-recursively test-dir "\\.org$"))
      ;; Only generate Typst files if they already exist, adding new test cases
      ;; must be done manually
      (when (file-exists-p (format "%s.typ" (file-name-sans-extension org-file)))
        (with-current-buffer (find-file-noselect org-file)
          (org-typst-export-to-typst))))))

(defun test/report (file status old new)
  (let ((format-status (lambda ()
                         (let ((status-string (cond ((eq status 'success) "PASS")
                                                    ((eq status 'skip) "SKIP")
                                                    ((eq status 'fail) "FAIL"))))
                           (princ (format "[%s] %s" status-string file) #'external-debugging-output))))
        (color (cond ((eq status 'success) "green")
                     ((eq status 'skip) "grey")
                     ((eq status 'fail) "red"))))
    (when  (eq status 'fail)
      (setq test-failed t))
    (if (not noninteractive)
        (with-current-buffer (get-buffer-create report-buffer)
          (let* ((start (point))
                 (map (make-sparse-keymap))
                 (end (progn (insert (funcall format-status)) (point)))
                 (ov-line (make-overlay start (1+ end)))
                 (ov-prefix (make-overlay start (+ start 6)))
                 (goto-diff (lambda () (interactive) (diff-buffers old new))))
            (when (or (eq status 'fail) (eq status 'success))
              (define-key map (kbd "RET") goto-diff)
              (define-key map [mouse-2] goto-diff))
            (overlay-put ov-line 'keymap map)
            (overlay-put ov-prefix 'keymap map)
            (overlay-put ov-prefix 'face `(:background ,color)))
          (newline))
      (princ (format "%s\n" (funcall format-status)) #'external-debugging-output))))

(defun test/run ()
  (interactive)
  (let* ((base-dir (vc-git-root default-directory))
         (test-dir (concat base-dir "tests/")))
    (when (not base-dir)
      (error "Not in a git repository"))
    (setq test-failed nil)
    (with-current-buffer (get-buffer-create "REPORT")
      (read-only-mode -1)
      (erase-buffer))
    (dolist (org-file (directory-files-recursively test-dir "\\.org$"))
      (let* ((org-buffer (find-file-noselect org-file))
             (typst-file (format "%s.typ" (file-name-sans-extension org-file)))
             (typst-new-file (format "%s.new.typ" (file-name-sans-extension org-file)))
             (typst-new-buffer (find-file typst-new-file)))
        (if (not (file-exists-p typst-file))
            (test/report org-file 'skip nil nil)
          (let* ((typst-buffer (find-file-noselect typst-file))
                 (typst-buffer-content (with-current-buffer typst-buffer
                                         (buffer-substring-no-properties (point-min) (point-max)))))
            (with-current-buffer org-buffer
              (org-typst-export-as-typst)
              (with-current-buffer typst-new-buffer
                (insert-buffer-substring org-typst-export-buffer-name)
                (set-buffer-modified-p nil))
              (test/report org-file
                           (if (string= typst-buffer-content
                                        (with-current-buffer org-typst-export-buffer-name
                                          (buffer-substring-no-properties (point-min) (point-max))))
                               'success
                             'fail)
                           typst-buffer
                           typst-new-buffer))))))
    (switch-to-buffer report-buffer)
    (delete-other-windows)
    (read-only-mode 1)
    (when noninteractive
      (if test-failed
          (error "Some tests failed")
        (message "All tests passed")))))

