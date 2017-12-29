;;; -*- mode:lisp; coding:utf-8  -*-


;;;
;;; This file is part of the MOREN environment
;;; Moren development console
;;; Copyright © 2017 Vladimir Mezentsev
;;;

(in-package :mordev)


(setq *about-conf*
      (mkjso
       "autoHideMenuBar" t
       "width" 660
       "height" 390
       "resizable" nil
       "maximizable" nil
       "frame" nil
       "backgroundColor" "#2e2c29"
       "show" nil
       ))

(defparameter *about-win* nil)

#|
(defun show-about ()
    (setf (oget *about-conf* "parent")
          (#j:electron:remote:getCurrentWindow)
          (oget *about-conf* "modal") t)
    (setq *about-win*  (make-new #j:electron:remote:BrowserWindow *about-conf*))
    (funcall ((oget *about-win* "loadURL" "bind")
              *about-win*
              (concat "file://" #j:__dirname "\\about.html")))
    (funcall ((oget *about-win* "once" "bind")
              *about-win*
              "ready-to-show"
              (lambda ()
                  (funcall ((oget *about-wun* "show" "bind") *about-win*)))))
    )
|#

(defun show-about ()
    (setf (oget *about-conf* "parent")
          (#j:electron:remote:getCurrentWindow)
          (oget *about-conf* "modal") t)
    (setq *about-win*  (make-new #j:electron:remote:BrowserWindow *about-conf*))
    (funcall ((oget *about-win* "loadURL" "bind")
              *about-win*
              (concat "file://" #j:__dirname "\\about.html"))) )




(defun close-about ()
    (funcall ((oget *about-win* "close" "bind") *about-win)))


(defun about-devtool ()
    (funcall ((oget *about-win* "webContents" "openDevTools" "bind") *about-win*)))


(defun get-position-about ()
    (vector-to-list (funcall ((oget *about-win* "getPosition" "bind") *about-win*))))

(defun set-position-about (x y)
    (funcall ((oget *about-win* "setPosition" "bind") *about-win* x y)))


(defun about-center ()
    (funcall ((oget *about-win* "center" "bind") *about-win*)))


(in-package :cl-user)

;;; EOF
