;;; -*- mode:lisp; coding:utf-8  -*-


;;; DOM - dom manipulation functions package
;;; This package is part of the MOREN Environment
;;; Copyright В© 2017 Vladimir Mezentsev
;;;


;;;
;;; Compilation note:
;;;
;;;     This file should follow the dom.lisp and html.lisp
;;;     when compiling the kernel level 1 bundle
;;;

;;;
;;; MAKE-OUTPUT-STREAM
;;;
;;; name - dom element id
;;; exists - existing dom element
;;;
;;;
;;; (setq *out (make-dom-output-stream))   ;; create stream *out
;;; (dom:add-class *out "report-style")    ;; add style class
;;; (dom:mount *div-report                 ;; mount *out to current viewport
;;;    (dom-output-stream *out))
;;; (format *out "This is a first<br>")    ;; write to stream
;;;  ...
;;;  ...
;;; (dom-output-stream-reset *out)         ;; reset stream
;;;  =>
;;;      clear all inner text
;;;      the next output will begin from first position;;;

(in-package :dom)

(export '(dom::make-dom-output-stream))
(defun make-dom-output-stream (&key name exists (scroll t) (plain t))
    (let ((buffer))
        (if exists
            (setq buffer exists)
            (setq buffer (html::produce (if plain "pre" "div")
                                        (list :id (if name name (gen-uid "output" "stream"))))))
        (vector 'stream
                ;; write-char
                (lambda (ch)
                    (let* ((span (html:span)))
                        (setf (oget span "innerHTML") (string ch))
                        (funcall ((oget buffer "appendChild" "bind" ) buffer span))))
                ;; write-string
                (lambda (string)
                    (let* ((span (html:span)))
                        (setf (oget span "innerHTML") string)
                        (funcall ((oget buffer "appendChild" "bind" ) buffer span))
                        (if scroll (funcall ((oget buffer "scrollIntoView" "bind") buffer nil)) )))
                'dom-stream
                buffer)))

;;;
;;; DOM-OUTPUT-STREAM
;;;
;;; Return dom-element from stream if exists
;;; or nil otherwise
;;;
;;; (dom-mount div1 (dom-output-stream *out1) (dom-output-stream *out2))
;;; =>
;;;         div1
;;;         |
;;;         |-div-from-out1
;;;         |
;;;         |-div-from-out2
;;;
;;;

(export '(dom::output-stream))
(defun output-stream (stream)
    (if (arrayp stream)
        (aref stream 4)
        nil))


;;;
;;; DOM-OUTPUT-STREAM-OPEN
;;;
;;; (dom-output-stream-open (dom-output-stream stream) parent-div)
;;;

(export '(dom::output-stream-open))
(defun output-stream-open (stream parent)
    (if (arrayp stream)
        (dom:mount parent (aref stream 4))
        nil))


;;;
;;; DOM-OUTPUT-RESET
;;;
;;; stream-reset
;;;
(export '(dom::output-stream-reset))
(defun output-stream-reset (stream)
    (if (arrayp stream)
        (setf (oget  (aref stream 4) "innerHTML") ""))
    (values-list nil))


;;;
;;; DOM-OUTPUT-STREAM-CLOSE
;;;
(export '(dom::output-stream-close))
(defun output-stream-close (stream)
    (if (arrayp stream)
        (dom:umount (aref stream 4)))
    (values-list nil))


(in-package :cl-user)
;;; EOF
