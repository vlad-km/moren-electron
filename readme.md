# Moren environment 

**Moren environment** created for rapidly programming and prototyping programs on [JSCL][jscl] language (subset of Common Lisp) in [Electron][electron].

>>Moren - reduction of the from moraine-morena (geological phenomenon).
The ancient moraines, formed the geological landscape of the contemporary world. 
Lisp,  also, as an ancient moraines, has identified the tectonics of the modern programming languages. 
When we see the increasingly popular programming language, we see in him the contours of Lisp tectonics.


## Status

**Development**


## Concept

To compile the programs, it is no longer necessary to use the host compiler (ccl/sbcl and JSCL), 
all compilations are performed in the environment, regardless of the presence of the Common Lisp compiler.
In other words, now you do not need to learn, install and configure the Common Lisp compilation environment. 

Moren, an environment that allows you to compile yourself step by step. 
All the components of the environment included in this version are compiled in it, without the use of a host compiler.
The only component for which the host compiler is used (Clozure Common Lisp Version 1.11-r16635 WindowsX8664) is `jscl.js` 
with some fixes in the original code (watch git `vald-km/jscl` brunch `prod` for more details).

Moren environment contains all the minimum functionality. Other additions, as necessary, can be developed and debugged in Moren, and added  `on fly`

Custom applications (desktop application) and extensions for browsers (Chrome) are also developed and debugged in the environment `on fly`

All the necessary libraries and components (JavaScripts, JSCL) are added to the development environment also  `on fly`

For use in the programs, all the functionality provided by Node and Chrome is available.

The final application can be ported to a single bundle for use in a browser, or as a desktop application (use Electron facilities).


## Components

- MOREN - Moren environment REPL based on: `KLIB`, `LORES`, `LESTRADE`

- KLIB - addition JSCL functions (like simple generic functions, structures), 
  interaction with the Chromium (DOM, HTML, String, Array) and others

- GENERIC - simple generic function, part of `KLIB`

- DOM - DOM manipulation functions, part of `KLIB`

- HTML - HTML tags definition. Part of `KLIB`

- LORES - is a tool, designed to help developers deal with large programs contained 
  in multiple files (system) and her compilation

- LESTRADE - is a object Inspector

- CME - built-in editor

- REPL - contains all need bundles and folder structures for instalation and use Moren environment repl 

- SDF - collection system definition files for each components `(lores:defsys syntax)`



## Documentation

See the `readme` for each component and the sections of the wiki. 
Will be addition as they available, asap.


## Installation

Just copy `REPL` folder to you computer and follow the steps in the installation instructions (`readme` in `REPL`)

## Copyright
Copyright © 2017 Vladimir Mezentsev

## License
GNU General Public License v3.0


[jscl]: <https://github.com/jscl-project/jscl>
[electron]: <https://electron.atom.io/>
