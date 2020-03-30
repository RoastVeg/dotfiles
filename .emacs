(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(misterioso))
 '(inhibit-startup-screen t)
 '(markdown-command "markdown_py")
 '(package-selected-packages
   '(typescript-mode dotenv-mode vterm xterm-color keychain-environment magit yaml-mode flymake-php flymake-cursor flymake-css flymake markdown-mode editorconfig jsx-mode ack json-mode rust-mode web-mode php-mode))
 '(php-mode-coding-style 'psr2))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(term-color-black ((t (:background "#2d3743" :foreground "#2d3743"))))
 '(term-color-blue ((t (:background "#008b8b" :foreground "#008b8b"))))
 '(term-color-cyan ((t (:background "#23d7d7" :foreground "#23d7d7"))))
 '(term-color-green ((t (:background "#7faf68" :foreground "#7faf68"))))
 '(term-color-magenta ((t (:background "#ed74cd" :foreground "#ed74cd"))))
 '(term-color-red ((t (:background "#ff4242" :foreground "#ff4242"))))
 '(term-color-white ((t (:background "#e1e1e0" :foreground "#e1e1e0"))))
 '(term-color-yellow ((t (:background "#ffad29" :foreground "#ffad29")))))

(setq vc-handled-backends '(Git))
(setq backup-directory-alist '(("" . "~/.emacs.d/backup")))
(setq create-lockfiles nil)

(unless (display-graphic-p)
  (defun wl-cut (beg end)
    "Wayland cut"
    (interactive "r")
    (call-process-shell-command (concat "exec wl-copy " (buffer-substring-no-properties beg end) " &") nil 0)
    (kill-region beg end))
  (defun wl-copy (beg end)
    "Wayland copy"
    (interactive "r")
    (call-process-shell-command (concat "exec wl-copy -n " (buffer-substring-no-properties beg end) " &") nil 0)
    (copy-region-as-kill beg end))
  (defun wl-paste ()
    "Wayland paste"
    (interactive)
    (insert (shell-command-to-string "wl-paste -n | tr -d \r")))
  (global-set-key (kbd "C-c C-w") 'wl-cut)
  (global-set-key (kbd "C-c M-w") 'wl-copy)
  (global-set-key (kbd "C-c C-y") 'wl-paste))

(global-set-key (kbd "C-c C-t") 'vterm-other-window)

(normal-erase-is-backspace-mode 1)

(defun on-frame-open (&optional frame)
  (unless (display-graphic-p frame)
    (set-face-background 'default "unspecified-bg" frame)
    (normal-erase-is-backspace-mode 0)))

(add-hook 'window-setup-hook 'on-frame-open)

(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  (when no-ssl
    (warn "\
Your version of Emacs does not support SSL connections,
which is unsafe because it allows man-in-the-middle attacks.
There are two things you can do about this warning:
1. Install an Emacs version that does support SSL and be safe.
2. Remove this warning from your init file so you won't see it again."))
  ;; Comment/uncomment these two lines to enable/disable MELPA and MELPA Stable as desired
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  ;;(add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
  (when (< emacs-major-version 24)
    ;; For important compatibility libraries like cl-lib
    (add-to-list 'package-archives (cons "gnu" (concat proto "://elpa.gnu.org/packages/")))))
(package-initialize)

(set-frame-font "-CTDB-Fira Code-normal-normal-normal-*-*-*-*-*-d-0-iso10646-1")

(defun fira-code-mode--make-alist (list)
  "Generate prettify-symbols alist from LIST."
  (let ((idx -1))
    (mapcar
     (lambda (s)
       (setq idx (1+ idx))
       (let* ((code (+ #Xe100 idx))
              (width (string-width s))
              (prefix ())
              (suffix '(?\s (Br . Br)))
              (n 1))
	 (while (< n width)
	   (setq prefix (append prefix '(?\s (Br . Bl))))
	   (setq n (1+ n)))
	 (cons s (append prefix suffix (list (decode-char 'ucs code))))))
     list)))

(defconst fira-code-mode--ligatures
  '("www" "**" "***" "**/" "*>" "*/" "\\\\" "\\\\\\"
    "{-" "[]" "::" ":::" ":=" "!!" "!=" "!==" "-}"
    "--" "---" "-->" "->" "->>" "-<" "-<<" "-~"
    "#{" "#[" "##" "###" "####" "#(" "#?" "#_" "#_("
    ".-" ".=" ".." "..<" "..." "?=" "??" ";;" "/*"
    "/**" "/=" "/==" "/>" "//" "///" "&&" "||" "||="
    "|=" "|>" "^=" "$>" "++" "+++" "+>" "=:=" "=="
    "===" "==>" "=>" "=>>" "<=" "=<<" "=/=" ">-" ">="
    ">=>" ">>" ">>-" ">>=" ">>>" "<*" "<*>" "<|" "<|>"
    "<$" "<$>" "<!--" "<-" "<--" "<->" "<+" "<+>" "<="
    "<==" "<=>" "<=<" "<>" "<<" "<<-" "<<=" "<<<" "<~"
    "<~~" "</" "</>" "~@" "~-" "~=" "~>" "~~" "~~>" "%%"
    "x" ":" "+" "+" "*"))

(defvar fira-code-mode--old-prettify-alist)

(defun fira-code-mode--enable ()
  "Enable Fira Code ligatures in current buffer."
  (setq-local fira-code-mode--old-prettify-alist prettify-symbols-alist)
  (setq-local prettify-symbols-alist (append (fira-code-mode--make-alist fira-code-mode--ligatures) fira-code-mode--old-prettify-alist))
  (prettify-symbols-mode t))

(defun fira-code-mode--disable ()
  "Disable Fira Code ligatures in current buffer."
  (setq-local prettify-symbols-alist fira-code-mode--old-prettify-alist)
  (prettify-symbols-mode -1))

(define-minor-mode fira-code-mode
  "Fira Code ligatures minor mode"
  :lighter " Fira Code"
  (setq-local prettify-symbols-unprettify-at-point 'right-edge)
  (if fira-code-mode
      (fira-code-mode--enable)
    (fira-code-mode--disable)))

(defun fira-code-mode--setup ()
  "Setup Fira Code Symbols"
  (set-fontset-font t '(#Xe100 . #Xe16f) "Fira Code Symbol"))

(provide 'fira-code-mode)

(when (display-graphic-p)
  (defun on-find-file ()
    (fira-code-mode))
  (add-hook 'find-file-hook 'on-find-file))

(editorconfig-mode 1)
(keychain-refresh-environment)

(global-set-key (kbd "<home>") 'beginning-of-line)
(global-set-key (kbd "<end>") 'end-of-line)

(setq vterm-kill-buffer-on-exit t)
;(add-hook 'vterm-exit-functions (lambda (vterm event)
;				  (let* ((buffer vterm)
;					 (window (get-buffer-window buffer)))
;				    (when window
;                                      (delete-window window)))))

(with-eval-after-load 'esh-mode
  (add-hook 'eshell-mode-hook
            (lambda ()
              (setq xterm-color-preserve-properties t)))

  (add-to-list 'eshell-preoutput-filter-functions 'xterm-color-filter)
  (setq eshell-output-filter-functions (remove 'eshell-handle-ansi-color eshell-output-filter-functions)))
(setenv "TERM" "xterm-24bit")

(require 'dired-x)
(setq dired-omit-files (concat dired-omit-files "\\|^\\..+$"))
(add-hook 'dired-mode-hook (lambda () (dired-omit-mode)))

(dired ".")
