---
title: Structure of MUPRO package
---


$\mu$ferro is a Fortran 90 program. It allows for dynamic memory allocation and a single executable which can be used for any type of calculation. Generally the executables and the thermodynamic potentials should reside in the following directories: 

```
-
|- Ferroelectric
|    |- Ferroelectric.exe
|    |- Potential
|    |- Example
|- Plot
|    |- some gnuplot scripts
```

The $\mathrm{\mu}$pro root directory contains the license.lic file and the \mupro distribution of specific version, in this example is \textbf{MUPRO\_1.0.6}. In the \textbf{MUPRO\_1.0.6} folder there are three directories,
\begin{itemize}
**Ferroelectric** contains the main program for \muferro phase-field simulation, an example PBS script for you to submit jobs on systems using PBS job queue system, a \textbf{Potentials} folder which contains several commonly used thermodynamic potentials and physical properties that the program needs, and an \textbf{Example} folder that contains some example projects for you to try out and gain experience with using the program.
**Plot** contains three pairs of gnuplot script and bash script, one for 1D plot, one for 2D scalar heat plot, and the third for 2D vector glyph plot.

