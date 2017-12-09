;;; -*- mode:lisp; coding:utf-8  -*-


;;;
;;; This file is part of the LORESDOC package
;;; tool for Moren environment
;;; Build template documentation
;;; Copyright © 2017 Vladimir Mezentsev
;;;

;;; Loresdoc package system  definition file

(lores:defsys :loresdoc
    :path "git/moren-electron/loresdoc"
    :components ((:file "loresdoc-pkg")
                 (:module "src"
                  :depends ("loresdoc-pkg")
                          (:file "vars")
                          (:file "structures")
                          (:file "preface")
                          (:file "printers" :depends ("src/vars" "src/structures"))
                          (:file "ref-walker" :depends ("src/printers"))
                          (:file "finality"))))


;;; EOF
