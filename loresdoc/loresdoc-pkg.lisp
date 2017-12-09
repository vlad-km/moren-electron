;;; -*- mode:lisp; coding:utf-8  -*-

;;; This file is part of the LORESDOC package
;;; Copyright © 2017 Vladimir Mezentsev
;;;

(in-package :cl-user)

(eval-when (:compile-toplevel :load-toplevel :execute)
    (unless (find-package :loresdoc)
        (make-package :loresdoc :use (list 'cl))))


(in-package :loresdoc)

(export
 '(jscl::oget jscl::new jscl::concat
   jscl::make-new jscl::fset jscl::js-null-p
   ))

(in-package :cl-user)

;;; EOF
