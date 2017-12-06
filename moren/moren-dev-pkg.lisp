;;; -*- mode:lisp;  coding:utf-8 -*-

;;;
;;; This file is part of the MOREN environment
;;; Moren development console
;;; Copyright © 2017 Vladimir Mezentsev
;;;
;;; MOREN environment created for rapidly programming and prototyping programs
;;; on JSCL language (subset of Common Lisp) in yours browser.
;;;
;;; MOREN is free software: you can redistribute it and/or modify it under
;;; the terms of the GNU General  Public License as published by the Free
;;; Software Foundation,  either version  3 of the  License, or  (at your
;;; option) any later version.
;;;
;;; MOREN is distributed  in the hope that it will  be useful, but WITHOUT
;;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;;; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
;;; for more details.
;;;
;;; You should  have received a  copy of  the GNU General  Public License
;;; Version 3 from  <http://www.gnu.org/licenses/>.
;;;
;;; JSCL   - JSCL is a Common Lisp to Javascript compiler, which is bootstrapped
;;; from Common Lisp and executed from the browser.
;;; https://github.com/jscl-project/jscl
;;;
;;; Version for Electron
;;;
;;; Electron is a framework for creating native applications with web technologies
;;; like JavaScript, HTML, and CSS.
;;; https://electron.atom.io/
;;;
;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
    (unless (find-package :mordev)
        (make-package :mordev :use (list 'cl))))


(in-package :mordev)

(export
 '(jscl::oget jscl::new jscl::concat
   jscl::make-new jscl::fset jscl::js-null-p
   jscl::%js-try
   jscl::while
   jscl::js-to-lisp jscl::lisp-to-js
   jscl::vector-to-list jscl::list-to-vector
   jscl::in
   jscl::objectp
   ))

(export
 '(klib::make-js-object
   klib::mkjso
   klib::curry))

(in-package :cl-user)

;;; EOF
