;; Turn off mouse interface early in startup to avoid momentary display
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;; No splash screen please ... jeez
(setq inhibit-startup-message t)

;; Set path to dependencies
(setq site-lisp-dir
      (expand-file-name "site-lisp" user-emacs-directory))

;; Set up load path
(add-to-list 'load-path user-emacs-directory)
(add-to-list 'load-path site-lisp-dir)

;; Keep emacs Custom-settings in separate file
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file)


;; Settings for currently logged in user
(setq user-settings-dir
      (concat user-emacs-directory "users/" user-login-name))
(add-to-list 'load-path user-settings-dir)

;; Add external projects to load path
(dolist (project (directory-files site-lisp-dir t "\\w+"))
  (when (file-directory-p project)
    (add-to-list 'load-path project)))

;; Write backup files to own directory
(setq backup-directory-alist
      `(("." . ,(expand-file-name
                 (concat user-emacs-directory "backups")))))

;; Make backups of files, even when they're in version control
(setq vc-make-backup-files t)

;; Save point position between sessions
(require 'saveplace)
(setq-default save-place t)
(setq save-place-file (expand-file-name ".places" user-emacs-directory))

;; Are we on a mac?
(setq is-mac (equal system-type 'darwin))

;; Setup packages
(require 'setup-package)

;; Install extensions if they're missing
(defun init--install-packages ()
  (packages-install
   '(magit
     paredit
     move-text
     dash
     god-mode
     gist
     htmlize
     visual-regexp
     elpy
     flycheck
     flx
     flx-ido
     css-eldoc
     yasnippet
     smartparens
     ido-vertical-mode
     ido-at-point
     simple-httpd
     guide-key
     nodejs-repl
     restclient
     highlight-escape-sequences
     whitespace-cleanup-mode
     elisp-slime-nav
     git-commit-mode
     gitconfig-mode
     gitignore-mode
     clojure-mode
     smex
     color-theme)))

;; Set up appearance after zenburn is there
(require 'appearance)

(condition-case nil
    (init--install-packages)
  (error
   (package-refresh-contents)
   (init--install-packages)))

;; Lets start with a smattering of sanity
(require 'sane-defaults)

;; Setup environment variables from the user's shell.
(when is-mac
  (require-package 'exec-path-from-shell)
  (exec-path-from-shell-initialize))

;; guide-key
(require 'guide-key)
(setq guide-key/guide-key-sequence '("C-x r" "C-x 4" "C-x v" "C-x 8"))
(guide-key-mode 1)
(setq guide-key/recursive-key-sequence-flag t)
(setq guide-key/popup-window-position 'bottom)

;; Setup extensions
(eval-after-load 'ido '(require 'setup-ido))
(eval-after-load 'org '(require 'setup-org))
(eval-after-load 'dired '(require 'setup-dired))
(eval-after-load 'magit '(require 'setup-magit))
(eval-after-load 'grep '(require 'setup-rgrep))
(eval-after-load 'shell '(require 'setup-shell))
(require 'setup-hippie)
(require 'setup-yasnippet)
(require 'setup-perspective)
(require 'setup-ffip)
(require 'setup-html-mode)
(require 'setup-paredit)

;; Default setup of smartparens
(require 'smartparens-config)
(setq sp-autoescape-string-quote nil)
(--each '(css-mode-hook
          restclient-mode-hook
          js-mode-hook
          ruby-mode
          markdown-mode)
  (add-hook it 'turn-on-smartparens-mode))

;; Language specific setup files
(eval-after-load 'js2-mode '(require 'setup-js2-mode))
(eval-after-load 'ruby-mode '(require 'setup-ruby-mode))
(eval-after-load 'clojure-mode '(require 'setup-clojure-mode))
(eval-after-load 'markdown-mode '(require 'setup-markdown-mode))
(eval-after-load 'elpy-mode '(require 'setup-elpy-mode))


;; Load stuff on demand
(autoload 'skewer-start "setup-skewer" nil t)
(autoload 'skewer-demo "setup-skewer" nil t)
(autoload 'flycheck-mode "setup-flycheck" nil t)
(autoload 'auto-complete-mode "auto-complete" nil t)

;; Map files to modes
(require 'mode-mappings)

;; Highlight escape sequences
(require 'highlight-escape-sequences)
(hes-mode)
(put 'font-lock-regexp-grouping-backslash 'face-alias 'font-lock-builtin-face)

;; Visual regexp
(require 'visual-regexp)
(define-key global-map (kbd "M-&") 'vr/query-replace)
(define-key global-map (kbd "M-/") 'vr/replace)

;; Functions (load all files in defuns-dir)
(setq defuns-dir (expand-file-name "defuns" user-emacs-directory))
(dolist (file (directory-files defuns-dir t "\\w+"))
  (when (file-regular-p file)
    (load file)))

(require 'expand-region)
(require 'multiple-cursors)
(require 'delsel)
(require 'jump-char)
(require 'eproject)
(require 'wgrep)
(require 'smart-forward)
(require 'change-inner)
(require 'multifiles)

;; Fill column indicator
(require 'fill-column-indicator)
(setq fci-rule-color "#111122")

;; Browse kill ring
;; (require 'browse-kill-ring)
;; (setq browse-kill-ring-quit-action 'save-and-restore)

;; Smart M-x is smart
(require 'smex)
(smex-initialize)

;; Setup key bindings
(require 'key-bindings)

;; Misc
(require 'project-archetypes)
(require 'my-misc)
(when is-mac (require 'mac))

;; Elisp go-to-definition with M-. and back again with M-,
(autoload 'elisp-slime-nav-mode "elisp-slime-nav")
(add-hook 'emacs-lisp-mode-hook (lambda () (elisp-slime-nav-mode t) (eldoc-mode 1)))

;; Email, baby
;;(require 'setup-mu4e)

;; Emacs server
(require 'server)
(unless (server-running-p)
  (server-start))

;; Run at full power please
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)

;; Conclude init by setting up specifics for the current user
(when (file-exists-p user-settings-dir)
  (mapc 'load (directory-files user-settings-dir nil "^[^#].*el$")))

;;publishing parameters for different projects in orgmode
(require 'org-publish)
;(load "org-exp-bibtex")
(setq org-publish-project-alist
      '(
        ("org-notes"
         :base-directory "~/Dropbox/org/"
         :base-extension "org"
         :publishing-directory "~/public_html/"
         :recursive t
         :publishing-function org-publish-org-to-html
         :headline-levels 4             ; Just the default
         :auto-preamble t)
        ("org-notes"
         :base-directory "~/Dropbox/org/"
         :base-extension "org"
         :publishing-directory "~/public_html/"
         :recursive t
         :publishing-function org-publish-org-to-html
         :headline-levels 4             ; Just the default
         :auto-preamble t)
        ("org-static"
         :base-directory "~/Dropbox/org/"
         :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf"
         :publishing-directory "~/public_html/"
         :recursive t
         :publishing-function org-publish-attachment)
        ("org" :components ("org-notes" "org-static"))

        ("luciferase-inherit"
         :base-directory "~/Dropbox/org/"
         :base-extension "css\\|js"
         :publishing-directory "~/public_html/luciferase/"
         :publishing-function org-publish-attachment
         :recursive t)

        ("luciferase-org"
         :base-directory "~/luciferase/"
         :auto-index t
         :index-filename "sitemap.org"
         :index-title "Sitemap"
         :recursive t
         :base-extension "org"
         :publishing-directory "~/public_html/luciferase/"
         :publishing-function org-publish-org-to-html
         :headline-levels 3
         :auto-preamble t)
        ("luciferase-static"
         :base-directory "~/luciferase/"
         :recursive t
         :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf\\|svg"
         :publishing-directory "~/public_html/luciferase/"
         :publishing-function org-publish-attachment)

        ("luciferase" :components ("luciferase-inherit" "luciferase-notes" "luciferase-static"))

        ("influenza-inherit"
         :base-directory "~/Dropbox/org/"
         :base-extension "css\\|js"
         :publishing-directory "~/public_html/influenza/"
         :publishing-function org-publish-attachment
         :recursive t)

        ("influenza-org"
         :base-directory "~/influenza/src"
         :auto-index t
         :index-filename "sitemap.org"
         :index-title "Sitemap"
         :recursive t
         :base-extension "org"
         :publishing-directory "~/public_html/influenza/"
         :publishing-function org-publish-org-to-html
         :headline-levels 3
         :auto-preamble t)

        ("influenza-static"
         :base-directory "~/influenza/src/figures"
         :recursive t
         :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf\\|svg"
         :publishing-directory "~/public_html/influenza/figures"
         :publishing-function org-publish-attachment)

        ("influenza" :components ("influenza-static" "influenza-inherit" "influenza-notes"))

        ("python_course-inherit"
         :base-directory "~/Dropbox/org/"
         :base-extension "css\\|js"
         :publishing-directory "~/public_html/python_course/"
         :publishing-function org-publish-attachment
         :recursive t)

        ("python_course-org"
         :base-directory "~/Documents/Presentations/python_course/"
         :auto-index t
         :index-filename "sitemap.org"
         :index-title "Sitemap"
         :recursive t
         :base-extension "org"
         :publishing-directory "~/public_html/python_course/"
         :publishing-function org-publish-org-to-html
         :headline-levels 3
         :auto-preamble t)
        ("python_course-static"
         :base-directory "~/Documents/Presentations/python_course/"
         :recursive t
         :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf\\|svg"
         :publishing-directory "~/public_html/python_course/"
         :publishing-function org-publish-attachment)

        ("python_course" :components ("python_course-inherit" "python_course-notes" "python_course-static"))

        ("frontiers-inherit"
         :base-directory "~/Dropbox/org/"
         :base-extension "css\\|js"
         :publishing-directory "~/public_html/frontiers/"
         :publishing-function org-publish-attachment
         :recursive t)

        ("frontiers-org"
         :base-directory "~/Dropbox/frontiers_paper/"
         :auto-index t
         :index-filename "sitemap.org"
         :index-title "Sitemap"
         :recursive t
         :base-extension "org"
         :publishing-directory "~/public_html/frontiers/"
         :publishing-function org-publish-org-to-html
         :headline-levels 3
         :auto-preamble t)

        ("frontiers-static"
         :base-directory "~/Dropbox/frontiers_paper/"
         :recursive t
         :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf\\|svg"
         :publishing-directory "~/public_html/frontiers/"
         :publishing-function org-publish-attachment)

        ("frontiers" :components ("frontiers-inherit" "frontiers-notes" "frontiers-static"))))
