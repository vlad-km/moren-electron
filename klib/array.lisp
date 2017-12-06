;;; -*- mode:lisp; coding:utf-8  -*-


;;;
;;; Wrapper for JS Array functions
;;; This file is part of the MOREN environment
;;; Copyright © 2017 Vladimir Mezentsev
;;;
;;;
;;;

(in-package :jarray)

;;; JS Array push
;;;
;;; (defparameter *vector #())
;;; (jarray:push *vector 11)
;;; => 1  ;; index of the elt
;;;
;;; (jarray:push *vector "String")
;;; => 2
;;; *vector
;;;      => #(11 <js-object "String">)
;;;
;;; So
;;; (js-to-lisp (aref *vector 1))
;;; => "String"
;;;
(defun js-push (vec elt)
    (let ((jv (jscl::lisp-to-js vec)))
        (funcall ((jscl::oget jv "push" "bind") jv elt))))

(export '(js-push))

;;; JS Array pop
;;;
;;; (jarray:pop *vector)
;;; => "String"
;;;
(defun js-pop (vec)
    (let ((ja (jscl::lisp-to-js vec)))
        (funcall ((jscl::oget ja "pop" "bind") ja))))

(export '(js-pop))


;;; JS Array reverse
;;;
;;; Destructive ops!!!
;;;
;;;
(defun js-reverse (vec)
    (let ((ja (jscl::lisp-to-js vec)))
        (funcall ((jscl::oget ja "reverse" "bind") ja))))

(export '(js-reverse))



;;; JS Array unshift
;;;
;;; (jarray:unshift *vv "fruit")
;;; => length of array
;;;
(defun js-unshift (vec val)
    (let ((ja (jscl::lisp-to-js vec)))
        (funcall ((jscl::oget ja "unshift" "bind") ja val))))

(export '(js-unshift))



;;; JS Array shift
;;;
;;; (jarray:shift *vv )
;;; => "fruit"
;;;
(defun js-shift (vec)
    (let ((ja (jscl::lisp-to-js vec)))
        (funcall ((jscl::oget ja "shift") ja))))

(export '(js-shift))




;;; JS Array indexOf
;;;
;;; (jarray:index-of *vector "fruit")
;;;; => 1
;;;

(defun index-of (vec val)
    (let ((ja (jscl::lisp-to-js vec)))
        (funcall ((jscl::oget ja "indexOf" "bind") ja val))))

(export '(index-of))


;;; JS Array splice
;;;
;;; *vv
;;; => #(1 2 3 4)
;;; (splice *vv 1 2 33)
;;; => #(2 3)
;;; *vv
;;; => #(1 33 4)

(defun splice (vec pos &optional how new)
    (let ((ja (jscl::lisp-to-js vec)))
        (if new
            (funcall ((jscl::oget ja "splice" "bind") ja pos how new))
            (if how
                (funcall ((jscl::oget ja "splice" "bind") ja pos how))
                (funcall ((jscl::oget ja "splice" "bind") ja pos)) ))))

(export '(splice))

(in-package :cl-user)

;;; EOF
