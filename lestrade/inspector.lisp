;;; -*- mode:lisp; coding:utf-8  -*-

;;;
;;;
;;; This file is part of the LESTRADE package.
;;; Object inspector for Moren environment
;;; Copyright © 2017 Vladimir Mezentsev
;;;
;;; LESTRADE is free software: you can redistribute it and/or modify it under
;;; the terms of the GNU General  Public License as published by the Free
;;; Software Foundation,  either version  3 of the  License, or  (at your
;;; option) any later version.
;;;
;;; LESTRADE is distributed  in the hope that it will  be useful, but WITHOUT
;;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;;; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
;;; for more details.
;;;
;;; You should  have received a  copy of  the GNU General  Public License
;;; Version 3 from  <http://www.gnu.org/licenses/>.
;;;



;;; Inspector Lestrade facilities

(in-package :lestrade)


;;; kludge for das type
(das:def-type 'das
    (lambda (obj) (das::das/standard-object-p obj)))

;;; package type predicate
(das:def-type 'package
    (lambda (obj) (packagep obj)))


(das:generic wtf (obj))
(export '(wtf))

(das:generic wtf/print-values (obj))



;;; printer
(defun wtf/values-printer (obj fn)
    (let ((len (length obj))
          (total)
          (last nil))
        (cond ((> len 20) (setq total 10) (setq last (1- len)))
              (t (setq total len)))
        (dotimes (i total)
            (format t "~a: ~s~%" i (funcall fn  i obj)))
        (when last
            (format t "...~%~a: ~s~%" last (funcall fn last obj)))))

;;; generic
(das:method wtf/print-values (obj)
            (format t "Value: ~s~%" obj))

;;; list
(das:method wtf/print-values ((obj list))
            (wtf/values-printer obj
                                (lambda (idx obj) (nth idx obj))))
;;; array
(das:method wtf/print-values ((obj array))
            (wtf/values-printer obj
                                (lambda (idx obj) (aref obj idx))))
;;; string
(das:method wtf/print-values ((obj string))
            (format t "Values: ~S~%" (if (<= (length obj) 100) obj (jstring:substr obj 0 99))))


;;;
;;; Documents
;;; for object, if exists
(defun wtf/documentation (obj type)
    (cond  ((eql type 'function)
            (let ((fn (fdefinition obj)))
                (oget fn "docstring")))
           ((eql type 'variable)
            (oget obj "vardoc"))))


;;;
;;; Lestrade, dumb inspector Lestrade
;;;
;;;    (lestrade:wtf *var*)
;;;    (lestrade:wtf '*var*)
;;;


;;; Any others object whose type is not defined into JSCL or DAS types system
(das:method wtf (obj)
            (let* ((keys (klib:jso-keys obj))
                   (sign (#j:String obj)))
                (format t "Object: ~a~%" sign)
                (when keys
                    (format t "Keys:~%")
                    (wtf keys))
                (values)))

;;; List
(das:method wtf ((obj list))
            (format t "List:~%Length: ~a~%" (length obj))
            (wtf/print-values obj)
            (values))


;;; Symbol
(das:method wtf ((obj symbol))
            (format t "Symbol: ~a~%Package: ~a~%"
                    (symbol-name obj) (package-name (symbol-package obj)))
            (unless (or (eql obj t) (eql obj nil))
                (multiple-value-bind (sym ext)
                    (find-symbol (symbol-name obj) (symbol-package obj))
                    (format t "~A ~A~%" sym ext))
                (let ((plist (symbol-plist obj)))
                    (when plist
                        (format t "Plist: ~a~%" plist)))
                (when (boundp obj)
                    (let ((doc (wtf/documentation obj 'variable)))
                        (format t "~A names a special variable~%" (symbol-name obj))
                        (when doc
                            (format t "Documentation: ~a~%" doc))
                        (format t "Value:~%")
                        (wtf (symbol-value obj))))
                (when (fboundp obj)
                    (if (gethash obj das::*das-gfd*)
                        (wtf/symbol-generic obj)
                        (format t "~A names a function~%" obj))
                    (wtf (fdefinition obj))))
            (values))

;;; symbol-generic
;;; :todo: method
(defun wtf/symbol-generic (obj)
    (let* ((gf (gethash obj das::*das-gfd*))
           (spec (das::das-gf-specialite gf))
           (mask (das::das-gf-lambda-mask gf))
           (keys (das::das-gf-key-count gf))
           (optionals (das::das-gf-optional-count gf))
           (rests (das::das-gf-rest-count gf)))
        (format t "~A names a generic function~%" obj)
        (format t "Generic:~%")
        (format t "   (~a ~a &key ~a &optional ~a &rest ~a)~%"
                (symbol-name obj) mask keys optionals rests)
        (format t "Methods:~%")
        (dolist (x spec)
            (format t "   (~a ~a)~%"
                    (symbol-name obj) x))))



;;; Keyword
(das:method wtf ((obj keyword))
            (format t "Keyword: ~a~%Package: ~a~%"
                    (symbol-name obj) (package-name (symbol-package obj)))
            (let ((plist (symbol-plist obj)))
                (when plist
                    (format t "Plist:~a~%" plist)))
            (values))


;;; ANy number
(das:method wtf ((obj number))
            (format t "Type: ~a~%Value: ~a~%"
                    (if (integerp obj) "Integer" "Float")
                    obj)
            (values))

;;; Character
(das:method wtf ((obj character))
            (format t "Type: Character~%Value: ~a~%" obj)
            (values))


;;; Sequence: list vector array
(das:method wtf ((obj array))
            (let ((dimensions (array-dimensions obj))
                  (type (array-element-type obj))
                  (size (length obj)))
                (if (vectorp obj)
                    (format t "Vector:~%   Length: ~a~%" (length obj))
                    (format t "Array:~%   Dimensions: ~a~%   Length: ~a~%   Element-type: ~a~%"
                            dimensions size type))
                (if (= size 0)
                    (let ((keys (klib:jso-keys obj)))
                        (when keys
                            (format t "Associative JS array~%")
                            (wtf keys))))
                (wtf/print-values obj)
                (values) ))

;;; String
(das:method wtf ((obj string))
            (format t "String:~%Length:~a~%" (length obj))
            (wtf/print-values obj)
            (values))

;;; Hash-table
(das:method wtf ((obj hash-table))
            (let ((test (cadr obj)))
                (format t "Hash-table:~%")
                (format t "Size: ~a~%Hashfn: ~a~%"
                        (hash-table-count obj)
                        (cond ((eq test #'jscl::eq-hash) 'eq)
                              ((eq test #'jscl::eql-hash) 'eql)
                              (t 'equal)))
                (values)))

;;; Function
(das:method wtf ((obj function))
            (let ((name (oget obj "fname"))
                  (doc (wtf/documentation obj 'function)))
                (format t "Function:~a~%" (if name name "anonimous"))
                (when doc
                    (format t "Documentation: ~a~%" doc))
                (values)))


;;; DAS object
(das:method wtf ((obj das))
            (format t "Structure: ~a~%" (cdr (aref obj 0)))
            (format t "Length: ~a~%" (length obj))
            (values))


;;; common lisp package
(das:method wtf ((obj package))
            (let ((exports (length (klib:jso-keys (oget obj "exports"))))
                  (symbols (length (klib:jso-keys (oget obj "symbols")))))
                (format t "Package: ~a~%Symbols: ~a~%Export symbols: ~a~%"
                        (package-name obj) symbols exports)
                (values)))




;;; Apropos

(das:generic apropos-of (symbol &optional package external-only))

(das:generic apropos-all (symbol))
(export '(lestrade::apropos-all))

;;;
(defun apropos/regexp-test (pattern str)
    (funcall ((oget pattern "test" "bind") pattern str)))



;;; must be string or symbol
(das:method apropos-of (symbol &optional package external-only)
            (format t "Lestrade: wtf ~a~%" symbol))


;;; apropos symbol
(das:method apropos-of ((symbol symbol) &optional package external-only)
            (apropos-of (symbol-name symbol) package external-only))


;;; apropos string
(das:method apropos-of ((symbol string) &optional package external-only))


;;; all packages
;;; must be string or symbol
(das:method apropos-all (symbol)
            (format t "Lestrade: wtf ~a?" symbol))

(das:method apropos-all ((symbol symbol))
            (apropos-all (symbol-name symbol)))

(das:method apropos-all ((symbol string))
            (let* ((result '())
                   (pattern (#j:RegExp symbol)))
                (jscl::map-for-in
                 (lambda (package)
                     (jscl::map-for-in
                      (lambda (x)
                          (when (apropos/regexp-test pattern (symbol-name x))
                              (push  x result)))
                      (jscl::%package-symbols package)))
                 jscl::*package-table*)

                (format t "Symbol ~a ~%" symbol)
                (cond (result
                       (format t "Matched with:~%")
                       (dolist (item (reverse result))
                           (wtf item)
                           (terpri)))
                      (t
                       (format t "Nothing match~%")
                       ))
                (values)))




(in-package :cl-user)

;;; EOF
