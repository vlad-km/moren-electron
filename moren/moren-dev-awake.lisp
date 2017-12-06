;;; -*- mode:lisp;  coding:utf-8 -*-

;;; This file is part of the MOREN environment
;;; Moren development console
;;; Copyright © 2017 Vladimir Mezentsev
;;;
;;;

(in-package :cl-user)

(unless #j:electron
    (setf #j:electron (require "electron")))


(unless #j:Fs
    (setf #j:Fs (require "fs")))

(unless #j:Rx
    (setf #j:Rx (require "rx")))


(setf #j:moren_kernel0 (require "./sys/klib"))

(setf #j:moren_repl_0 (require "./sys/moren-repl"))

(mordev::%moren-awake)

;;; EOF
