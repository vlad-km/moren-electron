;;; -*- mode:lisp; coding:utf-8  -*-

;;; This file is part of the LORESDOC package
;;; Copyright © 2017 Vladimir Mezentsev
;;;


(in-package :loresdoc)

;;; unit ref walker

;;; make doc template for sysname
;;; sysname - symbol
(export '(loresdoc::make-for))

(defun make-for  (sysname path)
    (unless (keywordp sysname)
        (error "Loresdoc: system name ~a must be keyword" sysname))
    (setq *knowsymbols* nil)
    (setq *docstream* (open-doc-template-file path))
    (lores::lores/mess-0 "~%Build template for ~a system...~%" (string sysname))
    ;; print document header
    (document/template-header sysname)
    ;; first pass - build symbols
    (dolist (unit (lores::defsys/components-flatten sysname))
        (unit/walker unit))
    ;; second pass - markdown format for each symbol
    (dolist (doc-from (reverse *knowsymbols*))
        ;;(lores::lores/mess-0 "UNT: ~s~%" doc-from)
        (document/definition doc-from))
    ;; print finaly text & close file
    (document/template-tail)
    (close-doc-template-file)
    (lores::lores/mess-0 "~%Done~%~%")
    (values))



;;; if the symbolic expression is one from declarations
;;; put his in the print queue
(defun unit/walker (pdu)
    (let* ((code (lores::unit/get-sexpr pdu))
           (lenco (length code)))
        (lores::lores/mess-0  "   File: ~a  ~a statements~%" (lores::def-unit-depend-name pdu) lenco)
        (push (make-doc-def-unit :path (lores::def-unit-pathname pdu)) *knowsymbols*)
        (dotimes (idx lenco)
            (setq elt (what-is-it (nth idx code)))
            ;; elt - structure or nil
            (if elt
                (push elt *knowsymbols*) ))))


;;; Document string for object, if exists
(defun get-documentation (obj type)
    "Get documentation string for object"
    ;;(lores::lores/mess-0 "Get doc: ~a ~a ~a~%" type obj (klib:jso-to-list obj))
    (cond  ((eql type 'function)
            (let ((fn (fdefinition obj)))
                ;;(lores::lores/mess-0 "Get doc fn: ~a ~a~%" fn (klib:jso-to-list fn))
                (oget fn "docstring")))
           ((eql type 'variable)
            (oget obj "vardoc"))))


;;;
(defun ref-symbol (symname)
    (find-symbol (symbol-name symname) *namespace*))

;;; what is it?
;;; return result structure or nil
(defun what-is-it (sexpr)
    "See the first symbol. if it's a declaration, include in the documentation"
    (let ((op)
          (name)
          (result))
        (setq op (car sexpr))
        (setq name (cadr sexpr))
        (setq body (cddr sexpr))
        (case (car sexpr)

          ((in-package)
           (setq *namespace* (find-package name) ))

          ;; variable / constant/parameter
          ((defvar defparameter defconstant)
           (setq result (make-doc-variable :op (case op
                                                 (defvar 'variable)
                                                 (defparameter 'parameter)
                                                 (defconstant 'constant))
                                           :name name
                                           :document (get-documentation (ref-symbol name) 'variable))))
          ;; function
          ((defun)
           (setq result (make-doc-function :name name
                                           :args (car body)
                                           :document (get-documentation (ref-symbol name) 'function))))
          ;; generic
          ((generic das:generic)
           (setq result (make-doc-generic :name name
                                          :args (car body))))
          ;; method
          ((method das:method)
           (setq result (make-doc-method :name name
                                         :args (car body))))
          ;; macro
          ((defmacro)
           (setq result (make-doc-macro :name name
                                        :args (car body))))
          ;; structure
          ((structure das:structure)
           (setq result (make-doc-structure :name name )))
          ;; jscl structure
          ((def!struct)
           (setq result (make-doc-jscl-struct :name name)))
          ;; set op
          ((setq setf fset)
           (setq result (make-doc-global-var :op op
                                             :name name))
           ;;(lores::lores/mess-0 "Glob: ~a~%" result)
           )
          ;; goddamn know
          (otherwise
           (setq result nil)) )
        result))


(in-package :cl-user)

;;; EOF
