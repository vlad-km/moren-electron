;;; -*- mode:lisp;  coding:utf-8 -*-

;;;
;;; This file is part of the DOM package
;;; DOM - dom manipulation functions package
;;; This package is part of the MOREN Environment
;;;
;;; Copyright © 2017 Vladimir Mezentsev
;;;
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
;;;
;;;


(eval-when (:compile-toplevel :load-toplevel :execute)
    (unless (find-package :dom)
        (make-package :dom :use (list 'cl))))

(in-package :dom)
(export '(jscl::oget jscl::new jscl::concat jscl::make-new jscl::fset))


;;; EOF
