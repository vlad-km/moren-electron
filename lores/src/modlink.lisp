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
;;;
;;;(export '(modlink))

#|
(defun modlink (sysname module-pathname &key (verbose t))
    (let ((stream))
        ;;(load sysname :force t :jeval nil :verbose verbose)
        (setq stream (lores/open-pcode-stream-output module-pathname))
        (lores/module-header stream)
        ;;(lores/make-pkg-stm sysname stream)
        (dolist (stm (reverse *pcode-file*))
            (fs-stream-write
             stream
             (lores/stm-wrapper
              (concat (jstring:replace stm *nl* " ") #\newline)) ) )
        (lores/module-tail stream)
        (funcall ((oget *pcode-output-stream* "end" "bind") *pcode-output-stream*))
        (setq *pcode-file* nil)
        ))
|#

#|
(defun modlink (sysname module-pathname &key (verbose t))
    (let ((stream)
          (rdf (gethash (sdfn sysname) *defsystems*)))
        ;;(load sysname :force t :jeval nil :verbose verbose)
        (setq stream (lores/open-pcode-stream-output module-pathname))
        (lores/module-header stream)
        ;;(lores/make-pkg-stm sysname stream)
        (dolist (stm (reverse (def-sys-pcode rdf)))
            (fs-stream-write
             stream
             (lores/stm-wrapper
              (concat (jstring:replace stm *nl* " ") #\newline)) ) )
        (lores/module-tail stream)
        (funcall ((oget *pcode-output-stream* "end" "bind") *pcode-output-stream*))
        (setq *pcode-file* nil)
        ))
|#

#|
(defun modlink (sysname module-pathname &key (verbose t))
    (let ((stream)
          (components))

        (setq stream (lores/open-pcode-stream-output module-pathname))
        (lores/module-header stream)

        (setq components (defsys/components-flatten sysname))
        (lores/mess-0 "Linked ~s with ~a components~%" (string sysname) (length components))
        (dolist (unit components)
            (dolist (stm (unit/get-pcode unit))
                (lores/mess-0 "File ~a: ~a statements ~%" (def-unit-depend-name unit) (length stm))
                (fs-stream-write
                 stream
                 (lores/stm-wrapper
                  (concat (jstring:replace stm *nl* " ") #\newline)) ) ))

        (lores/module-tail stream)
        (funcall ((oget *pcode-output-stream* "end" "bind") *pcode-output-stream*))

        ))
|#

#|
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
                  (concat (jstring:replace x *nl* " ") #\newline)) ) ))

        (lores/module-tail stream)
        (funcall ((oget *pcode-output-stream* "end" "bind") *pcode-output-stream*))
        (lores/mess-0 "Done~%")
        ))
|#

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
