;;; -*- mode:lisp; coding:utf-8  -*-

;;; This file is part of the LORESDOC package
;;; Copyright © 2017 Vladimir Mezentsev
;;;


(in-package :loresdoc)


(das:structure doc-def-unit path)
(das:def-type 'doc-def-unit
    (lambda (obj)
        (eq (cdr (das::das/structure-pred obj)) 'doc-def-unit)))

(das:structure doc-namespace name)
(das:def-type 'doc-namespace
    (lambda (obj)
        (eq (cdr (das::das/structure-pred obj)) 'doc-namespace)))



(das:structure doc-variable op name document)
(das:def-type 'doc-variable
    (lambda (obj)
        (eq (cdr (das::das/structure-pred obj)) 'doc-variable)))


(das:structure doc-function name args document)
(das:def-type 'doc-function
    (lambda (obj)
        (eq (cdr (das::das/structure-pred obj)) 'doc-function)))

(das:structure doc-generic name args document)
(das:def-type 'doc-generic
    (lambda (obj)
        (eq (cdr (das::das/structure-pred obj)) 'doc-generic)))


(das:structure doc-method name args)
(das:def-type 'doc-method
    (lambda (obj)
        (eq (cdr (das::das/structure-pred obj)) 'doc-method)))


(das:structure doc-macro name args)
(das:def-type 'doc-macro
    (lambda (obj)
        (eq (cdr (das::das/structure-pred obj)) 'doc-macro)))


(das:structure doc-structure name)
(das:def-type 'doc-structure
    (lambda (obj)
        (eq (cdr (das::das/structure-pred obj)) 'doc-structure)))

(das:structure doc-jscl-struct name)
(das:def-type 'doc-jscl-struct
    (lambda (obj)
        (eq (cdr (das::das/structure-pred obj)) 'doc-jscl-struct)))


(das:structure doc-global-var op name sexpr)
(das:def-type 'doc-global-var
    (lambda (obj)
        (eq (cdr (das::das/structure-pred obj)) 'doc-global-var)))



(in-package :cl-user)

;;; EOF
