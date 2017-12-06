# Moren environment (version for Electron)
**Moren environment** created for rapidly programming and prototyping programs on **JSCL** language (subset of Common Lisp) in Electron.

>>Moren - reduction of the from moraine-morena (geological phenomenon).
The ancient moraines, formed the geological landscape of the contemporary world. Lisp,  also, as an ancient moraines, has identified the tectonics of the modern programming languages. When we see the increasingly popular programming language, we see in him the contours of Lisp tectonics.

- JSCL is a Common Lisp to Javascript compiler, which is bootstrapped from Common Lisp and executed from the browser. [JSCL][jscl]
- Electron is a framework for creating native applications with web technologies like JavaScript, HTML, and CSS [Electron][electron]

## Concept
To compile the programs, it is no longer necessary to use the host compiler (ccl / sbcl and JSCL), all compilations are performed in the environment, regardless of the presence of the Common Lisp compiler.
In other words, now you do not need to learn, install and configure the Common Lisp compilation environment. The minimum knowledge of the Common Lisp language is still necessary.

Moren, an environment that allows you to compile yourself step by step. All the components of the environment included in this version are compiled in it, without the use of a host compiler.
The only component for which the host compiler is used (Clozure Common Lisp Version 1.11-r16635 WindowsX8664) is jscl.js with some bugfixes in the original code, for compatibility with Win/7 and speeding up the function `format`. Watch git **vald-km/jscl** **prod** brunch for more details.

Moren environment contains all the minimum functionality. Other additions, as necessary, can be developed and debugged in Moren, and added  "on fly."

Custom applications (desktop application) and extensions for browsers (Chrome) are also developed and debugged in the environment "on fly".

All the necessary libraries and components (JavaScripts, JSCL) are added to the development environment also  "on fly".

For use in the programs, all the functionality provided by Node and Chrome is available.

The final application can be ported to a single bundle for use in a browser, or as a desktop application (use Electron facilities).

## Components
- **Moren** Moren environment REPL based on: **Klib**, **Lores**, **Lestrade**. Console - **JQconsole**
- **Klib**  addition JSCL functions (like simple generic functions, structures), interaction with the Chromium (DOM, HTML, String, Array) and others
- **generic**  Simple generic function. Part of **Klib**
- **dom**  DOM manipulation functions. Part of **Klib**
- **Html** HTML tags definition. Part of **Klib**
- **Lores** is a tool, designed to help developers deal with large programs contained in multiple files (system) and her compilation
- **Lestrade** is a object Inspector
- **CME**   built-in editor, based on **CodeMirror**
- **Repl**  Moren environment repl ready for instalation and use (contains all need bundles and folder structures)
- **sdf**   Collection **Moren environment** system definition files for each components (Lores:defsys syntax)
- **JSCL.js** JSCL bundle with speed time acceleration of the work of some functions from the original environment (watch git **vald-km/jscl** **prod** brunch for more details). Use it.

## Documentation
See the `readme` for each component and the sections of the wiki. Will be addition as they available, asap.


## Installation
Just copy `Repl` folder to you computer and follow the steps in the installation instructions (`Readme.md` in `Repl`)

## License
GNU General Public License v3.0
Copyright © 2017 Vladimir Mezentsev


[jscl]: <https://github.com/jscl-project/jscl>
[electron]: <https://electron.atom.io/>
