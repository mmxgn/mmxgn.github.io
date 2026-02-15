;;; build-site.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2024 Emmanouil Theofanis Chourdakis
;;
;; Author: Emmanouil Theofanis Chourdakis <etchourdakis@gmail.com>
;; Maintainer: Emmanouil Theofanis Chourdakis <etchourdakis@gmail.com>
;; Created: Οκτωβρίου 05, 2024
;; Modified: Οκτωβρίου 05, 2024
;; Version: 0.0.1
;; Keywords: abbrev bib c calendar comm convenience data docs emulations extensions faces files frames games hardware help hypermedia i18n internal languages lisp local maint mail matching mouse multimedia news outlines processes terminals tex tools unix vc wp
;; Homepage: https://github.com/mmxgn/build-site
;; Package-Requires: ((emacs "24.3"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Description
;;
;;; Code:



(provide 'build-site)
;;; build-site.el ends here
;;;
;;;
;; Set the package installation directory so that packages aren't stored in the
;; ~/.emacs.d/elpa path.
(require 'package)
(setq package-user-dir (expand-file-name "./.packages"))
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

;; Initialize the package system
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Install dependencies
(package-install 'htmlize)

(require 'ox-publish)
;; Define the publishing project
(setq org-publish-project-alist
      (list
       (list "org-site:main"
             :recursive t
             :base-directory "./content"
             :publishing-function 'org-html-publish-to-html
             :publishing-directory "./public"
             :with-author nil           ;; Don't include author name
             :with-creator t            ;; Include Emacs and Org versions in footer
             :with-toc  nil ;; Include a table of contents
             :with-date t
             :section-numbers nil       ;; Don't include section numbers
             :time-stamp-file t
             :headline-levels 2
             :auto-sitemap t
             :author "mmxgn"
             :with-email nil
             :with-footnotes t
             :with-latex t
             :with-tables t
             :with-avatar-p t
             :with-badges-p t
             :with-smart-quotes t)
       ;; Static files (images, etc.)
       (list "org-site:static"
             :base-directory "./content/static"
             :base-extension "png\\|jpg\\|gif\\|pdf\\|css\\|js"
             :recursive t
             :publishing-directory "./public/static"
             :publishing-function 'org-publish-attachment)))    ;; Don't include time stamp in file

(setq org-html-validation-link nil
      org-html-head-include-scripts nil       ;; Use our own scripts
      org-html-head-include-default-style nil ;; Use our own styles
      org-html-head (concat
                     "<link rel=\"stylesheet\" href=\"https://cdn.simplecss.org/simple.min.css\" />"
                     "<link rel=\"stylesheet\" href=\"static/style.css\" />"))
;; (setq org-html-postamble 'nil)

(defun load-file-as-string (file-path)
  "Load the contents of the file at FILE-PATH and return it as a string."
  (with-temp-buffer
    (insert-file-contents file-path)
    (buffer-string)))

(setq org-html-preamble (load-file-as-string "content/static/preamble.html"))
;; (setq org-html-preamble (concat "<nav>"
;;                                 "<a href=\"index.html\">Home</i></a> "
;;                                 "<a href=\"blog.html\">Blog</a> "
;;                                 "<a href=\"https://github.com/mmxgn\">Github</a> "
;;                                 "<a href=\"https://linkedin.com/in/echourdakis\">LinkedIn</a> "
;;
;;                                 "<a href=\"static/cv.pdf\">CV</a> "
;;                                 "<a href=\"https://scholar.google.com/citations?user=Hf0rcRcAAAAJ&hl=en&oi=ao\">Google Scholar</a>"
;;                                 "</nav>"))

(setq org-html-postamble (load-file-as-string "content/static/postamble.html"))
(setq python-indent-offset 4)
;; Generate the site output
(org-publish-all t)
(message "Build complete!")

