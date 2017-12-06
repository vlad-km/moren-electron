;;; -*- mode:lisp;  coding:utf-8 -*-

;;;
;;; This file is part of the MOREN environment
;;; Moren development console
;;; Copyright © 2017 Vladimir Mezentsev
;;;
;;;
;;; MOREN environment created for rapidly programming and prototyping programs
;;; on JSCL language (subset of Common Lisp) in yours browser.
;;;
;;; MOREN is free software: you can redistribute it and/or modify it under
;;; the terms of the GNU General  Public License as published by the Free
;;; Software Foundation,  either version  3 of the  License, or  (at your
;;; option) any later version.
;;;
;;; MOREN is distributed  in the hope that it will  be useful, but WITHOUT
;;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;;; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
;;; for more details.
;;;
;;; You should  have received a  copy of  the GNU General  Public License
;;; Version 3 from  <http://www.gnu.org/licenses/>.
;;;
;;; JSCL   - JSCL is a Common Lisp to Javascript compiler, which is bootstrapped
;;; from Common Lisp and executed from the browser.
;;; https://github.com/jscl-project/jscl
;;;
;;; Version for Electron
;;;
;;; Electron is a framework for creating native applications with web technologies
;;; like JavaScript, HTML, and CSS.
;;; https://electron.atom.io/
;;;

;;;
;;;                             MOREN NAMESPACE
;;;

(in-package :mordev)


;;; RX JavaScript emitters
;;;(defvar *moren-rx-subjects* (jscl::new))

;;; emiter listener
;;;
;;; (mordev:rx-listen :err #'error-out-fn)
;;;
(defun rx-listen (name listener)
    (let ((subj (make-new #j:Rx:Subject)))
        (setf (oget *moren-rx-subjects* (concat "$" (string name))) subj)
        (funcall ((oget subj "subscribe" "bind") subj listener)) ))

(export '(mordev::rx-listen))

;;; rx emiter
;;;
;;; (mordev:rx-emit :err '"error")
;;;
(defun rx-emit (name arg)
    (let ((subj))
        (setq subj (oget *moren-rx-subjects* (concat "$" (string name))))
        (funcall ((oget subj "onNext" "bind") subj arg))  ))

(export '(mordev::rx-emit))


;;; emitter dispose
(defun rx-dispose (name))

(export '(mordev::rx-dispose))


;;; Full reset jqconsole command

;;; external interface for reset console command
;;; => (moren:jqreset)
;;;
(defun jqreset ()
    ;; full jq reset
    (#j:jqconsole:Reset)
    ;; ressurect jq bracket matching
    (#j:jqconsole:RegisterMatching "(" ")" "parents")
    ;; restart repl
    (rx-emit :repl-toplevel t)
    (values-list nil))

(export '(mordev::jqreset))


;;;
;;; Shadow JQ-console history
;;; console history stored in localStorage
;;;  does not match the entries in the jqconsole  dom structure
;;;


;;;
;;; get repl history from localStorage and place to array
;;;
;;; (moren:explore-repl-history)
;;; => History has 90 items
;;;
(export '(mordev::explore-repl-history))

(defun explore-repl-history ()
    (setq *repl-history
          (map 'vector (lambda (x) (js-to-lisp x)) #j:jqconsole:history))
    (format t "History has ~a items~%" (length *repl-history))
    (values))


;;;
;;; look repl history from to items
;;;
;;;     (moren:look-repl-history 5 10)
;;;     => items from 5 till 10
;;;
;;;     (moren:look-repl-history)
;;;     => all items
;;;
;;;     (moren:look-repl-history 10)
;;;     => items from 10 till end
;;;
(export '(mordev::look-repl-history))
(defun look-repl-history (&optional (start 0) (end 5))
    (let ((lh (length *repl-history))
          (num start)
          (last end))
        (if (>= end lh)
            (setq last (1- lh)))
        (tagbody fsm
         next
           (format t "~a: ~a~%" num (aref *repl-history num))
           (setq num (1+ num))
           (if (<= num last) (go next))
         stop)
        (values-list nil)))



;;;
;;; take repl history item
;;;
;;; if  lazily flipping long history by with by keystroke, just type
;;;    (moren:take-repl-history-item 2 or other number)
;;;
;;;    (moren:take-repl-history-item 2)<enter>
;;;    <enter>
;;;
(export '(mordev::take-repl-history-item))
(defun take-repl-history-item (num)
    (let ((state #j:jqconsole:state))
        ;; switch jqconsole state to input
        (setf #j:jqconsole:state 0)
        ;; substitute hist item as repl input string
        (#j:jqconsole:SetPromptText (aref *repl-history num))
        ;; restore state
        (setf #j:jqconsole:state state)
        ;; wait enter press
        (values) ))

;;;
;;; dump repl history to file
;;;
;;; (mordev:dump-repl-history "/workplace/repl"

(defun sh-glue ()
    (apply #'concat
           (map 'list (lambda (x) (concat x #\newline))
                #j:jqconsole:history)))

;;;(defparameter *repl-hist-pathname-template* "repl-history/devrepl-")

(defun sh-uniqid-repl-dump()
    (concat *repl-hist-pathname-template* (get-internal-real-time) ".txt"))

(defun sh-open-stream-output (name)
    (#j:Fs:createWriteStream name))

(defun sh-stream-write (stream str)
    (funcall ((oget stream "write" "bind") stream str)))

(defun sh-close-stream (stream)
    (funcall ((oget stream "end" "bind") stream)))

(export '(mordev::dump-repl-history))
(defun dump-repl-history (&optional (fname (sh-uniqid-repl-dump)))
    (let ((stream (sh-open-stream-output fname)))
        (sh-stream-write stream (sh-glue))
        (sh-close-stream stream)))


;;;    DEV REPL

;;; *standard-output*
;;;
;;; assign global variable *standard-output*
;;; as stream

(defun %write-string (string &optional (escape t))
    (#j:jqconsole:Write string "jqconsole-output" "" escape))


(defun %moren-standard-output-up ()
    (setq *standard-output*
          (vector 'stream
                  (lambda (ch) (%write-string (string ch)))
                  (lambda (string) (%write-string string)))) )

(defun %mordev-standard-output ()
    (setq *mordev-standard-output*
          (vector 'stream
                  (lambda (char) (rx-emit :char-out (string char))
                      (values-list nil))
                  (lambda (string) (rx-emit :string-out string)
                      (values-list nil) ))))

(defun %mordev-standard-error ()
    (setq *mordev-standard-error*
          (vector 'stream
                  (lambda (char) (rx-emit :err-char-out (string char))
                      (values-list nil))
                  (lambda (string) (rx-emit :err-string-out string)
                      (values-list nil) ))))


;;; rx-emit :char-out
(defun %char-out-fn (char)
    (%write-string (string char)))

;;; rx-emit :string-out
(defun %string-out-fn (string)
    (%write-string string))


;;; rx-emit :err-char-out
(defun %err-char-out-fn (char)
    (%write-err-string (string char)))

;;; rx-emit :err-string-out
(defun %err-string-out-fn (string)
    (%write-err-string string))


(defun %write-err-string (string)
    (#j:jqconsole:Write string "jqconsole-error"))


(defun %repl-print-output (result)
    (dolist (x result)
        (#j:jqconsole:Write (concat (write-to-string x) #\Newline) "jqconsole-return")))


;;; *standard-error*
(defun %repl-print-error (x)
    (#j:jqconsole:Write (concat x #\Newline) "jqconsole-error"))





;;;
;;; Repl history
;;;

;;; call everytime
(defun %repl-save-history (ignore)
    (let ((cutcount (- #j:jqconsole:history:length *jq-history-maxlen*)))
        (if (minusp cutcount)
            (#j:localStorage:setItem "jqhist"
                                     (#j:JSON:stringify (#j:jqconsole:GetHistory)))
            (#j:localStorage:setItem "jqhist"
                                     (#j:JSON:stringify
                                      (funcall
                                       ((oget #j:jqconsole:history "slice" "bind")
                                        #j:jqconsole:history
                                        cutcount)))))))

;;; call once at repl awake
(defun %repl-load-history ()
    (let ((raw (#j:localStorage:getItem "jqhist"))
          (hv)
          (cutcount))
        (unless (jscl::js-null-p raw)
            (setq hv (#j:JSON:parse raw))
            (setq raw nil)
            (setq cutcount (- (length hv) *jq-history-maxlen*))
            (if (minusp cutcount)
                (#j:jqconsole:SetHistory hv)
                (#j:jqconsole:SetHistory (funcall ((oget hv "slice" "bind") hv cutcount))) )
            (setq hv nil) ) ))

;;;
;;; Borrowed from original jscl/repl-web/repl.lisp
;;;
;;; Decides wheater the input the user has entered is completed or we
;;; should accept one more line.
(defun %indent-level (string)
    (let ((i 0)
          (stringp nil)
          (s (length string))
          (depth 0))

        (while (< i s)
            (cond
              (stringp
               (case (char string i)
                 (#\\
                  (incf i))
                 (#\"
                  (setq stringp nil)
                  (decf depth))))
              (t
               (case (char string i)
                 (#\( (incf depth))
                 (#\) (decf depth))
                 (#\"
                  (incf depth)
                  (setq stringp t)))))
            (incf i))

        (if (and (zerop depth))
            nil
            ;; We should use something based on DEPTH in order to make
            ;; edition nice, but the behaviour is a bit weird with
            ;; jqconsole.
            0)))


(defun jq-matching ()
    (#j:jqconsole:RegisterMatching "(" ")" "parents") )


;;; repl-eval handler
;;; moren:rx-emit :repl-eval

(defun %repl-eval (input)
    (%js-try
     (handler-case
         (let ((form (read-from-string input)))
             (dolist (x (multiple-value-list (jscl::eval-interactive form)))
                 ;;(rx-emit :out x)
                 (format *mordev-standard-output* "~a~%" x)))
       (error (msg)
           (format *mordev-standard-error* "ERROR: ~a~%" (_errmsg-expand msg))))
     (catch (err)
         (format *mordev-standard-error* "ERROR: ~a~%"
                 (or
                  (oget err "message") (_errmsg-expand err)))))
    (values-list nil) )




;;; repl toplevel
;;; mordev:rx-emit :repl-toplevel

(defun date/component (obj key)
    (funcall ((oget obj key "bind") obj)))

(defun date/make-prompt ()
    (let ((dt (make-new #j:Date)))
        (concat ""
                (date/component dt "getFullYear") "/"
                (1+ (date/component dt "getMonth")) "/"
                (date/component dt "getDate") " "
                (date/component dt "getHours") ":"
                (date/component dt "getMinutes") ":"
                (date/component dt "getSeconds") " "
                (package-name *package*) ">")))

(defun %repl ()
    ;;(#j:jqconsole:Write (concat (package-name *package*) "> ") "jqconsole-prompt")
    (#j:jqconsole:Write (date/make-prompt) "jqconsole-prompt")
    (flet ((repl-read (input)
               (when (> (length input) 0)
                   ;; ignore empty string
                   ;; without End of file error condition
                   (rx-emit :repl-eval input)
                   (rx-emit :history t))
               (rx-emit :repl-toplevel t)))
        (#j:jqconsole:Prompt t #'repl-read #'%indent-level)))




;;;;; EOF
