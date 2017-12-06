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


;;; system definition
;;;
(das:structure def-sys
               name        ;; system name
               (path "./") ;; repository path
               top-depends ;; top dependencies
               components  ;; components - files and modules
               sexpr       ;; cl statements
               pcode       ;; js code
               )

;;; system type definition
(das:def-type 'def-sys
    (lambda (obj)
        (eq (cdr (das::das/structure-pred obj)) 'def-sys )))


;;; one file from system
(das:structure def-unit
               package
               module
               name
               depend-name
               depends
               pathname
               valid
               (modtime 0)
               need
               (refname (make-hash-table :test #'eql))
               sexpr ;; cl statements
               pcode ;; js code
               )

(das:def-type 'def-unit
    (lambda (obj)
        (eq (cdr (das::das/structure-pred obj)) 'def-unit )))

;;; module - files and modules
;;;
;;; dir1
;;;     file1
;;;     file2
;;;     dir2
;;;        file1
;;;        file2
;;;     file3
;;;
;;; =>
;;;   (:module "dir1"
;;;       (:file "file1")
;;;       (:file "file2")
;;;       (:module "dir2"
;;;          (:file "file1")
;;;          (:file "file2"))
;;;       (:file "file3"))
;;;
;;;

(das:structure def-module
               name    ;; module name (directory under system path)
               depends ;; dependens list
               units   ;; files and other modules
               need)

(das:def-type 'def-module
    (lambda (obj)
        (eq (cdr (das::das/structure-pred obj)) 'def-module )))




;;; EOF
