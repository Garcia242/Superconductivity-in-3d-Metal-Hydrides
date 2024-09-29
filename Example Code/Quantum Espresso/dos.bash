#!/bin/bash -l

#Start by calculating a DOS for all stable forms and see how they look like
#required input files : X.scf_dos.in; X.pp_dos:in


# Batch script to run an MPI parallel job with the upgraded software
# stack under SGE with Intel MPI.

# 1. Force bash as the executing shell.
#$ -S /bin/bash

# 2. Request ten minutes of wallclock time (format hours:minutes:seconds).
#$ -l h_rt=1:00:00

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
export ESPRESSO_PSEUDO=$HOME/SSSP_1.3.0_PBE_efficiency


# Perform a DOS-quality SCF calculation to obtain all eigenvalues
# on a dense k-grid 

gerun pw.x -in FeH.scf-dos.in >FeH.scf-dos.out

#gerun pw.x -in FeH.nscf-dos.in >FeH.nscf-dos.out
#mpiexec_mpt -ppn $NSLOTS -n $NSLOTS pw.x < h3s.scf-dos.in > h3s.scf-dos.out

dos.x -in FeH.pp_dos.in > FeH.pp_dos.out
