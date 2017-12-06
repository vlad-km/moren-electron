;;; -*- mode:lisp; coding:utf-8 -*-

;;;
;;; Wrapper for JS String functions
;;; This file is part of the MOREN environment
;;; Copyright © 2017 Vladimir Mezentsev
;;;
;;;
;;;


(in-package :jstring)

(defvar *break nil)


(export '(jstring::to-lower-case))
(defun to-lower-case (src)
    (let ((jsrc (lisp-to-js src)))
        (funcall ((oget jsrc "toLowerCase" "bind") jsrc))))

;;; toUpperCase
;;;
(export '(jstring::to-upper-case))
(defun to-upper-case (src)
    (let* ((jsrc (lisp-to-js src)))
        (funcall ((oget jsrc "toUpperCase" "bind") jsrc))))

;;; indexOf
;;;
;;; => number index. (if eql -1, then no find)
;;;
(export '(jstring::index-of))
(defun index-of (src pat)
    (let* ((jsrc (lisp-to-js src)))
        (funcall ((oget jsrc "indexOf" "bind") jsrc pat))))


;;; substring(start [, end])
;;;
;;; => string
;;;
(export '(jstring::substring))
(defun substring (src start end)
    (let* ((jsrc (lisp-to-js src)))
        (funcall ((oget jsrc "substring" "bind") jsrc start end))))


;;; substr(start [, length])
;;;
;;; => string
(export '(jstring::substr))
(defun substr (src start len)
    (let* ((jsrc (lisp-to-js src)))
        (funcall ((oget jsrc "substr" "bind") jsrc start len))))

;;; slice(start [, end])
;;;
;;; => string
;;;
(export '(jstring::slice))
(defun slice (src start &optional end)
    (let* ((jsrc (lisp-to-js src)))
        (if end (funcall ((oget jsrc "slice" "bind") jsrc start end))
            (funcall ((oget jsrc "slice" "bind") jsrc start)))))


;;; split(delim max)
;;;
;;; NOte:
;;;      delimiter by default #\space
;;;      maximum elts - 100
;;;
;;; => #( sting string string)
;;;
(export '(jstring::split))
(defun split (src &optional (delim #\space) (max 100))
    (let* ((jsrc (lisp-to-js src)))
        (map 'vector (lambda (x) (js-to-lisp x))
             (funcall ((oget jsrc "split" "bind") jsrc delim max)))))

(defun split (src &optional (delim #\space) (max 100))
    (let ((jsrc (lisp-to-js src))
          (vec))
        (setq vec (funcall ((oget jsrc "split" "bind") jsrc delim max)))
        (dotimes (i (length vec))
            (setf (aref vec i) (js-to-lisp (aref vec i))))
        vec))

(export '(jstring::trim))
(defun trim (str)
    (let ((jstr (lisp-to-js str)))
        (funcall ((oget jstr "trim" "bind") jstr))))


;;; Global RegExp
;;;
;;; (reg-exp " {2,}")
;;; => #<JS-OBJECT / {2,}/>
;;;
;;;
;;; (string-split (trim (string-replace *str (reg-exp " {2,}" "g") " ")) )
;;; => split string without empty elements
;;;

;;;(export '(reg-exp))
;;;(fset 'reg-exp #j:RegExp)

;;; replace
;;;
;;;

(export '(jstring::replace))
(defun replace (src pat1 pat2)
    (let* ((j-src (lisp-to-js src)))
        (funcall ((oget j-src "replace" "bind") j-src pat1 pat2))))


(in-package :cl-user)

;;; EOF
