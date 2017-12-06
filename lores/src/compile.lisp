;;; -*- mode:lisp; coding:utf-8  -*-

;;; This file is part of the LORES system
;;; Copyright © 2017 Vladimir Mezentsev
;;;
;;;
;;; LORES is free software: you can redistribute it and/or modify it under
;;; the terms of the GNU General  Public License as published by the Free
;;; Software Foundation,  either version  3 of the  License, or  (at your
;;; option) any later version.
;;;
;;; LORES is distributed  in the hope that it will  be useful, but WITHOUT
;;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;;; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
;;; for more details.
;;;
;;; You should  have received a  copy of  the GNU General  Public License
;;; Version 3 from  <http://www.gnu.org/licenses/>.
;;;
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
        (lores/mess-0 "~a ~a<br>" (car sexpr) (cadr sexpr) ))

    (jscl::%js-try
     (handler-case
         (progn
             (let ((form-result))
                 (setq form-result (multiple-value-list (lores/eval sexpr pdu)))

                 (if *verbose*
                     (dolist (x form-result)
                         (lores/mess-0 "&nbsp&nbsp&nbsp ~a <br>" x) )) ))
       (error (msg)
           (setq *compile-error* (1+ *compile-error*))
           (if *verbose*
               (lores/mess-0 "&nbsp&nbsp&nbsp Error ~a <br><br>" (_errmsg-expand msg)))
           (let ((*verbose* t))
               (lores/mess-0 "~a ~a <br>Error ~a <br><br>"
                             (car sexpr)
                             (cadr sexpr)
                             (_errmsg-expand msg))
               )))
     (catch (err)
         (setq *compile-error* (1+ *compile-error*))
         (let ((*verbose* t))
             (lores/mess-0  "<font color='red'>Error: ~s</font>~%"
                            (or (oget err "message") err)))) ))


;;; Done compile
(defun lores/done-compile ()
    (#j:setTimeout
     (lambda ()
         (lores/mess-0 "Done<br>" )
         (lores/mess-0 "Compile ~a exprs <br>" (sysq/total-sexpr-compile) )
         (lores/mess-0 "Errors ~a  <br>" *compile-error* )
         (lores/mess-0 "Total execution time ~a seconds<br>" (roundnum *lores-exec-time* 3))
         (lores/mess-0 "        elapsed time ~a seconds<br>" (roundnum (/ (- (get-internal-real-time)
                                                                             *lores-start-time*) 1000.0) 3)  ))
     100))




;;; EOF
