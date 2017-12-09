;;; -*- mode:lisp; coding:utf-8  -*-

;;; This file is part of the LORESDOC package
;;; Copyright © 2017 Vladimir Mezentsev
;;;


(in-package :loresdoc)

;;; document template printers


(defun document/write (what)
    (write-doc-template what))

(das:generic document/definition (what))
(das:generic document-template (what))



(das:method document/definition (what) (error "what ~a?" what))

;;; print file name
;;; ## File: ...
(das:method document/definition ((what doc-def-unit))
            ;;(lores::lores/mess-0 "definition: ~a~%" what)
            ;;(lores::lores/mess-0 "definition: ~a~%" (document-template what))
            (document/write (document-template what)))

;;; print any variables - var/parameters/constants
(das:method document/definition ((what doc-variable))
            (document/write (document-template what)) )


;;; print functions
(das:method document/definition ((what doc-function))
            (document/write (document-template what)) )

;;; print generic
(das:method document/definition ((what doc-generic))
            (document/write (document-template what)) )

;;; print method
(das:method document/definition ((what doc-method))
            (document/write (document-template what)) )


;;; print macro
(das:method document/definition ((what doc-macro))
            (document/write (document-template what)) )


;;; print structure
(das:method document/definition ((what doc-structure))
            (document/write (document-template what)) )


;;; print jscl def!struct
(das:method document/definition ((what doc-jscl-struct))
            (document/write (document-template what)) )


;;; print set operators - setq/setf/fset
(das:method document/definition ((what doc-global-var))
            (document/write (document-template what)) )

;;; namespace
(das:method document/definition ((what doc-namespace))
            (document/write (document-template what)) )



;;; templates

(defun document/template-header (sysname)
    (document/write
     (format nil "# MOREN system ~a~%~%" (string sysname))))


(defun document/template-tail ()
    (document/write
     (concat
      #\newline #\newline
      "## Author" #\newline #\newline
      "## Copyright " #\newline #\newline
      "## License" #\newline #\newline)))


(defun format-header () #\newline)

(defun format-trailer () #\newline)


(defun format-return ()
    (concat #\newline "##### `Returns`" #\newline #\newline))


(defun format-example ()
    (concat #\newline
            "##### Example" #\newline #\newline
            "```lisp" #\newline #\newline
            "```" #\newline #\newline))



(das:generic format-name (what &optional esc))

(das:method format-name (what &optional esc) (error "Format-name: ~a" what))

(das:method format-name ((what symbol) &optional esc)
            (let ((name (symbol-name what))
                  (prefix " "))
                (if (eql (char name 0) #\*) (setq prefix " \\"))
                (concat prefix (if esc (format nil " (QUOTE ~a)" name) name) " ")))

(das:method format-name ((what list) &optional esc)
            (cond ((eql (car what) 'quote) (format-name (cadr what) t))
                  (format-name '<expression>) ) )


(defun format-signature (what)
    (concat "#### `" what "` "))


(defun format-opset (what)
    (concat " `" (symbol-name what) "` ") )


(defun format/arguments (lst)
    (mapcar (lambda (x)
                (cond ((symbolp x) (symbol-name x))
                      (t (format/arguments x)))) lst) )


(defun format-arguments (what)
    (if what
        (jstring:to-lower-case
         (format  nil "~a~%" (format/arguments what)))
        (concat "()" #\newline)))


(defun format/argument-item (item)
    (concat #\newline "- " (jstring:to-lower-case (symbol-name item)) #\newline))

(defun format-arguments-expand (what)
    (if what
        (let ((result))
            (dolist (item what)
                (cond ((member item '(&optional &key &rest &auxiliary)) t)
                      ((symbolp item)
                       (push (format/argument-item item) result))
                      ((consp item)
                       (push (format/argument-item (car item)) result))))
            (apply #'concat (concat #\newline "##### `Arguments`" #\newline) (reverse result)))
        (concat " " #\newline)))



(defun format-docstring (what)
    (if what (concat #\newline ">" what #\newline) #\newline))

(defun format-namespace (what)
    (concat #\newline #\newline
            "## :" (string what) " "
            #\newline))

;;; generic template
(das:method document-template (what) (error "TEMPL: ~a" what))


;;; file name/pathname
(das:method document-template ((what doc-def-unit))
            ;;(lores::lores/mess-0 "def-unit:~a~%" what)
            (concat #\newline "## File: " (doc-def-unit-path what) #\newline #\newline))


;;; declare variable/parameter/constant
(das:method document-template ((what doc-variable))
            (concat (format-header)
                    (format-signature "Variable")
                    (format-name (doc-variable-name what))
                    (format-docstring (doc-variable-document what))
                    (format-trailer)))




;;; function
(das:method document-template ((what doc-function))
            (concat (format-header)
                    (format-signature "Function")
                    (format-name (doc-function-name what))
                    (format-arguments (doc-function-args what))
                    (format-docstring (doc-function-document what))
                    (format-arguments-expand (doc-function-args what))
                    (format-return)
                    (format-example)
                    (format-trailer)))

;;; generic
(das:method document-template ((what doc-generic))
            (concat (format-header)
                    (format-signature "Generic function")
                    (format-name (doc-generic-name what))
                    (format-arguments (doc-generic-args what))
                    (format-docstring (doc-generic-document what))
                    (format-arguments-expand (doc-generic-args what))
                    (format-return)
                    (format-example)
                    (format-trailer)))

;;; method
(das:method document-template ((what doc-method))
            (concat (format-header)
                    (format-signature "Method")
                    (format-name (doc-method-name what))
                    (format-arguments (doc-method-args what))
                    (format-arguments-expand (doc-method-args what))
                    (format-return)
                    ;;(format-example)
                    (format-trailer)))




;;; macro
(das:method document-template ((what doc-macro))
            (concat (format-header)
                    (format-signature "Macro")
                    (format-name (doc-macro-name what))
                    (format-arguments (doc-macro-args what))
                    (format-arguments-expand (doc-macro-args what))
                    ;;(format-example)
                    (format-trailer)))


;;; structure
(das:method document-template ((what doc-structure))
            (concat (format-header)
                    (format-signature "Structure")
                    (format-name (doc-structure-name what))
                    ;;(format-example)
                    (format-trailer)))



;;; jscl-struct
(das:method document-template ((what doc-jscl-struct))
            (concat (format-header)
                    (format-signature "def!struct")
                    (format-name (doc-jscl-struct-name what))
                    (format-trailer)))


;;; set global? vars
(das:method document-template ((what doc-global-var))
            (concat (format-header)
                    (format-signature "Global variable")
                    ;;(lores::lores/mess-0 "GLOB: ~a~%" (doc-global-var-name what))
                    (format-opset (doc-global-var-op what))
                    (format-name (doc-global-var-name what))
                    (format-trailer)))

;;; namespace
(das:method document-template ((what doc-namespace))
            (format-namespace (doc-namespace-name what)))






(in-package :cl-user)
;;; EOF
