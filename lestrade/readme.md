# Lestrade - Object inspector

Part of Moren environment. 

Lestrade. Dumb Inspector Lestrade.

Is able to answer two questions:

- what is this (Moren release JSCL function describe)
- What about (Moren release JSCL function apropos)
- In some cases, he asks: what is it that you asked me?

## Examples

### lestrade:wtf

(lestrade:wtf variable|symbol) -> describe variable or symbol

```lisp
(lestrade:wtf *wtf)
(lestrade:wtf '*wtf)
(lestrade:wtf #(1 2 3))
(lestrade:wtf (lambda ()))
(lestrade:wtf nil)
```


```lisp
2017/12/6 10:35:48 CL-USER>(defvar *wtf nil "Lestrade example and debug variable")
*WTF
2017/12/6 10:36:42 CL-USER>(lestrade:wtf *wtf)
Symbol: NIL
Package: CL
2017/12/6 10:36:44 CL-USER>(lestrade:wtf '*wtf)
Symbol: *WTF
Package: CL-USER
*WTF :INTERNAL
*WTF names a special variable
Documentation: Lestrade example and debug variable
Value:
Symbol: NIL
Package: CL
```

```lisp
2017/12/6 10:40:7 CL-USER>(setq *wtf #(1 2 3 4))
#(1 2 3 4)
2017/12/6 10:40:52 CL-USER>(lestrade:wtf '*wtf)
Symbol: *WTF
Package: CL-USER
*WTF :INTERNAL
*WTF names a special variable
Documentation: Lestrade example and debug variable
Value:
Vector:
   Length: 4
0: 1
1: 2
2: 3
3: 4
2017/12/6 10:40:54 CL-USER>
```

```lisp
2017/12/6 10:40:54 CL-USER>(lestrade:wtf 'lestrade:wtf)
Symbol: WTF
Package: LESTRADE
LESTRADE:WTF :EXTERNAL
LESTRADE:WTF names a generic function
Generic:
   (WTF (T) &key 0 &optional 0 &rest 0)
Methods:
   (WTF (FUNCTION))
   (WTF (PACKAGE))
   (WTF (LESTRADE::DAS))
   (WTF (HASH-TABLE))
   (WTF (STRING))
   (WTF (ARRAY))
   (WTF (CHARACTER))
   (WTF (NUMBER))
   (WTF (KEYWORD))
   (WTF (SYMBOL))
   (WTF (LIST))
   (WTF (T))
Function:DGF-WTF1
2017/12/6 10:43:29 CL-USER>

```

### lestrade:apropos-all

```lisp
(lestrade:apropos-all 'wtf)
(lestrade:apropos-all "wtf")
```

## License 
GNU General Public License v3.0






