;;; -*- mode:lisp; coding:utf-8  -*-


;;;
;;; This file is part of the MOREN environment
;;; Moren development console
;;; Copyright © 2017 Vladimir Mezentsev


(in-package :mordev)


(defun _errmsg-expand (msg)
    (apply #'format nil (jscl::!condition-args msg)))


(in-package :cl-user)

;;; EOF
