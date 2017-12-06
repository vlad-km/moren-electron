;;; -*- mode:lisp; coding:utf-8  -*-

;;;
;;; This file is part of the DASGEN package
;;; Copyright © 2017 Vladimir Mezentsev
;;;
;;; DASGEN - simple implementation of Generic function for JSCL.
;;;
;;; DASGEN is free software: you can redistribute it and/or modify it under
;;; the terms of the GNU General  Public License as published by the Free
;;; Software Foundation,  either version  3 of the  License, or  (at your
;;; option) any later version.
;;;
;;; DASGEN is distributed  in the hope that it will  be useful, but WITHOUT
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

(in-package :das)

(defun das/structure-pred (x)
    (if (storage-vector-p x)
        (let ((kids (storage-vector-ref x 0)))
            (if (eq (car kids) 'structure)
                kids))))

(export '(das::das/structure-pred))

(export '(das::das/structure-type-kid))
(defun das/structure-type-kid (x)
    (cdr (storage-vector-ref x 0)))


(defmacro with-collect (&body body)
    (let ((head (gensym))
          (tail (gensym)))
        `(let* ((,head (cons 'sentinel nil))
                (,tail ,head))
             (flet ((collect (x)
                        (rplacd ,tail (cons x nil))
                        (setq ,tail (cdr ,tail))
                        x))
                 ,@body)
             (cdr ,head))))



;;(export '(das!structure))
(defmacro structure (name-and-options &rest slots)
    (let* ((name-and-options (ensure-list name-and-options))
           (name (first name-and-options))
           (name-string (symbol-name name))
           (options (rest name-and-options))
           (type-definition)
           (lform)
           (conc-name
             (let* ((form (assoc :conc-name options))
                    (concname (if form
                                  (if (second form)
                                      (symbol-name (second form))
                                      (concat name-string "-") )
                                  (concat name-string "-"))))
                 concname))
           (constructor (assoc :constructor options))
           (constructor-form (lambda ()
                                 (if constructor
                                     (values (second constructor) (third constructor))
                                     (values nil nil))) )
           (predicate (if (assoc :predicate options)
                          (second (assoc :predicate options))
                          (intern (concat name-string "-P"))))
           (copier (if (assoc :copier options)
                       (second (assoc :copier options))
                       (intern (concat "COPY-" name-string)))))
        (multiple-value-bind (construct-name args) (funcall constructor-form)
            (if construct-name
                (setq constructor construct-name)
                (setq constructor (intern (concat "MAKE-" name-string))))
            (if args
                (setq lform '&optional)
                (setq lform '&key)))
        (let* ((slot-descriptions
                 (mapcar (lambda (sd)
                             (cond
                               ((symbolp sd)
                                (list sd))
                               ((and (listp sd) (car sd) (null (cddr sd)))
                                sd)
                               (t
                                (error "Bad slot description `~S'." sd))))
                         slots))
               constructor-expansion
               predicate-expansion
               copier-expansion)
            (when constructor
                (setq constructor-expansion
                      `(defun ,constructor (,lform ,@slot-descriptions)
                           (vector (cons 'structure ',name) ,@(mapcar #'car slot-descriptions)))))
            (when predicate
                (setq predicate-expansion
                      `(defun ,predicate (x)
                           (eq (cdr (das/structure-pred x)) ',name))))
            (when copier
                (setq copier-expansion
                      `(defun ,copier (x)
                           ;;(unless (,predicate x)
                           ;;    (error "The object `~S' is not of type `~S'" x ,name-string))
                           (let ((copy (list-to-vector
                                        (copy-list (vector-to-list x)))))
                               copy))))
            `(progn
                 ,constructor-expansion
                 ,predicate-expansion
                 ,copier-expansion
                 ,type-definition
                 ,@(with-collect
                       (let ((index 1))
                           (dolist (slot slot-descriptions)
                               (let* ((name (car slot))
                                      (accessor-name (intern (concat conc-name (string name))))
                                      (setter-name (intern (concat "SET-" conc-name (string name)))))
                                   (collect
                                       `(defun ,setter-name (x value)
                                            ;;(unless (,predicate x)
                                            ;;    (error "The object `~S' is not of type `~S'" x ,name-string))
                                            (storage-vector-set x ,index value)))
                                   (collect
                                       `(defun ,accessor-name (x)
                                            ;;(unless (,predicate x)
                                            ;;    (error "The object `~S' is not of type `~S'" x ,name-string))
                                            (storage-vector-ref x ,index)))
                                   (collect
                                       `(define-setf-expander ,accessor-name (x)
                                            (let ((object (gensym))
                                                  (new-value (gensym)))
                                                (values (list object)
                                                        (list x)
                                                        (list new-value)
                                                        `(storage-vector-set ,object ,',index ,new-value)
                                                        `(storage-vector-ref ,object ,',index)))))
                                   (setq index (1+ index))   ))))
                 ',name) )))


(export '(das::structure))

(in-package :cl-user)
;;; EOF
