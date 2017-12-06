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

(in-package :lores)


;;;
;;; QLOAD
;;; Command for load and compile/recompile source programm  files in correct order
;;;
;;; (lores:qload sysname &key from verbose jeval force)
;;;
;;; Arguments:
;;;
;;;     sysname - system name. The name under which the system will be registered
;;;               in the main table for subsequent operations with its files.
;;;               Must be a keyword or string. The programm system is defined
;;;               by the structure in which it is specified: the namespace in which
;;;               all macros, functions and variables will be placed; location of each
;;;               file included in the system; other information (see details on DEFSYS.LISP)
;;;               In the general, sysname it is a package (namespase) for you programm. If it
;;;               is not in the environment, it will be created automatically. See detail in
;;;               defsys.lisp
;;;
;;;
;;; Keys:
;;;     from         - where to get sdf file. If specified, a new system
;;;                    definition file (sdf) will be loaded from this place, and all system
;;;                    files will be compiled according to the value of the jeval key
;;;     verbose t    - execution log
;;;     jeval   t    - upload code into V8 environment after lisp compilation, are not.
;;;     force   nil  - forced compilation all system files
;;;
;;; Firstly, the programm system must be registered in the Lores table.
;;; This is done by calling the function qload with the key :from which indicate the location
;;; of the file with a system description. Lores checks the description syntax and existence
;;; of each file, specified in the description.
;;;
;;; Then the whole system is compiled, and if there were no compilation errors
;;; the program can be used.
;;;
;;;     (lores:qload :my-program :from "/home/user/place/sdf-file-name.lisp")
;;;
;;; After editing one or more files on the system, just issue call function lores:qload with
;;; the system name.
;;;
;;;     (lores:qload :my-program)
;;;
;;; After the completion of the development cycle, you can:
;;;    - link all the system files into a single JavaScript module for downloads
;;;      without compiling the source files:
;;;
;;;                    (lores:modlink :my-program "path/bundle-name.js")
;;;
;;;    - or compile the system using JSCL facilite with one of the CCL/SBCL:
;;;                (jscl:bootstrap)  or
;;;                (jscl:compile-application)
;;;
;;;

;;; some QLOAD
(das:generic qload (name &key storecl storejs verbose force))

(das:method qload (name &key (storecl nil) (storejs nil) (verbose nil) (force nil))
            (error "Lores qload: incorrect system name ~a" name))

;;; load sdf from pathname
(das:method qload ((name string) &key (storecl nil) (storejs nil) (verbose nil) (force nil))
            (let ((sysname))
                (setq sysname (bootstrap-sdf-from name))
                (opload (def-sys-name sysname) :storecl storecl
                                               :storejs storejs
                                               :verbose verbose :force force)))


;;; load sdf from system table
;;; or system registry
#|
(das:method qload ((name symbol) &key (storecl nil) (storejs nil) (verbose nil) (force nil))
            (let ((sdf (gethash (sdfn name) *defsystems*)))
                (if sdf
                    (#j:setTimeout (lambda () (opload name :storecl storecl
                                                           :storejs storejs
                                                           :verbose verbose :force force)) 200)
                    (error "Lores qload: system ~a dasnt exists" name))))
|#

(das:method qload ((name symbol) &key (storecl nil) (storejs nil) (verbose nil) (force nil))
            (let ((sdf (gethash (sdfn name) *defsystems*)))
                (cond (sdf
                       (#j:setTimeout (lambda () (opload name :storecl storecl
                                                              :storejs storejs
                                                              :verbose verbose :force force)) 200))
                      (t (qload (defsys/make-registry-name name)
                                :storecl storecl :storejs storejs :verbose verbose :force force)))))

(export '(qload))

(defun bootstrap-sdf-from (path)
    (let ((expr)
          (sdf))
        (setq expr (read-from-string (lores/read-sdf-from path)))
        (unless (consp expr)
            (error "Lores qload: ~a isnt DEFSYS" path))
        (if (find (car expr) '(lores:defsys lores::defsys defsys))
            (setq sdf (eval expr))
            (error "Lores qload: ~a isnt DEFSYS" path))
        sdf))



;;; EOF
