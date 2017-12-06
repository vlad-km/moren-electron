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


(in-package :lores)

;;;
;;;
;;; (lores:opload :doms)
;;;
;;; Load system with :sysname
;;;
;;; The structure of the system must be declared earlier
;;; with defsys
;;;
;;; Keys:
;;;
;;;     verbose t    - Write a log to the console
;;;     force   nil  - forced compilation of the system
;;;
;;;

(defun opload (sysname &key (storecl nil) (storejs nil) (verbose nil) (jeval t) (force nil))
    (let* ((rdf (gethash (sdfn sysname) *defsystems*))
           (sysq '()))
        (unless rdf (error "Lores: Unknow system name ~a" sysname))

        (setq *sysq* '())
        (setq *store-sexpr* storecl)
        (setq *store-pcode* storejs)
        (setq *verbose* verbose)
        (setq *jeval* jeval)
        (setq *force* force)
        (lores/mess-0 "~%Check ~a dependences...~%" (string sysname))
        (check-dependences rdf)
        ;;(lores/mess-0 "Will be recompile ~a files~%" (length *sysq*))
        (if  *sysq*
             (progn
                 (lores/mess-0 "Will be recompiled ~a files~%" (length *sysq*))
                 (setq sysq *sysq*)
                 (lores/qloader rdf (reverse sysq)))
             (lores/mess-0 "Unmodified system ~a~%" (string sysname))

             )))
;;; EOF
