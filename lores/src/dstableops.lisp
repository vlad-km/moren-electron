;;; -*- mode:lisp; coding:utf-8  -*-

;;; This file is part of the LORES system
;;; LORES is a tool Moren Environment, designed to help developers deal
;;; with large programs contained in multiple files (system)
;;; Copyright © 2017 Vladimir Mezentsev
;;;


(in-package :lores)

;;;
;;; def-sys table operations
;;;


;;; reset *defsystems*
(export '(lores::reset))
(defun reset ()
    (setq *defsystems* (make-hash-table :test #'equal)))


;;; delete system from main table
(export '(lores::remsys))
(defun remsys (sysname &optional (tree nil))
    (let ((sdf (defsys/get-sdf-by-name sysname))
          (names))
        (unless sdf
            (error "Lores: undefined system ~a" sysname))
        (when tree
            ;; remove system tree (top depends) from table
            (setq names (lores/flatten-top-depends (def-sys-top-depends sdf)))
            (dolist (x names)
                (remhash (sdfn x) *defsystems*)))
        ;; remove system
        (remhash (sdfn sysname) *defsystems*)))




;;; EOF
