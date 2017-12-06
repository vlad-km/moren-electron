;;; -*- mode:lisp; coding:utf-8  -*-

;;;
;;; This file is part of the MOREN environment
;;; Moren development console system file definition
;;; Copyright © 2017 Vladimir Mezentsev
;;;


;;; System definition

(lores:defsys :mordev
    :depends (:lestrade)
    :path "git/moren-electron"
    :components ((:module "moren"
                          (:file "moren-dev-pkg")
                          (:file "vars")
                          (:file "preface"        :depends ("moren/moren-dev-pkg" "moren/vars"))
                          (:file "config"         :depends ("moren/preface"))
                          (:file "moren-dev"      :depends ("moren/preface"))
                          (:file "moren-dev-kbc"  :depends ("moren/preface"))
                          (:file "moren-dev-setup"
                           :depends ("moren/moren-dev" "moren/moren-dev-kbc")))))


;;; EOF
