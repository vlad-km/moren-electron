;;; -*- mode:lisp; coding:windows-1251  -*-


;;;
;;; This file is part of the LESTRADE package - object inspector
;;; for Moren environment
;;; Object inspector system file definition
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
