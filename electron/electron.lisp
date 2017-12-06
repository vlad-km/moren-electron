;;; -*- mode:lisp; coding:utf-8  -*-

;;;
;;; This file is part of the MOREN environment
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


(in-package :electron)

(defvar *el-glob-shortcut* nil)

(defun electron-pkg-init ()
    (setq *el-glob-shortcut* #j:electron:remote:globalShortcut))

(export '(electron-pkg-init))


(defun shortcut-register (keys fn)
    (funcall ((oget *el-glob-shortcut* "register" "bind") *el-glob-shortcut* keys fn)))

(export '(shortcut-register))

(defun shortcut-unregister (keys)
    (funcall ((oget *el-glob-shortcut* "unregister" "bind") *el-glob-shortcut* keys )))

(export '(shortcut-unregister))


(defun shortcut-is-registered (keys)
    (funcall ((oget *el-glob-shortcut* "isRegistered" "bind") *el-glob-shortcut* keys)))

(export '(shortcut-is-registered))


(defun shortcut-unregister-all ()
    (funcall ((oget *el-glob-shortcut* "unregisterAll" "bind") *el-glob-shortcut* )))


(export '(shortcut-unregister-all))



(defun native-image-create-from (path)
    (#j:electron:nativeImage:createFromPath  path))



(defun get-app-title ()
    (let ((win (#j:electron:remote:getCurrentWindow)))
        (funcall ((oget win "getTitle" "bind") win))))

(export '(get-app-title))


(defun set-app-title (title)
    (let ((win (#j:electron:remote:getCurrentWindow)))
        (funcall ((oget win "setTitle" "bind") win title))))

(export '(set-app-title))



(defun set-app-icon (native-img)
    (let ((win (#j:electron:remote:getCurrentWindow)))
        (funcall ((oget win "setIcon" "bind") win native-img))))


(defun set-autohide-menubar ()
    (let ((win (#j:electron:remote:getCurrentWindow)))
        (funcall ((oget win "setAutoHideMenuBar" "bind") win t))))

(export '(set-autohide-menubar))



(defun set-Menu-Bar-Visibility (op)
    (let ((win (#j:electron:remote:getCurrentWindow)))
        (funcall ((oget win "setMenuBarVisibility" "bind") win op))))

(export '(set-Menu-Bar-Visibility))


(in-package :cl-user)

;;; EOF
