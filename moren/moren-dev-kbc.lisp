;;; -*- mode:lisp;  coding:utf-8 -*-

;;;
;;; This file is part of the MOREN environment
;;; Moren development console
;;; Keyboard commands
;;; Copyright © 2017 Vladimir Mezentsev
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
;;; options - object {x:nnn, y:nnn}
;;;           mouse cursor position
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
;;; Reset console
(defun %kb-reset-console-fn ()
    (dump-repl-history)
    (mordev:jqreset))


;;; Control+Shift+H+E
;;; History explore
(defun %kb-sh-explore-fn ()
    (mordev:explore-repl-history))


;;; Generic fn for history command
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
;;; History look
;;; read start end from console prompt
(defun %kb-sh-look-fn ()
    (%kb-sh-generic-template "(mordev:look-repl-history)"))


;;; Control+Shift+H+I
;;; History item
;;; read item number from console prompt
(defun %kb-sh-take-item-fn ()
    (%kb-sh-generic-template "(mordev:take-repl-history-item ?)"))


;;; Control+Shift+H+D
;;; Dump History to file
(defun %kb-sh-dump-fn ()
    (mordev:dump-repl-history))


;;; Describe selected
(defun %kb-describe-fn ()
    (let* ((selected (#j:window:getSelection))
           (text (funcall ((oget selected "toString" "bind") selected)))
           (expr)
           (stream)
           (symbol))
        (handler-case
            (progn
                (setq stream (jscl::make-string-stream text))
                (setq value (jscl::ls-read stream))
                (terpri)
                (funcall *lestrade-wtf* value))
          (error (err)
              (format *mordev-standard-output* "Inspector: what that ~s ?" (jscl::!condition-args err))))))


;;; Moren top menu
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


;;; Moren popup menu
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
