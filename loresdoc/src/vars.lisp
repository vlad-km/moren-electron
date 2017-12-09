;;; -*- mode:lisp; coding:utf-8  -*-

;;; This file is part of the LORESDOC package
;;; Copyright © 2017 Vladimir Mezentsev
;;;


(in-package :loresdoc)


(defvar *knowsymbols* nil "Loresdoc job queue")
(defvar *docstream* nil "NODE FS output stream")
(defvar *namespace* *package* "Package for expression")


(in-package :cl-user)
;;; EOF
