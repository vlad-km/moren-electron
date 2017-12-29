;;; -*- mode:lisp; coding:utf-8  -*-

;;;
;;; This file is part of the MOREN environment
;;; Copyright © 2017 Vladimir Mezentsev
;;;


(in-package :electron)


(defun od/file-filter (name &rest names)
    (mkjso "name" (lisp-to-js name)
           "extensions"
           (map 'vector (lambda (x) (lisp-to-js x)) names)))

(export '(od/file-filter))


(defun od/filters (&rest objs)
    (apply 'vector objs))

(export '(od/filters))


#|
(defun od/options (&key title default-path button-label filters properties)
    (let ((args))
        (if title (push (list "title" (lisp-to-js title)) args))
        (if default-path (push (list "defaultPath" (lisp-to-js default-path)) args))
        (if button-label (push (list "buttonLabel" (lisp-to-js button-label)) args))
        (if filters (push (list "filters" filters) args))
        (if properties (push
                        (list "properties"
                              (map 'vector (lambda (x) (lisp-to-js x)) properties)) args))
        (if args (apply 'mkjso (apply 'append args)))
        ))
|#


(defun od/properties (&key file directory multi hidden)
    (let ((args))
        (if file (push (lisp-to-js "openFile") args))
        (if directory (push (lisp-to-js "openDirectory") args))
        (if multi (push (lisp-to-js "multiSelections") args))
        (if hidden (push (lisp-to-js "showHiddenFiles") args))
        (if args
            (apply 'vector args))))

(export '(od/properties))


;;; open file dialog
(defun show-open-dialog (&key title default-path button-label filters properties callback)
    (let ((res)
          (args)
          (ops (new)))
        (if title (push (list "title" (lisp-to-js title)) args))
        (if default-path (push (list "defaultPath" (lisp-to-js default-path)) args))
        (if button-label (push (list "buttonLabel" (lisp-to-js button-label)) args))
        (if filters (push (list "filters" filters) args))
        (if properties (push
                        (list "properties"
                              (map 'vector (lambda (x) (lisp-to-js x)) properties)) args))
        (if args
            (setq ops (apply 'mkjso (apply 'append args))))

        (setq res
              (if callback
                  (#j:electron:remote:dialog:showOpenDialog ops callback)
                  (#j:electron:remote:dialog:showOpenDialog ops)))
        (when (arrayp res)
            (return-from show-open-dialog
                (map 'list (lambda (x) (js-to-lisp x)) res)))
        nil))

(export '(show-open-dialog))



;;; save dialog
(defun show-save-dialog (&optional ops)
    (let ((res))
        (setq res (if ops
                      (#j:electron:remote:dialog:showSaveDialog ops)
                      (#j:electron:remote:dialog:showSaveDialog )))
        (when (stringp res) res)
        nil))

(export '(show-save-dialog))




;;; Displays a modal dialog that shows an error message.
(defun show-error-box (title content)
    (#j:electron:remote:dialog:showErrorBox
     (lisp-to-js title)
     (lisp-to-js content))
    (values))

(export '(show-error-box))



;;; message box
(defun mb/types (val)
    (case val
      (none (lisp-to-js "none"))
      (info (lisp-to-js "info"))
      (error (lisp-to-js "error"))
      (warning (lisp-to-js "warning"))
      (question  (lisp-to-js "question"))
      (otherwise (lisp-to-js "none"))))

(export '(mb/types))


(defun mb/buttons (&rest names)
    (map 'vector (lambda (x) (lisp-to-js x)) names))

(export '(mb/buttons))



(defun show-message-box (message &key type buttons checkboxLabel checkboxchecked
                                   defaultid title detail cancelid callback)
    (let ((ops))
        (push (list "message" (lisp-to-js message)) ops)
        (if type (push (list "type" (mb/types type)) ops))
        (if buttons (push (list "buttons" buttons) ops))

        (if checkboxLabel (push (list "checkboxLabel" (lisp-to-js checkboxLabel)) ops))
        (if checkboxchecked (push (list "checkboxchecked" checkboxchecked) ops))

        (if defaultid (push (list "defaultId" defaultid) ops))
        (if title (push (list "title" (lisp-to-js title)) ops))
        (if detail (push (list "detail" (lisp-to-js detail)) ops))
        (if cancelid (push (list "cancelId" (lisp-to-js cancelid)) ops))
        (setq ops (apply 'mkjso (apply 'append ops)))
        (if callback
            (#j:electron:remote:dialog:showMessageBox ops callback)
            (#j:electron:remote:dialog:showMessageBox ops)
            )))

(export '(show-message-box))



(in-package :cl-user)

;;; EOF
