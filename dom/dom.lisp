;;; -*- mode:lisp;  coding:utf-8 -*-


;;; DOM - dom manipulation functions package
;;; This package is part of the MOREN Environment
;;; Copyright © 2017 Vladimir Mezentsev
;;;



(in-package :dom)

;;;(export '(jscl::fset))


;;; window.document.body
;;;

;;;
(export '(dom::*body*))
(defvar *body* #j:window:document:body)



;;; window.document.head
(export '(dom::*head*))
(defvar *head* #j:window:document:head)


;;; window.document.title
(export '(dom::get-title))
(defun get-title ()
    (jscl::oget #j:window:document "title"))

(export '(dom::set-title))
(defun set-title (text)
    (setf (jscl::oget #j:window:document "title") text))


;;; element.value
;;;
;;; Return: value for dom element, if exists
;;;
(export '(dom::get-value))
(defun get-value (element)
    (jscl::oget element "value"))

;;; set dom element 'value'
;;;
;;; Return: none
;;;
(export '(dom::set-value))
(defun set-value (text)
    (setf (jscl::oget element "value") text)
    (values-list nil))

;;; (dom:get-element-by-id "id")
;;;
;;; Error condition if div with id does not exist
;;; ERROR: Cannot use 'in' operator to search for 'multiple-value' in null
;;;
;;; Error handling, if need:
;;;
;;;    (handler-case
;;;          (setq elt (dom:get-element-by-id id))
;;;      (error (err) (setq elt nil)))
;;;
;;; Return: dom element
;;;
(export '(dom::get-element-by-id))
(defun get-element-by-id (id)
    (#j:window:document:getElementById id))


;;; (dom:get-elements-by-class "class-mammals")
;;;
;;; Return: dom elements with class "class-mammals"
;;;
(export '(dom::get-elements-by-class))
(defun get-elements-by-class (id)
    (#j:window:document:getElementsByClassName id))



;;; elem.hasAttribute(name)
;;;
;;; (dom-has-attribute *div "Order")
;;; => t, nil of dom elt has attr or not
;;;
(export '(dom::has-attribute))
(defun has-attribute (elem name)
    (funcall ((jscl::oget elem "hasAttribute" "bind") elem name)))


;;; (dom:set-attribute *div "order")
;;;
;;; elm.setAttribute(val)
;;;
;;; Return: none
;;;
(export '(dom::set-attribute))
(defun set-attribute (elm attr val)
    (funcall ((jscl::oget elm "setAttribute" "bind")  elm attr val))
    (values-list nil))


;;; elm.getAttribute()
;;;
;;; (dom:get-attribute *div string-attr-name)
;;;
;;; Return: attr value or nil
;;;
(export '(dom::get-attribute))
(defun get-attribute (elm attr)
    (let ((rc (funcall ((jscl::oget elm "getAttribute" "bind") elm attr))))
        (if (jscl::js-null-p rc)
            nil
            rc)))


;;; elm.removeAttribute(attr)
;;;
;;; Return: none
;;;
(export '(dom::remove-attribute))
(defun remove-attribute (elm attr)
    (funcall ((jscl::oget elm "removeAttribute" "bind") elm attr))
    (values-list nil))

;;;
;;; (defun help-me (event) (format t "Help text~%"))
;;; (dom:set-event btn-help "onclick" #'help-me)
;;;
;;; Return: none
;;;
(export '(dom::set-event))
(defun set-event (elm event function)
    (setf (jscl::oget elm event) function)
    (values-list nil))

;;;
;;; (dom:element-p "sss") => nil
;;; (dom:element-p (dom-create "div")) => t
;;;
;;; Return: t or nil - element is dom-element or not
;;;
(export '(dom::element-p))
(defun element-p (u)
    (if (jscl::oget u "appendChild")  t nil))


;;; dom:get-inner-html
;;;
;;; (dom:get-inner-html (dom:escape-html "<p>text</p>"))
;;; => "&lt;p&gt;test&lt;/p&gt;"
;;;
;;; Return; string
;;;
(export '(dom::get-inner-html))
(defun get-inner-html (div)
    (jscl::oget div "innerHTML"))


;;; dom:set-inner-html
;;;
;;; (setq *es (dom:escape-html "<p>text</p>"))
;;; (string (dom:set-inner-html *es "One two three"))
;;;
;;; Return: none
;;;
(export '(dom::set-inner-html))
(defun set-inner-html (div str)
    (setf (jscl::oget div "innerHTML") str)
    (values-list nil))


;;; dom:remove-child
;;;
;;; (dom-remove-child div)
;;;
(export '(dom::remove-child))
(defun remove-child (elem)
    (if (jscl::js-null-p (jscl::oget elem "parentNode"))
        (return-from remove-child nil)
        (let ((var (jscl::oget elem "parentNode")))
            (funcall ((jscl::oget var "removeChild" "bind") var elem ))))
    t)

;;; aliase for remove-child
(export '(dom::umount))
(fset 'umount #'remove-child)


;;; dom:class-name-str
;;;
;;; (dom:class-name-str div)
;;; => string "class1 class2 ...classn"
;;;    i.e. el.className
;;;

(export '(dom::class-name-str))
(defun class-name-str (elem)
    (jscl::oget elem "className"))


;;; dom:class-name-list
;;;
;;; (dom:class-name-list elem)
;;; =>
;;;   (list "name1" "name2") or nil
;;;
;;; (dom:class-name-list elem)
;;; =>
;;;   #("name1" "name2")
;;;
;;; => nil
;;;    if elem hasnt any class
;;;

(export '(dom::class-name-list))
(defun class-name-list (elem)
    (let ((cls (jscl::lisp-to-js (jscl::oget elem "className")))
          (result nil))
        (if (> (jscl::oget cls "length") 0)
            (dolist (x (jscl::vector-to-list (funcall ((jscl::oget cls "split" "bind") cls " "))))
                (push (jscl::js-to-lisp x) result)))
        result))


;;; dom:contains-class
;;;
;;; (dom:contains-class class-name)
;;; => logical  i.e. exists/none
;;;

(export '(dom::contains-class))
(defun contains-class (elem class-name)
    (let* ((collection (jscl::oget elem "classList")))
        (funcall ((jscl::oget collection "contains" "bind") collection class-name))))


;;; dom:add-class
;;;
;;; (dom:add-class div "invisible")
;;;
;;; Return: none
;;;
(export '(dom::add-class))
(defun add-class (elem class)
    (let* ((collection (jscl::oget elem "classList")))
        (funcall ((jscl::oget collection "add" "bind") collection class))
        (values-list nil)))


;;; dom:remove-class
;;;
;;; (dom:remove-class div "visible")
;;;
;;; Return: none
;;;
(export '(dom::remove-class))
(defun remove-class (elem class)
    (let* ((collection (jscl::oget elem "classList")))
        (funcall ((jscl::oget collection "remove" "bind") collection class))
        (values-list nil)))


;;; dom:toggle-class
;;;
;;; (dom:toggle-class div "visible")
;;; =>
;;;   if class exists - remove it
;;;   else add new class to dom element
;;;
;;; Return: none
;;;
(export '(dom::toggle-class))
(defun toggle-class (elem class)
    (let* ((collection (jscl::oget elem "classList")))
        (funcall ((jscl::oget collection "toggle" "bind") collection class))
        (values-list nil)))

;;; dom:mount
;;; dom:append-child
;;;
;;; parent.appendChild(children)
;;;
;;; Return: parent with new childs
;;;
(defun append-child (dom::parent &rest childs)
    (dolist (elt childs)
        (if (jscl::oget elt "appendChild")
            (funcall ((jscl::oget parent "appendChild" "bind" ) parent elt))
            (setf (jscl::oget parent "innerHTML")
                  (jscl::concat (jscl::oget parent "innerHTML") elt))))
    parent)

;;; Aliase for append-child
(fset 'mount #'append-child)
(export '(dom::append-child mount))


;;; dom:clear
;;;
;;; clear innerHTML field
;;;
;;; Return: none
(export '(dom::clear))
(defun clear (elm)
    (setf (jscl::oget elm "innerHTML") "")
    (values-list nil))



;;; dom:parent-node
;;;
;;;
;;;    (dom:parent-node *chk)
;;;     => [object HTMLDivElement]
;;;
;;; Right form:
;;;
;;;    (if (not (js-null-p (dom:parent-node div)))
;;;           .... div has parent
;;;           .... div hasnt parent)
;;;
;;;
(export '(dom::parent-node))
(defun parent-node (element)
    (jscl::oget element "parentNode"))


;;; dom:node-name
;;;
;;;
;;; (dom:node-name *chk)
;;; => "INPUT"
;;;
(export '(dom::node-name))
(defun node-name (element)
    (jscl::oget element "nodeName"))


;;; dom:has-child-nodes
;;;
;;; (dom:has-child-nodes *chk)
;;;   => t or nil
;;;
(export '(dom::has-child-nodes))
(defun has-child-nodes (element)
    (funcall ((jscl::oget element "hasChildNodes" "bind") element)))


;;; dom:child-element-count
;;;
;;; (dom:child-element-count pid)
;;; => 0 or collection size
;;;
(export '(dom::child-element-count))
(defun child-element-count (element)
    (jscl::oget element "childElementCount"))


;;; dom-element-childs-collection
;;;
;;; Get dom element childs collection
;;;
;;;  It causes an error if the collection has a nodeText elements
;;;  => ERROR: Out of range.
;;;

(export '(dom::childs-collection))
(defun childs-collection (element)
    (jscl::oget element "childNodes"))



;;; todo: node.children


;;; dom:first-element-child
;;;
;;;  (dom:first-element-child pid)
;;;  => [object HTMLDivElement]
;;;
;;;
(export '(dom::first-element-child))
(defun first-element-child (element)
    (if (jscl::js-null-p (jscl::oget element "firstElementChild"))
        nil
        (jscl::oget element "firstElementChild")))

;;; dom:last-elemeent-child
;;;
;;;  (dom:last-element-child pid)
;;;  => [object HTMLDivElement]
;;;
;;;
(export '(dom::last-element-child))
(defun last-element-child (element)
    (if (jscl::js-null-p (jscl::oget element "lastElementChild"))
        nil
        (jscl::oget element "lastElementChild")))


;;; dom:next-sibling
;;;
;;; NOte: ERROR condition if hasnt sibling
;;;
;;;
;;; Return: nil if none sibling or next sibling
;;;
(export '(dom::next-sibling))
(defun next-sibling (element)
    (if (jscl::js-null-p (jscl::oget element "nextSibling"))
        nil
        (jscl::oget element "nextSibling") ))


;;; dom:parent-node
;;;
(export '(dom::parent-node))
(defun parent-node (element)
    (jscl::oget element "parentNode"))



;;; dom:insert-before
;;;
;;;
(export '(dom::insert-before))
(defun insert-before (element new-element)
    (funcall ((jscl::oget element "parentNode" "insertBefore" "bind")
              (jscl::oget element "parentNode")
              new-element
              element)))

;;; dom:insert-after
;;;
;;; inserts a new element after the specified element
;;;
;;; Note: ERROR condition hasnt right sibling
;;;
;;; Workaround:
;;;     If you dont check sibling (dom-element-next-sibling) => nil or [dom element]
;;;     its you problem, catch error (for example: (handler-case (...) (error (msg))) )
;;;
(export '(dom::insert-after))
(defun insert-after (element new-element)
    (funcall ((jscl::oget element "parentNode" "insertBefore" "bind")
              (jscl::oget element "parentNode")
              new-element
              (jscl::oget element "nextSibling") )))


;;; dom:insert-top
;;;
;;; insert new element to top dom stucture
;;;
;;; Note: ERROR condition if element hasnt child
;;;
(export '(dom::insert-top))
(defun insert-top (element new-element)
    (funcall ((jscl::oget element "insertBefore" "bind")
              element
              new-element
              (jscl::oget element "firstElementChild"))))


(in-package :cl-user)

;;; EOF
