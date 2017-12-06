;;; -*- mode:lisp; coding:utf-8  -*-

;;;
;;; This file is part of the LORES system
;;; Copyright © 2017 Vladimir Mezentsev
;;;
;;;
;;; LORES is free software: you can redistribute it and/or modify it under
;;; the terms of the GNU General  Public License as published by the Free
;;; Software Foundation,  either version  3 of the  License, or  (at your
;;; option) any later version.
;;;
;;; LORES is distributed  in the hope that it will  be useful, but WITHOUT
;;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;;; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
;;; for more details.
;;;
;;; You should  have received a  copy of  the GNU General  Public License
;;; Version 3 from  <http://www.gnu.org/licenses/>.
;;;


(in-package #:lores)



;;; NODE.JS FS primitives

(unless #j:Fs
    (setf #j:Fs (require "fs")) )

(fset 'reg-exp #j:RegExp)


;;; read - sync / async
(fset 'fs-read-file-sync #j:Fs:readFileSync)
(fset 'fs-read-file-async #j:Fs:readFile)

;;; stat - sync
(defun lores/fs-stat (pathname)
    (#j:Fs:statSync pathname))

;;; exists - sync
(defun lores/fs-exists (pathname)
    (#j:Fs:existsSync pathname))

;;; time modify
(defun lores/fs-get-modify-time (pathname)
    (let* ((stat (lores/fs-stat pathname ))
           (datemod (oget stat "mtime"))
           (modtime (funcall ((oget datemod "getTime" "bind") datemod))))
        modtime))




;;; System definition name utils
(das:generic sdfn (name))

(das:method sdfn (other)
            (error "Lores sdfn: wtf system name ~a?" other))

(das:method sdfn ((name symbol))
            (jstring:to-upper-case (symbol-name name)))

(das:method sdfn ((name string)) name)




(defvar *sexpr* nil)
(defvar *complen* 0 )
(defvar *comptr* 0)
(defvar *compile-error* 0)


;;; compiler output stream
(defvar *compiler-stream* *standard-output*)

(export '(lores::*compiler-stream*))
(export '(lores::stream-set))

(defun stream-set (stream)
    (setq *compiler-stream* stream))

(defun lores/mess-0 (&rest more-args)
    (if *verbose*
        (#j:setTimeout
         (lambda ()
             (apply #'format *compiler-stream* more-args))))
    (values))

(defun lores/mess-0 (&rest more-args)
    (#j:setTimeout
     (lambda ()
         (apply #'format *compiler-stream* more-args)))
    (values))


;;; p-code
(defvar *pcode-file* '())
(defvar *pcode* '())

(defconstant *nl* (Reg-exp (code-char 10) "g"))



;;;
;;; Timers
;;;

(defvar *lores-exec-time* 0)
(defvar *lores-start-time* 0)
(defvar *lores-end-time* 0)


;;;
;;; timer
;;;
(defmacro op/ctimer (form)
    (let ((start (gensym))
          (etime (gensym)))
        `(let ((,start (get-internal-real-time))
               (,etime 0))
             (prog1 (progn ,form)
                 (setq ,etime (/ (- (get-internal-real-time) ,start) 1000.0))
                 (incf *lores-exec-time* ,etime)
                 (if *verbose*
                     (lores/mess-0 "Execution took ~a seconds.<br><br>" ,etime))  ))))

;;;
;;; Lores environment counters initialize
;;;
(defun lores/qloader-init ()
    ;;(setq *sexpr* '())
    (setq *complen* 0)
    (setq *comptr* 0)
    (setq *compile-error* 0)
    (setq *lores-exec-time* 0)
    (setq *lores-start-time* (get-internal-real-time))
    (setq *lores-end-time* 0)
    (setq *pcode-file* nil))





;;;
;;; Kludges
;;;

(defconstant *round-base* #(10 10 100 1000 10000))
(defun roundnum (num &optional (base 1))
    (let ((magic (aref *round-base* base)))
        (/ (floor (* num magic)) magic)))


;;; queue for sexpr counters
(defvar *sysq-sexpr* '())

;;; clear before system compilation
(defun sysq/clear-sexpr-counter ()
    (setq *sysq-sexpr* '()))

;;;  store sexpr count for unit
(defun sysq/store-sexpr-count (num)
    (push num *sysq-sexpr*))

;;; total sum
(defun sysq/total-sexpr-compile ()
    (reduce #'+ *sysq-sexpr*))


;;; EOF
