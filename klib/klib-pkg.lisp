;;; -*- mode:lisp;  coding:utf-8 -*-

;;;
;;; This file is part of the MOREN environment
;;; Copyright © 2017 Vladimir Mezentsev
;;;
;;;

(in-package :cl-user)

;;; kludge for jscl external symbols
(export  '(jscl::oget jscl::new jscl::make-new jscl::fset
           jscl::def!struct
           jscl::concat jscl::join jscl::ensure-list
           jscl::lisp-to-js  jscl::js-to-lisp  jscl::js-null-p
           jscl::objectp
           jscl::%js-try
           jscl::aset
           jscl::oset
           jscl::storage-vector-set jscl::storage-vector-ref jscl::storage-vector-p
           jscl::list-to-vector jscl::vector-to-list
           jscl::sequencep
           jscl::delete-property
           jscl::in
           jscl::while
           jscl::map-for-in
           jscl::%js-vref
           jscl::%js-vset
           jscl::make-string-stream
           jscl::ls-read
           jscl::!condition-p
           jscl::make-!condition
           jscl::!condition-args
           jscl::!condition-type))

(fset 'reg-exp #j:RegExp)

(eval-when (:compile-toplevel :load-toplevel :execute)
    (unless (find-package :electron)
        (make-package :electron :use (list 'cl)))
    (unless (find-package :klib)
        (make-package :klib :use (list 'cl)))
    (unless (find-package :das)
        (make-package :das :use (list 'cl)))
    (unless (find-package :jstring)
        (make-package :jstring :use (list 'cl)))
    (unless (find-package :jarray)
        (make-package :jarray :use (list 'cl)))
    (unless (find-package :dom)
        (make-package :dom :use (list 'cl)))
    (unless (find-package :html)
        (make-package :html :use (list 'cl))))


(in-package :electron)
(export '(jscl::oget))
(unless #j:electron
    (setf #j:electron (require "electron")))




(in-package :klib)
(export  '(jscl::oget jscl::new jscl::make-new jscl::fset
           jscl::concat jscl::ensure-list
           jscl::lisp-to-js  jscl::js-to-lisp  jscl::js-null-p
           jscl::objectp
           jscl::while
           jscl::%js-try
           jscl::aset jscl::oset
           jscl::storage-vector-set jscl::storage-vector-ref jscl::storage-vector-p
           jscl::list-to-vector jscl::vector-to-list
           jscl::sequencep
           jscl::make-string-stream
           jscl::ls-read
           jscl::!condition-p
           jscl::make-!condition
           jscl::!condition-args
           jscl::!condition-type))


(in-package :jstring)
(export '(jscl::oget jscl::new jscl::concat jscl::make-new jscl::fset))
(export '(jscl::lisp-to-js jscl::js-to-lisp
          jscl::list-to-vector jscl::vector-to-list))
(export '(klib::mkjso))


(in-package :jarray)
(export '(jscl::oget jscl::new jscl::concat jscl::make-new jscl::fset))
(export '(jscl::js-to-lisp jscl::lisp-to-js))




(in-package :dom)
(export '(jscl::oget jscl::new jscl::concat jscl::make-new jscl::fset))


(in-package :html)
(export '(jscl::oget jscl::new jscl::concat jscl::make-new jscl::fset))


(in-package :das)
(export  '(jscl::oget jscl::new jscl::make-new jscl::fset
           jscl::concat jscl::ensure-list
           jscl::lisp-to-js  jscl::js-to-lisp  jscl::js-null-p
           jscl::objectp
           jscl::while
           jscl::%js-try
           jscl::aset jscl::oset
           jscl::storage-vector-set jscl::storage-vector-ref jscl::storage-vector-p
           jscl::list-to-vector jscl::vector-to-list
           jscl::sequencep))

(in-package :cl-user)
