;;; -*- mode:lisp; coding:utf-8  -*-


;;;
;;; This file is part of the MOREN environment
;;; Moren development console
;;; Copyright © 2017 Vladimir Mezentsev


(in-package :mordev)

;;; Moren configurator


;;; get config variable from registry
(export '(moren/get-config))
(defun moren/get-config (key)
    (let ((raw (#j:localStorage:getItem key)))
        (if (js-null-p raw)
            nil
            (read-from-string raw))))


;;; store config varible to registry
;;; (moren/set-config "lores-central-register" "./sdf")
;;; (concat (moren/get-config "lores-central-register") "/" name)
;;;
(export '(moren/set-config))
(defun moren/set-config (key value)
    (#j:localStorage:setItem key
                             (write-to-string value)))

;;; registry initialize
;;; first spawn moren
(let ((config-template
        ;; moren config template
        ;; for first start
        (list
         (list "lores-sdf-repository" "./sdf")
         (list "moren-boot" (list "./sys/lestrade" "./sys/lores")) )))

    (defun moren/check-firstly ()
        (unless (moren/get-config "moren-alive-timestamp")
            (moren/set-config  "moren-alive-timestamp" (get-internal-real-time))
            (dolist (x config-template)
                (moren/set-config (car x) (cadr x))))))


(defun moren/set-boot-list (lst)
    (moren/set-config "moren-boot" lst))


(defun moren/boot-from (path)
    (let ((exists (#j:Fs:existsSync path)))
        (cond (exists
               (format t "boot require ~a~%" path)
               (time (require path)))
              (t
               (format t "boot package ~a not exists~%" path)))))

(defun moren/boot-bundles ()
    (#j:console:log "boot-bundles" (find-package :mordev))
    (dolist (path (moren/get-config "moren-boot"))
        (moren/boot-from path)))

(defun moren/boot-bundles ()
    (#j:console:log "boot-bundles" (find-package :mordev))
    (%js-try
     (progn
         (dolist (path (moren/get-config "moren-boot"))
             (moren/boot-from path)))
     (catch (msg)
         (#j:console:log "что-то пошло не так" msg))))




(in-package :cl-user)

;;; EOF
