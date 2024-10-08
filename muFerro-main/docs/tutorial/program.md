# Program Structure

The general procedure of a ferroelectric main program is as follows:

1. Read necessary parameters from the input files. You may also hard coded all parameters in the program with reading from external input files.
2. Normalize the parameters. This is purely for numerical benefits, as avoiding multiplication of very large and very small value can improve the solver accuracy.
3. Simulation system setup using the normalized parameters. 
4. Start the main iteration loop.
    1. solve poisson equation to get the electric driving force
    2. solve the mechanical equilibrium and get the elastic driving force
    3. calculate landau driving force
    4. evolve polarization
    5. output the result of current timestep
5. Finalize the whole program
