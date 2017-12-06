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

(unless (find :lores *features*)
    (push  :lores *features*))

(unless (find-package :mordev)
    (format t "~%Welcome to Moren development environment~%"))

(in-package :cl-user)

;;; EOF
