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


(in-package :lores)


(defvar *sysq* '())

;;;
(defun sysq/job-queue (pdu)
    (if pdu (lores/mess-0 "Sysq: ~a~%" (def-unit-depend-name pdu))
        (lores/mess-0 "Sysq: empty~%"))
    (push pdu *sysq*))


(defvar *current-depend* nil)

;;; renew dependens table
(defun depend/renew ()
    (setq *current-depend*
          (make-hash-table :test #'equal)))

;;; mark new dependence
(defun depend/mark (name)
    (setf (gethash name *current-depend*) t))

;;; exists
(defun depend/exists (name)
    (gethash name *current-depend*))


;;;
(defun lores/flatten-top-depends (dsl)
    ;;(print (list 'flatten dsl))
    (mapcan #'(lambda (sysname)
                  (nconc (list sysname)
                         (lores/flatten-top-depends
                          (def-sys-top-depends (gethash (sdfn sysname) *defsystems*) ))))
            dsl))


;;;
;;; check system dependences
;;;
(defun check-dependences (sdf)
    (depend/renew)
    (setq *sysq* nil)
    (dolist (x (def-sys-components sdf))
        (qload/check-dependence x)))


(defun check-dependences (sdf)
    (let ((topcomponents '())
          (ds)
          (topdepnames (lores/flatten-top-depends (def-sys-top-depends sdf))))
        ;;(print (list 'top-names topdepnames))
        (when topdepnames
            ;; if exists top-components
            ;; get all
            (dolist (sname topdepnames)
                (setq ds (gethash (sdfn sname) *defsystems*))
                ;;(print (list 'get-components-for sname (def-sys-name ds) (def-sys-components ds)))
                (push (def-sys-components ds) topcomponents)))
        ;;(print (list 'topcomponents (length topcomponents)))
        (depend/renew)
        (setq *sysq* nil)

        ;; check top depend components
        (dolist (from-sys topcomponents)
            (dolist (x from-sys)
                ;;(print (list 'check x))
                (qload/check-dependence x)))

        ;; check target system components
        (dolist (x (def-sys-components sdf))
            ;;(print (list 'check x))
            (qload/check-dependence x))))



(das:generic qload/check-dependence (pdu))

(das:method qload/check-dependence (pdu) (error "wtf ~a???" pdu))

;; for module

#|
(das:method qload/check-dependence
            ((pdu def-module))
            (let ((src (def-module-units pdu))
                  (md (def-module-depends pdu))
                  (qall))
                ;; firstly check module dependences
                (if md
                    (dolist (name-from md)
                        ;;(print (list 'check-dep-mod (def-module-name pdu) 'for name-from (depend/exists name-from)))
                        (if (depend/exists name-from)
                            (setq qall t))))
                (if qall
                    ;; enqueue all module
                    (qload/enqueue-all-module src)
                    ;; or check dependences for each module units
                    (progn
                        (dolist (x src)
                            (qload/check-dependence x))))))
|#

(das:method qload/check-dependence
            ((pdu def-module))
            (let ((src (def-module-units pdu))
                  (md (def-module-depends pdu))
                  (qall))
                (cond (*force*
                       (qload/enqueue-all-module src))
                      (t
                       ;; firstly check module dependences
                       (if md
                           (dolist (name-from md)
                               ;;(print (list 'check-dep-mod (def-module-name pdu) 'for name-from (depend/exists name-from)))
                               (if (depend/exists name-from)
                                   (setq qall t))))
                       (if qall
                           ;; enqueue all module
                           (qload/enqueue-all-module src)
                           ;; or check dependences for each module units
                           (progn
                               (dolist (x src)
                                   (qload/check-dependence x))))))))



;;; system queue
(defun qload/enqueue-all-module (lst)
    (dolist (x lst)
        (qload/job-queue x)))

(das:generic qload/job-queue (pdu))

(das:method qload/job-queue (pdu) (error "wtf jobq ?"))

(das:method qload/job-queue ((pdu def-unit))
            (sysq/job-queue pdu))

(das:method qload/job-queue ((pdu def-module))
            (dolist (x (def-module-units pdu))
                (qload/job-queue x)))

;;;
;;; :module src
;;; :file   argon
;;;   depend-name src/argon
;;;
;;; none module
;;; :file argon
;;;   depend-name argon
;;;
;;; :module src
;;;   :module drv
;;;     :file dev
;;;     depend-name src/drv/dev
;;;

;;; :todo: depricate
(defun qload/make-depend-name (name)
    (if *dsp-current-module-name*
        (let ((mq (reverse *dsp-current-module-name*))
              (res)
              (depname))
            (dolist (x mq)
                (push (concat x "/") res))
            (setq depname (concat (apply #'concat (rest (reverse res))) name))
            depname )
        name))


;;; check dependence for file
(das:method qload/check-dependence
            ((pdu def-unit))
            (let ((already))
                ;; firstly *force*
                (cond (*force*
                       (sysq/job-queue pdu))
                      (t
                       ;; secondly check dependences list
                       (dolist (name-from (def-unit-depends pdu))
                           (if (depend/exists name-from)
                               (progn
                                   (setq already t)
                                   (sysq/job-queue pdu)
                                   (depend/mark (def-unit-depend-name pdu))) ))
                       ;; check modify time
                       (unless already
                           (when (qload/check-modify pdu)
                               (depend/mark (def-unit-depend-name pdu))
                               (sysq/job-queue pdu)))))))


;;; check file modify time
#|
(defun qload/check-modify (pdu)
    (let* ((stat (lores/fs-stat (def-unit-pathname pdu) ))
           (datemod (oget stat "mtime"))
           (modtime (funcall ((oget datemod "getTime" "bind") datemod)))
           (need) )
        ;; file was modify
        (when (> modtime (def-unit-modtime pdu))
            ;; store last mtime from stat
            (set-def-unit-modtime pdu modtime)
            ;; set need comilation flag
            (setq need t))
        need ))
|#

(defun qload/check-modify (pdu)
    (let* ((modtime (lores/fs-get-modify-time (def-unit-pathname pdu)))
           (need) )
        ;; file was modify
        (when (> modtime (def-unit-modtime pdu))
            ;; store last mtime from stat
            (set-def-unit-modtime pdu modtime)
            ;; set need comilation flag
            (setq need t))
        need ))

;;; sync modtime on compilation phase
(defun qload/sync-modtime (pdu)
    (let ((modtime (lores/fs-get-modify-time (def-unit-pathname pdu)) ))
        (set-def-unit-modtime pdu modtime)))


;;; EOF
