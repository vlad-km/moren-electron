;;; -*- mode:lisp; coding:utf-8  -*-

;;; This file is part of the LORES system
;;; LORES is a tool Moren Environment, designed to help developers deal
;;; with large programs contained in multiple files (system)
;;; Copyright © 2017 Vladimir Mezentsev
;;;

(in-package :lores)


;;; evaluator
(defun lores/eval (sexpr pdu)
    (let* ((jscode))
        (setq jscode (jscl::with-compilation-environment
                         (jscl::compile-toplevel sexpr t t)))
        (jscl::js-eval jscode)
        (if *store-sexpr* (unit/store-sexpr pdu sexpr))
        (if *store-pcode* (unit/store-js pdu jscode))
        (cadr sexpr) ))


;;; Compile expression
(defun lores/compile-0 (sexpr pdu)
    (if *verbose*
        (lores/mess-0 "~a ~a~%" (car sexpr) (cadr sexpr) ))

    (jscl::%js-try
     (handler-case
         (progn
             (let ((form-result))
                 (setq form-result (multiple-value-list (lores/eval sexpr pdu)))

                 (if *verbose*
                     (dolist (x form-result)
                         (lores/mess-0 "    ~a ~%" x) )) ))
       (error (msg)
           (setq *compile-error* (1+ *compile-error*))
           (if *verbose*
               (lores/mess-0 "    Error ~a ~%~%" (_errmsg-expand msg)))
           (let ((*verbose* t))
               (lores/mess-0 "~a ~a ~%Error ~a ~%~%"
                             (car sexpr)
                             (cadr sexpr)
                             (_errmsg-expand msg))
               )))
     (catch (err)
         (setq *compile-error* (1+ *compile-error*))
         (let ((*verbose* t))
             (lores/mess-0  "Error: ~s~%"
                            (or (oget err "message") err)))) ))


;;; Done compile
(defun lores/done-compile ()
    (#j:setTimeout
     (lambda ()
         (lores/mess-0 "Done<br>" )
         (lores/mess-0 "Compile ~a exprs ~%" (sysq/total-sexpr-compile) )
         (lores/mess-0 "Errors ~a  ~%" *compile-error* )
         (lores/mess-0 "Total execution time ~a seconds~%" (roundnum *lores-exec-time* 3))
         (lores/mess-0 "        elapsed time ~a seconds~%" (roundnum (/ (- (get-internal-real-time)
                                                                           *lores-start-time*) 1000.0) 3)  ))
     100))




;;; EOF
