;;; -*- mode:lisp; coding:utf-8  -*-


;;;
;;; This file is part of the MOREN environment
;;; Moren development console
;;; Copyright © 2017 Vladimir Mezentsev


(in-package :mordev)

;;; Moren configurator


;;; get config variable from registry
(export '(moren/get-config))
(defun moren/get-config (key)
    (let ((raw (#j:localStorage:getItem key)))
        (if (js-null-p raw)
            nil
            (read-from-string raw))))


;;; store config varible to registry
;;; (moren/set-config "lores-central-register" "./sdf")
;;; (concat (moren/get-config "lores-central-register") "/" name)
;;;
(export '(moren/set-config))
(defun moren/set-config (key value)
    (#j:localStorage:setItem key
                             (write-to-string value)))

;;; registry initialize
;;; first spawn moren
(let ((config-template
        ;; moren config template
        ;; for first start
        (list
         (list "lores-sdf-repository" "./sdf"))))

    (defun moren/check-firstly ()
        (unless (moren/get-config "moren-alive-timestamp")
            (moren/set-config  "moren-alive-timestamp" (get-internal-real-time))
            (dolist (x config-template)
                (moren/set-config (car x) (cadr x))))))





(in-package :cl-user)

;;; EOF
