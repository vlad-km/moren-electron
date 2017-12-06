;;; -*- mode:lisp; coding:utf-8  -*-

;;; This file is part of the LORES system
;;; Copyright © 2017 Vladimir Mezentsev


;;; unit references


;;; clear def-unit reference before compile/recompile
;;; compile step I
(defun unit/clear-reference (pdu)
    (set-def-unit-pcode pdu nil)
    (set-def-unit-sexpr pdu nil)
    (set-def-unit-refname pdu (make-hash-table :test 'eql)))

;;; save all unit references for each unit sexpr
;;; compile step II

;;;
;;; :todo: deprecate
(defun unit/save-reference (pdu cl js)
    (push js (def-unit-pcode pdu))
    (push cl (def-unit-sexpr pdu)))

(defun unit/store-js (pdu js)
    (push js (def-unit-pcode pdu)) )

(defun unit/store-sexpr (pdu cl)
    (push cl (def-unit-sexpr pdu)) )


;;; reorder all codes after compile def-unit
;;; compile step III

;;; :todo: deprecte
(defun unit/reorder-reference (pdu)
    (set-def-unit-pcode pdu (reverse (def-unit-pcode pdu)))
    (set-def-unit-sexpr pdu (reverse (def-unit-sexpr pdu))))


;;; get reorder js code from modlink
(defun unit/get-pcode (pdu)
    (reverse (def-unit-pcode pdu)))


;;; get reorder cl code for any walkers
(defun unit/get-sexpr (pdu)
    (reverse (def-unit-sexpr pdu)))


;;;
(defun defsys/get-sdf-by-name (sym)
    (gethash (sdfn sym) *defsystems*))

;;; flatten system components
(defun defsys/components-flatten (symname)
    (labels ((rec (x acc)
                 (cond ((null x) acc)
                       ((das:typep x 'lores::def-unit)
                        (cons x acc))
                       ((das:typep x 'lores::def-module)
                        (rec (lores::def-module-units x) acc))
                       (t (rec (car x)
                               (rec (cdr x) acc))) )))
        (let ((sdf (lores::defsys/get-sdf-by-name symname)))
            (unless sdf (error "Lores: system ~a not found" symname))
            (rec (lores::def-sys-components sdf) nil) )))


;;; EOF
