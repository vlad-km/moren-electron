;;; -*- mode:lisp; coding:utf-8  -*-


;;; This file is part of the MOREN environment
;;; Moren development console
;;; Copyright © 2017 Vladimir Mezentsev


;;; global variables

(in-package :mordev)

;;; RX JavaScript emitters
(defvar *moren-rx-subjects* (jscl::new))


;;; shadow history
(defvar *jq-history-maxlen* 100)
(defvar *repl-hist-pathname-template* "repl-history/devrepl-" "template for repl-history dump file")
(defvar *repl-history nil "Shadow JQ-console history")

;;; keyboard
(defvar *moren-top-menu* nil)
(defvar *moren-top-menu-template* nil)
(defvar *moren-popup-menu nil)
(defvar *moren-popup-content nil)

;;; output streams
(defvar *mordev-standard-output* nil)
(defvar *moren-html-output* nil)
(defvar *mordev-standard-error* nil)

(defvar *lestrade-wtf* nil)

(in-package :cl-user)

;;; EOF
