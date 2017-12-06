;;; -*- mode:lisp; coding:utf-8  -*-

;;; This file is part of the LORES system
;;; LORES is a tool Moren Environment, designed to help developers deal
;;; with large programs contained in multiple files (system)
;;; Copyright © 2017 Vladimir Mezentsev
;;;



(in-package :lores)

(unless (find :lores *features*)
    (push  :lores *features*))

(unless (find-package :mordev)
    (format t "~%Welcome to Moren development environment~%"))

(in-package :cl-user)

;;; EOF
