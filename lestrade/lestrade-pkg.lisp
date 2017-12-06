;;; -*- mode:lisp;  coding:utf-8 -*-

;;; This file is part of the LESTRADE package.
;;; Object inspector for Moren environment
;;; Copyright © 2017 Vladimir Mezentsev
;;;


;;; Package definition

(eval-when (:compile-toplevel :load-toplevel :execute)
    (unless (find-package :lestrade)
        (make-package :lestrade :use (list 'cl))))


(in-package :lestrade)

(export
 '(jscl::oget jscl::new jscl::concat
   jscl::make-new jscl::fset jscl::js-null-p
   jscl::%js-try
   jscl::while
   jscl::js-to-lisp jscl::lisp-to-js
   jscl::vector-to-list jscl::list-to-vector
   jscl::in
   jscl::objectp
   ))

(export
 '(klib::make-js-object
   klib::mkjso
   klib::curry))

(in-package :cl-user)

;;; EOF
