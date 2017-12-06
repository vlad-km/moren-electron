;;; -*- mode:lisp; coding:utf-8  -*-

;;;
;;; This file is part of the MOREN environment
;;; IPL Moren development console system file definition
;;; Copyright © 2017 Vladimir Mezentsev
;;;


(lores:defsys :moren-awake
    :depends (:mordev)
    :path "git/moren-electron"
    :components ((:module "moren"
                          (:file "moren-dev-awake"))))

;;; EOF
