;;; -*- mode:lisp; coding:utf-8 -*-



(defun informer ()
    (banner)
    (established)
    (last-interaction)
    (terpri)
    (directories)
    (format t "~%~%~%"))


(defun directories ()
    (let ((host (#j:os:hostname))
          (home (#j:os:homedir))
          (cwd (#j:process:cwd))
          (sdf (#j:localStorage:getItem "lores-sdf-repository")))
        (if (js-null-p sdf) (setq sdf "undefined") (setq sdf (#j:JSON:parse sdf)))
        (format t "HOSTNAME::~a HOMEDIR::~a CWD::~a  SDF::~a~%" host home cwd sdf)))


(defun established ()
    (let ((timestamp (#j:JSON:parse (#j:localStorage:getItem "moren-alive-timestamp"))))
        (format t "Moren instance was established ~a ~%" (string (make-new #j:Date timestamp)))))

(defun last-interaction ()
    (let ((timestamp (#j:JSON:parse (#j:localStorage:getItem "moren-last-iter-timestamp"))))
        (format t "Last interaction time: ~a ~%" (string (make-new #j:Date timestamp)))))




(defun banner ()
    (terpri)

    (format t
            "
 ____    ____     ___     _______      ________   ____  _____
|_   \\  /   _|  .'   `.  |_   __ \\    |_   __  | |_   \\|_   _|
  |   \\/   |   /  .-.  \\   | |__) |     | |_ \\_|   |  \ \ | |
  | |\\  /| |   ( |   | )   |  __ /      |  _| _    | |\\ \\| |
 _| |_\\/_| |_  \\  `-'  /  _| |  \\ \\_   _| |__/ |  _| |_\\   |_
|_____||_____|  `.___.'  |____| |___| |________| |_____|\\____|
"))





;;; EOF
