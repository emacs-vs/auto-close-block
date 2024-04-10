;;; auto-close-block.el --- Automatically close block  -*- lexical-binding: t; -*-

;; Copyright (C) 2024  Shen, Jen-Chieh

;; Author: Shen, Jen-Chieh <jcs090218@gmail.com>
;; Maintainer: Shen, Jen-Chieh <jcs090218@gmail.com>
;; URL: https://github.com/emacs-vs/auto-close-block
;; Version: 0.1.0
;; Package-Requires: ((emacs "26.1"))
;; Keywords: convenience

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Automatically close block.
;;

;;; Code:

(defgroup auto-close-block nil
  "Automatically close block."
  :prefix "auto-close-block-"
  :group 'convenience
  :link '(url-link :tag "Repository" "https://github.com/emacs-vs/auto-close-block"))

(defcustom auto-close-block-pair
  '((c-mode            . (("/*" "*/")))
    (c++-mode          . (("/*" "*/")))
    (objc-mode         . (("/*" "*/")))
    (csharp-mode       . (("/*" "*/")))
    (swift-mode        . (("/*" "*/")))
    (jai-mode          . (("/*" "*/")))
    (java-mode         . (("/*" "*/")))
    (processing-mode   . (("/*" "*/")))
    (groovy-mode       . (("/*" "*/")))
    (jenkinsfile-mode  . (("/*" "*/")))
    (javascript-mode   . (("/*" "*/")))
    (js-mode           . (("/*" "*/")))
    (js2-mode          . (("/*" "*/")))
    (js3-mode          . (("/*" "*/")))
    (json-mode         . (("/*" "*/")))
    (rjsx-mode         . (("/*" "*/")))
    (web-mode          . (("<!--" " -->" " ") ("/*" "*/")))
    (html-mode         . (("<!--" " -->" " ") ("/*" "*/")))
    (php-mode          . (("/*" "*/") ("<?php" "?>" " ")))
    (actionscript-mode . (("/*" "*/")))
    (typescript-mode   . (("/*" "*/")))
    (go-mode           . (("/*" "*/")))
    (scala-mode        . (("/*" "*/")))
    (rust-mode         . (("/*" "*/")))
    (rustic-mode       . (("/*" "*/")))
    (css-mode          . (("/*" "*/")))
    (ssass-mode        . (("/*" "*/")))
    (scss-mode         . (("/*" "*/")))
    (shader-mode       . (("/*" "*/")))
    (lua-mode          . (("--[[" "]]"))))
  "Pair of block to close."
  :type 'alist
  :group 'auto-close-block)

;;
;; (@* "Externals" )
;;

(defvar lsp-inhibit-lsp-hooks)

;;
;; (@* "Util" )
;;

(defun auto-close-block--comment-p ()
  "Return non-nil if it's inside comment."
  (nth 4 (syntax-ppss)))

;;
;; (@* "Entry" )
;;

(defun auto-close-block-mode--enable ()
  "Enable `auto-close-block-mode'."
  (add-hook 'after-change-functions #'auto-close-block--after-change 10 t))

(defun auto-close-block-mode--disable ()
  "Disable `auto-close-block-mode'."
  (remove-hook 'after-change-functions #'auto-close-block--after-change t))

;;;###autoload
(define-minor-mode auto-close-block-mode
  "Minor mode `auto-close-block-mode'."
  :lighter " AutoCloseBlock"
  :group auto-close-block
  (if auto-close-block-mode (auto-close-block-mode--enable)
    (auto-close-block-mode--disable)))

;;
;; (@* "Core" )
;;

(defun auto-close-block--eolp ()
  "Return non-nil if nothing behind us."
  (save-excursion
    (null (re-search-forward "[^[:space:]]" (line-end-position) t))))

(defun auto-close-block--data ()
  "Return block data."
  (cdr (assoc major-mode auto-close-block-pair)))

(defun auto-close-block--after-change (beg end len &rest _)
  "Hook after change.

Arguments BEG, END and LEN came from the hook."
  (let ((lsp-inhibit-lsp-hooks))
    (when-let ((adding (< (+ beg len) end))
               (data (auto-close-block--data))
               ((auto-close-block--eolp)))
      (cl-some (lambda (pair)
                 (when-let* ((start (nth 0 pair))
                             (end (nth 1 pair))
                             (after ( or (nth 2 pair) ""))
                             ((looking-back (regexp-quote start)
                                            (length start))))
                   (insert end)
                   (forward-char (- 0 (length end)))
                   (insert after)
                   t))
               data))))

(provide 'auto-close-block)
;;; auto-close-block.el ends here
