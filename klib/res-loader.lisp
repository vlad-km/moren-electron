;;; -*- mode:lisp;  coding:utf-8 -*-

;;;
;;; Resource loader (js & css) function
;;; This file is part of the MOREN environment
;;; Copyright © 2017 Vladimir Mezentsev
;;;
;;;

(in-package :klib)

;;;
;;; Load rx.js from http://localhost/???/vendor/
;;;
;;;         (resloadjs "/vendor/rx.js")
;;;
;;; Load css file from http://localhost/???/css/
;;;
;;;         (resloadcss "/css/calendar.css")
;;;
;;;

(defun resloadjs (from &optional onload)
    (let ((link (#j:window:document:createElement "script"))
          (docbody #j:window:document:body ))

        (setf (oget link "charset") "utf-8")
        (setf (oget link "type") "text/javascript")
        (setf (oget link "src") from)

        (if onload
            (setf (oget link "onload")
                  (lambda (ignore)
                      (funcall ((oget docbody "removeChild" "bind") docbody link ))
                      (funcall onload))))
        (funcall ((oget docbody "appendChild" "bind" ) docbody link))
        (unless onload
            (funcall ((oget docbody "removeChild" "bind") docbody link )))
        ))

(export '(klib::resloadjs))


(defun resloadcss (from &optional onload)
    (let ((link (#j:window:document:createElement "link")))

        (setf (oget link "rel") "stylesheet")
        (setf (oget link "type") "text/css")
        (setf (oget link "href") from)

        (if onload
            (setf (oget link "onload")
                  (lambda (ignore) (funcall onload))))
        (funcall ((oget #j:window:document:body "appendChild" "bind" ) #j:window:document:body link))))


(export '(klib::resloadcss))



(in-package :cl-user)
;;; EOF
