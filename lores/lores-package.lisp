;;; -*- mode:lisp; coding:utf-8  -*-

;;; This file is part of the LORES system
;;; LORES is a tool Moren Environment, designed to help developers deal
;;; with large programs contained in multiple files (system)
;;; Copyright © 2017 Vladimir Mezentsev
;;;

(in-package :cl-user)

(eval-when (:compile-toplevel :load-toplevel :execute)
    (unless (find-package :lores)
        (make-package :lores :use (list 'cl))))


(in-package :lores)

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
