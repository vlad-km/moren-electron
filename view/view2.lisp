;;; -*- mode:lisp; coding:utf-8  -*-
;;;
;;; viewport sketch
;;;
;;; Copyright, 2017, mvk
;;;
;;; (boot:compile '((:file "/tmp/kass/git/moren-electron/view/view2.lisp")))
;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
    (unless (find-package :viewport)
        (make-package :viewport :use (list 'cl))))


(in-package :viewport)


(export '(klib::make-js-object klib::mkjso))
(export '(jscl::oget jscl::concat))


;;;
;;; viewport structure
;;;

(das:structure viewport
               position
               left top
               width height
               overflow
               border
               div)

(export '(viewport-div))


;;; type predicate
(das:def-type 'viewport
    (lambda (obj)
        (eq (cdr (das:das/structure-pred obj)) 'viewport )))

;;; viewport background
;;;
(das:structure background
               color
               image
               repeat
               attachment
               position)

(export '(make-background))


(das:def-type 'background
    (lambda (obj)
        (eq (cdr (das:das/structure-pred obj)) 'background )))


;;; viewport border
;;; :radius "5px" :style "groove" etc. etc. from atribute border spec
;;;
(das:structure border
               style
               width
               color
               padding
               radius
               padding
               margin
               background )

(export '(make-border))

(das:def-type 'border
    (lambda (obj)
        (eq (cdr (das:das/structure-pred obj)) 'border )))

;;;
;;; get/set border/backgrounf style
;;;
;;; set border style
;;;
;;; (viewport:border-style *vp  "width" "3px" "color" "white" "style" "groove")
;;; => t
;;;
;;; get border style
;;;
;;; (viewport:border-style *vp)
;;; => string or nil
;;;

(das:generic style-setter (elt prefix conses))

(das:generic background-style (vp &rest conses))
(export '(background-style))

(das:generic border-style (vp &rest conses))
(export '(border-style))


(das:method border-style (vp &rest conses)
            (if conses
                (style-setter vp "border-" conses)
                (oget vp "style" "border")))


(das:method border-style ((vp viewport) &rest conses)
            (apply #'border-style (viewport-div vp) conses))

(das:method background-style (vp &rest conses)
            (if conses
                (style-setter vp "background-" conses)
                (oget vp "style" "background")))


(das:method background-style ((vp viewport) &rest conses)
            (apply #'background-style (viewport-div vp) conses))

(das:method style-setter (elt prefix conses)
            (let ((key)
                  (val))
                (tagbody fsm
                 next (setq key (pop conses))
                   (unless key (go stop))
                   (setq val (pop conses))
                   (unless val (error "css-setter: check args ~a" conses))
                   (setf (oget elt "style" (concat prefix key)) val)
                   (go next)
                 stop )
                t))

(defun set-border-style (vp border)
    (setf (oget (viewport-div vp) "style" "border")
          (wpborder-expand border)))


(defun set-background-style (vp background)
    (setf (oget (viewport-div vp) "style" "background")
          (wpbackground-expand border)))



;;;
;;; background/border expanders
;;;

(defun wpbackground-expand (bp)
    (let ((rs '()))
        (labels ((result (fmt arg)
                     (push (concat fmt arg ";") rs)))
            (if (background-color bp) (result "background-color:" (background-color bp)))
            (if (background-image bp) (result "background-image:" (background-image bp)))
            (if (background-repeat bp) (result "background-repeat:" (background-repeat bp)))
            (if (background-attachment bp) (result "background-attachment:" (background-attachment bp)))
            (if (background-position bp) (result "background-position:" (background-position bp)))
            (apply #'concat rs))))

(defun wpborder-expand (bp)
    (let* ((rs '()))
        (labels ((result (fmt arg)
                     (push (concat fmt arg ";") rs)))
            (if (border-style bp) (result "border-style:" (border-style bp) ))
            (if (border-width bp) (result "border-width:" (border-width bp) ))
            (if (border-color bp) (result "border-color:" (border-color bp) ))
            (if (border-padding bp) (result "border-padding:" (border-padding bp) ))
            (if (border-radius bp) (result "border-radius:" (border-radius bp) ))
            (apply #'concat rs))))


;;;
;;; Create viewport element
;;;
;;; position = absolute | fixed | relative
;;; color = any color for text "red" "orange" "#0666"
;;; hide =t do not display until unhide viewport
;;; drag =t make viewport draggable. just click and pull
;;; scroll = auto | hidden | scroll | visible | inherit
;;;

(export '(create))
(defun create (&key (parent nil) (childs nil) (position "absolute")
                 (left 10) (top 10) (width 300) (height 200) color
                 border (padding nil) margin background (hide nil) (drag nil)
                 (scroll nil))
    (let* ((css)
           (div)
           (vp)
           (rs '()))
        (setq css
              (concat "position:" position ";"
                      (concat "left:" left
                              "px;top:" top
                              "px;width:" width
                              "px;height:" height "px;")))
        (push css rs)
        ;;(print rs)
        (if padding
            (push (concat "padding:" padding ";") rs))
        (if margin
            (push (concat "margin:" margin ";") rs))
        (if color
            (push (concat "color:" color ";") rs) )
        ;;(print 'to-background)
        (if background
            (push (wpbackground-expand background) rs))
        (if border
            (push (wpborder-expand border) rs))
        (if scroll
            (push (concat "overflow:" scroll ";") rs))

        (setf div (html:div :id (klib:gen-uid "vp" "div") :style (apply #'concat (reverse rs))))

        (if hide
            (setf (oget div "style" "display") "none"))
        (setf vp
              (make-viewport :position position :left left :top top :width width
                             :height height :border border :div  div ))
        (if childs
            (apply #'dom:mount
                   (append (list div)
                           (mapcar (lambda (x) (if (symbolp x) (symbol-value x) x)) childs))))
        (if parent
            (dom:mount parent div))
        (if drag
            (let ((pvp (#j:$ div )))
                (funcall ((oget pvp "draggable" "bind") pvp))) )
        vp))






;;;
;;;
;;; o1 => (create-viewport :position "relative" :left 1 :top 1 :width w1 :height h1)
;;; o2 => (create-viewport :position "relative" :left 5 :top 5 :width w2 :height h2)
;;; o3 => (create-viewport :width (+ w1 w2 10) :height (+ h1 h2 10))
;;;
;;; (dom-mount (viewport-div 03) (viewport-div o1) (viewport-div o2))
;;; (dom-mount (dom-get-body) (viewport-div o3))
;;;                             or
;;; (viewport:childs-mount o3 o1 o2)
;;; (dom-mount (dom-get-body) o3)
;;;

(export '(childs-mount))

(defun childs-mount (vp &rest childs)
    (apply #'dom:mount
           (append (list (viewport-div vp))
                   (mapcar (lambda (x) (viewport-div x)) childs))))




;;;
;;; (viewport:get-position vp) => ("100px" "100px")
;;; (viewport:get-position vp t) => (100 100)
;;; => (left top)
;;;

(export '(get-position))

(defun get-position (vp &optional (int nil))
    (let* ((div (viewport-div vp))
           (left (oget div  "style" "left"))
           (top (oget div  "style" "top")))
        (flet ((parser (str) (parse-integer str :junk-allowed t)))
            (if int
                (list (parser left) (parser top))
                (list left top))  )))


;;;
;;; (viewport:move vp :left 120 :top 100)
;;;

(export '(move))

#|
(defun move (vp &key left top)
    (let* ((div (viewport-div vp)))
        (if left
            (setf (oget div  "style" "left") (concat left "px")))
        (if top
            (setf (oget div "style" "top") (concat top "px" ))))
    (values))
|#

(das:generic move (vp &key left top))

(das:method move (vp &key left top)
            (if left
                (setf (oget vp  "style" "left") (concat left "px")))
            (if top
                (setf (oget vp "style" "top") (concat top "px" )))
            (values))

(das:method move ((vp viewport) &key left right)
            (move (viewport-div vp) :left left :right right))


;;;
;;; display / none
;;;
;;; (viewport:hide vp)
;;; (viewport:show vp)
;;;

(export '(hide show))

(das:generic hide (vp))

(das:method hide (vp)
            (setf (oget vp "style" "display") "none")
            (values))

(das:method hide ((vp viewport))
            (hide (viewport-div vp)))


(das:generic show (vp))

(das:method show (vp)
            (setf (oget vp "style" "display") "")
            (values))

(das:method show ((vp viewport))
            (show (viewport-div vp)))


#|
(defun hide (vp)
    (setf (oget (viewport-div vp) "style" "display") "none")
    (values))

(defun show (vp)
    (setf (oget (viewport-div vp) "style" "display") "")
    (values))
|#



;;; toggle

(das:generic toggle (vp))

(das:method toggle (vp)
            (jq:toggle (jq:$ vp)))

(das:method toggle ((vp viewport))
            (jq:toggle (jq:$ (viewport-div vp))))


;;;
;;; zIndex


(export '(front back layer zindex))


(defun zindex (vp)
    (oget (viewport-div vp) "style" "zIndex"))

(defun front (vp &optional (zIndex 90))
    (setf (oget (viewport-div vp) "style" "zIndex") zIndex)
    (values) )

(defun back (vp)
    (setf (oget (viewport-div vp)  "style" "zIndex") -1)
    (values) )

(defun layer (vp layer)
    (setf (oget (viewport-div vp)  "style" "zIndex") layer)
    (values) )



;;; get/set viewport css
;;;
;;; (viewport:css vp prop &optional value)
;;;

(das:generic css (vp prop &optional value))
(export '(css))


(das:method css (vp prop &optional value)
            (let* ((div (#j:$ vp)))
                (if value
                    (funcall ((oget div "css" "bind") div prop value))
                    (funcall ((oget div "css" "bind") div prop)))))

(das:method css ((vp viewport) prop &optional value)
            (css (viewport-div vp) prop value))


;;; jquery.draggable
;;;
;;; (viewport-draggable vp)
;;;

(das:generic draggable (vp))
(export '(draggable))

(das:method draggable (vp)
            (let ((pvp (#j:$ vp)))
                (funcall ((oget pvp "draggable" "bind") pvp))))

(das:method draggable ((vp viewport))
            (draggable (viewport-div vp)))

;;;
;;; change  viewport backgroundImage
;;;
;;; (viewport:bg-image vp "images/way.jpg")

(das:generic bg-image (vp ref &optional style))
(export '(bg-image))

(das:method bg-image (vp ref &optional style)
            (let* ((url (concat "url(" ref ")")))
                (setf (oget vp "style" "backgroundImage") url)
                (when style
                    (setf (oget vp "style" "backgroundSize") style))))

(das:method bg-image ((vp viewport) ref &optional style)
            (bg-image (viewport-div vp) ref style))



(in-package :cl-user)


;;;;; eof
