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


;;; all generic store
(defvar *das-gfd* (make-hash-table :test #'equal))

(defun das/store-gfd (name gf)
    (setf (gethash name *das-gfd*) gf))


;;; return gf descriptor from global table
;;; or error
;;; fast
(defun das/gf-get-for (name)
    (let ((g (gethash name *das-gfd*)))
        (if g
            g
            (error "Generic ~a not found" name))))



;;;
;;; DAS GF descriptor
;;;

;;; make descriptor as vector with type-kid and data store
(defun make-das-gf (&key name arglist lambda-len lambda-mask  mask-len rest-count
                      optional-count key-count specialite methods)
    (vector (cons 'structure 'das-gf)
            name
            arglist
            lambda-len
            lambda-mask
            mask-len
            rest-count
            optional-count
            key-count
            specialite
            methods))


(defmacro dasgen-proto-generic (name location)
    (let* ((getter (intern (symbol-name name)))
           (setter (intern (concat "SET-" (string getter)))))
        `(progn
             (defun ,getter (obj)
                 (storage-vector-ref obj ,location))

             (defun ,setter (obj value)
                 (storage-vector-set obj ,location value))
             (defsetf ,getter ,setter) )))


;;;; accessor's read/write
(dasgen-proto-generic das-gf-name 1)
(dasgen-proto-generic das-gf-arglist 2)
(dasgen-proto-generic das-gf-lambda-len 3)
(dasgen-proto-generic das-gf-lambda-mask 4)
(dasgen-proto-generic das-gf-mask-len 5)
(dasgen-proto-generic das-gf-rest-count 6)
(dasgen-proto-generic das-gf-optional-count 7)
(dasgen-proto-generic das-gf-key-count 8)
(dasgen-proto-generic das-gf-specialite 9)
(dasgen-proto-generic das-gf-methods 10)



;;;
;;; generic as function
;;;
(defun make-das-gf-method (&key name lambda-len lambda-mask mask-len
                             lambda-vars rest-count  optional-count  key-count fn)
    (vector (cons 'structure 'das-gf-method)
            name
            lambda-len
            lambda-mask
            mask-len
            lambda-vars
            rest-count
            optional-count
            key-count
            fn
            nil
            nil
            nil
            nil))

;;; accessor's
(dasgen-proto-generic das-gf-method-name 1)
(dasgen-proto-generic das-gf-method-lambda-len 2)
(dasgen-proto-generic das-gf-method-lambda-mask 3)
(dasgen-proto-generic das-gf-method-mask-len 4)
(dasgen-proto-generic das-gf-method-lambda-vars 5)
(dasgen-proto-generic das-gf-method-rest-count 6)
(dasgen-proto-generic das-gf-method-optional-count 7)
(dasgen-proto-generic das-gf-method-key-count 8)
(dasgen-proto-generic das-gf-method-fn 9)

(dasgen-proto-generic das-gf-method-primary 10)
(dasgen-proto-generic das-gf-method-around 11)
(dasgen-proto-generic das-gf-method-before 12)
(dasgen-proto-generic das-gf-method-after  13)


(defparameter *das-gf-mask-stop-tokens* '(&rest &optional &key))

;;;
;;; todo: bad name. rename das/gf-lambda-counter
;;;
(defun das/lambda-counter (lambda-list)
    (let ((count 0))
        (dolist (slot lambda-list)
            (cond ((atomp slot)
                   (if (find slot *das-gf-mask-stop-tokens*)
                       (return-from das/lambda-counter count)
                       (incf count)) )
                  (t (error (concat "Dont recognized expr " slot))))
            count)))

;;;
;;; very simple specialize parser
;;;
(defun das/gf-mask-spec-parser-type (expr)
    (if (symbolp expr)
        (return-from das/gf-mask-spec-parser-type
            (das-typedef-type (das/find-typedef expr)))
        (error "Invalid typename ~a" expr)))

;;;
;;; todo: bad name. rename das/gf-lambda-mask
;;;   return mask count args arglist without typespec

(defun das/lambda-mask (lambda-list)
    (let ((count 0)
          (reqvars)
          (mask '()))
        (dolist (slot lambda-list)
            ;; Symbol
            (cond ((atom slot)
                   ;; If in stop-list, returned
                   (if (find slot *das-gf-mask-stop-tokens*)
                       (return-from das/lambda-mask (values (reverse mask) count (reverse reqvars)))
                       ;; else mark mask
                       (progn
                           (push slot reqvars)
                           (push t mask)
                           (incf count))) )
                  ;; cons
                  ((consp slot)
                   (case (length slot)
                     ;; May be nil
                     ((0 1)
                      (error "Cant recognize ~a" slot)
                      )
                     ;; or class specializer
                     ;;    type specializer (var list|integer|float)
                     (2 (let ((var (car slot))
                              (type (cadr slot)))
                            ;;(print (list 'mask slot (car slot) (cadr slot)))
                            (setq type (das/gf-mask-spec-parser-type type))
                            (push var reqvars)
                            (incf count)
                            (push type mask) ))
                     ;; other conses dont implemented
                     (otherwise (error  "Specializers form ~a not implemented~%" slot)))
                   ) ))
        (values (reverse mask) count (reverse reqvars))))

;;;
;;; optionals counter
;;;

(defun das/gf-optionals-counter (sub-lambda-list)
    (let ((count 0))
        (dolist (slot sub-lambda-list)
            (if (find slot *das-gf-mask-stop-tokens*)
                (return-from das/gf-optionals-counter count))
            (setq count (1+ count)) )
        count))


(defun das/gf-find-optional-args (lambda-list)
    (let* ((len (length lambda-list))
           (rest (position '&rest lambda-list))
           (optional  (position '&optional lambda-list))
           (key  (position '&key lambda-list)))
        (labels ((counter (pos)
                     (cond (pos
                            (das/gf-optionals-counter (subseq lambda-list (1+ pos) len)))
                           (t 0))))
            (values (counter rest) (counter optional) (counter key)))))

;;;
;;; das/gf creator
;;;

;;; with remove specializers
(defun das/gf-parse-lambda-list (lambda-list)
    (multiple-value-bind
          (mask lmask vars)
        (das/lambda-mask lambda-list)
        (multiple-value-bind
              (rest optional key)
            (das/gf-find-optional-args lambda-list)
            (list
             :lambda-len (length lambda-list)
             :lambda-mask mask
             :mask-len lmask
             :lambda-vars (if (= lmask (length lambda-list))
                              vars
                              (append vars (subseq lambda-list lmask)))
             :rest-count rest
             :optional-count optional
             :key-count key))))

;;; version for type specializers
(defun das/gf-parse-lambda-list (lambda-list)
    (multiple-value-bind
          (mask lmask vars)
        (das/lambda-mask lambda-list)
        (multiple-value-bind
              (rest optional key)
            (das/gf-find-optional-args lambda-list)
            (list
             :lambda-len (length lambda-list)
             :lambda-mask mask
             :mask-len lmask
             :lambda-vars (if (= lmask (length lambda-list))
                              vars
                              (append vars (subseq lambda-list lmask)))
             :rest-count rest
             :optional-count optional
             :key-count key))))



;;;
;;; Create gf descriptor from  lambda list
;;; Called from DEF!GENERIC
;;; Used das/lambda-mask
;;;      das/gf-find-optional-args
;;;
(defun das/gf-create (name lambda-list)
    (let ((gf))
        (multiple-value-bind (mask lmask vars) (das/lambda-mask lambda-list)
            (multiple-value-bind (rest optional key)
                (das/gf-find-optional-args lambda-list)
                (setq gf (make-das-gf
                          :name name
                          :arglist lambda-list
                          :lambda-len (length lambda-list)
                          :lambda-mask mask
                          :mask-len lmask
                          :rest-count rest
                          :optional-count optional
                          :key-count key))))
        gf))



;;;
;;; DAS/GF ROOT METHOD
;;;

(defun %every-identity (seq)
    (dolist (elt seq)
        (unless (identity elt)
            (return-from %every-identity nil)))
    t)

(defun %type-value-compare (vals mask)
    (let ((res))
        (dotimes (idx (length vals))
            (push (das/typep (nth idx vals) (nth idx mask)) res ))
        (reverse res)))

(defun das/root-dgf (gfname &rest vars)
    (let* ((gf (das/gf-get-for gfname))
           (mhd)
           (args)
           (argvals))
        (labels ((invoke-by (method-mask)
                     (apply (das-gf-method-fn (gethash method-mask mhd)) args ) ))
            ;; prepare methods and args for invoke call
            ;; get methods table
            (setq mhd (das-gf-methods gf))
            (setq args (first vars))
            (setq argvals (subseq args 0 (das-gf-mask-len gf)))
            ;; search method by mask
            (dolist (mask (das-gf-specialite gf))
                (if (%every-identity
                     (%type-value-compare argvals mask) )
                    (return-from das/root-dgf (invoke-by mask)) )))))

;;;
;;; DAS!GENERIC MACRO
;;;

(defmacro generic (name (&rest vars))
    (let ((gf (das/gf-create name vars ))
          (fname)
          (fn (intern (symbol-name (gensym (concat  "DGF-" (princ-to-string name)))))) )
        (setq fname (intern (symbol-name `,name)))
        `(progn
             ;; Define gf accessor with uniq name DGF-generic-name--bla-bla-bla
             (defun ,fn (&rest args) (das/root-dgf ',fname args))
             ;; Set function symbol
             (fset ',fname (fdefinition ',fn))
             ;; Store descriptor to global table
             (das/store-gfd ',fname ',gf)
             ',fname)
        ))

(export '(das::generic))


;;;
;;; check method lambda list
;;; only for DEF!METHOD
;;;
;;; lambda check list
;;;    1 - count required lambda arguments
;;;    2 - count optional lambda arguments
;;;    3 - count rest arguments
;;;    4 - count key arguments
;;;
;;; Remove type specializers from required arguments
;;;
;;; Return prop list with  method lambda list parameters
;;;


(defun das/gf-check-lambda  (gf arglist)
    (let ((method-lambda (das/gf-parse-lambda-list arglist)))
        (if (or (/= (das-gf-rest-count gf)
                    (getf method-lambda :rest-count))
                (/= (das-gf-optional-count gf)
                    (getf method-lambda :optional-count))
                (/= (das-gf-key-count gf)
                    (getf method-lambda :key-count))
                (/= (das-gf-mask-len gf)
                    (getf method-lambda :mask-len)))
            (error (format nil
                           "Method lambda list: ~a~%      ~a~%Generic lambda list: ~a~%       ~a~%"
                           (getf method-lambda :lambda-mask)
                           arglist
                           (das-gf-lambda-mask gf)
                           (das-gf-arglist gf))))
        method-lambda) )


;;;
;;; add new method
;;;


;;;
;;; Sort function for specialite
;;;
;;; Use:
;;;    at clos/gf-add-method
;;;    most specified method mask must be first
;;;    in method mask list for clos/gf-root
;;; <= ((t integer t) (t integer integer) (t t t))
;;; => ((t integer integer) (t integer t) (t t t))
;;;

(defun das/sort-method-mask-comparator (x y)
    (let* ((mixt (mapcar (lambda (xx yy) (cons xx yy)) x y ))
           (winx (count-if (lambda (pair)
                               (das/subtypep (car pair) (cdr pair))) mixt))
           (winy (count-if (lambda (pair)
                               (das/subtypep (cdr pair) (car pair))) mixt)))
        (cond ((< winx winy) 1)
              ((= winx winy) 0)
              (t -1))))


;;;
(defun das/gf-sort-specialite (lst)
    (let* ((jarray (list-to-vector lst))
           (sort (lambda (fn)
                     (funcall ((oget jarray "sort" "bind") jarray fn)))))
        (funcall sort #'das/sort-method-mask-comparator)
        (vector-to-list jarray)))


;;;
;;; add new method definition
;;;

(defun das/gf-add-method (gf method-lambda method-body)
    (let* ((md (apply #'make-das-gf-method method-lambda))
           (mht (das-gf-methods gf))
           (hash (getf method-lambda :lambda-mask)) )

        ;; its first call for this generic
        (unless mht
            ;; create mask-method hash table
            (setq mht (make-hash-table :test #'equal))
            (set-das-gf-methods gf mht) )

        ;; update method table and specialite
        (multiple-value-bind (mask ok) (gethash hash mht)
            (if ok
                ;; Method with such a mask already exists
                ;; You just need to change the body function of the method
                ;; specialite list do not change
                (warn "Method ~a redefinition~%" (das-gf-name gf))
                (progn
                    ;; This is a unique mask
                    ;; Remember it in the specialite list and sort the list
                    (push (getf method-lambda :lambda-mask) (das-gf-specialite gf))
                    (set-das-gf-specialite gf (das/gf-sort-specialite (das-gf-specialite gf))) ) ))
        ;; In this place to compile the method body
        ;; For connecting call-next environment
        (set-das-gf-method-fn md method-body)
        ;; Store method descriptor
        ;; key = hash (mask)
        (setf (gethash hash  mht) md )
        (values)))


;;;
;;; DAS!METHOD macro
;;;
(defmacro method (name (&rest arglist) &rest body)
    (let* ((gfname (intern (symbol-name `,name)))
           (method-lambda (das/gf-check-lambda (das/gf-get-for gfname) arglist))
           (arg-list)
           (a!list))
        (setq a!list (getf method-lambda :lambda-vars))
        `(das/gf-add-method
          (das/gf-get-for ',gfname)
          ',method-lambda
          #'(lambda  ,a!list . ,body)) ))

(export '(das::method))


(in-package :cl-user)
;;; EOF
