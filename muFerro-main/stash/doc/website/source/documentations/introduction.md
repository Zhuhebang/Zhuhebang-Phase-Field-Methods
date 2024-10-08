---
title: Introduction
description: 
---

## &mu;PRO and muFerro
 &mu;PRO represents Microstructure-Property, which is a bundle of several phase-field based microstructure modeling programs, ranging from alloy solidification and precipitation to ferroelectric and ferromagnetic domain evolution. Different from most simulation programs, all of the programs in  &mu;PRO package is solved through spectral method rather than finite difference or finite element methods. MPI and FFTW3 boost our code efficiency, and empowers us to perform 3D simulations at relatively low cost.
 
 muFerro is one of the modules in  &mu;PRO package, which can evolve ferroelectric domains structures by solving the time dependent Ginzburg Landau equation as well as taking elastic and electric contribution into consideration. The equation is solved using a semi-implicit spectral scheme [^1] in a parallel fashion. This ensures the coupled equations to be solved accurately and efficiently[^2].
 
 muFerro simulates bulk single crystals and thin films clamped on substrates, to study the electric polarization response to external mechanical and electrical stimuli. Some interesting features includes the ability to different film orientations into account, inhomogeneous structure (such as superlattices and islands), flexoelectric effect, dislocations, charged defects and secondary order prameters (such as oxygen-octahedral rotation and tilt).



[^1]:This is a test message:

[^2]:  Message 2