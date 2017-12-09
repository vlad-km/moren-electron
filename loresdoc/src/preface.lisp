;;; -*- mode:lisp; coding:utf-8  -*-

;;; This file is part of the LORESDOC package
;;; Copyright © 2017 Vladimir Mezentsev
;;;


(in-package #:loresdoc)


(defun open-doc-template-file (path)
    (setq *docstream*
          (#j:Fs:createWriteStream path)))

(defun write-doc-template (what)
    ;;(lores::lores/mess-0 "WRT:~s~%" what)
    (funcall ((oget *docstream* "write" "bind") *docstream* what)))

(defun close-doc-template-file ()
    (funcall ((oget *docstream* "end" "bind") *docstream*)))


(in-package :cl-user)
;;; EOF
