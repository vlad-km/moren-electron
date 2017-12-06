;;; -*- mode:lisp; coding:utf-8  -*-

;;;
;;; This file is part of the MOREN environment
;;; Copyright © 2017 Vladimir Mezentsev
;;;


;;; Moren environment kernel library. System definition file
;;;
(lores:defsys :klib
    :path "git/moren-electron"
    :components ((:module "klib"
                          (:file "klib-pkg")
                          (:file "attic")
                          (:file "jsom")
                          (:file "string")
                          (:file "array")
                          (:file "klib-load")
                          (:file "res-loader"))
                 (:module "generic"
                          (:file "das-types")
                          (:file "das-structure")
                          (:file "das-generic"))
                 (:module "electron"
                          (:file "electron"))
                 (:module "klib"
                          (:file "html-base"))
                 (:module "dom"
                          (:file "dom")
                          (:file "stream-output"))
                 (:module "klib"
                          (:file "finality"))))


;;; EOF
