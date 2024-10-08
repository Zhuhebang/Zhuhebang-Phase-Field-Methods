# The basic main program

This is a minimum ferroelectric main program that use the PhaseFieldSDK.

## Files and folder
- data.f90, define the global data used by the main program
- input.f90, read parameters from input file
- main.f90, the main program entry point
- output.f90, subroutines for output data
- setup.f90, system setup subroutines
- setup, this is just an example of how you can use the module submodule structure to properly separate subroutines. You can also put all submodules in the setup module
    - electric.f90, poisson solver setup
    - elastic.f90, mechanical equilibrium solver setup 
    - ferroelectric.f90, ferroelectric related setup
    - initial.f90, setup initial condition
    - tdgl.f90, TDGL solver setup
- solve.f90, call the solvers from SDK to solve the electric, elastic and TDGL equation.
