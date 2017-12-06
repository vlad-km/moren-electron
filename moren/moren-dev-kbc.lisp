;;; -*- mode:lisp;  coding:utf-8 -*-

;;;
;;; This file is part of the MOREN environment
;;; Moren development console
;;; Keyboard commands
;;; Copyright © 2017 Vladimir Mezentsev
;;;
;;;
;;; MOREN environment created for rapidly programming and prototyping programs
;;; on JSCL language (subset of Common Lisp) in yours browser.
;;;
;;; MOREN is free software: you can redistribute it and/or modify it under
;;; the terms of the GNU General  Public License as published by the Free
;;; Software Foundation,  either version  3 of the  License, or  (at your
;;; option) any later version.
;;;
;;; MOREN is distributed  in the hope that it will  be useful, but WITHOUT
;;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;;; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
;;; for more details.
;;;
;;; You should  have received a  copy of  the GNU General  Public License
;;; Version 3 from  <http://www.gnu.org/licenses/>.
;;;
;;; JSCL   - JSCL is a Common Lisp to Javascript compiler, which is bootstrapped
;;; from Common Lisp and executed from the browser.
;;; https://github.com/jscl-project/jscl
;;;
;;; Version for Electron
;;;
;;; Electron is a framework for creating native applications with web technologies
;;; like JavaScript, HTML, and CSS.
;;; https://electron.atom.io/
;;;
;;;

;;;
;;;                             MOREN NAMESPACE
;;;

(in-package :mordev)


;;; start electron section


(defun show-open-dialog ()
    (let ((prop (mkjso "properties" (vector (lisp-to-js "openFile")
                                            (lisp-to-js "multiSelections"))))
          (select))
        (setq select (vector-to-list (#j:electron:remote:dialog:showOpenDialog prop)))
        (mapcar (lambda (x) (js-to-lisp x)) select)))



;;; set app menu
(defun set-app-topmenu (menu)
    (#j:electron:remote:Menu:setApplicationMenu menu))


;;; make topmenu from template
(defun make-topmenu-from (template)
    (#j:electron:remote:Menu:buildFromTemplate template))

;;; new menu
(defun new-menu (&optional obj)
    (if obj
        (make-new #j:electron:remote:Menu obj)
        (make-new #j:electron:remote:Menu)))


;;; new menu item
(defun new-menu-item (&rest options)
    (flet ((new-item (args)
               (if (null options)
                   (error "wtf ~a options?")
                   (if (oddp (length options))
                       (error "Odd length options")))
               (apply #'make-js-object options)))
        (make-new #j:electron:remote:MenuItem (new-item options))))


;;; context menu
;;;
;;; options - object {x:nnn, y:nnn}
;;;           mouse cursor position
;;;
(defun menu-popup (menu &optional browser-window options)
    (funcall ((oget menu "popup" "bind")
              menu
              (#j:electron:remote:getCurrentWindow) options)))


;;; append menu item
(defun menu-append (menu item &rest items)
    (let ((cc (curry (lambda (x)
                         (funcall ((oget menu "append" "bind") menu x))))))
        (funcall cc item)
        (dolist (x items)
            (funcall cc x))))



;;; insert item to menu position
(defun menu-insert (menu position item)
    (funcall ((oget menu "insert" "bind") menu position item)))


;;; end electron section


;;; keyboard handlers

;;; Control+Shift+R
;;;
;;; Reset console

(defun %kb-reset-console-fn ()
    (mordev:jqreset))



;;; Control+Shift+H+E
;;;
;;; History explore
;;;
(defun %kb-sh-explore-fn ()
    (mordev:explore-repl-history))


;;;
;;; Generic fn for history command
;;;
(defun %kb-sh-generic-template (template)
    (let ((state #j:jqconsole:state))
        ;; switch jqconsole state to input
        (setf #j:jqconsole:state 0)
        ;; substitute hist item as repl input string
        (#j:jqconsole:SetPromptText template)
        ;; restore state
        (setf #j:jqconsole:state state)
        ;; wait enter press
        (values) ))


;;; Control+Shift+H+L
;;;
;;; History look
;;; read start end from console prompt
;;;

(defun %kb-sh-look-fn ()
    (%kb-sh-generic-template "(mordev:look-repl-history)"))


;;; Control+Shift+H+I
;;;
;;; History item
;;; read item number from console prompt
;;;

(defun %kb-sh-take-item-fn ()
    (%kb-sh-generic-template "(mordev:take-repl-history-item ?)"))


;;; Control+Shift+H+D
;;;
;;; Dump History to file
;;;
(defun %kb-sh-dump-fn ()
    (mordev:dump-repl-history))

;;;
;;; Apropos
;;;

(defun moren-map-symbols (fn package)
    (map-for-in fn (%package-symbols package))
    (dolist (used (package-use-list package))
        (jscl::%map-external-symbols fn package)))

#|
(defun moren-map-apropos-symbols (string package)
    (let ((fn (lambda (symbol)
                  (format
                   t
                   "~a~%"
                   (concat (string symbol) " "
                           (if (boundp symbol) " ((bound)"
                               (if (fboundp symbol) " (fbound)" "  ")))))))
        (flet ((handle-symbol (symbol)
                   (when (search string (symbol-name symbol) :test #'char-equal)
                       (funcall fn symbol))))
            (do-symbols (symbol package) (handle-symbol symbol)))))
|#

(defun moren-map-apropos-symbols (string &optional (package *package*))
    (let ((fn (lambda (symbol)
                  (format
                   t
                   "~a~%"
                   (concat (string symbol) " "
                           (if (boundp symbol) " ((bound)"
                               (if (fboundp symbol) " (fbound)" "  ")))))))
        (flet ((handle-symbol (symbol)
                   (when (search string (symbol-name symbol) :test #'char-equal)
                       (funcall fn symbol))))

            ;;(do-symbols (symbol package) (handle-symbol symbol))

            (jscl::map-for-in (lambda (symbol) (handle-symbol symbol)) (jscl::%package-symbols package))
            (dolist (used (package-use-list package))
                (jscl::%map-external-symbols (lambda (symbol) (handle-symbol symbol)) package))
            )))





(defun moren-apropos-list (string &optional package external-only)
    (let (symbols)
        (map-apropos-symbols
         (lambda (symbol)
             (pushnew symbol symbols :test #'eq))
         string package external-only)
        symbols))

(defun moren-apropos (string)
    (moren-map-apropos-symbols (string string)))

;;;
;;; list all packages
;;;
(defun %kb-aprop-all-packages ()
    (mordev:rx-emit :out (list-all-packages)))

;;;
;;; Describe selected
;;;
(defun %kb-describe-fn ()
    (let* ((selected (#j:window:getSelection))
           (text (funcall ((oget selected "toString" "bind") selected)))
           (expr)
           (stream)
           (symbol))
        (format *mordev-standard-output* "~%---> Inspect ")
        (handler-case
            (progn
                (setq stream (jscl::make-string-stream text))
                (setq value (jscl::ls-read stream))
                (prin1 value)
                (prin1 '<---)
                (terpri)
                (describe value))
          (error (err)
              (format *mordev-standard-output* "Inspector: what that ~s ?" (jscl::!condition-args err))))))


;;; Moren top menu
;;;
#|
(defun moren-top-menu-template()
    (vector
     (mkjso "label" "Moren"
            "submenu" (vector
                       (mkjso "label" "Reset console"
                              "accelerator" "CmdOrCtrl+Shift+R"
                              "click"
                              (lambda (item bw event) (%kb-reset-console-fn)))

                       (mkjso "label" "Explore history"
                              "accelerator" "CmdOrCtrl+Shift+E"
                              "click"
                              (lambda (item bw event) (%kb-sh-explore-fn) ))

                       (mkjso "label" "Look history"
                              "accelerator" "CmdOrCtrl+Shift+L"
                              "click"
                              (lambda (item bw event) (%kb-sh-look-fn) ))

                       (mkjso "label" "Take history item"
                              "accelerator" "CmdOrCtrl+Shift+T"
                              "click"
                              (lambda (item bw event) (%kb-sh-take-item-fn) ))

                       (mkjso "label" "Dump history"
                              "accelerator" "CmdOrCtrl+Shift+D"
                              "click"
                              (lambda (item bw event) (%kb-sh-dump-fn) ))
                       )) ;; end Moren menu

     (mkjso "label" "Edit"
            "submenu" (vector
                       (mkjso "label" "Copy"
                              "role" "copy"
                              "accelerator" "CmdOrCtrl+C")
                       (mkjso "label" "Paste"
                              "role" "paste"
                              "accelerator" "CmdOrCtrl+V")))

     (mkjso "label" "View"
            "submenu" (vector
                       (mkjso "label" "Toggle Developer Tool"
                              "accelerator" "CmdOrCtrl+Shift+I"
                              "click"
                              (lambda (item bw event)
                                  (when bw
                                      (funcall ((oget bw "toggleDevTools" "bind") bw)) ))  )))

     (mkjso "label" "Help"
            "role" "help"
            "submenu" (vector))

     ))
|#

(defun moren-top-menu-template()
    (vector
     (mkjso "label" "Moren"
            "submenu" (vector
                       (mkjso "label" "Reset console"
                              "accelerator" "CmdOrCtrl+Shift+R"
                              "click"
                              (lambda (item bw event) (%kb-reset-console-fn)))
                       (mkjso "label" "Shadow history"
                              "submenu" (vector
                                         (mkjso "label" "Explore history"
                                                "accelerator" "CmdOrCtrl+Shift+E"
                                                "click"
                                                (lambda (item bw event) (%kb-sh-explore-fn) ))

                                         (mkjso "label" "Look history"
                                                "accelerator" "CmdOrCtrl+Shift+L"
                                                "click"
                                                (lambda (item bw event) (%kb-sh-look-fn) ))

                                         (mkjso "label" "Take history item"
                                                "accelerator" "CmdOrCtrl+Shift+T"
                                                "click"
                                                (lambda (item bw event) (%kb-sh-take-item-fn) ))

                                         (mkjso "label" "Dump history"
                                                "accelerator" "CmdOrCtrl+Shift+D"
                                                "click"
                                                (lambda (item bw event) (%kb-sh-dump-fn) )) ))
                       (mkjso "label" "Describe"
                              "accelerator" "Alt+Shift+D"
                              "click"
                              (lambda (item bw event) (%kb-describe-fn)))

                       )) ;; end Moren menu

     (mkjso "label" "Edit"
            "submenu" (vector
                       (mkjso "label" "Copy"
                              "role" "copy"
                              "accelerator" "CmdOrCtrl+C")
                       (mkjso "label" "Paste"
                              "role" "paste"
                              "accelerator" "CmdOrCtrl+V")))

     (mkjso "label" "View"
            "submenu" (vector
                       (mkjso "label" "Toggle Developer Tool"
                              "accelerator" "CmdOrCtrl+Shift+I"
                              "click"
                              (lambda (item bw event)
                                  (when bw
                                      (funcall ((oget bw "toggleDevTools" "bind") bw)) ))  )))

     (mkjso "label" "Help"
            "role" "help"
            "submenu" (vector))

     ))






;;; setup topmenu command
(defun setup-top-menu ()
    (set-app-topmenu
     (make-topmenu-from
      (moren-top-menu-template))))


;;;
;;; Moren popup menu
;;;

(defun moren-popup-describe-fn ()
    (new-menu-item  "label" "Describe selected"
                    "click" (lambda (item bw event)
                                (%kb-describe-fn))))

;;; setup popup menu command
(defun setup-moren-popup ()
    (setq *moren-popup-menu (new-menu))
    (setq *moren-popup-content (moren-popup-describe-fn))
    (menu-append *moren-popup-menu *moren-popup-content)
    (#j:window:addEventListener
     "contextmenu"
     (lambda (event)
         (funcall ((oget event "preventDefault" "bind") event))
         (menu-popup *moren-popup-menu))))


(defun %mordev-keyboard-setup ()
    (setup-top-menu)
    (setup-moren-popup))


;;;;; EOF
