(when (require 'elpy nil t)
  (elpy-enable)
  (elpy-clean-modeline))
(define-key elpy-mode-map (kbd "C-;") 'iedit-mode)
(provide 'setup-elpy-mode)
(add-to-list 'yas-snippet-dirs "~/.emacs.d/snippets/")

