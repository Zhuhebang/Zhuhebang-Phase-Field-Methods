---
title: Quick tutorial
description: 
---


The files needed for this tutorial can be found in the muFerro example folder (usually located at mupro/install/path/MUPRO\_version\_number/Ferroelectric/Example).


## Step 1
Copy the following three files from the example folder to your work directory.

1. **input.in** This file is the main input file of muFerro. Tags in each line gives predefined keywords which tells the program what to perform. It is followed by an equation sign ’=’ and one or several values associated with the keyword. For each keyword, a default will be used if it is not been specified in the file.
2. **Polar.in** This file describes the initial polarization distribution of the simulated system. The program still works even if without **Polar.in**, and it will use the default random noise as initial structure. This file contains the polarization at each grid points in a columnar fashion. An example of the file is shown in Table \ref{quick-example-polar-in}. The first line specify the x, y and z ranges of the simulation system. Starting from the second line, the first three columns represents the grid position. The 3rd to 6th columns represents the polarization components projected to the x, y, and z axis of the Catesian coordinate for calculation (global coordinate), Px, Py, Pz. The 7th to 9th columns represents the polarization components projected to the 1, 2, and 3 axis of the crystallographic coordinates (local coordinate). 
2. **pot.in** This file stores the necessary thermodynamic parameters and other physical properties for the ferroelectric material you want to simulate, such as of Landau potential coefficients, elastic constants, and electrostrictive coefficents. Note that for the same material, a few different versions of thermodynamic parameters may exist. For this quick tutorial, $\text{BaTiO}_\text{3}$ from reference \ref{Wang 2010} is used. The content of this pot.in is shown in Listing \ref{quick-example-pot-in}. 

Example **Polar.in** file for a 10x10x10 system.

| 10  | 10 | 10 |          |       |          |          |          |          |
|-----|----|----|----------|-------|----------|----------|----------|----------|
| 1   | 1  | 1  | 0.00E+00 | 0.00E | 0.00E+00 | 0.00E+00 | 0.00E+00 | 0.00E+00 |
| 1   | 1  | 2  | 0.00E+00 | 0.00E | 0.00E+00 | 0.00E+00 | 0.00E+00 | 0.00E+00 |
| 1   | 1  | 3  | 0.00E+00 | 0.00E | 0.00E+00 | 0.00E+00 | 0.00E+00 | 0.00E+00 |
| ... |    |    |          |       |          |          |          |          |
| 1   | 1  | 10 | 0.00E+00 | 0.00E | 0.00E+00 | 0.00E+00 | 0.00E+00 | 0.00E+00 |
| 1   | 2  | 1  | 0.00E+00 | 0.00E | 0.00E+00 | 0.00E+00 | 0.00E+00 | 0.00E+00 |
| 1   | 2  | 2  | 0.00E+00 | 0.00E | 0.00E+00 | 0.00E+00 | 0.00E+00 | 0.00E+00 |
| ... |    |    |          |       |          |          |          |          |
| 1   | 10 | 10 | 0.00E+00 | 0.00E | 0.00E+00 | 0.00E+00 | 0.00E+00 | 0.00E+00 |
| 2   | 10 | 10 | 0.00E+00 | 0.00E | 0.00E+00 | 0.00E+00 | 0.00E+00 | 0.00E+00 |
| 3   | 10 | 10 | 0.00E+00 | 0.00E | 0.00E+00 | 0.00E+00 | 0.00E+00 | 0.00E+00 |
| ... |    |    |          |       |          |          |          |          |
| 10  | 10 | 10 | 0.00E+00 | 0.00E | 0.00E+00 | 0.00E+00 | 0.00E+00 | 0.00E+00 |


## Step 2
Run the muFerro program.

If you have successfully installed the package through the **install.sh** we provided, then you should be able to run it just by typing **mupro-Ferroelectric** in terminal. Otherwise, you need to find the **Ferroelectric.exe** located in the Ferroelectric folder of our muFerro distribution and then either execute it by give the whole path to the binary, or copy it to your current working directory. You need to make sure you have all the three input files copied to the current directory where you're trying to run the muFerro program.