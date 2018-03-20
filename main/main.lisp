;;; -*- mode:lisp; coding:utf-8 -*-


;;; electron application main page
;;; This file is part of the Moren environment
;;; Copyright © 2018 Vladimir Mezentsev
;;;

;;; for compilation on host:jscl
;;;
;;; (hsdf:add-component main "jso.lisp")
;;; (hsdf:add-component main "main.lisp")
;;; (hsdf:compile-it main)
;;;


(defparameter main-options
  (jso:mk
   "title" "Moren environment"
   "show" nil
   "width"  1100
   "height"  700
   "icon"  "./about/moren/Lizard-logo-c.png"
   "backgroundColor"  "#2e2c29"
   "webPreferences" (jso:mk
                     "webSecurity" nil
                     "nativeWindowOpen" t)))


(defparameter splash-options
  (jso:mk
   "show" nil
   "width"  600
   "height"  300
   "frame" nil))


(defparameter native-window-prop
  (jso:mk "nativeWindowOpen" t))

(defparameter modal-window-options
  (jso:mk "modal" t
          "parent" nil
          "frame" nil
          "webPreference" (jso:mk
                           "nativeWindowOpen" t)))

(defparameter frame-web-preference-prop
  (jso:mk
   "webPreference" (jso:mk
                    "nativeWindowOpen" t)))

(defparameter unframe-web-preference-prop
  (jso:mk "frame" nil
          "webPreference" (jso:mk
                           "nativeWindowOpen" t)))



(defvar boot-page "bootmd.html")
(defvar splash-page "about/splash.html")
(defparameter landdir "./")


(defun check-file-exists (pathname)
    (#j:Fs:existsSync pathname))


(defun read-sync-from (path &optional (encoding "utf-8"))
    (let ((data))
        (handler-case
            (progn
                (setq data (#j:Fs:readFileSync path encoding))
                (cond ((jscl::js-null-p data)
                       (setq data nil))
                      (t (setq data (#j:JSON:parse data)))))
          (error (msg)
              (error msg)))
        data))


(defun awake (from)
    (let ((initial (read-sync-from from))
          (bp))
        (when initial
            (if (setq bp (jso:_get (initial "bootpage")))
                (setq boot-page bp))
            (if (setq bp (jso:_get (initial "splashpage")))
                (setq splash-page bp))
            (if (setq bp (jso:_get (initial "title")))
                (jso:_set (main-options "title") bp))
            (if (setq bp (jso:_get (initial "icon")))
                (jso:_set (main-options "icon") bp))
            (if (setq bp (jso:_get (initial "background")))
                (jso:_set (main-options "backgroundColor") bp))
            (if (setq bp (jso:_get (initial "webSecurity")))
                (jso:_set (main-options "webPreferences" "webSecurity") bp)) )))


(defun main-window ()
    (let ()
        (setf #j:main (jscl::make-new #j:electron:BrowserWindow main-options))
        (jso:_set (modal-window-options "parent") #j:main)
        (setf #j:splash (jscl::make-new #j:electron:BrowserWindow splash-options))
        (funcall ((jscl::oget #j:splash "loadURL" "bind") #j:splash (url-format splash-page)))
        (funcall ((jscl::oget #j:main "loadURL" "bind") #j:main (url-format boot-page)))
        (#j:splash:once
         "ready-to-show"
         (lambda (&optional a b c d)
             (#j:splash:show) ))
        (#j:main:once
         "ready-to-show"
         (lambda (&optional a b c d)
             (#j:splash:destroy)
             (#j:main:show)))))


(defun listen-main-webcontents ()
    (setf #j:main_web_contents #j:main:webContents)
    (#j:main_web_contents:on
     "new-window"
     (lambda (event url frame-name disposition  options features)
         (setf #j:new_window_event event)
         (#j:new_window_event:preventDefault)
         (cond ((equal frame-name "modal")
                ;; create modal child window
                (#j:Object:assign options modal-window-options))
               ((equal frame-name "frame")
                ;; create frame child window
                (#j:Object:assign options frame-web-preference-prop))
               ((equal frame-name "unframe")
                ;; create child without frame
                (#j:Object:assign options
                                  (jso:mk "frame" nil "webPreference" native-window))))
         (setf #j:new_window_event:newGuest (make-new #j:electron:BrowserWindow options)))))



(defun url-format (path)
    (#j:url:format
     (jso:mk
      "pathname" (concat landdir "\\" path)
      "protocol" "file"
      "slashes" t)))

(defun _errmsg-expand (msg)
    (apply #'format nil (jscl::!condition-args msg)))



(defun boot ()
    (setf #j:electron (require "electron"))
    (setf #j:App #j:electron:app)
    (setf #j:url (require "url"))
    (setf #j:path (require "path"))
    (setq landdir (#j:process:cwd))
    (#j:App:once "ready"
                 (lambda (&optional a b c d)
                     (main-window))))


;;; bootstrap main page

(boot)

;;; EOF
