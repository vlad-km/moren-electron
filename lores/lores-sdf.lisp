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

(lores:defsys :lores
    :path  "git/moren-electron/lores"
    :components ((:file "lores-package")
                 (:module "src"
                  :depends ("lores-package")
                          (:file "preface"
                           :documentation "Utils and aux functions")
                          (:file "structures"
                           :documentation "Global structures definition")
                          (:file "vars"
                           :documentation "Global variables")
                          (:file "defsys"
                           :depends ("src/structures" "src/vars")
                           :documentation "Lores:defsys macro definition")
                          (:file "dstableops"
                           :documentation "Operations with *defsytsems* table")
                          (:file "qload"
                           :depends ("src/structures" "src/vars")
                           :documentation "qload command"      )
                          (:file "builder" :depends ("src/structures" "src/vars"))
                          (:file "opload"  :depends ("src/builder") )
                          (:file "references")
                          (:file "compile" :depends ("src/references"))
                          (:file "qloader" :depends ("src/references" "src/compile" ))
                          (:file "modlink" :depends ("src/preface" "src/references"))
                          (:file "finality"))))
