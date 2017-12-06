;;; -*- mode:lisp;  coding:utf-8 -*-

;;;
;;; LOAD - load & compile lisp file
;;; This file is part of the MOREN environment
;;; Copyright © 2017 Vladimir Mezentsev
;;;
;;;

;;;
;;; 1. file with name 'midagi.lisp' contain
;;;
;;;     (defparameter *ara (make-array 5 :initial-element 0)
;;;     (defun fun1 () (print 'Im-fun1))
;;;     (defun fun2 (x) (identity x))
;;;
;;; CL-USER>(load "j/midagi.lisp")
;;;
;;;

;;; workaround for send null from jscl to js
(defvar *sendNull-proto* "var reqXHRsendNull = function (req) {req.send(null);}")

(unless #j:reqXHRsendNull
    (#j:eval *sendNull-proto*))

(defun %asyn/print (fmt &rest args)
    (#j:setTimeout (lambda () (apply #'format t fmt args)) 4 ))


(defun %xhr/receive (uri fn-ok &optional fn-err)
    (let ((req (make-new #j:XMLHttpRequest)))
        (funcall ((oget req "open" "bind") req "GET" uri t))
        (funcall ((oget req "setRequestHeader" "bind") req "Cache-Control" "no-cache"))
        (funcall ((oget req "setRequestHeader" "bind") req "Cache-Control" "no-store"))
        (setf (oget req "onreadystatechange")
              (lambda (evt)
                  (if (= (oget req "readyState") 4)
                      (if (= (oget req "status") 200)
                          (funcall fn-ok (oget req "responseText"))
                          (if fn-err
                              (funcall fn-err uri (oget req "status") )
                              (print (concat #\newline "xhr: error " (oget req "statusText") " " uri )) )))))
        (#j:reqXHRsendNull req) ))


;;; compile-eval-print
(defun %ldr/compile (sexpr verbose)
    (if verbose
        (%asyn/print "~a ~a~%" (car sexpr) (cadr sexpr)))
    (%js-try
     (handler-case
         (progn
             (let ((result))
                 (setq result (multiple-value-list (eval sexpr)))
                 (dolist (x result)
                     (%asyn/print  "&nbsp&nbsp&nbsp~a~%"  x )))
             t)
       (error (msg)
           (let ((errmsg (!condition-args msg)))
               (%asyn/print "Error: ~a~%" errmsg))
           nil))
     (catch (err)
         (%asyn/print "Error: ~a~%" (or (oget err "message") err))
         nil)))


;;; read-compile-eval loop
(defun %%load-form-eval (input verbose ready)
    (let ((stream)
          (expr)
          (eof (gensym "LOADER" )))
        (%asyn/print "~%")
        (setq stream (make-string-stream input))
        (tagbody loader-rdr
         rdr-feeder
           (setq expr (ls-read stream nil eof))
           (if (eql expr eof) (go rdr-eof))
           (%ldr/compile expr verbose)
           (go rdr-feeder)
         rdr-eof)
        (if ready (funcall ready))
        (values-list nil)))



;;; replace cntrl-r from input files
(defun %ldr-replace% (src)
    (let ((j-src (lisp-to-js src))
          (reg (#j:RegExp (code-char 13) "g")))
        (funcall ((oget j-src "replace" "bind") j-src reg " "))))


(export '(load))
(defun load (name &key verbose ready)
    (%xhr/receive  name
                   (lambda (input)
                       (%%load-form-eval (%ldr-replace% input) verbose ready))
                   (lambda (uri status)
                       (princ
                        (concat
                         "Load: Can't load " uri
                         " Status " status)) (terpri) ) )
    (values-list nil))


;;; EOF
