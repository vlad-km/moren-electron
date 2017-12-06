;;; -*- mode:lisp; coding:utf-8  -*-

;;; HTML - HTML tags definition package
;;; This package is part of the MOREN Environment
;;; Copyright © 2017 Vladimir Mezentsev

;;; HTML package base engine for link with Moren kernel lib

(in-package :html)


(defun attr-converter (name)
    (if (symbolp name) (symbol-name name) name))


(defun produce (tagname attrs)
    (let ((obj (#j:window:document:createElement tagname))
          (elt)
          (attribute)
          (value)
          (fn))

        (tagbody produce-fsm
         feeder
           (setq attribute (pop attrs))
           (unless attribute (go stop))
           (setq value (pop attrs))
           (unless value (go fewerr))
           ;; set innerHTML
           (if (eql attribute :text)
               (progn
                   (setf (jscl::oget obj "innerHTML") value)
                   (go feeder)))
           ;; appendChild
           (if (eql attribute :mount)
               (progn
                   (funcall ((jscl::oget obj "appendChild" "bind") obj value))
                   (go feeder)))
           ;; onevent
           (if (eql attribute :on)
               ;; value may be keyword or string
               ;; :on "onclick" #'fn
               ;; :on :onclick #'fn
               (progn
                   (unless (setq fn (pop attrs)) (go fewerr))
                   (setf (jscl::oget obj (attr-converter value)) fn)
                   (go feeder)))

           ;; other tag attribute
           (funcall ((jscl::oget obj "setAttribute" "bind")  obj (attr-converter attribute) value))
           (go feeder)
         fewerr
           (error "HTML: Too few arguments")
         stop
           (return-from produce obj))))



(defun div (&rest parms)
    (produce "div" parms))
(export '(html::div))

;;; html a tag
;;;
;;; (htmp:a ...)

(defun a (&rest parms)
    (produce "a" parms))
(export '(html::a))

;;; html span tag
;;;
;;;

(defun span (&rest parms)
    (produce "span" parms))
(export '(html::span))


;;; html script
;;;
;;;

(defun script (&rest parms)
    (produce "script" parms))
(export '(html::script))


;;; html style tag
;;;
;;;

(defun link (&rest parms)
    (produce "link" parms))
(export '(html::link))

;;; html img
;;;
;;;

(defun img (&rest parms)
    (produce "img" parms))
(export '(html::img))


;;; html h1 tag
;;;
;;;

(defun h1 (&rest parms)
    (produce "h1" parms))
(export '(html::h1))


;;; html h2 tag
;;;
;;;

(defun h2 (&rest parms)
    (produce "h2" parms))
(export '(html::h2))


;;; html h3 tag
;;;
;;;

(defun h3 (&rest parms)
    (produce "h3" parms))
(export '(html::h3))


;;; html article tag
;;;
;;;

(defun article (&rest parms)
    (produce "article" parms))
(export '(html::article))


;;; html input tag
;;;
;;;

(defun input (&rest parms)
    (produce "input" parms))
(export '(html::input))


;;; html button tag
;;;
;;;

(defun button (&rest parms)
    (produce "button" parms))
(export '(html::button))


;;; html select tag
;;;
;;;

(defun select (&rest parms)
    (produce "select" parms))
(export '(html::select))

;;; html ul tag
;;;
;;;

(defun ul (&rest parms)
    (produce "ul" parms))
(export '(html::ul))


;;; html li tag
;;;
;;;

(defun li (&rest parms)
    (produce "li" parms))
(export '(html::li))

;;; html textarea tag
;;;
;;;

(defun textarea (&rest parms)
    (produce "textarea" parms))
(export '(html::textarea))



(in-package :cl-user)
;;; EOF
