;;; -*- mode:lisp; coding:utf-8  -*-

;;; This file is part of the LORES system
;;; LORES is a tool Moren Environment, designed to help developers deal
;;; with large programs contained in multiple files (system)
;;; Copyright © 2017 Vladimir Mezentsev
;;;


(in-package :lores)

(defvar *lores-registry* "./sdf")
(defvar *store-sexpr* nil "Do not store lisp expressions")
(defvar *store-pcode* nil "Do not store js code")
(defvar *verbose* nil "Print some info about compile")
(defvar *jeval* t "Not use")
(defvar *force* nil "Force recompilation all system component")

;;; macro defsys working stack
(defvar *dsp-current-defsys* nil)
(defvar *dsp-current-sysname* nil)
(defvar *dsp-current-path* nil)
(defvar *dsp-current-module-name* '(nil))

(defvar *defsystems* (make-hash-table :test #'equal) "Global system table")



;;; EOF
