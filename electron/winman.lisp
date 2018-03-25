;;; -*- mode:lisp; coding:utf-8  -*-

;;;
;;; This file is part of the MOREN environment
;;; Moren development console
;;; Copyright © 2017,2018 Vladimir Mezentsev
;;;

(defpackage #:bw
  (:use #:cl))


(in-package :bw)
(export '(jscl::new jscl::oget jscl::make-new jscl::concat jscl::fset))
(export '(jscl::list-to-vector))

(unless #j:curwin
    (setf #j:curwin #j:electron:remote:getCurrentWindow))

(defmacro external (&body names)
    `(export '(,@names)))

;;;
(defparameter *bwd-templ*
  (jso:mk
   "autoHideMenuBar" t
   "width" 600
   "height" 400
   "resizable" t
   "maximizable" t
   "frame" nil
   "move" t
   "backgroundColor" "#2e2c29"
   "show" nil
   ))


;;;
;;; open by new browser-window
;;; return obj

(external new-window)
(defun new-window (&optional properties url)
    (let ((wd))
        (unless properties
            (setq properties (jso:copy *bwd-templ*)))
        (setq wd (make-new #j:electron:remote:BrowserWindow properties))
        (when url
            (jso:mcall (wd "loadURL") url))
        wd))



;;; get browser-contents-id
;;; use for ipc-send-to
(external getid)
(defun getid (win)
    (let ((contents (jso:_get (win "webContents" "id"))))
        contents))


;;; webBrowser API
(external once)
(defun once (win what fn)
    (jso:mcall (win "once") what fn))


(external on)
(defun on (win what fn)
    (jso:mcall (win "on") what fn))



(external load-url)
(defun load-url (win url)
    (jso:mcall (win "loadURL") url))



(defun url-format (path)
    (#j:url:format
     (jso:mk
      "pathname" (concat landdir "\\" path)
      "protocol" "file"
      "slashes" t)))


;;; visibilties
(external show)
(defun show (win)
    (jso:mcall (win "show")))

(external hide)
(defun hide (win)
    (jso:macll (win "hide")))

;;; living
(external destroy)
(defun destroy (win)
    (jso:mcall (win "destroy")))


(external close)
(defun close (win)
    (jso:mcall (win "close")))


;;; Minimizes the window. On some platforms the minimized window
;;; will be shown in the Dock.
(external minimize)
(defun minimize (win)
    (jso:mcall (win "minimize")))



;;; Restores the window from minimized state to its previous state.
(external restore)
(defun restore (win)
    (jso:mcall (win "restore")))


;;; Returns Boolean - Whether the window is minimized.
(external isMinimized)
(defun isMinimized (win)
    (jso:mcall (win "isMinimized")))


;;; devtool
(external open-devtool)
(defun open-devtool (win)
    (jso:mcall (win "webContents" "openDevTools") ))



;;; bounds

;;; => {x y width height}
(external get-bounds)
(defun get-bounds (win)
    (jso:mcall (win "getBounds")))


;;; => #(x y width height)
(external set-bounds)
(defun set-bounds (win bounds)
    (jso:mcall (win "setBounds") bounds))


;;; content bounds
(external get-content-bounds)
(defun get-content-bounds (win)
    (jso:mcall (win "getContentBounds")))

;;; window size
;;; => #(width height)
(external get-size)
(defun get-size (win)
    (jso:mcall (win "getSize")))


(external set-size)
(defun set-size (win width height)
    (jso:mcall (win "setSize") width height))

;;; content size
(external set-content-size)
(defun set-content-size (win width height)
    (jso:mcall (win "setContentSize") width height))

;;; => #(width height)
(external get-content-size)
(defun get-content-size (win)
    (jso:mcall (win "getContentSize")))


;;; capture contents
;;;
;;; rectangle => {width height x y}
;;; see https://github.com/electron/electron/blob/master/docs/api/structures/rectangle.md
;;;
;;; callback for example:
;;;
;;; (lambda (x)
;;;    (format t "~%size ~a~%" (jso:to-list (jso:mcall (x "getSize"))))
;;;    (#j:console:log (jso:mcall (x "toDataURL")))
;;;    (format t "dataURL length ~a~%" (length (jso:mcall (x "toDataURL"))))
;;;    (#j:console:log (jso:mcall (x "toJPEG") 100)))
;;;
;;; see https://github.com/electron/electron/blob/master/docs/api/native-image.md
;;;
(external capture-page)
(defun capture-page (win callback &optional rectangle)
    (if rectangle
        (jso:mcall (win "capturePage") rectangle callback)
        (jso:mcall (win "capturePage") callback)))

;;;
;;;setContentProtection
;;; Prevents the window contents from being captured by other apps
;;;
(external content-protection)
(defun content-protection (win flag)
    (jso:mcall (win "setContentProtection") flag))



;;; postion

;;; get => #(x y)
(external get-position)
(defun get-position (win)
    (jso:mcall (win "getPosition")))

;;; set (x y)
(external set-position)
(defun set-position (win x y)
    (jso:mcall (win "setPosition") x y))

;;; to center screen
(external center)
(defun center (win)
    (jso:mcall (win "center")))


;;; decor
(external get-title)
(defun get-title (win)
    (jso:mcall (win "getTitle")))

(external set-title)
(defun set-title (win title)
    (jso:mcall (win "setTitle") title))

(external set-icon)
(defun set-icon (win path)
    (jso:mcall (win "setIcon") path))

;;; parents/childs
(external get-parent)
(defun get-parent (win)
    (let ((parent (jso:mcall (win "getParentWindow") )))
        (if (js-null-p parent)
            nil
            parent)))

(external get-child)
(defun get-child (win)
    (let ((childs (jso:mcall (win "getChildWindows") )))
        (if (js-null-p childs)
            nil
            childs)))

(in-package :cl-user)

;;; EOF
