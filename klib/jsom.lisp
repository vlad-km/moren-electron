;;; -*- mode:lisp; coding:utf-8 -*-

;;;
;;; JSOM - js object manipulation functions
;;; This file is part of the MOREN environment
;;; Copyright © 2017 Vladimir Mezentsev
;;;


(in-package :klib)

;;; make-js-object
;;; mkjso
;;;
;;; (make-js-object "name" "val" "next" (make-js-object "name2" "val2"))
;;; => {name: "val", next: {name2: "val2"}}
;;;

(defun make-js-object (&rest kv)
    (let* ((obj (new))
           (idx 0)
           (key-val))
        (if (oddp (length kv))
            (error "JSO: Too few arguments"))
        (dolist (it kv)
            (if (oddp idx)
                (setf (oget obj key-val) it)
                (setq key-val it))
            (incf idx))
        obj))

;;; aliase
(fset 'mkjso #'make-js-object)
(export '(klib::make-js-object klib::mkjso))


;;; map-js-object
;;;
;;; js object iterator
;;;
;;; (map-js-object obj  #'(lambda (x y) (print x)) )
;;;
;;; "aaa"
;;; "bbb"
;;;

(defun map-js-object (obj fn)
    (mapcar #'(lambda (x) (funcall fn x (oget obj x)))
            (map 'list #'(lambda (x) (js-to-lisp x)) (#j:Object:keys obj))))

;;; aliase
(fset 'map-jso #'map-js-object)
(export '(klib::map-js-object klib::map-jso))


;;; get-js-object-keys
;;;
;;; Return list object keys
;;;
;;; => ("bbb" "aaa")
;;;

(defun get-js-object-keys (js-object)
    (map 'list #'(lambda (x) (js-to-lisp x)) (#j:Object:keys js-object)))

;;; aliase
(fset 'jso-keys #'get-js-object-keys)
(export '(klib::get-js-object-keys klib::jso-keys))


;;; js-object-to-list
;;;
;;; => ("aa" 1 "bb" 2)
;;;

(defun js-object-to-list (obj)
    (mapcar #'(lambda (x) (list x (oget obj x)))
            (map 'list #'(lambda (x) (js-to-lisp x)) (#j:Object:keys obj))))

(fset 'jso-to-list #'js-object-to-list)
(export '(klib::js-object-to-list klib::jso-to-list))


;;;
;;; copies js object
;;; returning a new object with inherite propertiess
;;;

(fset '%jso-assign #j:Object:assign)

(defun jso-copy (obj)
    (#j:Object:assign (new) obj))

(export '(klib::jso-copy))

;;;
;;; Merge few objects to new object
;;;
;;; The identical properties are replaced
;;; See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/assign
;;; for details
;;;
(defun jso-merge (&rest objs)
    (apply '%jso-assign (new) objs))

(export '(klib::jso-merge))

;;;
;;; delete properties from obj
;;; use (delete-property key obj) from JSCL
;;;

(defvar *jsom-version* 1)

(in-package :cl-user)
;;;; EOF
