;;; -*- mode:lisp;  coding:utf-8 -*-

;;; DOM - dom manipulation functions package
;;; This package is part of the MOREN Environment
;;; Copyright В© 2017 Vladimir Mezentsev
;;;


(eval-when (:compile-toplevel :load-toplevel :execute)
    (unless (find-package :dom)
        (make-package :dom :use (list 'cl))))

(in-package :dom)
(export '(jscl::oget jscl::new jscl::concat jscl::make-new jscl::fset))


;;; EOF
