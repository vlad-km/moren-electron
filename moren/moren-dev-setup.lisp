;;; -*- mode:lisp;  coding:utf-8 -*-

;;;
;;; This file is part of the MOREN environment
;;; Moren development console
;;; Setup dev console
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

;;;
;;;                             MOREN NAMESPACE
;;;    Setup console
;;;

(in-package :mordev)


;;; event handlers setup
(defun %%all-emitters-up ()
    (rx-listen :out #'%repl-print-output)
    (rx-listen :err #'%repl-print-error)
    (rx-listen :char-out #'%char-out-fn)
    (rx-listen :string-out #'%string-out-fn)
    (rx-listen :err-char-out #'%err-char-out-fn)
    (rx-listen :err-string-out #'%err-string-out-fn)
    (rx-listen :history #'%repl-save-history)
    (rx-listen :repl-eval #'%repl-eval)
    (rx-listen :repl-toplevel (lambda (ignore) (%repl))) )


(defun %dev-console-header ()
    (electron:set-app-title
     (concat
      "MOREN Environment Development console "
      (lisp-implementation-type) " "
      (lisp-implementation-version) " "
      (jscl::compilation-notice) )))

(defun jq-console-dom-check ()
    (if (js-null-p (dom:get-element-by-id "moren-dev-repl-id"))
        (dom:mount dom:*body*
                   (html:div :id "moren-dev-repl-id")) ))

(defun jq-console-setup ()
    (let ((reload (if #j:jqconsole t nil)))
        (let ((jq (#j:$ "#moren-dev-repl-id")))
            (setf #j:jqconsole (funcall ((oget jq "jqconsole" "bind") jq  "" "")))
            ;;(#j:console:log "init console. Reload " reload)
            (if reload (reload-jq-console))
            (jq-matching))))

(defun reload-jq-console ()
    (let* ((container #j:jqconsole:$container)
           (parent (aref (funcall ((oget container "parent" "bind") container)) 0))
           (console-div)
           (console-count (oget parent "childElementCount")))
        (when (> console-count 1)
            ;;(#j:console:log "Reload " container parent console-count)
            (setq console-div (aref (oget parent "children") 0))
            ;;(#j:console:log "Delete console " console-div)
            (funcall ((oget console-div "remove" "bind") console-div)))))



;;; repl boot
(defun %moren-awake ()
    (let ((jq))
        ;; Electron decorate
        ;;    setup title
        ;;    hide menu bar
        (%dev-console-header)
        (electron:set-autohide-menubar)
        (electron:set-Menu-Bar-Visibility nil)
        ;; repl up
        ;;(setq jq (#j:$ "#moren-dev-repl-id"))
        ;;(setf #j:jqconsole (funcall ((oget jq "jqconsole" "bind") jq  "" "")))
        ;;(jq-matching)
        (jq-console-dom-check)
        (jq-console-setup)
        (%repl-load-history)
        ;;(%moren-standard-output-up)
        (%mordev-standard-output)
        (%mordev-standard-error)
        (setq *standard-output* *mordev-standard-output*)
        (%%all-emitters-up)
        (%mordev-keyboard-setup)
        (#j:window:addEventListener "load"
                                    (lambda (&rest args) (%repl)))))


(in-package :cl-user)

;;;;; EOF
