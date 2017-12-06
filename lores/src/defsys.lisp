;;; -*- mode:lisp; coding:utf-8  -*-

;;; This file is part of the LORES system
;;; LORES is a tool Moren Environment, designed to help developers deal
;;; with large programs contained in multiple files (system)
;;; Copyright © 2017 Vladimir Mezentsev
;;;

;;; LORES
;;;
;;; LORES setup a system by declare:
;;;   -  which files should be included
;;;   - and what order they need to be compile.
;;;
;;; Let's a program has several different files, say 10 for example,
;;; and has just edited two of them. Those two files will need to be recompiled.
;;; Also may be other files that will be need to be recompiled because
;;; contain code depends in some way on the code in the files that were just edited.
;;;
;;; Without LORES,  have to separately issue commands to load and compile each of
;;; the files in the correct order.
;;;
;;; With LORES,  just issue one function call and the Lores will figure out
;;; which files need to be recompiled and will determine correct order.
;;;


(in-package #:lores)


;;; DEFSYS
;;;

;;; global systems table
;;;

(defun defsys/init ()
    (setq *dsp-current-defsys* nil)
    (setq *dsp-current-sysname* nil)
    (setq *dsp-current-path* nil)
    (setq *dsp-current-module-name* '(nil)))


;;;
;;; DEFSYS macro
;;;
(export '(lores::defsys))

#|
(defmacro defsys (sysname &rest other)
    (let ((lst `,other)
          (tag)
          (res)
          (fu))
        (setq res (make-def-sys :name `,sysname))
        (push `,sysname *dsp-current-sysname*)
        (push "./" *dsp-current-path*)
        (setq *dsp-current-module-name* '())
        (tagbody
         next
           (setq tag (pop lst))
           (print (list 'tag tag))
           (unless tag (go endof))
           (when (symbolp tag)
               (case tag
                 (:path
                  (setf (car *dsp-current-path*) (car lst))
                  (set-def-sys-path res (pop lst))
                  (go next))
                 (:components
                  (set-def-sys-components res (parse-components (pop lst)))
                  (print 'end-component)
                  (go next))))
           (go next)
         endof )
        `(_defsys ,res)
        ))
|#

(defun _errmsg-expand (msg)
    (apply #'format nil (jscl::!condition-args msg)))

(defun _badsysdef (msg)
    (lores/mess-0 "Lores defsys: ~a~%" (_errmsg-expand msg)))

(defmacro defsys (sysname &body other)
    (let ((sname (gensym))
          (lst (gensym))
          (tag (gensym))
          (res (gensym))
          (next (gensym))
          (nlx (gensym))
          (endof (gensym)))
        `(block ,nlx
             (let ((,sname ,sysname)
                   (,lst ',other)
                   (,tag)
                   (,res)
                   (*dsp-current-module-name* '()))
                 (setq ,res (make-def-sys :name ,sname))
                 (push ,sname *dsp-current-sysname*)
                 (push "./" *dsp-current-path*)
                 (handler-case
                     (progn
                         (tagbody
                            ,next
                            (setq ,tag (pop ,lst))
                            ;;(print (list 'tag ,tag))
                            (unless ,tag (go ,endof))
                            (when (symbolp ,tag)
                                (case ,tag
                                  (:documentation
                                   (unless (stringp (car ,lst))
                                       (error "documentation must be a string"))
                                   (pop ,lst)
                                   (go ,next))
                                  (:depends
                                   ;;(print (list 'top-dep-for *dsp-current-sysname* *dsp-current-path*  *dsp-current-module-name*))
                                   (set-def-sys-top-depends ,res (defsys-top-depends (pop ,lst)))
                                   ;;(print (list 'top-depends-result (def-sys-name ,res) (def-sys-top-depends ,res)))
                                   ;;(print (list 'top-dep-stk *dsp-current-sysname* *dsp-current-path*  *dsp-current-module-name*))
                                   (go ,next))
                                  (:path
                                   (setf (car *dsp-current-path*) (car ,lst))
                                   (set-def-sys-path ,res (pop ,lst))
                                   (go ,next))
                                  (:components
                                   ;;(print (list 'components-for *dsp-current-sysname* *dsp-current-path*  *dsp-current-module-name*))
                                   (set-def-sys-components ,res (parse-components (pop ,lst)))
                                   ;;(print 'end-component)
                                   (go ,next))))
                            (error "bad defsys keyword - ~a" ,tag)
                            ,endof
                            (pop *dsp-current-sysname*)
                            (pop *dsp-current-path*)
                            (_defsys ,res)))
                   (error (msg)
                       (_badsysdef msg)
                       (return-from ,nlx nil)) )
                 (return-from ,nlx ,res))  )))


;;; defsystem top dependences
;;;
;;; :depends (:system-from-register "system-from-pathname")
;;;

#|
(defun defsys-top-depends (lst)
    (unless (consp lst)
        (error "defsys top depends ~a must be list" lst))
    (let ((rdf)
          (sdf)
          (expr)
          (sign)
          result)
        (dolist (sysname-from lst)
            (cond ((stringp sysname-from)
                   ;; load defsys from regular pathname
                   (setq rdf (lores/read-sdf-from sysname-from))
                   (setq expr (read-from-string rdf))
                   (setq sign (car expr))
                   ;;(setq her-name (symbol-name (cadr expr)))
                   (if (find sign '(lores:defsys lores::defsys defsys))
                       (progn
                           (setq sdf (eval expr))
                           (push (def-sys-name sdf) result))
                       (error " ~a isnt DEFSYS" sysname-from)))
                  ((symbolp sysname-from)
                   ;; read from system register
                   )))
        (reverse result)))
|#

(defun defsys-top-depends (lst)
    (unless (consp lst)
        (error "defsys top depends ~a must be list" lst))
    (let ((rdf)
          (sdf)
          (expr)
          (sign)
          result)
        (dolist (sysname-from lst)
            (cond ((stringp sysname-from)
                   ;; load defsys from regular pathname
                   (setq rdf (lores/read-sdf-from sysname-from))
                   (setq expr (read-from-string rdf))
                   (setq sign (car expr))
                   ;;(setq her-name (symbol-name (cadr expr)))
                   (if (find sign '(lores:defsys lores::defsys defsys))
                       (progn
                           (setq sdf (eval expr))
                           (push (def-sys-name sdf) result))
                       (error " ~a isnt DEFSYS" sysname-from)))
                  ((symbolp sysname-from)
                   (setq sdf (gethash (sdfn sysname-from) *defsystems*))
                   (unless sdf
                       ;;(print (list 'load-reg sysname-from))
                       ;; not in table
                       ;; read from registry
                       (setq rdf (lores/read-sdf-from-registry sysname-from))
                       (setq expr (read-from-string rdf))
                       (setq sign (car expr))
                       ;;(setq her-name (symbol-name (cadr expr)))
                       (if (find sign '(lores:defsys lores::defsys defsys))
                           (progn
                               (setq sdf (eval expr))
                               (push (def-sys-name sdf) result))
                           (error " ~a isnt DEFSYS" sysname-from))
                       ))))
        ;;(print (list 'return-from-top-d result))
        (reverse result)))



(defun lores/read-sdf-from (pathname)
    (let ((reg-del (reg-exp "[\\r]" "g" )))
        (unless (lores/fs-exists pathname)
            (error "file ~a dasnt exists" pathname))
        (setq rdf (fs-read-file-sync pathname "utf-8"))
        (jstring:replace rdf reg-del " ")))


(defun lores/read-sdf-from (pathname)
    (let ((reg-del (reg-exp "[\\r]" "g" )))
        (unless (lores/fs-exists pathname)
            (error "file ~a dasnt exists" pathname))
        ;;(setq rdf (fs-read-file-sync pathname "utf-8"))
        (jstring:replace (fs-read-file-sync pathname "utf-8") reg-del " ")))

;;; hardcode!!
;;; make ./sdf/{sysname}/{sysname}-sdf.lisp from sysname
;;; :todo:
(defun defsys/make-registry-name (sysname)
    (let ((sname (jstring:to-lower-case (string sysname))))
        (concat
         *lores-registry* "/"
         sname "/"
         sname "-sdf.lisp")))

(defun lores/read-sdf-from-registry (sysname)
    (lores/read-sdf-from (defsys/make-registry-name sysname)))


;;; system registration
(defun _defsys (dfs)
    ;;(print (list '_def dfs))
    (setf (gethash (sdfn (def-sys-name dfs)) *defsystems*) dfs)
    dfs)


;;;
;;; parse components
;;;
(defun parse-components (src)
    (let ((lst src)
          (item)
          (res))
        (tagbody
         feed
           (unless (setq item (pop lst)) (go endof))
           (case (car item)
             (:file (push (parse-file-component item) res))
             (:module (push (parse-module-component item) res))
             (otherwise (error "wtf component ~a?" item)))
           (go feed)
         endof)
        (reverse res)
        ))

;;; (:file "string" :depends ("name" "name" ...))
(defun parse-file-component (lst)
    (let ((pdu (make-def-unit))
          (kv)
          (fname))
        (setq kv (getf lst :file))
        (unless kv
            (error "must be file name"))
        (unless (stringp kv)
            (error "file name must be string"))
        (setq fname (parse/compose-file-name kv))
        (set-def-unit-pathname pdu fname)
        (parse/check-file-exists pdu)
        (set-def-unit-name pdu kv)
        (set-def-unit-depend-name pdu (parse/make-depend-name kv))
        (set-def-unit-module pdu (parse/current-module-name))
        (setq kv (getf lst :depends))
        (when kv
            (parse/check-depends kv)
            (set-def-unit-depends pdu kv))
        pdu))

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

#|
(defun parse/make-depend-name (name)
    (if (car *dsp-current-module-name*)
        (let ((mq (reverse *dsp-current-module-name*))
              (pref (concat (string (car *dsp-current-sysname*)) "/"))
              (res)
              (depname))
            (dolist (x mq)
                (push (concat pref x "/") res))
            (setq depname (concat (apply #'concat (reverse res)) name))
            depname )
        name))
|#

(defun parse/make-depend-name (name)
    (let ((pref (concat (string (car *dsp-current-sysname*)) "/") ))
        (if (car *dsp-current-module-name*)
            (let ((mq (reverse *dsp-current-module-name*))
                  (res)
                  (depname))
                (dolist (x mq)
                    (push (concat pref x "/") res))
                (setq depname (concat (apply #'concat (reverse res)) name))
                depname )
            (concat pref name))))



(defun parse/check-file-exists (pdu)
    (let ((fstat)
          (pathname (def-unit-pathname pdu)))
        (unless (lores/fs-exists pathname)
            (error "file ~a dasnt exists" pathname))
        (setq fstat (lores/fs-stat pathname))
        (if (funcall ((oget fstat "isFile" "bind") fstat))
            (set-def-unit-valid pdu t)
            (error "it not regular file ~a" fname) )))

(defun parse/make-modules-path ()
    (if (car *dsp-current-module-name*)
        (let ((mq (reverse *dsp-current-module-name*))
              (res))
            (dolist (x mq)
                (push (concat x "/") res))
            (setq res (apply #'concat (reverse res)))
            res )
        nil))


(defun parse/compose-file-name (kv)
    (let ((extension (find #\. kv))
          (md (parse/make-modules-path)))
        (unless extension (setq kv (concat kv ".lisp")))
        (concat (car *dsp-current-path*)
                (if md
                    (concat "/" md kv)
                    (concat "/" kv)))))

(defun parse/check-depends (lst)
    (unless (consp lst) (error "depends ~a must be list" lst))
    (dolist (x lst)
        (unless (stringp x)
            (error "depends ~a must have type 'string'" x))))

;;; *current* stack
(defun parse/store-current-module-name (name)
    ;;(print (list 'store name *dsp-current-module-name*))
    (push name *dsp-current-module-name*))

(defun parse/reset-current-module-name (name)
    (setf (car *dsp-current-module-name*) name))

(defun parse/restore-current-module-name ()
    ;;(print (list 'restore *dsp-current-module-name*))
    (pop *dsp-current-module-name*)
    )

(defun parse/current-module-name ()
    (car *dsp-current-module-name*))

;;; parse component
(defun parse-module-component (src)
    (let ((pdu (make-def-module))
          (lst src)
          (res)
          (val)
          (kv))
        (tagbody
         feed
           (setq item (pop lst))
           (setq val (car lst))
           (unless item (go endof))
           (when (keywordp item)
               (case item
                 (:module
                  (unless (stringp val)
                      (error "module name ~a must be string" val))
                  (parse/store-current-module-name val)
                  (set-def-module-name pdu val)
                  (pop lst))
                 (:depends
                  (parse/check-depends val)
                  (set-def-module-depends pdu val)
                  (pop lst))
                 (:documentation
                  (unless (stringp val)
                      (error "module documentation must be a string" val))
                  (pop lst))
                 (otherwise (error "wtf module syntax ~?" item)))
               (go feed))
           (when (consp item)
               (case (car item)
                 (:file (push (parse-file-component item) res))
                 (:module (push (parse-module-component item) res)))
               (go feed))
           (error "wtf component keyword ~a?" item)
         endof)
        (set-def-module-units pdu (reverse res))
        (parse/restore-current-module-name)
        ;;(print (list 'end-module pdu))
        pdu))

;;; EOF
