;;; -*- mode:lisp; coding:utf-8  -*-

;;; This file is part of the LORES system
;;; LORES is a tool Moren Environment, designed to help developers deal
;;; with large programs contained in multiple files (system)
;;; Copyright © 2017 Vladimir Mezentsev
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
