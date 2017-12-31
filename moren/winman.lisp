;;; -*- mode:lisp; coding:utf-8  -*-

;;;
;;; This file is part of the MOREN environment
;;; Moren development console
;;; Copyright © 2017 Vladimir Mezentsev
;;;

(in-package :mordev)

(defvar *main-brow-win* (#j:electron:remote:getCurrentWindow))


(defparameter *brow-win-tab* (make-hash-table :test #'eql))

;;; get browser-window descriptor
(defun bw/get-wd (name)
    (gethash name *brow-win-tab*))

;;; put browser-window descriptor
(defun bw/put-wd (name bwd)
    (setf (gethash name *brow-win-tab*) bwd))

;;;
(defun bw/main ()
    *main-brow-win* )

;;;
(defparameter *bwd-templ*
  (mkjso
   "autoHideMenuBar" t
   "width" 660
   "height" 390
   "resizable" nil
   "maximizable" nil
   "frame" nil
   "backgroundColor" "#2e2c29"
   "show" nil
   ))

;;; get brwowin template
(defun bw/get-templ ()
    (klib:jso-copy *bwd-templ*))

;;; merge template with additional args
;;; (brow/templ-merge-args (mkjso "width" 300 "height" 400  "backgroundColor" "rgba(12, 101, 12, 0.4)" ))
;;;
(defun bw/templ-merge-args (obj)
    (klib:jso-merge (klib:jso-copy *bwd-templ*) obj))




;;;
;;; open by chrome.window.open
;;; return #()
(defun bw/window-open (frame-name &key url width height x y)
    (let ((options)
          (url1 (if url url "")))
        (if width (push (concat "width=" width) options))
        (if height (push (concat "height=" height) options))
        (if x (push (concat "x=" x ) options))
        (if y (push (concat "y=" y ) options))
        (if options
            (#j:window:open url1 frame-name (join options #\,))
            (#j:window:open url1 frame-name))
        ))


;;;
;;; open by new browser-window
;;; return obj
(defun bw/new-window (prop &optional url)
    (let ((wd (make-new #j:electron:remote:BrowserWindow prop)))
        (if url
            (funcall ((oget wd "loadURL" "bind")
                      wd url)))
        wd))

(defun bw/once (win what fn)
    (funcall ((oget win "once" "bind")  win fn)))


(defun bw/load-url (win url)
    (funcall ((oget win "loadURL" "bind") win url)))


(defun bw/show (win)
    (funcall ((oget win "show" "bind") win)))

(defun bw/hide (win)
    (funcall ((oget win "hide" "bind") win)))

(defun bw/destroy (win)
    (funcall ((oget win "destroy" "bind") win)))


(defun bw/close (win)
    (funcall ((oget win "close" "bind") win)))


(defun bw/open-devtool (win)
    (funcall ((oget win "webContents" "openDevTools" "bind") win)))


(defun bw/get-position (win)
    (vector-to-list (funcall ((oget win "getPosition" "bind") win))))

(defun bw/set-position (win x y)
    (funcall ((oget win "setPosition" "bind") win x y)))


(defun bw/center (win)
    (funcall ((oget win "center" "bind") win)))


(in-package :cl-user)

;;; EOF
