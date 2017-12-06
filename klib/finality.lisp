;;; -*- mode:lisp; coding:utf-8  -*-

;;;
;;; This file is part of the MOREN environment
;;; Copyright © 2017 Vladimir Mezentsev
;;;
;;;




(in-package :cl-user)

(export '(klib:mkjso klib:make-js-object))
(export '(klib:resloadjs klib:resloadcss))
(export '(klib:load))


(unless (find :klib *features*)
    (push  :klib *features*))



;;; EOF
