;;; -*- mode:lisp; coding:utf-8  -*-


;;;
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

;;;
;;; qloader
;;;
;;; load & compile files from system queue
;;;

(defun lores/gen-uniq-eof ()
    (gensym (concat "LORES-" (#j:Date:now) "-EOF-")))



(defun lores/qloader  (rdf units)
    (let ((text)
          (reg-del (reg-exp "[\\r]" "g" ))
          (qp)
          (eof (lores/gen-uniq-eof))
          (stream)
          (loader) )

        ;; silent return if units is empty
        (unless units
            (lores/mess-0 "~%Has no units for compile...~%")
            (return-from lores/qloader nil))

        (lores/qloader-init)
        (sysq/clear-sexpr-counter)
        (setq *sexpr* rdf)
        (setq *pcode* rdf)
        (setq qp units)
        (setq loader
              (lambda (pdu)
                  (let ((break)
                        (expr)
                        (context)
                        (expcount 0)
                        (begtime 0)
                        (endtime 0))

                      (unit/clear-reference pdu)
                      (lores/mess-0 "Read file: ~a ~%" (def-unit-depend-name pdu) )
                      (setq begtime (get-internal-real-time))
                      (op/ctimer (setq context
                                       (jstring:replace
                                        (fs-read-file-sync (def-unit-pathname pdu) "utf-8")
                                        reg-del " ")))
                      (qload/sync-modtime pdu)
                      (setq stream (jscl::make-string-stream context))
                      (setq expcount 0)
                      (tagbody loader-rdr
                       rdr-feeder
                         (handler-case
                             (progn (setq expr (jscl::ls-read stream nil eof)))
                           (error (msg)
                               (setq *compile-error* (1+ *compile-error*))
                               (lores/mess-0 "Lores rdr: ~a~%" (_errmsg-expand msg))
                               (setq break t)))
                         (if (or (eql expr eof) break) (go rdr-eof))

                         (op/ctimer (lores/compile-0 expr pdu))

                         (setq expcount (1+ expcount))
                         (go rdr-feeder)
                       rdr-eof)
                      (setq endtime (get-internal-real-time))
                      (lores/done-unit-compile pdu expcount  begtime endtime)
                      (sysq/store-sexpr-count expcount)
                      ;;(setq *complen* (+ *complen* expcount))
                      ;; if units queue not empty call next read-compile
                      (cond ((and qp (not break))
                             (#j:setTimeout
                              (lambda () (funcall loader (pop qp))) 100))
                            (t ;;(setq *complen* (length (def-sys-sexpr *sexpr*)))
                             (lores/done-compile)
                             (setq *package* (find-package :cl-user)) ) )
                      (values))) )
        ;; lets go first unit
        (funcall loader (pop qp)) ))





;;;
;;; Done compile

(defun lores/done-unit-compile (pdu ec start stop)
    (#j:setTimeout
     (lambda ()
         (lores/mess-0
          "~a: Compile ~a/~a/~a exprs. Errors ~a. Time ~a sec~%~%"
          (def-unit-depend-name pdu)
          ec (length (def-unit-sexpr pdu)) (length (def-unit-pcode pdu))
          *compile-error*
          (/ (- stop start) 1000.0))
         (incf *complen* (length (def-unit-sexpr pdu))))
     100))


;;; EOF
