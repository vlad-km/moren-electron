;;; -*- mode:lisp; coding:utf-8  -*-


;;;
;;; This file is part of the LESTRADE package.
;;; Object inspector for Moren environment
;;; Copyright © 2017 Vladimir Mezentsev
;;;

;;; Lestrade system definition file

(lores:defsys :lestrade
    :path "git/moren-electron"
    :components ((:module "lestrade"
                          (:file "lestrade-pkg")
                          (:file "inspector")
                          (:file "finality"))))


;;; EOF
