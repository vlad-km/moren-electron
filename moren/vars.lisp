;;; -*- mode:lisp; coding:utf-8  -*-

;;;
;;; This file is part of the MOREN environment
;;; Moren development console
;;; Copyright © 2017 Vladimir Mezentsev


;;; global variables

(in-package :mordev)

;;; RX JavaScript emitters
(defvar *moren-rx-subjects* (jscl::new))


;;; shadow history
(defvar *jq-history-maxlen* 100)
(defvar *repl-hist-pathname-template* "repl-history/devrepl-")

;;; keyboard
(defvar *moren-top-menu* nil)
(defvar *moren-top-menu-template* nil)
(defvar *moren-popup-menu nil)
(defvar *moren-popup-content nil)

(defvar *repl-history nil "Shadow JQ-console history")

;;; output streams
(defvar *mordev-standard-output* nil)
(defvar *mordev-standard-error* nil)


(in-package :cl-user)

;;; EOF
