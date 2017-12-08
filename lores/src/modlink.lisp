;;; -*- mode:lisp; coding:utf-8  -*-

;;; This file is part of the LORES system
;;; LORES is a tool Moren Environment, designed to help developers deal
;;; with large programs contained in multiple files (system)
;;; Copyright © 2017 Vladimir Mezentsev
;;;


(in-package :lores)


(defvar *pcode-output-stream* nil)


(defun lores/open-pcode-stream-output (name)
    (setq *pcode-output-stream*
          (#j:Fs:createWriteStream name)))

(defun fs-stream-write (stream str)
    (funcall ((oget stream "write" "bind") stream str)))
;;;
;;; Link pcode to one module for load as resource file
;;;
(defun lores/module-header (stream)
    (fs-stream-write
     stream
     (concat "(function(jscl){ 'use strict'; (function(values, internals){ " #\newline)))

(defun lores/module-tail (stream)
    (fs-stream-write
     stream
     (concat
      #\newline
      "})(jscl.internals.pv, jscl.internals); })( typeof require !== 'undefined'? require('./jscl'): window.jscl)"
      #\newline)))

(defun lores/stm-wrapper (pcode)
    (concat
     ;;#\newline
     "(function(values, internals){"
     ;;#\newline
     pcode
     ;;#\newline
     ";})(values,internals);"  #\newline) )

(defun lores/make-pkg-stm (sysname stream)
    (fs-stream-write
     stream
     (clopa/stm-wrapper
      (concat
       "var l1=internals.intern('"
       (format nil "~A" (symbol-name sysname))
       "','CL-USER');"
       "var l2=internals.intern('USE','KEYWORD'); l2.value=l2;
var l3=internals.intern('CL','CL-USER'); var l4=internals.intern('FIND-PACKAGE','CL');
var l5=internals.intern('LIST','CL'); var l6=internals.intern('MAKE-PACKAGE','CL');
return l6.fvalue(values,l1,l2.value,l5.fvalue(internals.pv,l4.fvalue(internals.pv,l3)))"
       ))))



;;;
;;; Command modlink sysname module-pathname
;;;
;;; Precondition:
;;;
;;; The system was precompiled and the js statements in the *pcode*
;;; for uploading to module file
;;;


(defun modlink (sysname module-pathname &key (verbose t))
    (let ((stream)
          (components))

        (setq stream (lores/open-pcode-stream-output module-pathname))
        (lores/module-header stream)

        (setq components (defsys/components-flatten sysname))
        (lores/mess-0 "Bundle ~s with ~a components~%" (string sysname) (length components))
        (dolist (unit components)
            (setq stm (unit/get-pcode unit))
            (lores/mess-0 "   File ~a: ~a statements ~%" (def-unit-depend-name unit) (length stm))
            (dolist (x stm)
                (fs-stream-write
                 stream
                 (lores/stm-wrapper
                  (jstring:replace x *nl* " ") ) ) ))

        (lores/module-tail stream)
        (funcall ((oget *pcode-output-stream* "end" "bind") *pcode-output-stream*))
        (lores/mess-0 "Done~%")
        ))



(export '(modlink))



;;; EOF
