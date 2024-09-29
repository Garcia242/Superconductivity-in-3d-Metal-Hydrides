#!/bin/bash -l

#perform the Phonon calculation after checking if the compound behaves like a metal

#included files needed : X.scf-ph.in; X.elph.in; X.q2r:in; X.matdyn.in

# Batch script to run an MPI parallel job with the upgraded software
# stack under SGE with Intel MPI.

# 1. Force bash as the executing shell.
#$ -S /bin/bash

# 2. Request ten minutes of wallclock time (format hours:minutes:seconds).
#$ -l h_rt=12:00:00

# Budget setting
#$ -P Gold
#$ -A UKCP_ED_P

# 3. Request 1 gigabyte of RAM per process.
#$ -l mem=1G

# 5. Set the name of the job.
#$ -N QE_try

# 6. Select the MPI parallel environment and processes.
#$ -pe mpi 80

# 7. Set the working directory to the current directory.
#$ -cwd

module unload compilers mpi gcc-libs
module load gcc-libs/10.2.0
module load compilers/gnu/10.2.0
module load mpi/openmpi/4.0.5/gnu-10.2.0
module load fftw/3.3.9/gnu-10.2.0
module load quantum-espresso/7.3.1-cpu/gnu-10.2.0

mpirun --mca orte_base_help_aggregate 0
# Set the path here to where ever you keep your pseudopotentials.
#export ESPRESSO_PSEUDO=$HOME/SSSP_1.3.0_PBE_efficiency




# Perform a phonon calculation incl electron-phonon coupling
# First step: a standard SCF calculation
gerun pw.x -in  FeH.scf-ph.in > FeH.scf-ph.out
# Second step: a phonon calculation
gerun ph.x -in FeH.elph.in > FeH.elph.out


# Postprocessing
# 1. Convert force constant from q- to real-space
q2r.x -in FeH.q2r.in > FeH.q2r.out
# 2. Re-calculate dynamical matrix on denser q-grid
#    and get Eliashberg function
gerun matdyn.x -in FeH.matdyn.in > FeH.matdyn.out