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

;;;
;;; DAS TYPES
;;; Very simple types system
;;;


;;;
;;; TYpe definition structure
;;;
;;; typedef structure storage-vector release
;;;

;;; constructor

(defun make-das-typedef (&key type supertype predicate class)
    (vector (cons 'structure 'das-typedef) type supertype predicate class))


;;; predicate
(defun das-typedef-p (x)
    (eq (cdr (das/structure-pred x)) 'das-typedef))

;;; accessor's
;;; type
(defun das-typedef-type (x)
    ;;(unless (das-typedef-p x)
    ;;    (error "The object `~S' is not of type `~S'" x "DAS-TYPEDEF"))
    (storage-vector-ref x 1))

;;; supertype
(defun das-typedef-supertype (x)
    ;;(unless (das-typedef-p x)
    ;;    (error "The object `~S' is not of type `~S'" x "DAS-TYPEDEF"))
    (storage-vector-ref x 2))

;;; predicate
(defun das-typedef-predicate (x)
    ;;(unless (das-typedef-p x)
    ;;    (error "The object `~S' is not of type `~S'" x "DAS-TYPEDEF"))
    (storage-vector-ref x 3))

;;; class
(defun das-typedef-class (x)
    ;;(unless (das-typedef-p x)
    ;;    (error "The object `~S' is not of type `~S'" x "DAS-TYPEDEF"))
    (storage-vector-ref x 4))


;;; accessors setf expander

(define-setf-expander das-typedef-type (x)
    (let ((g!object (gensym))
          (g!new-value (gensym)))
        (values (list g!object)
                (list x)
                (list g!new-value)
                `(storage-vector-set ,g!object 1 ,g!new-value)
                `(storage-vector-ref ,g!object 1))))


(define-setf-expander das-typedef-supertype (x)
    (let ((g!object (gensym))
          (g!new-value (gensym)))
        (values (list g!object)
                (list x)
                (list g!new-value)
                `(storage-vector-set ,g!object 2 ,g!new-value)
                `(storage-vector-ref ,g!object 2))))


(define-setf-expander das-typedef-predicate (x)
    (let ((g!object (gensym))
          (g!new-value (gensym)))
        (values (list g!object)
                (list x)
                (list g!new-value)
                `(storage-vector-set ,g!object 3 ,g!new-value)
                `(storage-vector-ref ,g!object 3))))



(define-setf-expander das-typedef-class (x)
    (let ((g!object (gensym))
          (g!new-value (gensym)))
        (values (list g!object)
                (list x)
                (list g!new-value)
                `(storage-vector-set ,g!object 4 ,g!new-value)
                `(storage-vector-ref ,g!object 4))))

;;;
;;; Global type store
;;;
(defvar *das-types* (make-hash-table :test #'equal))


;;;
;;; Store type definition
;;;

(defun def-type (&rest typedef)
    ;;(print (list 'def-type (car typedef) (cadr typedef) (caddr typedef)))
    (setf (gethash (car typedef) *das-types*)
          (make-das-typedef :type (car typedef)
                            :predicate (cadr typedef)
                            :supertype (caddr typedef)
                            :class (cadddr typedef))))

(export '(das::def-type))
(fset 'das/def-type #'def-type)

;;;
;;; Find deftype for symbol type
;;; (das/find-typedef symbol) => das-typedef
;;;

(defun find-typedef (type)
    (let ((ok (gethash type *das-types*)))
        (if ok ok (error "~a not type name" type))))

(export '(das::find-typedef))
(fset 'das/find-typedef #'find-typedef)



;;; DAS TYPES PREDICATE
;;;
;;; ht - hash table
;;; generic form = (hash-table mem fn &others)
;;; properties
;;;    (car ht) = hash-table
;;;    (length ht) = 3
;;;    (cadr ht) = function
;;;

(defun das/hash-table-p (value)
    (and (consp value)
         (eq (car value) 'hash-table)
         (= (length value) 3)
         (functionp (cadr value)) ) )


(defun das/standard-object-p (obj)
    (and (storage-vector-p obj)
         (> (length obj) 0)
         (consp (storage-vector-ref obj 0))
         (= (length (storage-vector-ref obj 0)) 2) ))


(defun das/standard-object-p (obj)
    (and (storage-vector-p obj)
         (> (length obj) 0)
         (consp (storage-vector-ref obj 0))
         (member (car (storage-vector-ref obj 0)) '(structure instance))
         t ))


(defun das/standard-object-type-kid (obj)
    (storage-vector-ref obj 0))


;;; JSCL compile features
;;; numberp ... functionp hasnt function symbol
;;; So, make wrapper's for them

;;;(export '(das/numberp das/characterp das/symbolp das/functionp))

(defun das/numberp (value) (numberp value))
(defun das/characterp (value) (characterp value))
(defun das/symbolp (value) (symbolp value))
(defun das/functionp (value) (functionp value))


;;;
;;; types/classes hierarchy
;;;
;;; t             atom
;;; character      t
;;; function       t
;;; array          t
;;; sequence       t
;;; number         t
;;; symbol         t
;;; vector         array sequence
;;; string         vector
;;; list           sequence
;;; cons           list
;;; null           list
;;; float          number
;;; integer        number
;;; hash-table     t
;;;
;;; standard-object             t
;;; metaobject                  standard-object
;;; specializer                 metaobject
;;; method                      metaobject
;;; slot-definition             metaobject
;;; class                       specializer
;;; standard-class              class
;;; instance                    standard-class
;;; builtin-class               class
;;; structure-class             class
;;; structure                   structure-class
;;; standard-method             method
;;; standard-accessor           standard-method
;;; standard-slot-definition    slot-definition
;;; direct-slot-definition      slot-definition
;;; effective-slot-definition   slot-definition
;;;

(defparameter *das-basic-types*
  '((hash-table das/hash-table-p t)
    (number das/numberp t)
    (integer integerp number)
    (float floatp number)
    (cons consp sequence)
    (sequence sequencep t)
    (list listp cons sequence)
    (vector vectorp  sequence)
    (character das/characterp t)
    (symbol das/symbolp t)
    (keyword keywordp symbol)
    (function das/functionp t)
    (array arrayp t)
    (string stringp vector)
    (atom atom)
    (das das/structure-pred t)
    (null null list)
    (t atom)
    (nil atom null) ))

(map 'nil
     (lambda (typedef)
         (setf (gethash (car typedef) *das-types*)
               (make-das-typedef :type (car typedef)
                                 :predicate (cadr typedef)
                                 :supertype (ensure-list (caddr typedef))
                                 :class (cadddr typedef)))) *das-basic-types*)

;;;
;;; Some das-type-of
;;;
(defun das/type-of (value)
    (unless value
        (return-from das/type-of 'null))
    (cond
      ((null value) 'null)
      ((eql value t) 'boolean)
      ((integerp value) 'integer)
      ((floatp value) 'float)
      ((stringp value) 'string)
      ((functionp value) 'function)
      ((keywordp value) 'keyword)
      ((symbolp value) 'symbol)
      ;;((consp value) 'cons)
      ;;((keywordp value) 'keyword)
      ((characterp value) 'character)
      ;; hash-table
      ((das/hash-table-p value)
       'hash-table)
      ((consp value) 'cons)
      ((das/standard-object-p value)
       (cdr (das/standard-object-type-kid value)))
      ;; (sequence (make-array '(2 2))) => nil
      ;; (sequence (make-array '(1))) => t
      ;; (sequence (vector 0)) => t
      ;; (sequence #()) => t
      ((sequencep value)
       'sequence)
      ;; (vectorp (make-array 1)) => t
      ;; (vectorp (make-array '(1))) => t
      ;; (vectorp (make-array '(1 2))) => nil
      ;; (vectorp (vector 0)) => t
      ;; (vector #()) => t
      ;; unreacable with suuperclass sequence
      ((vectorp value) 'vector)
      ;; (make-array '(2 2))
      ((arrayp value) 'array)
      (t (error "wtf ? ~a" value)) ))

(fset 'type-of #'das/type-of)
(export '(das::type-of))


;;;
;;; class-of
;;;

;;;(export '(das/class-of))

(defun das/class-of (type)
    (das-typedef-class (das/find-typedef type) ))



;;;
;;; typep
;;; typep object type-specifier &optional environment
;;;      => generalized-boolean
;;;
;;; Returns true if object is of the type specified by type-specifier;
;;; otherwise, returns false.
;;;
;;; (das/typep (make-array 0 :element-type 'Ax) 'vector) =>  true
;;; (das/typep 12 'integer) =>  true
;;; (das/typep nil t) =>  true
;;; (das/typep nil nil) =>  false


;;;
;;; typep 11 'integer
;;;       'y 'symbol

(defun das/typep (value type)
    (if (eq type nil)
        (return-from das/typep nil))
    (if (eq type t)
        (return-from das/typep t))
    (if (symbolp type)
        (let ((def (das/find-typedef type))
              (fn))
            (if def
                (if (setq fn (das-typedef-predicate def))
                    (funcall fn value)
                    (error "Invalid typedef ~a" type))
                (error "Cant find typedef ~a" type )))
        (error "Invalid type ~a" type) ))


(fset 'typep #'das/typep)
(export '(das::typep))


;;; all supertypes for type

;;; ihnerit types
(defun %das-inherit-types (supers)
    ;;(print (list '%%inherit supers))
    (mapcan #'(lambda (c)
                  (nconc (list c)
                         (%das-inherit-types
                          (das-typedef-supertype (das/find-typedef c)))))
            supers))

(defun %build-inherit-types (for)
    (%das-inherit-types (das-typedef-supertype (das/find-typedef for))))


;;;
;;; return supertype specializer if type1 is subtype type2
;;; nil if not
;;;
(defun das/subtypep (type1 type2)
    (find type2 (%build-inherit-types type1)))


(fset 'subtypep #'das/subtypep)
(export '(das::subtypep))


(in-package :cl-user)
;;;EOF
